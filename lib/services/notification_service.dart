import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _local.initialize(initSettings);

    // Foreground messages: show a local notification.
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        _local.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'ashapa_channel',
              'Ashapa Music',
              channelDescription: 'Sabbin waƙoƙi da sanarwa daga Ashapa Music',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  /// Get this device's FCM token — useful for targeted pushes / debugging.
  Future<String?> getToken() => _fcm.getToken();

  /// Subscribe every user to a "new_songs" topic so the admin can
  /// broadcast "sabon waƙa ya fito!" notifications from the Firebase
  /// Console (Cloud Messaging > New notification > Topic: new_songs).
  Future<void> subscribeToNewSongs() => _fcm.subscribeToTopic('new_songs');
}
