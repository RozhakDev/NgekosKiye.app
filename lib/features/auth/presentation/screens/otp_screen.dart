import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ngekoskiye/core/theme/app_colors.dart';

import '../controllers/auth_controller.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpCtrl = TextEditingController();

  void _verify() async {
    if (_otpCtrl.text.isEmpty) return;
    final notifier = ref.read(authControllerProvider.notifier);
    await notifier.verifyOtp(widget.email, _otpCtrl.text.trim());

    if (mounted && !ref.read(authControllerProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verifikasi sukses. Silakan masuk.'), backgroundColor: Colors.black),
      );
      context.go('/login');
    }
  }

  void _resend() async {
    final notifier = ref.read(authControllerProvider.notifier);
    await notifier.resendOtp(widget.email);

    if (mounted && !ref.read(authControllerProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP telah dikirim ulang.'), backgroundColor: Colors.black),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (!state.isLoading && state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error.toString(), style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.error),
        );
      }
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('VERIFIKASI OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Kami telah mengirimkan 6 digit kode OTP ke:\n${widget.email}', style: const TextStyle(height: 1.5)),
            const SizedBox(height: 32),
            TextField(
              controller: _otpCtrl,
              decoration: const InputDecoration(labelText: 'Kode OTP', hintText: '123456'),
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isLoading ? null : _verify,
              child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('VERIFIKASI'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: isLoading ? null : _resend,
              style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary),
              child: const Text('KIRIM ULANG OTP'),
            ),
          ],
        ),
      ),
    );
  }
}