import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/session_controller.dart';
import '../../debug/debug_fab.dart';

/// Profil (lengkap pada Tahap 8). Tahap 2: identitas akun + tombol keluar.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.signOutButton),
          ),
        ],
      ),
    );
    if (ok ?? false) await ref.read(sessionProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(sessionProvider).user;
    final t = Theme.of(context).textTheme;
    final handle = user == null ? '' : '@${user.username}';
    return AppScaffold.brand(
      title: l10n.profileTitle,
      subtitle: l10n.profileSubtitle,
      floatingActionButton: const DebugFab(),
      body: ListView(
        children: [
          if (user != null)
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryLight,
                    foregroundImage:
                        user.photoUrl.startsWith('data:') ||
                            user.photoUrl.startsWith('http')
                        ? null
                        : null,
                    child: Text(
                      user.name.isEmpty
                          ? '?'
                          : user.name[0].toUpperCase(), // l10n-ignore
                      style: t.titleLarge?.copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: t.titleMedium),
                        const SizedBox(height: 2),
                        Text(user.email, style: t.bodySmall),
                        Text(handle, style: t.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          const StagePlaceholder(stage: 8, icon: Icons.account_circle_outlined),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.signOutButton,
            variant: AppButtonVariant.outline,
            icon: Icons.logout_rounded,
            onPressed: () => _confirmSignOut(context, ref),
          ),
        ],
      ),
    );
  }
}
