import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/domain/notification_models.dart';
import 'package:ism_customer/domain/notification_text.dart';

AppNotification n({
  String id = 'n',
  String audience = 'customer',
  String title = 'Order diterima',
  String body = '',
  String ordersNo = 'OR/20261121/001',
  String createdAt = '2026-11-21T01:00:00Z',
  List<String> readBy = const [],
  String key = '',
  Map<String, String> params = const {},
}) => AppNotification(
  id: id,
  audience: audience,
  type: 'order',
  title: title,
  body: body,
  orderId: 'o1',
  ordersNo: ordersNo,
  readBy: readBy,
  createdAt: createdAt,
  key: key,
  params: params,
);

void main() {
  group('NotificationRules', () {
    test('hanya audience customer, terbaru di atas, maks 100', () {
      final list = [
        n(id: 'a', createdAt: '2026-11-20T00:00:00Z'),
        n(id: 'p', audience: 'panel', createdAt: '2026-11-25T00:00:00Z'),
        n(id: 'b', createdAt: '2026-11-22T00:00:00Z'),
        for (var i = 0; i < 120; i++)
          n(id: 'x$i', createdAt: '2026-01-01T00:00:${i % 60}Z'),
      ];
      final out = NotificationRules.prepare(list);
      expect(out.length, 100);
      expect(out.first.id, 'b');
      expect(out[1].id, 'a');
      expect(out.any((e) => e.id == 'p'), isFalse);
    });
    test('unreadCount: uid tidak ada di readBy', () {
      final list = [
        n(id: '1'),
        n(id: '2', readBy: ['u1']),
        n(id: '3', readBy: ['u2']),
      ];
      expect(NotificationRules.unreadCount(list, 'u1'), 2);
      expect(list[1].isUnreadFor('u1'), isFalse);
    });
  });

  group('NotificationTextRules', () {
    test('judul dikenal → kunci + ordersNo', () {
      final t = NotificationTextRules.title(
        n(title: 'Delivery Order diterbitkan'),
      );
      expect(t.key, 'deliveryOrderIssued');
      expect(t.params['ordersNo'], 'OR/20261121/001');
    });
    test('isi: nomor DO & PO diambil dari body asli', () {
      final b = NotificationTextRules.body(
        n(
          title: 'Delivery Order diterbitkan',
          body: 'Order OR/1 dikirim dengan No. DO DO-2611-0001.',
        ),
      );
      expect(b.key, 'deliveryOrderIssuedBody');
      expect(b.params['doNo'], 'DO-2611-0001');
      final p = NotificationTextRules.body(
        n(
          title: 'Sertifikat siap',
          body: 'PO PO-77 untuk order OR/1 tercatat, sertifikat siap diterbitkan.',
        ),
      );
      expect(p.params['poNo'], 'PO-77');
    });
    test('key/params dari CSMS (PRD §12) diutamakan', () {
      final t = NotificationTextRules.title(
        n(title: 'apa saja', key: 'orderReceived', params: {'ordersNo': 'X'}),
      );
      expect(t.key, 'orderReceived');
      expect(t.params['ordersNo'], 'X');
    });
    test('judul tak dikenal → apa adanya', () {
      final t = NotificationTextRules.title(
        n(title: 'Pesan khusus', body: 'Isi khusus'),
      );
      expect(t.raw, 'Pesan khusus');
      expect(
        NotificationTextRules.body(n(title: 'Pesan khusus', body: 'Isi khusus'))
            .raw,
        'Isi khusus',
      );
    });
    test('semua judul customer CSMS terpetakan', () {
      for (final title in [
        'Order diterima',
        'Rekomendasi pekerjaan & penawaran',
        'Persetujuan diterima',
        'Order ditunda',
        'Rekomendasi ditolak',
        'PO diterima',
        'Menunggu Purchase Order',
        'Service selesai',
        'Dokumen ditolak',
        'Sertifikat siap',
        'Delivery Order diterbitkan',
        'Akun terverifikasi',
        'Akun diaktifkan',
        'Akun dinonaktifkan',
      ]) {
        expect(
          NotificationTextRules.title(n(title: title)).raw,
          isNull,
          reason: title,
        );
      }
    });
  });
}
