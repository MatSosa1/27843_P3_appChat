import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin plugin;

  NotificationService(this.plugin);

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('ic_notification');

    const settings = InitializationSettings(
      android: androidInit,
    );

    await plugin.initialize(settings);
  }

  Future<void> show({
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

    await plugin.show(0, title, body, details);
  }

  Future<void> requestPermission() async {
    final androidPlugin =
        plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }
}
