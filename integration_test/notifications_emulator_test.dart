// Tahap 7 — notifikasi terhadap Firebase Emulator: customer membuat
// notifikasi untuk dirinya (diizinkan rules), listener menerimanya,
// menandai dibaca (arrayUnion uid), dan rules menolak perubahan lain.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ism_customer/core/config/env.dart';
import 'package:ism_customer/data/firebase.dart';
import 'package:ism_customer/data/notifications_repository.dart';
import 'package:ism_customer/domain/notification_models.dart';

// Akun seed emulator — bukan kredensial nyata.
const seedEmail = 'ops@samudra.example.com';
const seedPassword = 'Cust#2026!';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late NotificationsRepository repo;
  late String uid;

  setUpAll(() async {
    expect(Env.useEmulator, isTrue);
    expect(await initFirebase(), isTrue);
    repo = NotificationsRepository(FirebaseFirestore.instance);
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: seedEmail,
      password: seedPassword,
    );
    uid = cred.user!.uid;
  });

  tearDownAll(() => FirebaseAuth.instance.signOut());

  testWidgets(
    'listener menerima notifikasi baru < 3 dtk, tandai dibaca sinkron',
    (tester) async {
      final stamp = DateTime.now().millisecondsSinceEpoch;
      const title = 'Order diterima';
      final docRef = await FirebaseFirestore.instance
          .collection('notifications')
          .add({
            'audience': 'customer',
            'roles': null,
            'customerId': 'c1',
            'customerEmail': seedEmail,
            'type': 'order',
            'title': title,
            'body': 'Order OR/TEST/$stamp sudah kami terima.',
            'orderId': 'o1',
            'ordersNo': 'OR/TEST/$stamp',
            'link': null,
            'readBy': <String>[],
            'createdAt': DateTime.now().toUtc().toIso8601String(),
            'createdBy': 'Ops Samudra',
            'createdByUid': uid,
          });

      final list = await repo
          .watchForEmail(seedEmail)
          .firstWhere((l) => l.any((n) => n.id == docRef.id))
          .timeout(const Duration(seconds: 3));
      final mine = list.firstWhere((n) => n.id == docRef.id);
      expect(mine.isUnreadFor(uid), isTrue);
      expect(list.first.id, docRef.id, reason: 'terbaru di atas');
      expect(NotificationRules.unreadCount(list, uid), greaterThan(0));

      await repo.markRead(docRef.id, uid);
      final after = await repo
          .watchForEmail(seedEmail)
          .firstWhere(
            (l) => !l.firstWhere((n) => n.id == docRef.id).isUnreadFor(uid),
          )
          .timeout(const Duration(seconds: 3));
      expect(after, isNotEmpty);

      // markAllRead idempoten
      await repo.markAllRead([docRef.id], uid);

      // Rules: mengubah field selain readBy ditolak
      await expectLater(
        docRef.update({'title': 'diubah'}),
        throwsA(
          isA<FirebaseException>().having(
            (e) => e.code,
            'code',
            'permission-denied',
          ),
        ),
      );
    },
  );
}
