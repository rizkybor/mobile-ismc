import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/domain/order_models.dart';

import '../fixtures/orders.dart' as fx;

void main() {
  group('Order.fromMap', () {
    test('field lengkap', () {
      expect(fx.o6.ordersNo, 'OR/20261121/006');
      expect(fx.o6.poNumber, 'PO-2611-77');
      expect(fx.o6.productsList.single.serialNumber, 'GX-A0');
      expect(fx.o6.productNames, ['Gas Meter']);
    });
    test('toleran null / tipe salah', () {
      final o = Order.fromMap('x', {
        'ordersNo': null,
        'productsList': 'bukan list',
        'statusHistory': null,
        'pdfFiles': 'salah',
        'invoiceTotal': 'abc',
        'invoiceTempo': 'yes',
      });
      expect(o.ordersNo, '');
      expect(o.productsList, isEmpty);
      expect(o.statusHistory, isEmpty);
      expect(o.pdfFiles, isEmpty);
      expect(o.invoiceTotal, 0);
      expect(o.invoiceTempo, isFalse);
    });
    test('products dipisah koma & dirapikan', () {
      final o = Order.fromMap('x', {
        'products': 'Gas Meter, UTI Meter ,,Pressure Gauge',
      });
      expect(o.productNames, ['Gas Meter', 'UTI Meter', 'Pressure Gauge']);
    });
    test('toMap → fromMap bolak-balik (cache)', () {
      final back = Order.fromMap(fx.completed.id, fx.completed.toMap());
      expect(back.deliveryOrderNumber, 'DO-2611-0001');
      expect(back.statusHistory.length, 8);
      expect(back.pdfFiles['certificateGas']?.docId, 'c1');
      expect(back.invoiceStatus, 'Lunas');
    });
    test('sortNewest', () {
      final a = Order.fromMap('a', {'createdAt': '2026-01-01T00:00:00Z'});
      final b = Order.fromMap('b', {'createdAt': '2026-02-01T00:00:00Z'});
      expect(Order.sortNewest([a, b]).map((o) => o.id), ['b', 'a']);
    });
  });
}
