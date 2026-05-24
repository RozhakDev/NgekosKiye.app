import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/utils/snackbar_utils.dart';

/// Menampilkan halaman verifikasi kode OTP.
///
/// Widget ini digunakan setelah pengguna melakukan registrasi
/// atau permintaan verifikasi.
class OtpScreen extends ConsumerStatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  /// Membuat state yang mengelola interaksi halaman.
  ///
  /// Digunakan oleh Flutter untuk menghubungkan widget dengan state-nya.
  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

/// Mengelola timer, input, dan aksi verifikasi OTP.
///
/// State ini menjaga proses verifikasi tetap terarah untuk pengguna.
class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpCtrl = TextEditingController();
  final _focusNode = FocusNode();
  
  Timer? _timer;
  int _start = 60;
  bool _canResend = false;

  /// Menyiapkan state awal saat widget pertama kali dibuat.
  ///
  /// Method ini dipakai untuk memulai listener, timer, atau pemuatan data awal.
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  /// Memulai hitung mundur untuk pengiriman ulang OTP.
  ///
  /// Method ini mengatur kapan tombol kirim ulang dapat digunakan.
  void _startTimer() {
    setState(() {
      _start = 45;
      _canResend = false;
    });
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _canResend = true;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  /// Membersihkan controller dan resource saat halaman tidak digunakan.
  ///
  /// Method ini mencegah resource tetap aktif setelah widget ditutup.
  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Menghasilkan teks hitung mundur dalam format menit dan detik.
  ///
  /// Nilai ini ditampilkan agar pengguna mengetahui sisa waktu.
  String get timerText {
    final minutes = (_start ~/ 60).toString().padLeft(2, '0');
    final seconds = (_start % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Memvalidasi kode OTP lalu mengirimnya untuk diverifikasi.
  ///
  /// Method ini dijalankan saat pengguna mengonfirmasi kode.
  void _verify() async {
    if (_otpCtrl.text.length < 6) return;
    final notifier = ref.read(authControllerProvider.notifier);
    await notifier.verifyOtp(widget.email, _otpCtrl.text.trim());

    if (mounted && !ref.read(authControllerProvider).hasError) {
      NotificationUtils.show(
        context,
        message: 'Verifikasi sukses. Silakan masuk.',
        type: SnackBarType.success,
      );
      context.go('/login');
    }
  }

  /// Meminta kode OTP baru dan mengatur ulang timer.
  ///
  /// Method ini digunakan saat pengguna meminta pengiriman ulang.
  void _resend() async {
    if (!_canResend) return;
    
    final notifier = ref.read(authControllerProvider.notifier);
    await notifier.resendOtp(widget.email);

    if (mounted && !ref.read(authControllerProvider).hasError) {
      _startTimer();
      NotificationUtils.show(
        context,
        message: 'OTP telah dikirim ulang.',
      );
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

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 24,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'VERIFIKASI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Masukkan Kode OTP',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        text: 'Kami telah mengirimkan 6 digit kode ke email Anda ',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    Center(
                      child: Pinput(
                        length: 6,
                        controller: _otpCtrl,
                        focusNode: _focusNode,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        separatorBuilder: (index) => const SizedBox(width: 8),
                        onCompleted: (pin) {
                          if (!isLoading) _verify();
                        },
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Belum menerima kode? ',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          children: [
                            TextSpan(
                              text: _canResend ? 'Kirim ulang' : 'Kirim ulang ($timerText)',
                              style: TextStyle(
                                color: _canResend ? AppColors.primary : AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: _canResend ? (TapGestureRecognizer()..onTap = _resend) : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: (isLoading || _otpCtrl.text.length < 6) ? null : _verify,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                ),
                child: isLoading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text(
                      'VERIFIKASI',
                      style: TextStyle(letterSpacing: 1.2),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}