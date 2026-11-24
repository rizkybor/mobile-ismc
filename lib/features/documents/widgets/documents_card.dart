import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/i18n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/documents.dart';
import '../../../domain/order_models.dart';
import '../../../shared/widgets/widgets.dart';
import '../document_ui.dart';

/// Kartu Dokumen di detail order (PRD F-05.1): daftar dokumen, chip
/// pembayaran, item terkunci dengan gembok.
class DocumentsCard extends StatelessWidget {
  const DocumentsCard({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    final docs = DocumentRules.customerDocuments(order);
    final payment = DocumentRules.paymentState(order);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: l10n.detailDocumentsTitle,
            action: payment == PaymentState.none
                ? null
                : StatusChip(
                    label: DocumentUi.paymentLabel(l10n, payment),
                    tone: DocumentUi.paymentTone(payment),
                  ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (docs.isEmpty)
            Text(l10n.docsEmpty, style: t.bodySmall)
          else
            for (final d in docs) _DocTile(order: order, doc: d),
          const SizedBox(height: AppSpacing.sm),
          Text(
            payment == PaymentState.tempo
                ? l10n.docsTempoNote
                : l10n.docsPaymentNote,
            style: t.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({required this.order, required this.doc});
  final Order order;
  final CustomerDocument doc;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    final open = DocumentRules.canDownload(order, doc.type);
    final title = DocumentUi.title(l10n, doc.type);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: open
          ? () => context.push(
              Routes.pdfViewer,
              extra: PdfViewRequest(document: doc, title: title),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: open ? AppColors.primaryLight : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                open ? DocumentUi.icon(doc.type) : Icons.lock_outline_rounded,
                color: open ? AppColors.primary : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: t.titleSmall?.copyWith(
                      color: open
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    open ? doc.fileName : l10n.docLocked,
                    style: t.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (open)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}
