import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      settings: initializationSettings, // ✅ FIX DI SINI
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notif diklik");
      },
    );

    await _notificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );

  }

  static Future<void> showNotification(
      String name, String jobdesk, String deadline) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'sipanitia_channel_v2',
        'Notifikasi Tugas Baru',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: 0,
        title: 'Halo $name, ada tugas nich!',
        body: 'Tugas: $jobdesk. Deadline: $deadline',
        notificationDetails: platformDetails,
      );

      print("DEBUG: Notifikasi terkirim!");
    } catch (e) {
      print("DEBUG ERROR: $e");
    }
  }
}