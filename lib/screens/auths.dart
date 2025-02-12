import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatschat/widgets/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() {
    return _AuthenticationScreenstate();
  }
}

class _AuthenticationScreenstate extends State<AuthenticationScreen> {
  var _isLogin = true;
  var _entereduserName = '';
  var _enteredEmail = '';
  var _enteredPassword = '';
  File? _selectedImage;
  var _isAuthenticating = false;

  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    // if (isValid) {
    //   _formKey.currentState!.save();
    //   print(_enteredEmail);
    //   print(_enteredPassword);
    // }

    if (!isValid || !_isLogin && _selectedImage == null) {
      SnackBar(
        content: ScaffoldMessenger(
          child: Text(
            'Please fillout the overall form to proceed!',
          ),
        ),
      );
      return;
    }

    //Alternate check is given above
    // if(!_isLogin && _selectedImage == null){
    //   return;
    // }

    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        //Log Users in
        final usercredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        // print(usercredentials);
      } else {
        final usercredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        // print(usercredentials);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user-image')
            .child('${usercredentials.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageURL = await storageRef.getDownloadURL();
        print(imageURL);

        FirebaseFirestore.instance
            .collection('user')
            .doc(usercredentials.user!.uid)
            .set({
          'username': _entereduserName,
          'email': _enteredEmail,
          'password': _enteredPassword,
          'image_URL': imageURL,
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        //.....
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed!'),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 30,
                  bottom: 30,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //UserimagePicker()
                          if (!_isLogin)
                            UserImagePicker(
                              onPickedImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),
                          // if(_isAuthenticating)
                          // CircularProgressIndicator(),
                          // if(!_isAuthenticating)
                          if(!_isLogin)
                          TextFormField(
                            decoration: InputDecoration(labelText: 'User Name'),
                            enableSuggestions: false,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length < 4) {
                                return 'User Name should be atleast or greater than four characters';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _entereduserName = newValue!;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'email address',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Email address is not valid';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          // if(!_isAuthenticating)
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'password',
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password should be more than 6 characters';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          if (_isAuthenticating) CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(_isLogin ? 'Login Up' : 'Sign Up'),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin =
                                      !_isLogin; //another short representation
                                  // _isLogin = _isLogin ? false : true;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'Create an account'
                                  : 'I already have an account'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
