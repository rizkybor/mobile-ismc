import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes.dart';
import '../../../core/config/contacts.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/account_status.dart';
import '../../../shared/widgets/widgets.dart';

/// Kartu status akun di Beranda untuk status selain `active` (PRD F-02.3):
/// stepper 3 langkah, atau kartu merah "akun nonaktif" dengan kontak ISM.
class AccountStatusCard extends StatelessWidget {
  const AccountStatusCard({super.key, required this.state});
  final AccountState state;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      AccountStatus.inactive => const _InactiveCard(),
      AccountStatus.unregistered => const _StepperCard(currentStep: 1),
      AccountStatus.waiting => const _StepperCard(currentStep: 2),
      AccountStatus.active => const SizedBox.shrink(),
    };
  }
}

class _StepperCard extends StatelessWidget {
  const _StepperCard({required this.currentStep});

  /// 0..2: langkah yang sedang berjalan.
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    final steps = [
      (l10n.activationStep1, null),
      (l10n.activationStep2, null),
      (l10n.activationStep3, l10n.activationStep3Hint),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentStep == 1
                          ? l10n.accountStatusUnregisteredTitle
                          : l10n.accountStatusWaitingTitle,
                      style: t.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentStep == 1
                          ? l10n.accountStatusUnregisteredBody
                          : l10n.accountStatusWaitingBody,
                      style: t.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < steps.length; i++)
            _StepRow(
              index: i,
              label: steps[i].$1,
              hint: steps[i].$2,
              state: i < currentStep
                  ? _StepState.done
                  : i == currentStep
                  ? _StepState.current
                  : _StepState.waiting,
              isLast: i == steps.length - 1,
            ),
          if (currentStep == 1) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.activationCta,
              icon: Icons.business_outlined,
              onPressed: () => context.push(Routes.activation),
            ),
          ],
        ],
      ),
    );
  }
}

enum _StepState { done, current, waiting }

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.label,
    required this.hint,
    required this.state,
    required this.isLast,
  });

  final int index;
  final String label;
  final String? hint;
  final _StepState state;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final sc = context.statusColors;
    final color = switch (state) {
      _StepState.done => sc.done,
      _StepState.current => sc.current,
      _StepState.waiting => sc.waiting,
    };
    final t = Theme.of(context).textTheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state == _StepState.waiting
                        ? Colors.transparent
                        : color,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: state == _StepState.done
                      ? const Icon(Icons.check, size: 15, color: Colors.white)
                      : Text(
                          '${index + 1}',
                          style: t.labelMedium?.copyWith(
                            color: state == _StepState.waiting
                                ? color
                                : Colors.white,
                          ),
                        ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: state == _StepState.done
                          ? sc.done
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: t.bodyMedium?.copyWith(
                      fontWeight: state == _StepState.current
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: state == _StepState.waiting
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (hint != null) Text(hint!, style: t.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InactiveCard extends StatelessWidget {
  const _InactiveCard();

  Future<void> _open(Uri uri) async {
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.block_rounded, color: AppColors.error),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.accountStatusInactiveTitle,
                  style: t.titleMedium?.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.accountStatusInactiveBody, style: t.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: l10n.contactCall,
                  icon: Icons.call_outlined,
                  variant: AppButtonVariant.outline,
                  onPressed: () =>
                      _open(Uri.parse('tel:${IsmContacts.phoneDial}')),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: l10n.contactEmail,
                  icon: Icons.mail_outline_rounded,
                  variant: AppButtonVariant.outline,
                  onPressed: () =>
                      _open(Uri.parse('mailto:${IsmContacts.email}')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
