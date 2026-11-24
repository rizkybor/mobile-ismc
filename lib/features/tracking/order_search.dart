import '../../domain/order_models.dart';
import '../../domain/order_status.dart';
import '../../domain/order_tracking.dart';

enum TrackingFilter { active, done }

/// Pencarian & filter daftar Lacak (PRD F-04.1) — murni, mudah diuji.
abstract final class OrderSearch {
  /// Selesai = ketujuh tahap selesai (bukan sekadar statusDesc).
  static bool isFinished(Order o) => OrderTrackingRules.buildTracking(o).done;

  static List<Order> apply(
    List<Order> orders, {
    required TrackingFilter filter,
    String query = '',
  }) {
    final q = query.trim().toLowerCase();
    return [
      for (final o in orders)
        if ((filter == TrackingFilter.done) == isFinished(o) && _matches(o, q))
          o,
    ];
  }

  static bool _matches(Order o, String q) {
    if (q.isEmpty) return true;
    final hay = [
      o.ordersNo,
      o.vesselName,
      o.statusDesc,
      OrderStatusRules.statusLabel(o.statusDesc),
      o.products,
      for (final p in o.productsList) ...[
        p.product,
        p.type,
        p.series,
        p.serialNumber,
      ],
    ].join(' ').toLowerCase();
    return hay.contains(q);
  }
}
