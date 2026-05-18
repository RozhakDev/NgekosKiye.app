import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum SnackBarType { success, error, info }

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
        accentColor = AppColors.secondary;
        icon = Icons.info_rounded;
        break;
    }

    final effectiveAction = action == null
        ? null
        : SnackBarAction(
            label: action.label,
            textColor: accentColor,
            onPressed: action.onPressed,
          );

    final snackBar = SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
      action: effectiveAction,
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}