
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
NotificationService._();

static final NotificationService instance =
NotificationService._();

final FirebaseMessaging _messaging =
FirebaseMessaging.instance;

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

final FirebaseAuth _auth =
FirebaseAuth.instance;

// ==========================
// INITIALIZE
// ==========================

Future<void> initialize() async {
await _requestPermission();

await saveFCMToken();

FirebaseMessaging.onMessage.listen(
_handleForegroundMessage,
);

FirebaseMessaging.onMessageOpenedApp.listen(
_handleNotificationTap,
);

final initialMessage =
await _messaging.getInitialMessage();

if (initialMessage != null) {
_handleNotificationTap(
initialMessage,
);
}
}

// ==========================
// REQUEST PERMISSION
// ==========================

Future<void> _requestPermission() async {
await _messaging.requestPermission(
alert: true,
badge: true,
sound: true,
provisional: false,
);
}

// ==========================
// GET TOKEN
// ==========================

Future<String?> getToken() async {
return await _messaging.getToken();
}

// ==========================
// SAVE TOKEN
// ==========================

Future<void> saveFCMToken() async {
final user = _auth.currentUser;

if (user == null) return;

final token =
await _messaging.getToken();

if (token == null) return;

await _firestore
    .collection('employees')
    .doc(user.uid)
    .set({
'fcmToken': token,
}, SetOptions(merge: true));

debugPrint(
'FCM Token Saved: $token',
);
}

// ==========================
// TOKEN REFRESH
// ==========================

void listenTokenRefresh() {
_messaging.onTokenRefresh.listen(
(token) async {
final user =
_auth.currentUser;

if (user == null) return;

await _firestore
    .collection('employees')
    .doc(user.uid)
    .update({
'fcmToken': token,
});

debugPrint(
'FCM Token Refreshed',
);
},
);
}

// ==========================
// FOREGROUND MESSAGE
// ==========================

void _handleForegroundMessage(
RemoteMessage message,
) {
debugPrint(
'Foreground Notification',
);

debugPrint(
'Title: ${message.notification?.title}',
);

debugPrint(
'Body: ${message.notification?.body}',
);
}

// ==========================
// NOTIFICATION CLICK
// ==========================

void _handleNotificationTap(
RemoteMessage message,
) {
debugPrint(
'Notification Clicked',
);

debugPrint(
'Data: ${message.data}',
);

// TODO:
// Navigate to Chat Screen
// Navigate to Group Chat
// Open Announcement
}

// ==========================
// BACKGROUND HANDLER
// ==========================

static Future<void>
firebaseMessagingBackgroundHandler(
RemoteMessage message,
) async {
debugPrint(
'Background Message Received',
);

debugPrint(
message.messageId,
);
}
}
