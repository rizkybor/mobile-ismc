import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

enum InlineMessageTone { error, success, info }

/// Pesan sebaris di dalam form (galat, sukses, info) dengan ikon.
class InlineMessage extends StatelessWidget {
  const InlineMessage({
    super.key,
    required this.text,
    this.tone = InlineMessageTone.error,
  });

  final String text;
  final InlineMessageTone tone;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (tone) {
      InlineMessageTone.error => (AppColors.error, Icons.error_outline_rounded),
      InlineMessageTone.success => (
        AppColors.success,
        Icons.check_circle_outline_rounded,
      ),
      InlineMessageTone.info => (AppColors.primary, Icons.info_outline_rounded),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
