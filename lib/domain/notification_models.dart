/// Notifikasi in-app (PRD F-06, §6 koleksi `notifications`). Murni Dart.
library;

String _s(Object? v) => v is String ? v : (v == null ? '' : v.toString());

class AppNotification {
  const AppNotification({
    required this.id,
    required this.audience,
    required this.type,
    required this.title,
    required this.body,
    required this.orderId,
    required this.ordersNo,
    required this.readBy,
    required this.createdAt,
    this.key = '',
    this.params = const {},
  });

  final String id;
  final String audience;

  /// order | approval | success | warning | error | info | account.
  final String type;
  final String title;
  final String body;
  final String orderId;
  final String ordersNo;
  final List<String> readBy;

  /// ISO datetime.
  final String createdAt;

  /// (PRD §12 butir 3) kunci & parameter terjemahan bila CSMS sudah
  /// menyediakannya.
  final String key;
  final Map<String, String> params;

  bool isUnreadFor(String uid) => !readBy.contains(uid);

  factory AppNotification.fromMap(String id, Map<String, Object?> m) {
    final rawRead = m['readBy'];
    final rawParams = m['params'];
    return AppNotification(
      id: id,
      audience: _s(m['audience']),
      type: _s(m['type']),
      title: _s(m['title']),
      body: _s(m['body']),
      orderId: _s(m['orderId']),
      ordersNo: _s(m['ordersNo']),
      readBy: rawRead is List ? rawRead.map(_s).toList() : const [],
      createdAt: _s(m['createdAt']),
      key: _s(m['key']),
      params: rawParams is Map
          ? {for (final e in rawParams.entries) _s(e.key): _s(e.value)}
          : const {},
    );
  }
}

abstract final class NotificationRules {
  static const maxShown = 100;

  /// Hanya untuk customer, terbaru di atas (urut di aplikasi — rules tidak
  /// mengizinkan orderBy), dibatasi [maxShown].
  static List<AppNotification> prepare(Iterable<AppNotification> all) {
    final list = all.where((n) => n.audience == 'customer').toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.length > maxShown ? list.sublist(0, maxShown) : list;
  }

  static int unreadCount(Iterable<AppNotification> list, String uid) =>
      list.where((n) => n.isUnreadFor(uid)).length;
}
