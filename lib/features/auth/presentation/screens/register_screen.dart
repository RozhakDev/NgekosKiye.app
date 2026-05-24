import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';

/// Menampilkan form pendaftaran akun baru.
///
/// Widget ini mengumpulkan data dasar pengguna sebelum registrasi.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  /// Membuat state yang mengelola interaksi halaman.
  ///
  /// Digunakan oleh Flutter untuk menghubungkan widget dengan state-nya.
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

/// Mengelola state input dan aksi pendaftaran akun.
///
/// State ini menyiapkan data form sebelum dikirim ke controller.
class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  /// Membersihkan controller dan resource saat halaman tidak digunakan.
  ///
  /// Method ini mencegah resource tetap aktif setelah widget ditutup.
  @override
  void dispose() {
    _emailCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  /// Memvalidasi input lalu menjalankan proses pendaftaran akun.
  ///
  /// Method ini menyiapkan data pengguna sebelum dikirim.
  void _register() async {
    if (!_agreedToTerms) {
      NotificationUtils.show(
        context,
        message: 'Anda harus menyetujui Syarat & Ketentuan.',
        type: SnackBarType.error,
      );
      return;
    }

    final data = {
      "username": _userCtrl.text.trim(),
      "email": _emailCtrl.text.trim(),
      "password": _passCtrl.text,
      "password_confirm": _passCtrl.text, 
    };

    final notifier = ref.read(authControllerProvider.notifier);
    await notifier.register(data);

    if (mounted && !ref.read(authControllerProvider).hasError) {
      NotificationUtils.show(
        context,
        message: 'Registrasi sukses. Silakan cek email untuk OTP.',
        type: SnackBarType.success,
      );
      final email = Uri.encodeComponent(_emailCtrl.text.trim());
      context.push('/otp?email=$email');
    }
  }

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (!state.isLoading && state.hasError) {
        NotificationUtils.show(
          context,
          message: state.error.toString(),
          type: SnackBarType.error,
        );
      }
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.go('/'),
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
                'Buat Akun Baru',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Daftar untuk mulai mencari dan menyimpan hunian idaman Anda.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              
              const Text('Nama Pengguna', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _userCtrl,
                decoration: const InputDecoration(
                  hintText: 'ngekoskiye.official',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text('Alamat Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  hintText: 'ngekoskiye@email.com',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              
              const Text('Kata Sandi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                decoration: InputDecoration(
                  hintText: 'Minimal 8 karakter',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                obscureText: _obscurePassword,
              ),
              const SizedBox(height: 32),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreedToTerms,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) {
                        setState(() => _agreedToTerms = val ?? false);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        text: 'Saya menyetujui ',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                        children: [
                          TextSpan(text: 'Syarat & Ketentuan', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          TextSpan(text: ' dan '),
                          TextSpan(text: 'Kebijakan Privasi', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          TextSpan(text: ' yang berlaku.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: isLoading ? null : _register,
                child: isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('DAFTAR SEKARANG', style: TextStyle(letterSpacing: 1.2)),
              ),
              const SizedBox(height: 32),
              
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Sudah punya akun? ',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Masuk di sini',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()..onTap = () => context.push('/login'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}