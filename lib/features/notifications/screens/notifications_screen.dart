import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/formatters.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/i18n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/notifications_repository.dart';
import '../../../domain/notification_models.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/session_controller.dart';
import '../../debug/debug_fab.dart';
import '../notification_ui.dart';
import '../notifications_provider.dart';

/// Notifikasi (PRD F-06): daftar realtime, belum dibaca, tandai semua,
/// tap → tandai dibaca → detail order bila ada `orderId`.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final list = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadCountProvider);
    final uid = ref.watch(sessionProvider).user?.uid ?? '';

    return AppScaffold.brand(
      title: l10n.notificationsTitle,
      subtitle: unread > 0
          ? l10n.notifUnreadCount(unread)
          : l10n.notificationsSubtitle,
      headerTrailing: unread > 0
          ? TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () {
                final ids = (list.value ?? const <AppNotification>[])
                    .where((n) => n.isUnreadFor(uid))
                    .map((n) => n.id);
                ref.read(notificationsRepositoryProvider).markAllRead(ids, uid);
              },
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: Text(l10n.notifMarkAllRead),
            )
          : null,
      floatingActionButton: const DebugFab(),
      padding: EdgeInsets.zero,
      body: list.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: const [
            SkeletonBox(height: 72),
            SizedBox(height: AppSpacing.sm),
            SkeletonBox(height: 72),
            SizedBox(height: AppSpacing.sm),
            SkeletonBox(height: 72),
          ],
        ),
        error: (_, _) =>
            ErrorState(onRetry: () => ref.invalidate(notificationsProvider)),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.notifications_none_rounded,
                title: l10n.notifEmptyTitle,
                message: l10n.notifEmptyBody,
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xl * 4,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) =>
                    _NotificationTile(n: items[i], uid: uid),
              ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.n, required this.uid});
  final AppNotification n;
  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    final lang = ref.watch(localeProvider).languageCode;
    final unread = n.isUnreadFor(uid);
    final (icon, color) = NotificationUi.iconFor(n.type);
    final at = Formatters.parseIso(n.createdAt);

    return AppCard(
      elevated: unread,
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () async {
        if (unread && uid.isNotEmpty) {
          await ref
              .read(notificationsRepositoryProvider)
              .markRead(n.id, uid)
              .catchError((_) {});
        }
        if (n.orderId.isNotEmpty && context.mounted) {
          unawaited(context.push(Routes.order(n.orderId)));
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        NotificationUi.title(l10n, n),
                        style: t.titleSmall?.copyWith(
                          fontWeight: unread
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (unread)
                      Container(
                        width: 9,
                        height: 9,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  NotificationUi.body(l10n, n),
                  style: t.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  at == null ? '' : _relative(l10n, at, lang),
                  style: t.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _relative(AppLocalizations l10n, DateTime at, String lang) {
    final r = Formatters.relative(at);
    return switch (r.kind) {
      RelativeKind.justNow => l10n.relativeJustNow,
      RelativeKind.minutes => l10n.relativeMinutes(r.value),
      RelativeKind.hours => l10n.relativeHours(r.value),
      RelativeKind.yesterday => l10n.relativeYesterday,
      RelativeKind.date => Formatters.formatDateTime(at, lang),
    };
  }
}
