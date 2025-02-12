import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickedImage});

  final void Function(File pickedImage) onPickedImage;

  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _imagePickerFile;

  void _imagePicker() async {
    final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 150,);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _imagePickerFile = File(pickedImage.path);
    });

    widget.onPickedImage(_imagePickerFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              _imagePickerFile != null ? FileImage(_imagePickerFile!) : null,
        ),
        TextButton.icon(
          onPressed: _imagePicker,
          label: Text('Add Image'),
          icon: Icon(
            Icons.image,
            color: Theme.of(context).colorScheme.primary,
          ),
        )
      ],
    );
  }
}
