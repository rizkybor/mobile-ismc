import 'package:flutter/material.dart';

import '../../core/i18n/l10n.dart';
import '../../domain/documents.dart';
import '../../shared/widgets/status_chip.dart';

/// Judul & ikon dokumen (DOC_TYPES web, diterjemahkan).
abstract final class DocumentUi {
  static String title(AppLocalizations l10n, DocType t) => switch (t) {
    DocType.quotation => l10n.docQuotation,
    DocType.invoice => l10n.docInvoice,
    DocType.certificateGas => l10n.docCertificateGas,
    DocType.certificateUti => l10n.docCertificateUti,
    DocType.certificateKan => l10n.docCertificateKan,
  };

  static IconData icon(DocType t) => switch (t) {
    DocType.quotation => Icons.request_quote_outlined,
    DocType.invoice => Icons.receipt_long_outlined,
    DocType.certificateGas ||
    DocType.certificateUti ||
    DocType.certificateKan => Icons.workspace_premium_outlined,
  };

  static String paymentLabel(AppLocalizations l10n, PaymentState s) =>
      switch (s) {
        PaymentState.paid => l10n.paymentPaid,
        PaymentState.tempo => l10n.paymentTempo,
        PaymentState.unpaid => l10n.paymentUnpaid,
        PaymentState.none => '',
      };

  static ChipTone paymentTone(PaymentState s) => switch (s) {
    PaymentState.paid => ChipTone.done,
    PaymentState.tempo => ChipTone.current,
    PaymentState.unpaid => ChipTone.pending,
    PaymentState.none => ChipTone.neutral,
  };
}

/// Parameter yang dikirim ke layar pratinjau PDF.
class PdfViewRequest {
  const PdfViewRequest({required this.document, required this.title});
  final CustomerDocument document;
  final String title;
}
