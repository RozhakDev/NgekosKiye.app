import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Menentukan jenis pesan singkat yang ditampilkan kepada pengguna.
///
/// Nilai ini mengatur gaya snackbar sesuai konteks pesan.
enum SnackBarType { success, error, info }

/// Menyediakan helper untuk menampilkan snackbar bergaya aplikasi.
///
/// Class ini menjaga tampilan pesan tetap konsisten di berbagai halaman.
class NotificationUtils {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    SnackBarAction? action,
  }) {
    Color accentColor;
    IconData icon;
    const Color surfaceColor = Color(0xFF2A2A2A);

    switch (type) {
      case SnackBarType.success:
        accentColor = const Color(0xFF25D366);
        icon = Icons.check_circle_rounded;
        break;
      case SnackBarType.error:
        accentColor = AppColors.error;
        icon = Icons.error_rounded;
        break;
      case SnackBarType.info:
      default:
        accentColor = AppColors.primary;
        icon = Icons.info_rounded;
        break;
    }

    final snackBar = SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: EdgeInsets.zero,
      duration: const Duration(seconds: 4),
      content: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(width: 12),
            
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            if (action != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  action.onPressed();
                },
                style: TextButton.styleFrom(
                  foregroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  action.label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
