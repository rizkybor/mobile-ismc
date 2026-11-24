import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/notification_models.dart';
import 'firebase_providers.dart';

/// Koleksi `notifications` (PRD §6, F-06). Query **tanpa** orderBy/limit
/// (rules); urut & batasi di aplikasi. Update hanya `readBy` dengan uid
/// sendiri (`arrayUnion`).
class NotificationsRepository {
  NotificationsRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('notifications');

  Stream<List<AppNotification>> watchForEmail(String email) => _col
      .where('customerEmail', isEqualTo: email)
      .snapshots()
      .map(
        (s) => NotificationRules.prepare(
          s.docs.map((d) => AppNotification.fromMap(d.id, d.data())),
        ),
      );

  Future<void> markRead(String id, String uid) => _col.doc(id).update({
    'readBy': FieldValue.arrayUnion([uid]),
  });

  /// Batch kecil (≤ 400 per commit) untuk "Tandai semua dibaca".
  Future<void> markAllRead(Iterable<String> ids, String uid) async {
    final list = ids.toList();
    for (var i = 0; i < list.length; i += 400) {
      final batch = _db.batch();
      for (final id in list.sublist(i, (i + 400).clamp(0, list.length))) {
        batch.update(_col.doc(id), {
          'readBy': FieldValue.arrayUnion([uid]),
        });
      }
      await batch.commit();
    }
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(ref.watch(firestoreProvider)),
);
