import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/profile_controller.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isEditing = false;

  void _saveProfile() async {
    final success = await ref.read(profileControllerProvider.notifier).updateProfile({
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'phone_number': _phoneCtrl.text.trim(),
    });

    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: Colors.black),
      );
    }
  }

  void _logout() {
    ref.read(profileControllerProvider.notifier).logout();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('AKUN SAYA'),
        actions: [
          if (profileState.value != null && !_isEditing)
            IconButton(icon: const Icon(Icons.edit), onPressed: () {
              final user = profileState.value!;
              _firstNameCtrl.text = user.firstName;
              _lastNameCtrl.text = user.lastName;
              _phoneCtrl.text = user.phoneNumber;
              setState(() => _isEditing = true);
            }),
        ],
      ),
      body: profileState.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Data tidak ditemukan'));
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.background,
                child: Icon(Icons.person, size: 50, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              _buildField('Email', user.email, isEditable: false),
              const SizedBox(height: 16),
              _buildField('Username', user.username, isEditable: false),
              const SizedBox(height: 16),
              _buildField('Nama Depan', user.firstName, controller: _firstNameCtrl),
              const SizedBox(height: 16),
              _buildField('Nama Belakang', user.lastName, controller: _lastNameCtrl),
              const SizedBox(height: 16),
              _buildField('Nomor Telepon', user.phoneNumber, controller: _phoneCtrl),
              
              const SizedBox(height: 48),
              if (_isEditing)
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('SIMPAN PERUBAHAN'),
                )
              else
                OutlinedButton(
                  onPressed: _logout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text('KELUAR'),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildField(String label, String value, {TextEditingController? controller, bool isEditable = true}) {
    if (_isEditing && isEditable && controller != null) {
      return TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const Divider(color: AppColors.border),
      ],
    );
  }
}