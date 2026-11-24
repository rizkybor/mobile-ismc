// Tahap 5 — detail order terhadap Firebase Emulator (seed CSMS).
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ism_customer/core/config/env.dart';
import 'package:ism_customer/data/firebase.dart';
import 'package:ism_customer/data/orders_repository.dart';
import 'package:ism_customer/domain/order_tracking.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Akun seed emulator — bukan kredensial nyata.
const seedEmail = 'ops@samudra.example.com';
const seedPassword = 'Cust#2026!';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late OrdersRepository repo;

  setUpAll(() async {
    expect(Env.useEmulator, isTrue);
    expect(await initFirebase(), isTrue);
    repo = OrdersRepository(
      FirebaseFirestore.instance,
      await SharedPreferences.getInstance(),
    );
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: seedEmail,
      password: seedPassword,
    );
  });

  tearDownAll(() => FirebaseAuth.instance.signOut());

  testWidgets(
    'order milik sendiri (o6) terbaca langsung; tracking sesuai web',
    (tester) async {
      final o = await repo.fetchOrder('o6');
      expect(o, isNotNull);
      expect(o!.ordersNo, 'OR/20261121/006');
      expect(o.poNumber, 'PO-2611-77');
      expect(o.pdfFiles['quotation']?.docId, 'qtn1');
      final t = OrderTrackingRules.buildTracking(o);
      expect(t.steps[3].state, TrackState.done);
      expect(t.steps[4].state, TrackState.current);
      expect(t.steps[2].note.params['no'], 'QTN-2611-0001');
    },
  );

  testWidgets('order customer lain (o3) → null (ditolak rules)', (
    tester,
  ) async {
    expect(await repo.fetchOrder('o3'), isNull);
  });

  testWidgets('id tidak ada → null', (tester) async {
    expect(await repo.fetchOrder('tidak-ada'), isNull);
  });
}
