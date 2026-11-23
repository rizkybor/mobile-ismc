import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Skala tipografi Inter (PRD §10: ukuran dasar 15–16 pt).
abstract final class AppTypography {
  static const fontFamily = 'Inter';

  static const button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static TextTheme textTheme(TextTheme base) {
    const c = AppColors.textPrimary;
    const s = AppColors.textSecondary;
    return base.copyWith(
      displaySmall: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.15,
        color: c,
      ),
      headlineMedium: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.2,
        color: c,
      ),
      headlineSmall: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.25,
        color: c,
      ),
      titleLarge: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: c,
      ),
      titleMedium: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.35,
        color: c,
      ),
      titleSmall: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: c,
      ),
      bodyLarge: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: c,
      ),
      bodyMedium: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: c,
      ),
      bodySmall: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: s,
      ),
      labelLarge: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: c,
      ),
      labelMedium: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: s,
      ),
      labelSmall: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: s,
      ),
    );
  }
}
