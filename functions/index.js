const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Cloud Firestore trigger for new messages
exports.myFunction = functions.firestore
  .document('chat/{messageId}')
  .onCreate(async (snapshot, context) => {
    // Get the message data from Firestore snapshot
    const messageData = snapshot.data();
    const username = messageData['username'];
    const text = messageData['text'];

    // Send a notification to all devices subscribed to the 'chat' topic
    const message = {
      notification: {
        title: username,
        body: text,
      },
      data: {
        // Additional data sent with the notification (optional)
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      topic: 'chat',
    };

    try {
      // Send the message
      await admin.messaging().send(message);
      console.log('Notification sent successfully!');
    } catch (error) {
      console.error('Error sending notification:', error);
    }

    return null; // Returning null since we don’t have async operations after this
  });