import 'package:flutter/material.dart';

import '../../core/i18n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'app_card.dart';

/// Isi sementara layar yang dikerjakan di tahap berikutnya.
class StagePlaceholder extends StatelessWidget {
  const StagePlaceholder({super.key, required this.stage, this.icon});
  final int stage;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.topCenter,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.headerGradient,
              ),
              child: Icon(
                icon ?? Icons.auto_awesome_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                l10n.stageChip(stage),
                style: t.labelMedium?.copyWith(color: AppColors.primaryDark),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.stagePlaceholder(stage),
              textAlign: TextAlign.center,
              style: t.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.stagePlaceholderHint,
              textAlign: TextAlign.center,
              style: t.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
