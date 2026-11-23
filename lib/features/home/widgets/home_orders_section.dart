import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/order_models.dart';
import '../../../domain/order_status.dart';
import '../../../shared/widgets/widgets.dart';
import '../orders_controller.dart';
import 'order_card.dart';
import 'stat_cards.dart';

/// Isi Beranda untuk akun aktif: statistik + 5 order terbaru.
class HomeOrdersSection extends ConsumerWidget {
  const HomeOrdersSection({super.key});

  static const recentCount = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final orders = ref.watch(customerOrdersProvider);
    final fromCache = ref.watch(
      customerOrdersProvider.notifier.select((n) => n.fromCache),
    );

    return orders.when(
      loading: () => const _HomeSkeleton(),
      error: (_, _) => ErrorState(
        message: l10n.homeErrorBody,
        onRetry: () => ref.read(customerOrdersProvider.notifier).refresh(),
      ),
      data: (list) => _HomeData(list: list, fromCache: fromCache),
    );
  }
}

class _HomeData extends StatelessWidget {
  const _HomeData({required this.list, required this.fromCache});
  final List<Order> list;
  final bool fromCache;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final recent = list.take(HomeOrdersSection.recentCount).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (fromCache) ...[
          InlineMessage(
            text: l10n.homeCachedNotice,
            tone: InlineMessageTone.info,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        StatCards(stats: OrderStats.of(list)),
        const SizedBox(height: AppSpacing.xl),
        SectionTitle(
          title: l10n.homeRecentOrders,
          action: list.length > HomeOrdersSection.recentCount
              ? TextButton(
                  onPressed: () => context.go(Routes.tracking),
                  child: Text(l10n.homeSeeAll),
                )
              : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (recent.isEmpty)
          EmptyState(
            icon: Icons.inventory_2_outlined,
            title: l10n.homeEmptyTitle,
            message: l10n.homeEmptyBody,
          )
        else
          for (final o in recent) ...[
            OrderCard(order: o),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(child: SkeletonBox(height: 96)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: SkeletonBox(height: 96)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: SkeletonBox(height: 96)),
          ],
        ),
        SizedBox(height: AppSpacing.xl),
        SkeletonBox(height: 20, width: 140),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 150),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 150),
      ],
    );
  }
}
