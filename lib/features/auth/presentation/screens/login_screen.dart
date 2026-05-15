import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;
    
    ref.read(authControllerProvider.notifier).login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (!state.isLoading && state.hasError) {
        final errorMsg = state.error.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg, style: const TextStyle(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            action: errorMsg.toLowerCase().contains('belum diverifikasi') ? SnackBarAction(
              label: 'Verifikasi',
              textColor: Colors.white,
              onPressed: () {
                final email = _emailController.text.trim();
                context.push('/otp', extra: email);
              },
            ) : null,
          ),
        );
      }
    });

    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('MASUK'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'SELAMAT DATANG',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            const Text('Silakan masuk dengan email dan kata sandi Anda.'),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Kata Sandi'),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: authState.isLoading ? null : _login,
              child: authState.isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('MASUK'),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/register'),
              style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary),
              child: const Text('BELUM PUNYA AKUN? DAFTAR DI SINI'),
            )
          ],
        ),
      ),
    );
  }
}