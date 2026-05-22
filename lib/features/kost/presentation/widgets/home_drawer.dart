import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
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
                    _showInfoModal(
                      context,
                      title: 'Syarat & Ketentuan',
                      icon: Icons.gavel,
                      content: 'Dengan menggunakan platform NgekosKiye, Anda menyetujui aturan berikut:\n\n1. Pembayaran harus dilakukan melalui kanal resmi.\n2. Pembatalan sewa mengikuti kebijakan pemilik kost.\n3. Pengguna wajib memberikan data identitas yang valid.\n4. Penyalahgunaan platform akan ditindak secara hukum.',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.textSecondary),
                  title: const Text('Kebijakan Privasi', style: TextStyle(color: AppColors.textPrimary)),
                  onTap: () {
                    context.pop();
                    _showInfoModal(
                      context,
                      title: 'Kebijakan Privasi',
                      icon: Icons.security,
                      content: 'NgekosKiye sangat menghargai privasi data Anda.\n\nData pribadi seperti email dan nomor telepon dienkripsi secara aman dan hanya digunakan untuk keperluan verifikasi dan komunikasi transaksi. Kami tidak memperjualbelikan data Anda kepada pihak ketiga.',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: AppColors.textSecondary),
                  title: const Text('Pusat Bantuan', style: TextStyle(color: AppColors.textPrimary)),
                  onTap: () {
                    context.pop();
                    _showInfoModal(
                      context,
                      title: 'Pusat Bantuan',
                      icon: Icons.support_agent,
                      content: 'Tim layanan pelanggan NgekosKiye siap membantu Anda 24/7.\n\nHubungi kami melalui:\nEmail: cs@ngekoskiye.app\nWhatsApp: +62 838-4792-1480\n\nAtau kunjungi FAQ kami di website resmi.',
                    );
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
                      applicationVersion: 'v1.0.0',
                      applicationLegalese: '© 2026 NgekosKiye\nPlatform pencarian kost modern yang aman dan terpercaya.',
                      applicationIcon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.domain, color: AppColors.primary, size: 32),
                      ),
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

  void _showInfoModal(BuildContext context, {required String title, required IconData icon, required String content}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Mengerti'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}