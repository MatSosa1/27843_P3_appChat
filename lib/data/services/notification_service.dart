import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings(
      'ic_notification',
    );

    const settings = InitializationSettings(
      android: androidInit,
    );

    await _plugin.initialize(settings);
  }

  static Future<void> show({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'chat',
      'Chat Messages',
      channelDescription: 'Notificaciones del chat',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_notification',
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(0, title, body, details);
  }

  static Future<void> requestPermission() async {
    final androidPlugin =
      _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }
}
