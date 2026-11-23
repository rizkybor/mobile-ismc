import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/formatters.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/i18n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/order_models.dart';
import '../../../domain/order_status.dart';
import '../../../domain/order_tracking.dart';
import '../../../shared/widgets/widgets.dart';
import '../../tracking/tracking_text.dart';
import '../../tracking/widgets/mini_progress.dart';

/// Kartu order (PRD F-03.2): No. order, tanggal, vessel, produk, chip status,
/// mini-progress 7 segmen, tahap saat ini.
class OrderCard extends ConsumerWidget {
  const OrderCard({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    final lang = ref.watch(localeProvider).languageCode;
    final stage = OrderStatusRules.stageOf(order.statusDesc);
    final tracking = OrderTrackingRules.buildTracking(order);
    final created = Formatters.parseIso(order.createdAt);

    return AppCard(
      onTap: () => context.push(Routes.order(order.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.ordersNo, style: t.titleMedium),
                    if (created != null)
                      Text(
                        Formatters.formatDate(created, lang),
                        style: t.bodySmall,
                      ),
                  ],
                ),
              ),
              StatusChip(
                label: OrderStageUi.label(l10n, stage),
                tone: OrderStageUi.tone(stage),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.directions_boat_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.vesselName,
                  style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: 4,
            children: [
              for (final p in order.productNames)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: OrderStageUi.productColor(p),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(p, style: t.bodySmall),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          MiniProgress(tracking: tracking),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  TrackingText.currentLabel(l10n, tracking),
                  style: t.labelMedium?.copyWith(
                    color: tracking.done
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
              ),
              Text(
                l10n.trackingProgress(
                  tracking.doneCount,
                  tracking.steps.length,
                ),
                style: t.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
