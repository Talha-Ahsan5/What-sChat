import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatschat/widgets/chat_messages.dart';
import 'package:whatschat/widgets/new_messages.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("WhatsChat"),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessages(),
          ),
          NewMessages(),
        ],
      ),
    );
  }
}
