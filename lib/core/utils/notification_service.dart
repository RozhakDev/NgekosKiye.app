import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Menangani pesan Firebase saat aplikasi berjalan di background.
///
/// Fungsi ini disiapkan sebagai entry point untuk Firebase Messaging.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

}

/// Mengelola inisialisasi dan tampilan notifikasi aplikasi.
///
/// Class ini menangani izin, listener, dan notifikasi lokal.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Menyiapkan izin, channel, dan listener notifikasi aplikasi.
  ///
  /// Method ini dipanggil saat aplikasi mulai berjalan.
  static Future<void> initialize() async {
    await _messaging.requestPermission();

    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _localNotifications.initialize(settings: initSettings);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(message.notification!);
      }
    });

    String? token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
  }

  /// Menampilkan notifikasi lokal dari payload Firebase.
  ///
  /// Method ini digunakan saat pesan diterima ketika aplikasi aktif.
  static Future<void> _showLocalNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'ngekoskiye_channel',
      'NgekosKiye Notifications',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFFF95D18),
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: platformDetails,
    );
  }
}