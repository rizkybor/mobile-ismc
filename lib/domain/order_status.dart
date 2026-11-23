/// Pengelompokan `statusDesc` (PRD §7) — port dari CSMS `helper/orderStatus.js`.
/// Nilai `statusDesc` di database tetap; hanya tampilan yang dikelompokkan.
library;

import 'order_models.dart';

enum OrderStage { draft, inProgress, approval, done, rejected }

abstract final class OrderStatusRules {
  static const _byStatus = <String, OrderStage>{
    'Entry': OrderStage.draft,
    '-': OrderStage.draft,
    'Waiting for Inspection process': OrderStage.inProgress,
    'Progress for Inspection': OrderStage.inProgress,
    'Inspection is Pending': OrderStage.inProgress,
    'Inspection is Completed': OrderStage.inProgress,
    'Waiting for Certificate process': OrderStage.inProgress,
    'PO not finished yet': OrderStage.inProgress,
    'Waiting for Client to approve Inspection': OrderStage.approval,
    'Waiting for Approval Client': OrderStage.approval,
    'Waiting for PO Client': OrderStage.approval,
    'Final Order': OrderStage.done,
    'Done': OrderStage.done,
    'Rejected': OrderStage.rejected,
    'Inspection Rejected': OrderStage.rejected,
    'Reject': OrderStage.rejected,
  };

  /// Status tak dikenal → `inProgress` agar total dashboard tetap sama
  /// dengan jumlah order (sama dengan web).
  static OrderStage stageOf(String statusDesc) =>
      _byStatus[statusDesc] ?? OrderStage.inProgress;

  static const _shortLabels = <String, String>{
    'Waiting for Client to approve Inspection': 'Waiting for Approval',
    'Waiting for Approval Client': 'Waiting for Approval',
    'Waiting for Certificate process': 'Waiting for Certificate',
  };

  /// Teks `statusDesc` asli (bahasa sistem) yang dipendekkan — bukan
  /// terjemahan; dipakai di detail order.
  static String statusLabel(String statusDesc) =>
      _shortLabels[statusDesc] ?? statusDesc;
}

/// Ringkasan Beranda (PRD F-03.1).
class OrderStats {
  const OrderStats({
    required this.total,
    required this.inProgress,
    required this.done,
    required this.rejected,
  });

  final int total;

  /// total − selesai − ditolak.
  final int inProgress;
  final int done;
  final int rejected;

  factory OrderStats.of(Iterable<Order> orders) {
    var done = 0;
    var rejected = 0;
    var total = 0;
    for (final o in orders) {
      total++;
      switch (OrderStatusRules.stageOf(o.statusDesc)) {
        case OrderStage.done:
          done++;
        case OrderStage.rejected:
          rejected++;
        case OrderStage.draft:
        case OrderStage.inProgress:
        case OrderStage.approval:
          break;
      }
    }
    return OrderStats(
      total: total,
      inProgress: total - done - rejected,
      done: done,
      rejected: rejected,
    );
  }
}
