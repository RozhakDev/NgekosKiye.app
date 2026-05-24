import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/utils/notification_service.dart';

/// Menjalankan inisialisasi awal sebelum aplikasi ditampilkan.
///
/// Fungsi ini menyiapkan konfigurasi, Firebase, notifikasi, dan root aplikasi.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await NotificationService.initialize();

  runApp(
    const ProviderScope(
      child: NgekosKiyeApp(),
    ),
  );
}

/// Menyiapkan struktur utama aplikasi dengan routing dan tema global.
///
/// Widget ini menjadi root dari seluruh tampilan aplikasi.
class NgekosKiyeApp extends ConsumerWidget {
  const NgekosKiyeApp({super.key});

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'NgekosKiye',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}