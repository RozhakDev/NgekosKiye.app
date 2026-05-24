import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';

/// Menampilkan form permintaan pemulihan kata sandi.
///
/// Widget ini meminta email pengguna untuk memulai reset akun.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  /// Membuat state yang mengelola interaksi halaman.
  ///
  /// Digunakan oleh Flutter untuk menghubungkan widget dengan state-nya.
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

/// Mengelola input email dan proses permintaan reset kata sandi.
///
/// State ini mengirim permintaan pemulihan saat data sudah valid.
class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();

  /// Membersihkan controller dan resource saat halaman tidak digunakan.
  ///
  /// Method ini mencegah resource tetap aktif setelah widget ditutup.
  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  /// Memvalidasi input lalu menjalankan aksi utama halaman.
  ///
  /// Method ini dipakai pada form pemulihan atau reset kata sandi.
  void _submit() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      NotificationUtils.show(context, message: 'Masukkan alamat email yang valid.', type: SnackBarType.error);
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).forgotPassword(email);
    if (success && mounted) {
      NotificationUtils.show(context, message: 'Kode OTP telah dikirim ke email Anda.', type: SnackBarType.success);
      context.push('/reset-password?email=${Uri.encodeComponent(email)}');
    }
  }

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (!state.isLoading && state.hasError) {
        NotificationUtils.show(context, message: state.error.toString(), type: SnackBarType.error);
      }
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Lupa Kata Sandi',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukkan alamat email yang terdaftar. Kami akan mengirimkan kode OTP untuk mengatur ulang kata sandi Anda.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              
              const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  hintText: 'ngekoskiye@email.com',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 48),
              
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('KIRIM KODE OTP', style: TextStyle(letterSpacing: 1.2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}