import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/profile_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../domain/user_model.dart';
import '../../../../core/widgets/custom_empty_state.dart';

/// Menampilkan informasi profil dan form pengeditan pengguna.
///
/// Widget ini memungkinkan pengguna melihat dan memperbarui data akun.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  /// Membuat state yang mengelola interaksi halaman.
  ///
  /// Digunakan oleh Flutter untuk menghubungkan widget dengan state-nya.
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

/// Mengelola state edit profil dan aksi keluar akun.
///
/// State ini menyimpan nilai input saat pengguna mengubah profil.
class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isEditing = false;

  /// Menyimpan perubahan profil yang diisi pengguna.
  ///
  /// Method ini mengirim data edit ke controller profil.
  void _saveProfile() async {
    final success = await ref.read(profileControllerProvider.notifier).updateProfile({
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'phone_number': _phoneCtrl.text.trim(),
    });

    if (success && mounted) {
      setState(() => _isEditing = false);
      NotificationUtils.show(
        context,
        message: 'Profil berhasil diperbarui',
      );
    }
  }

  /// Menjalankan proses keluar akun dan mengarahkan pengguna ke login.
  ///
  /// Method ini dipakai saat pengguna memilih keluar dari akun.
  void _logout() {
    ref.read(profileControllerProvider.notifier).logout();
    context.go('/');
  }

  /// Membersihkan controller dan resource saat halaman tidak digunakan.
  ///
  /// Method ini mencegah resource tetap aktif setelah widget ditutup.
  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final isLoading = profileState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: profileState.when(
        data: (user) {
          if (user == null) {
            return CustomEmptyState(
              message: 'Data profil tidak ditemukan.',
              icon: Icons.person_off_outlined,
              onRetry: () => ref.read(profileControllerProvider.notifier).fetchProfile(),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 48),
                  
                  if (_isEditing)
                    _buildEditForm(user, isLoading)
                  else
                    _buildProfileInfo(user),
                    
                  const SizedBox(height: 48),
                  
                  if (!_isEditing)
                    OutlinedButton(
                      onPressed: _logout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text('KELUAR DARI AKUN', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
      ),
    );
  }

  /// Menampilkan ringkasan identitas pengguna di bagian atas profil.
  ///
  /// Method ini menyusun avatar dan nama pengguna.
  Widget _buildProfileHeader(UserModel user) {
    final initial = user.firstName.isNotEmpty 
        ? user.firstName[0].toUpperCase() 
        : user.username[0].toUpperCase();

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.firstName.isNotEmpty ? '${user.firstName} ${user.lastName}' : user.username,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'TENANT',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.0),
          ),
        ),
      ],
    );
  }

  /// Menampilkan detail informasi profil pengguna.
  ///
  /// Method ini memperlihatkan username, email, dan nomor telepon.
  Widget _buildProfileInfo(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Detail Pengguna', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            TextButton(
              onPressed: () {
                _firstNameCtrl.text = user.firstName;
                _lastNameCtrl.text = user.lastName;
                _phoneCtrl.text = user.phoneNumber;
                setState(() => _isEditing = true);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AppColors.primary,
              ),
              child: const Text('Ubah', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildInfoRow(Icons.person_outline, 'Username', user.username),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(color: AppColors.border),
        ),
        _buildInfoRow(Icons.email_outlined, 'Email', user.email),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(color: AppColors.border),
        ),
        _buildInfoRow(Icons.phone_outlined, 'Nomor Telepon', user.phoneNumber.isEmpty ? '-' : user.phoneNumber),
      ],
    );
  }

  /// Menampilkan satu baris informasi dengan label dan nilai.
  ///
  /// Method ini menjaga format detail tetap konsisten.
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: AppColors.textSecondary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  /// Menampilkan form untuk mengubah data profil pengguna.
  ///
  /// Method ini digunakan saat pengguna masuk ke mode edit.
  Widget _buildEditForm(UserModel user, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Perbarui Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 24),
        
        const Text('Nama Depan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _firstNameCtrl,
          decoration: const InputDecoration(hintText: 'Ngekos', prefixIcon: Icon(Icons.person_outline)),
        ),
        const SizedBox(height: 16),

        const Text('Nama Belakang', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _lastNameCtrl,
          decoration: const InputDecoration(hintText: 'Kiyee', prefixIcon: Icon(Icons.person_outline)),
        ),
        const SizedBox(height: 16),

        const Text('Nomor Telepon', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: 'Contoh: 08xxxxxxxxx', prefixIcon: Icon(Icons.phone_outlined)),
        ),
        const SizedBox(height: 48),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : () => setState(() => _isEditing = false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}