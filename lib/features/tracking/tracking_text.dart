import 'package:flutter/material.dart';

import '../../core/i18n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/order_status.dart';
import '../../domain/order_tracking.dart';
import '../../shared/widgets/status_chip.dart';

/// Terjemahan teks Lacak Order (PRD §8) dari [TrackText] domain.
abstract final class TrackingText {
  static String step(AppLocalizations l10n, TrackStepKey key) => switch (key) {
    TrackStepKey.order => l10n.trackingStepOrder,
    TrackStepKey.workform => l10n.trackingStepWorkform,
    TrackStepKey.quotation => l10n.trackingStepQuotation,
    TrackStepKey.service => l10n.trackingStepService,
    TrackStepKey.certificate => l10n.trackingStepCertificate,
    TrackStepKey.invoice => l10n.trackingStepInvoice,
    TrackStepKey.delivery => l10n.trackingStepDelivery,
  };

  static String payment(AppLocalizations l10n, String key) => switch (key) {
    'paid' => l10n.paymentPaid,
    'tempo' => l10n.paymentTempo,
    _ => l10n.paymentUnpaid,
  };

  static String resolve(AppLocalizations l10n, TrackText t) {
    if (t.raw != null) return t.raw!;
    final p = t.params;
    return switch (t.key) {
      '' => '',
      'noteWorkformEntry' => l10n.trackingNoteWorkformEntry,
      'noteQuotation' => l10n.trackingNoteQuotation(p['no'] ?? ''),
      'noteQuotationCreated' => l10n.trackingNoteQuotationCreated,
      'noteServiceWaitingPo' => l10n.trackingNoteServiceWaitingPo,
      'noteCertNoPo' => l10n.trackingNoteCertNoPo,
      'notePo' => l10n.trackingNotePo(p['no'] ?? ''),
      'noteInvoice' => l10n.trackingNoteInvoice(
        p['no'] ?? '',
        payment(l10n, p['payment'] ?? ''),
      ),
      'noteInvoiceNotIssued' => l10n.trackingNoteInvoiceNotIssued,
      'orderCreated' => l10n.trackingEventOrderCreated,
      'workformStarted' => l10n.trackingEventWorkformStarted,
      'recommendationSent' => l10n.trackingEventRecommendationSent,
      'recommendationApproved' => l10n.trackingEventRecommendationApproved,
      'recommendationPending' => l10n.trackingEventRecommendationPending,
      'recommendationRejected' => l10n.trackingEventRecommendationRejected,
      'inspectionDecision' => l10n.trackingEventInspectionDecision,
      'poReceivedCertificate' => l10n.trackingEventPoReceivedCertificate,
      'serviceDoneWaitingPo' => l10n.trackingEventServiceDoneWaitingPo,
      'serviceDoneCertificate' => l10n.trackingEventServiceDoneCertificate,
      'poConfirmedCertificateReady' =>
        l10n.trackingEventPoConfirmedCertificateReady,
      'documentRejected' => l10n.trackingEventDocumentRejected,
      'quotationCreated' => l10n.trackingEventQuotationCreated,
      'quotationUpdated' => l10n.trackingEventQuotationUpdated,
      'poRecorded' => l10n.trackingEventPoRecorded,
      'poUpdated' => l10n.trackingEventPoUpdated,
      'poRemoved' => l10n.trackingEventPoRemoved,
      'certificateIssued' => l10n.trackingEventCertificateIssued,
      'invoiceIssued' => l10n.trackingEventInvoiceIssued,
      'invoiceUpdated' => l10n.trackingEventInvoiceUpdated,
      'invoicePaid' => l10n.trackingEventInvoicePaid,
      'invoiceUnpaid' => l10n.trackingEventInvoiceUnpaid,
      'deliveryOrderIssued' => l10n.trackingEventDeliveryOrderIssued,
      'reverted' => l10n.trackingEventReverted,
      _ => t.key,
    };
  }

  /// Label tahap saat ini (atau "Selesai").
  static String currentLabel(AppLocalizations l10n, OrderTracking t) {
    final c = t.current;
    return c == null ? l10n.trackingFinished : step(l10n, c.key);
  }
}

/// Label & warna chip untuk kelompok status (PRD §7).
abstract final class OrderStageUi {
  static String label(AppLocalizations l10n, OrderStage s) => switch (s) {
    OrderStage.draft => l10n.orderStageDraft,
    OrderStage.inProgress => l10n.orderStageInProgress,
    OrderStage.approval => l10n.orderStageApproval,
    OrderStage.done => l10n.orderStageDone,
    OrderStage.rejected => l10n.orderStageRejected,
  };

  static ChipTone tone(OrderStage s) => switch (s) {
    OrderStage.draft => ChipTone.neutral,
    OrderStage.inProgress => ChipTone.current,
    OrderStage.approval => ChipTone.pending,
    OrderStage.done => ChipTone.done,
    OrderStage.rejected => ChipTone.rejected,
  };

  /// Titik warna produk (PRD Tahap 4).
  static Color productColor(String name) {
    final n = name.toLowerCase();
    if (n.contains('gas')) return AppColors.productGas;
    if (n.contains('uti')) return AppColors.productUti;
    return AppColors.productOther;
  }
}

/// Warna tiap [TrackState] mengikuti token status.
Color stepStateColor(BuildContext context, TrackState s) {
  final c = context.statusColors;
  return switch (s) {
    TrackState.done => c.done,
    TrackState.current => c.current,
    TrackState.warning => c.pending,
    TrackState.error => c.rejected,
    TrackState.todo => c.waiting,
  };
}
