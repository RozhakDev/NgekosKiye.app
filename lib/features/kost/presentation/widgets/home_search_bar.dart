import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

/// Menampilkan kolom pencarian pada area sliver halaman utama.
///
/// Widget ini mengarahkan pengguna menuju halaman pencarian.
class HomeSearchBarSliver extends StatelessWidget {
  const HomeSearchBarSliver({super.key});

  /// Membangun tampilan widget berdasarkan state yang tersedia.
  ///
  /// Digunakan untuk menyusun elemen UI sesuai data yang diterima.
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () => context.push('/search'),
        child: Container(
          color: AppColors.primary,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(
                  'Cari kos di kota mana?',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.5), 
                    fontSize: 14, 
                    fontWeight: FontWeight.w400
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}