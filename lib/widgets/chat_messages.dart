import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:whatschat/widgets/message_bubbles.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  void firebasePushNotificationSettings() async {
    final fcm = FirebaseMessaging.instance;

    final notificationSetting = await fcm.requestPermission();
    notificationSetting.sound;

    final token = await fcm.getToken(); //You can use http request or firebase sdk to send token in backend
    print(token);
    await fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();
    firebasePushNotificationSettings();
  }

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No messages found!'),
          );
        }

        if (snapshot.hasError) {
          return Text('Something went wrong!');
        }

        final loadedmessages = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 20,
            left: 15,
            right: 13,
          ),
          reverse: true,
          itemCount: loadedmessages.length,
          itemBuilder: (context, index) {
            final chatmessages = loadedmessages[index].data();
            final newChatMessages = index + 1 < loadedmessages.length
                ? loadedmessages[index + 1].data()
                : null;

            final currentChatmessageUserId = chatmessages['userId'];
            final newChatMessagesUserId =
                newChatMessages != null ? newChatMessages['userId'] : null;

            final nextUserIsSame =
                currentChatmessageUserId == newChatMessagesUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                  message: chatmessages['text'],
                  isMe: authenticatedUser.uid == currentChatmessageUserId);
            } else {
              return MessageBubble.first(
                userImage: chatmessages['userimage'],
                username: chatmessages['username'],
                message: chatmessages['text'],
                isMe: authenticatedUser.uid == currentChatmessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
