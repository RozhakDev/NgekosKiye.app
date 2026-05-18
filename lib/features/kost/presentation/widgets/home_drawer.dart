import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';

class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);

    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          profileState.when(
            data: (user) {
              final name = user != null ? (user.firstName.isNotEmpty ? '${user.firstName} ${user.lastName}' : user.username) : 'Tamu';
              final email = user?.email ?? 'Selamat datang di NgekosKiye';
              final initial = user != null ? (user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : user.username[0].toUpperCase()) : 'N';

              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppColors.primary),
                margin: EdgeInsets.zero,
                accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                accountEmail: Text(email, style: const TextStyle(fontSize: 12)),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(initial, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
              );
            },
            loading: () => const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              margin: EdgeInsets.zero,
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
            error: (_, __) => const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              margin: EdgeInsets.zero,
              child: Center(child: Text('Gagal memuat profil', style: TextStyle(color: Colors.white))),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppColors.textSecondary),
                  title: const Text('Syarat & Ketentuan', style: TextStyle(color: AppColors.textPrimary)),
                  onTap: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syarat & Ketentuan segera hadir.')));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: AppColors.textSecondary),
                  title: const Text('Pusat Bantuan', style: TextStyle(color: AppColors.textPrimary)),
                  onTap: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pusat Bantuan segera hadir.')));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.textSecondary),
                  title: const Text('Kebijakan Privasi', style: TextStyle(color: AppColors.textPrimary)),
                  onTap: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kebijakan Privasi segera hadir.')));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.textSecondary),
                  title: const Text('Tentang Aplikasi', style: TextStyle(color: AppColors.textPrimary)),
                  onTap: () {
                    context.pop();
                    showAboutDialog(
                      context: context,
                      applicationName: 'NgekosKiye',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2026 Ngekost.id',
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Keluar', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            onTap: () {
              ref.read(profileControllerProvider.notifier).logout();
              context.go('/login');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}