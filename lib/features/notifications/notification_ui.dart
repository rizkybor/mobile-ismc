import 'package:flutter/material.dart';

import '../../core/i18n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/notification_models.dart';
import '../../domain/notification_text.dart';

/// Ikon/warna per `type` dan terjemahan judul/isi.
abstract final class NotificationUi {
  static (IconData, Color) iconFor(String type) => switch (type) {
    'order' => (Icons.inventory_2_outlined, AppColors.primary),
    'approval' => (Icons.rule_rounded, AppColors.warning),
    'success' => (Icons.check_circle_outline_rounded, AppColors.success),
    'warning' => (Icons.pause_circle_outline_rounded, AppColors.warning),
    'error' => (Icons.error_outline_rounded, AppColors.error),
    'account' => (Icons.verified_user_outlined, AppColors.primary),
    _ => (Icons.info_outline_rounded, AppColors.primary),
  };

  static String title(AppLocalizations l10n, AppNotification n) =>
      _resolve(l10n, NotificationTextRules.title(n));

  static String body(AppLocalizations l10n, AppNotification n) =>
      _resolve(l10n, NotificationTextRules.body(n));

  static String _resolve(AppLocalizations l10n, NotificationText t) {
    if (t.raw != null) return t.raw!;
    final no = t.params['ordersNo'] ?? '';
    return switch (t.key) {
      'orderReceived' => l10n.notifOrderReceived,
      'orderReceivedBody' => l10n.notifOrderReceivedBody(no),
      'recommendationQuotation' => l10n.notifRecommendationQuotation,
      'recommendationQuotationBody' => l10n.notifRecommendationQuotationBody(
        no,
      ),
      'approvalReceived' => l10n.notifApprovalReceived,
      'approvalReceivedBody' => l10n.notifApprovalReceivedBody(no),
      'orderOnHold' => l10n.notifOrderOnHold,
      'orderOnHoldBody' => l10n.notifOrderOnHoldBody(no),
      'recommendationRejected' => l10n.notifRecommendationRejected,
      'recommendationRejectedBody' => l10n.notifRecommendationRejectedBody(no),
      'poReceived' => l10n.notifPoReceived,
      'poReceivedBody' => l10n.notifPoReceivedBody(no),
      'waitingPo' => l10n.notifWaitingPo,
      'waitingPoBody' => l10n.notifWaitingPoBody(no),
      'serviceDone' => l10n.notifServiceDone,
      'serviceDoneBody' => l10n.notifServiceDoneBody(no),
      'documentRejected' => l10n.notifDocumentRejected,
      'documentRejectedBody' => l10n.notifDocumentRejectedBody(no),
      'certificateReady' => l10n.notifCertificateReady,
      'certificateReadyBody' => l10n.notifCertificateReadyBody(
        no,
        t.params['poNo'] ?? '-',
      ),
      'deliveryOrderIssued' => l10n.notifDeliveryOrderIssued,
      'deliveryOrderIssuedBody' => l10n.notifDeliveryOrderIssuedBody(
        no,
        t.params['doNo'] ?? '-',
      ),
      'accountVerified' => l10n.notifAccountVerified,
      'accountVerifiedBody' => l10n.notifAccountVerifiedBody,
      'accountActivated' => l10n.notifAccountActivated,
      'accountActivatedBody' => l10n.notifAccountActivatedBody,
      'accountDeactivated' => l10n.notifAccountDeactivated,
      'accountDeactivatedBody' => l10n.notifAccountDeactivatedBody,
      _ => t.key,
    };
  }
}
