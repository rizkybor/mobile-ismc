import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/formatters.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/i18n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/order_models.dart';
import '../../../domain/order_status.dart';
import '../../../domain/order_tracking.dart';
import '../../../shared/widgets/widgets.dart';
import '../../documents/widgets/documents_card.dart';
import '../order_detail_provider.dart';
import '../tracking_text.dart';
import '../widgets/mini_progress.dart';
import '../widgets/order_history.dart';
import '../widgets/order_products.dart';
import '../widgets/track_stepper.dart';

/// Detail order (PRD F-04.2–F-04.5): kepala, stepper 7 tahap, daftar alat,
/// riwayat, tempat dokumen (Tahap 6), bagikan ringkasan. Bisa dibuka dari
/// notifikasi / deep link `ismcustomer://order/<id>`.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final detail = ref.watch(orderDetailProvider(orderId));

    return AppScaffold(
      title: l10n.orderDetailTitle,
      padding: EdgeInsets.zero,
      actions: [
        if (detail.value case final Order o)
          IconButton(
            tooltip: l10n.detailShare,
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => _share(context, o),
          ),
      ],
      body: detail.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: const [
            SkeletonBox(height: 120),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 320),
          ],
        ),
        error: (_, _) => ErrorState(
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
        data: (order) => order == null
            ? EmptyState(
                icon: Icons.search_off_rounded,
                title: l10n.orderNotFoundTitle,
                message: l10n.orderNotFoundBody,
              )
            : _Detail(order: order),
      ),
    );
  }

  void _share(BuildContext context, Order o) {
    final l10n = context.l10n;
    final tracking = OrderTrackingRules.buildTracking(o);
    final text = l10n.shareSummary(
      o.ordersNo,
      o.vesselName,
      TrackingText.currentLabel(l10n, tracking),
    );
    SharePlus.instance.share(ShareParams(text: text));
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    final lang = ref.watch(localeProvider).languageCode;
    final tracking = OrderTrackingRules.buildTracking(order);
    final stage = OrderStatusRules.stageOf(order.statusDesc);
    final created = Formatters.parseIso(order.createdAt);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(orderDetailProvider(order.id).future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xl * 2,
        ),
        children: [
          // Kepala
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(order.ordersNo, style: t.headlineSmall),
                    ),
                    StatusChip(
                      label: OrderStageUi.label(l10n, stage),
                      tone: OrderStageUi.tone(stage),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _kv(
                  t,
                  Icons.directions_boat_outlined,
                  l10n.detailVessel,
                  order.vesselName,
                ),
                if (created != null)
                  _kv(
                    t,
                    Icons.calendar_today_outlined,
                    l10n.detailCreated,
                    Formatters.formatDateTime(created, lang),
                  ),
                _kv(
                  t,
                  Icons.flag_outlined,
                  l10n.detailStatus,
                  OrderStatusRules.statusLabel(order.statusDesc),
                ),
                const SizedBox(height: AppSpacing.md),
                MiniProgress(tracking: tracking, height: 8),
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
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(title: l10n.detailProgressTitle),
                const SizedBox(height: AppSpacing.lg),
                TrackStepper(tracking: tracking),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DocumentsCard(order: order),
          const SizedBox(height: AppSpacing.lg),
          OrderProducts(order: order),
          const SizedBox(height: AppSpacing.lg),
          OrderHistory(tracking: tracking),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.detailShare,
            variant: AppButtonVariant.outline,
            icon: Icons.ios_share_rounded,
            onPressed: () {
              final text = l10n.shareSummary(
                order.ordersNo,
                order.vesselName,
                TrackingText.currentLabel(l10n, tracking),
              );
              SharePlus.instance.share(ShareParams(text: text));
            },
          ),
        ],
      ),
    );
  }

  Widget _kv(TextTheme t, IconData icon, String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: Text(
            k,
            style: t.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ),
        Expanded(child: Text(v, style: t.bodyMedium)),
      ],
    ),
  );
}
