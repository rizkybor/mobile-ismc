import 'package:flutter/material.dart';

import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/order_models.dart';
import '../../../shared/widgets/widgets.dart';
import '../tracking_text.dart';

/// Daftar alat (PRD F-04.4): produk, merk, tipe, S/N.
class OrderProducts extends StatelessWidget {
  const OrderProducts({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    final items = order.productsList;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: l10n.detailProductsTitle),
          const SizedBox(height: AppSpacing.sm),
          if (items.isEmpty)
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final p in order.productNames)
                  StatusChip(label: p, tone: ChipTone.neutral),
              ],
            ),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: OrderStageUi.productColor(items[i].product),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(items[i].product, style: t.titleSmall),
                      const SizedBox(height: 2),
                      _kv(t, l10n.detailProductBrand, items[i].type),
                      _kv(t, l10n.detailProductType, items[i].series),
                      _kv(t, l10n.detailProductSn, items[i].serialNumber),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _kv(TextTheme t, String k, String v) => Row(
    children: [
      SizedBox(
        width: 48,
        child: Text(
          k,
          style: t.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
      ),
      Expanded(
        child: Text(v.isEmpty ? '-' : v, style: t.bodySmall), // l10n-ignore
      ),
    ],
  );
}
