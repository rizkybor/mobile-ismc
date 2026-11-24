import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/features/tracking/order_search.dart';

import '../fixtures/orders.dart' as fx;

void main() {
  final all = [fx.o1, fx.o3, fx.o6, fx.completed, fx.tempo];

  test('filter Berjalan vs Selesai (selesai = 7 tahap selesai)', () {
    final active = OrderSearch.apply(all, filter: TrackingFilter.active);
    final done = OrderSearch.apply(all, filter: TrackingFilter.done);
    expect(done.map((o) => o.invoiceNo), ['INV-2611-0003']);
    expect(active.length, 4);
    // Tempo belum dihitung selesai
    expect(active.any((o) => o.invoiceTempo), isTrue);
  });

  test('cari No. order, vessel, status (label pendek), produk, S/N', () {
    List<String> q(String s) => OrderSearch.apply(
      all,
      filter: TrackingFilter.active,
      query: s,
    ).map((o) => o.ordersNo).toList();
    expect(q('/003'), ['OR/20261121/003']);
    expect(q('bahari'), hasLength(4));
    expect(q('waiting for approval'), ['OR/20261121/003']);
    expect(q('gas meter'), hasLength(4));
    expect(q('GX-A0'), hasLength(4));
    expect(q('tidak ada'), isEmpty);
  });
}
