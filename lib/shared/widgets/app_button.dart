import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'app_loader.dart';

enum AppButtonVariant { primary, outline, text }

/// Tombol dengan tiga varian dan status memuat (spinner, tombol dinonaktifkan).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.icon,
    this.semanticId,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final IconData? icon;

  /// Accessibility identifier (Maestro E2E).
  final String? semanticId;

  @override
  Widget build(BuildContext context) {
    final onTap = loading ? null : onPressed;
    final child = loading
        ? AppLoader(
            size: 7,
            color: variant == AppButtonVariant.primary
                ? Colors.white
                : AppColors.primary,
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    return switch (variant) {
      AppButtonVariant.primary => FilledButton(onPressed: onTap, child: child),
      AppButtonVariant.outline => OutlinedButton(
        onPressed: onTap,
        child: child,
      ),
      AppButtonVariant.text => TextButton(onPressed: onTap, child: child),
    };
  }
}
