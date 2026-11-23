import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/domain/order_models.dart';
import 'package:ism_customer/domain/order_status.dart';

Order o(String status) => Order.fromMap('x', {'statusDesc': status});

void main() {
  group('stageOf (PRD §7)', () {
    test('kelompok', () {
      expect(OrderStatusRules.stageOf('Entry'), OrderStage.draft);
      expect(OrderStatusRules.stageOf('-'), OrderStage.draft);
      expect(
        OrderStatusRules.stageOf('Waiting for Inspection process'),
        OrderStage.inProgress,
      );
      expect(
        OrderStatusRules.stageOf('PO not finished yet'),
        OrderStage.inProgress,
      );
      expect(
        OrderStatusRules.stageOf('Waiting for Client to approve Inspection'),
        OrderStage.approval,
      );
      expect(
        OrderStatusRules.stageOf('Waiting for PO Client'),
        OrderStage.approval,
      );
      expect(OrderStatusRules.stageOf('Final Order'), OrderStage.done);
      expect(OrderStatusRules.stageOf('Done'), OrderStage.done);
      expect(OrderStatusRules.stageOf('Rejected'), OrderStage.rejected);
      expect(
        OrderStatusRules.stageOf('Inspection Rejected'),
        OrderStage.rejected,
      );
    });
    test('tak dikenal → inProgress', () {
      expect(
        OrderStatusRules.stageOf('Waiting for Inspection Approval'),
        OrderStage.inProgress,
      );
      expect(OrderStatusRules.stageOf(''), OrderStage.inProgress);
    });
  });

  test('statusLabel dipendekkan', () {
    expect(
      OrderStatusRules.statusLabel('Waiting for Client to approve Inspection'),
      'Waiting for Approval',
    );
    expect(
      OrderStatusRules.statusLabel('Waiting for Certificate process'),
      'Waiting for Certificate',
    );
    expect(OrderStatusRules.statusLabel('Final Order'), 'Final Order');
  });

  test('OrderStats: sedang diproses = total − selesai − ditolak', () {
    final s = OrderStats.of([
      o('Entry'),
      o('Waiting for Inspection process'),
      o('Waiting for Client to approve Inspection'),
      o('Final Order'),
      o('Done'),
      o('Rejected'),
      o('status aneh'),
    ]);
    expect(s.total, 7);
    expect(s.done, 2);
    expect(s.rejected, 1);
    expect(s.inProgress, 4);
  });
}
