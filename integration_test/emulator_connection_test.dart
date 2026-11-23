// Bukti koneksi ke Firebase Emulator (Tahap 1, kriteria selesai #2).
// Jalankan dengan emulator CSMS aktif & sudah di-seed:
//   flutter test integration_test/emulator_connection_test.dart \
//     -d <device> --dart-define-from-file=env/dev.json
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ism_customer/core/config/env.dart';
import 'package:ism_customer/data/firebase.dart';
import 'package:ism_customer/data/orders_repository.dart';

// Akun seed emulator (repo CSMS qa/automation/seed/seed.mjs) — bukan kredensial nyata.
const seedEmail = 'ops@samudra.example.com';
const seedPassword = 'Cust#2026!';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login akun seed & membaca orders miliknya dari emulator', (
    tester,
  ) async {
    expect(
      Env.useEmulator,
      isTrue,
      reason: 'pakai env/dev.json (USE_EMULATOR)',
    );
    final ready = await initFirebase();
    expect(ready, isTrue);

    final auth = FirebaseAuth.instance;
    await auth.signInWithEmailAndPassword(
      email: seedEmail,
      password: seedPassword,
    );
    expect(auth.currentUser?.email, seedEmail);

    final repo = OrdersRepository(FirebaseFirestore.instance);
    final orders = await repo.fetchCustomerOrders(seedEmail);
    // Seed CSMS membuat beberapa order untuk PT Samudra Bahari Lines.
    expect(orders, isNotEmpty);
    for (final o in orders) {
      expect(o['customerEmail'], seedEmail);
      expect(o['isDeleted'], isFalse);
    }
    // ignore: avoid_print
    print('[integration] orders terbaca: ${orders.length}');
    await auth.signOut();
  });
}
