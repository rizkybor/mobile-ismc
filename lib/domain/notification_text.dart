/// Terjemahan notifikasi (PRD §5A): judul yang dikenal dari CSMS
/// (`helper/orderEvents.js`) dipetakan ke kunci l10n + `ordersNo`;
/// bila dokumen punya `key`/`params` (PRD §12 butir 3) pakai itu; selain
/// itu teks tampil apa adanya. Murni Dart.
library;

import 'notification_models.dart';

class NotificationText {
  const NotificationText.key(this.key, {this.params = const {}}) : raw = null;
  const NotificationText.raw(String text)
    : key = '',
      params = const {},
      raw = text;

  final String key;
  final Map<String, String> params;
  final String? raw;
}

abstract final class NotificationTextRules {
  /// Judul CSMS → kunci logis.
  static const titleKeys = <String, String>{
    'Order diterima': 'orderReceived',
    'Rekomendasi pekerjaan & penawaran': 'recommendationQuotation',
    'Persetujuan diterima': 'approvalReceived',
    'Order ditunda': 'orderOnHold',
    'Rekomendasi ditolak': 'recommendationRejected',
    'PO diterima': 'poReceived',
    'Menunggu Purchase Order': 'waitingPo',
    'Service selesai': 'serviceDone',
    'Dokumen ditolak': 'documentRejected',
    'Sertifikat siap': 'certificateReady',
    'Delivery Order diterbitkan': 'deliveryOrderIssued',
    'Akun terverifikasi': 'accountVerified',
    'Akun diaktifkan': 'accountActivated',
    'Akun dinonaktifkan': 'accountDeactivated',
  };

  static NotificationText title(AppNotification n) {
    if (n.key.isNotEmpty) return NotificationText.key(n.key, params: n.params);
    final k = titleKeys[n.title.trim()];
    return k == null
        ? NotificationText.raw(n.title)
        : NotificationText.key(
            k,
            params: {'ordersNo': n.ordersNo, ...n.params},
          );
  }

  /// Isi: diterjemahkan dengan kunci yang sama (`<key>Body`) bila dikenal;
  /// nomor DO/PO diambil dari body asli bila ada.
  static NotificationText body(AppNotification n) {
    final t = title(n);
    if (t.raw != null) return NotificationText.raw(n.body);
    final params = {...t.params};
    final doMatch = RegExp(r'No\. DO ([^\s.]+)').firstMatch(n.body);
    if (doMatch != null) params['doNo'] = doMatch.group(1)!;
    final poMatch = RegExp(r'PO ([^\s]+) untuk').firstMatch(n.body);
    if (poMatch != null) params['poNo'] = poMatch.group(1)!;
    return NotificationText.key('${t.key}Body', params: params);
  }
}
