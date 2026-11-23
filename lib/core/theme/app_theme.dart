import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius_shapes.dart';
import 'app_typography.dart';

/// Tema terang aplikasi (Material 3, huruf Inter). Mode gelap opsional —
/// token terpusat di [AppColors] sehingga mudah ditambahkan nanti.
abstract final class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.accentRed,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.borderSoft,
      surfaceContainerHighest: AppColors.background,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      extensions: const [StatusColors.light],
      textTheme: AppTypography.textTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.navy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.navy,
          letterSpacing: -0.2,
        ),
        shape: Border(bottom: BorderSide(color: AppColors.borderSoft)),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryLight,
        indicatorShape: AppShapes.chip,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11.5,
            letterSpacing: 0.1,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: AppShapes.card,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: AppShapes.inputBorder(AppColors.border),
        enabledBorder: AppShapes.inputBorder(AppColors.border),
        focusedBorder: AppShapes.inputBorder(AppColors.primary, width: 1.6),
        errorBorder: AppShapes.inputBorder(AppColors.error),
        focusedErrorBorder: AppShapes.inputBorder(AppColors.error, width: 1.6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 15),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: AppShapes.button,
          elevation: 0,
          textStyle: AppTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: AppShapes.button,
          side: const BorderSide(color: AppColors.primary, width: 1.4),
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          textStyle: AppTypography.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.button.copyWith(fontSize: 15),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: AppShapes.chip,
        side: BorderSide.none,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSoft,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
        shape: AppShapes.button,
        contentTextStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryLight,
      ),
    );
  }
}
