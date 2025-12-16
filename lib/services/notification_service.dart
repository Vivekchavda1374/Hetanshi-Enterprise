import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hetanshi_enterprise/utils/toast_utils.dart';
import 'package:hetanshi_enterprise/services/firestore_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Top-level function for background handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // REPLACE WITH YOUR ACTUAL SERVER KEY FROM FIREBASE CONSOLE -> PROJECT SETTINGS -> CLOUD MESSAGING
  // NOTE: This uses the Legacy HTTP API which is easier for client-side testing but less secure.
  // For production, use OAuth 2.0 via a backend server.
  static const String _serverKey = 'YOUR_SERVER_KEY_HERE'; 

  Future<void> initialize(BuildContext context) async {
    // 1. Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      // Subscribe to general topic (Not supported on Web yet)
      if (!kIsWeb) {
        await _firebaseMessaging.subscribeToTopic('all');
      }
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // 2. Set Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Get FCM Token
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
        debugPrint("FCM Token: $token");
    }

    // 4. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      
      if (message.notification != null) {
        String title = message.notification?.title ?? 'Notification';
        String body = message.notification?.body ?? '';
        
        if (title.isNotEmpty && body.isNotEmpty && context.mounted) {
           ToastUtils.showInfo(context, "$title: $body");
        }
      }
    });

    // 5. Handle Content Click (App Open)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('A new onMessageOpenedApp event was published!');
    });
  }

  /// Send notification to all users subscribed to 'all' topic
  Future<void> sendNotificationToAll(String title, String body) async {
    if (_serverKey == 'YOUR_SERVER_KEY_HERE') {
      debugPrint("Warning: Server Key not set. Notification will not be sent.");
      return;
    }

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': '/topics/all',
          },
        ),
      );
      debugPrint("Notification sent successfully: $title");
      
      // Save to Firestore History
      await FirestoreService().addNotification(title, body);

    } catch (e) {
      debugPrint("Error sending notification: $e");
    }
  }
}

