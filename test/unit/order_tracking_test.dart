import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/domain/order_models.dart';
import 'package:ism_customer/domain/order_tracking.dart';

import '../fixtures/orders.dart' as fx;

TrackState st(OrderTracking t, int i) => t.steps[i].state;

void main() {
  group('buildTracking (PRD §8, port orderTracking.js)', () {
    test('order baru → tahap 1 berjalan', () {
      final t = OrderTrackingRules.buildTracking(fx.o1);
      expect(st(t, 0), TrackState.done);
      expect(st(t, 1), TrackState.current);
      expect(t.current?.key, TrackStepKey.workform);
      expect(t.doneCount, 1);
      expect(t.progress, 14);
      expect(t.steps[0].note.raw, 'OR/20261121/001');
    });

    test(
      'menunggu client + quotationNo → tahap 2 berjalan, catatan Penawaran',
      () {
        final t = OrderTrackingRules.buildTracking(fx.o3);
        expect(st(t, 1), TrackState.done);
        expect(st(t, 2), TrackState.current);
        expect(t.steps[2].note.key, 'noteQuotation');
        expect(t.steps[2].note.params['no'], 'QTN-2611-0003');
      },
    );

    test(
      'Final Order + PO tanpa sertifikat → tahap 4 berjalan, catatan PO',
      () {
        final t = OrderTrackingRules.buildTracking(fx.o6);
        expect(st(t, 3), TrackState.done);
        expect(st(t, 4), TrackState.current);
        expect(t.steps[4].note.key, 'notePo');
        expect(t.steps[4].note.params['no'], 'PO-2611-77');
      },
    );

    test('sertifikat tanpa PO → tahap 4 selesai "Dicetak tanpa PO"; invoice belum bayar → tahap 5 tertunda', () {
      final t = OrderTrackingRules.buildTracking(fx.certNoPoUnpaid);
      expect(st(t, 4), TrackState.done);
      expect(t.steps[4].note.key, 'noteCertNoPo');
      expect(st(t, 5), TrackState.warning);
      expect(t.steps[5].note.key, 'noteInvoice');
      expect(t.steps[5].note.params['payment'], 'unpaid');
    });

    test('Tempo → tahap 5 selesai tapi tertunda (warning)', () {
      final t = OrderTrackingRules.buildTracking(fx.tempo);
      expect(st(t, 5), TrackState.warning);
      expect(t.steps[5].note.params['payment'], 'tempo');
      expect(t.done, isFalse);
    });

    test('Lunas + DO → semua selesai, riwayat terbaru di atas', () {
      final t = OrderTrackingRules.buildTracking(fx.completed);
      expect(t.done, isTrue);
      expect(t.progress, 100);
      expect(t.current, isNull);
      expect(t.hasHistory, isTrue);
      expect(t.events.first.status, 'Delivery Order');
      expect(t.events.first.label.key, 'deliveryOrderIssued');
      // tanggal tahap = kejadian pertama yang menandainya
      expect(t.steps[4].at, '2026-11-22T01:00:00.000Z');
      expect(t.steps[5].at, '2026-11-24T01:00:00.000Z');
      expect(t.steps[6].at, '2026-11-25T01:00:00.000Z');
    });

    test(
      'Inspection Rejected → tahap 2 ditolak; Rejected → tahap 4 ditolak',
      () {
        expect(
          st(OrderTrackingRules.buildTracking(fx.inspectionRejected), 2),
          TrackState.error,
        );
        expect(
          st(OrderTrackingRules.buildTracking(fx.rejected), 4),
          TrackState.error,
        );
      },
    );

    test('order tanpa statusHistory → riwayat disusun dari data (approx)', () {
      final t = OrderTrackingRules.buildTracking(fx.certNoPoUnpaid);
      expect(t.hasHistory, isFalse);
      expect(t.events, isNotEmpty);
      expect(t.events.every((e) => e.approx), isTrue);
      final statuses = t.events.map((e) => e.status).toList();
      expect(
        statuses,
        containsAll([
          'Waiting for Inspection process',
          'Certificate',
          'Invoice',
        ]),
      );
      // Invoice (23 Nov) lebih baru dari Certificate (22 Nov) → di atas
      expect(
        statuses.indexOf('Invoice'),
        lessThan(statuses.indexOf('Certificate')),
      );
    });

    test('eventLabel: Final Order + note "PO dikonfirmasi"', () {
      final l = OrderTrackingRules.eventLabel(
        const StatusEvent(status: 'Final Order', note: 'PO dikonfirmasi'),
      );
      expect(l.key, 'poConfirmedCertificateReady');
      final unknown = OrderTrackingRules.eventLabel(
        const StatusEvent(status: 'Status Aneh'),
      );
      expect(unknown.raw, 'Status Aneh');
    });
  });
}
