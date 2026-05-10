import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passConfirmCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  void _register() async {
    final data = {
      "username": _userCtrl.text.trim(),
      "email": _emailCtrl.text.trim(),
      "password": _passCtrl.text,
      "password_confirm": _passConfirmCtrl.text,
      "first_name": _firstNameCtrl.text.trim(),
      "last_name": _lastNameCtrl.text.trim(),
      "phone_number": _phoneCtrl.text.trim(),
    };

    final notifier = ref.read(authControllerProvider.notifier);
    await notifier.register(data);

    if (mounted && !ref.read(authControllerProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi sukses. Silakan cek email untuk OTP.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.black),
      );
      context.push('/otp', extra: _emailCtrl.text.trim());
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
      appBar: AppBar(title: const Text('DAFTAR AKUN')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          TextField(controller: _firstNameCtrl, decoration: const InputDecoration(labelText: 'Nama Depan')),
          const SizedBox(height: 16),
          TextField(controller: _lastNameCtrl, decoration: const InputDecoration(labelText: 'Nama Belakang')),
          const SizedBox(height: 16),
          TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'Username')),
          const SizedBox(height: 16),
          TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Nomor Telepon'), keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Kata Sandi'), obscureText: true),
          const SizedBox(height: 16),
          TextField(controller: _passConfirmCtrl, decoration: const InputDecoration(labelText: 'Konfirmasi Kata Sandi'), obscureText: true),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: isLoading ? null : _register,
            child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('DAFTAR'),
          ),
        ],
      ),
    );
  }
}