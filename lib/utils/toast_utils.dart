import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hetanshi_enterprise/utils/app_theme.dart';

class ToastUtils {
  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, AppColors.successGreen, Icons.check_circle_outline);
  }

  static void showError(BuildContext context, String message) {
    _showToast(context, message, AppColors.errorRed, Icons.error_outline);
  }

  static void showInfo(BuildContext context, String message) {
    _showToast(context, message, AppColors.infoSkyBlue, Icons.info_outline);
  }

  static void showWarning(BuildContext context, String message) {
    _showToast(context, message, AppColors.warningOrange, Icons.warning_amber_rounded);
  }

  static void _showToast(BuildContext context, String message, Color color, IconData icon) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      elevation: 4,
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
