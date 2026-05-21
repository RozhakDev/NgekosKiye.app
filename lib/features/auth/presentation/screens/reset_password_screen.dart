import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _otpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _otpCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final otp = _otpCtrl.text.trim();
    final password = _passCtrl.text;

    if (otp.length < 6) {
      NotificationUtils.show(context, message: 'Masukkan 6 digit kode OTP.', type: SnackBarType.error);
      return;
    }
    
    if (password.length < 8) {
      NotificationUtils.show(context, message: 'Kata sandi minimal 8 karakter.', type: SnackBarType.error);
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).resetPassword(widget.email, otp, password);
    if (success && mounted) {
      NotificationUtils.show(context, message: 'Kata sandi berhasil diatur ulang. Silakan masuk.', type: SnackBarType.success);
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (!state.isLoading && state.hasError) {
        NotificationUtils.show(context, message: state.error.toString(), type: SnackBarType.error);
      }
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Atur Ulang Sandi',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: 'Masukkan kode OTP yang dikirim ke email ',
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
                    const TextSpan(text: ' beserta kata sandi baru Anda.'),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              const Text('Kode OTP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Center(
                child: Pinput(
                  length: 6,
                  controller: _otpCtrl,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  separatorBuilder: (index) => const SizedBox(width: 8),
                ),
              ),
              const SizedBox(height: 32),
              
              const Text('Kata Sandi Baru', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
              const SizedBox(height: 48),
              
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('ATUR ULANG SANDI', style: TextStyle(letterSpacing: 1.2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}