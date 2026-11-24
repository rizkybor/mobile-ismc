import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatters.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/i18n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/order_tracking.dart';
import '../../../shared/widgets/widgets.dart';
import '../tracking_text.dart';

/// Riwayat order (PRD F-04.3): terbaru di atas, 5 pertama + "Tampilkan semua".
class OrderHistory extends ConsumerStatefulWidget {
  const OrderHistory({super.key, required this.tracking});
  final OrderTracking tracking;

  static const initialCount = 5;

  @override
  ConsumerState<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends ConsumerState<OrderHistory> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = ref.watch(localeProvider).languageCode;
    final t = Theme.of(context).textTheme;
    final events = widget.tracking.events;
    final shown = _expanded
        ? events
        : events.take(OrderHistory.initialCount).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: l10n.detailHistoryTitle),
          const SizedBox(height: AppSpacing.md),
          if (events.isEmpty)
            Text(l10n.detailHistoryEmpty, style: t.bodySmall)
          else ...[
            for (var i = 0; i < shown.length; i++)
              _EventRow(
                event: shown[i],
                isLast: i == shown.length - 1,
                lang: lang,
              ),
            if (!widget.tracking.hasHistory) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(l10n.detailHistoryApprox, style: t.bodySmall),
                  ),
                ],
              ),
            ],
            if (events.length > OrderHistory.initialCount)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded ? l10n.detailShowLess : l10n.detailShowAll,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.event,
    required this.isLast,
    required this.lang,
  });
  final TrackEvent event;
  final bool isLast;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    final at = Formatters.parseIso(event.at);
    final meta = [
      if (at != null) Formatters.formatDateTime(at, lang),
      if (event.by.isNotEmpty) l10n.historyBy(event.by),
    ].join(' · ');
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 16,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TrackingText.resolve(l10n, event.label),
                    style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  if (event.note.isNotEmpty)
                    Text(event.note, style: t.bodySmall),
                  if (meta.isNotEmpty)
                    Text(
                      meta,
                      style: t.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
