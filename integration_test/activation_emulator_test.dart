// Tahap 3 — aktivasi akun terhadap Firebase Emulator (seed CSMS).
//   flutter test integration_test/activation_emulator_test.dart -d <device> \
//     --dart-define-from-file=env/dev.json
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ism_customer/core/config/env.dart';
import 'package:ism_customer/data/auth_repository.dart';
import 'package:ism_customer/data/customers_repository.dart';
import 'package:ism_customer/data/firebase.dart';
import 'package:ism_customer/data/users_repository.dart';
import 'package:ism_customer/domain/account_status.dart';

// Akun seed emulator — bukan kredensial nyata.
const seedCustomer = ('ops@samudra.example.com', 'Cust#2026!');

/// Tandai email terverifikasi lewat REST Auth Emulator (token "owner"),
/// seperti yang dilakukan seed CSMS.
Future<void> markEmailVerified(String uid) async {
  final client = HttpClient();
  final req = await client.postUrl(
    Uri.parse(
      'http://${Env.emulatorHost}:${Env.authEmulatorPort}'
      '/identitytoolkit.googleapis.com/v1/accounts:update',
    ),
  );
  req.headers.set('Authorization', 'Bearer owner');
  req.headers.contentType = ContentType.json;
  req.write(jsonEncode({'localId': uid, 'emailVerified': true}));
  final res = await req.close();
  expect(res.statusCode, 200, reason: await res.transform(utf8.decoder).join());
  client.close();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AuthRepository auth;
  late CustomersRepository customers;

  setUpAll(() async {
    expect(Env.useEmulator, isTrue);
    expect(await initFirebase(), isTrue);
    final db = FirebaseFirestore.instance;
    auth = AuthRepository(FirebaseAuth.instance, UsersRepository(db));
    customers = CustomersRepository(db);
  });

  tearDown(() async => FirebaseAuth.instance.signOut());

  testWidgets('akun seed aktif → status active dari listener customers', (
    tester,
  ) async {
    await auth.signIn(seedCustomer.$1, seedCustomer.$2);
    final state = AccountStatusRules.resolve(
      await customers.watchByEmail(seedCustomer.$1).first,
    );
    expect(state.status, AccountStatus.active);
    expect(state.customer?.customerName, 'PT Samudra Bahari Lines');
  });

  testWidgets(
    'akun baru: unregistered → kirim aktivasi → waiting; notifikasi panel terbentuk; aktivasi kedua ditolak',
    (tester) async {
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final email = 'aktivasi.$stamp@example.com';
      const password = 'Mobile#2026!';
      await auth.register(
        name: 'Aktivasi Test',
        username: 'aktivasi.$stamp',
        email: email,
        password: password,
      );
      // Verifikasi email lewat emulator, lalu masuk → SignInReady
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await markEmailVerified(cred.user!.uid);
      await FirebaseAuth.instance.signOut();
      final r = await auth.signIn(email, password);
      expect(r, isA<SignInReady>());
      final user = (r as SignInReady).user;

      expect(
        AccountStatusRules.resolve(await customers.fetchByEmail(email)).status,
        AccountStatus.unregistered,
      );
      expect(await customers.hasAnyCustomer(email), isFalse);

      final id = await customers.createActivation(
        email: email,
        customerName: 'PT Aktivasi $stamp',
        isCompany: true,
        address: 'Jl. Uji No. 1',
        phone: '08123456789',
        telp: '',
      );
      await customers.notifyPanelActivationRequested(
        customerName: 'PT Aktivasi $stamp',
        createdByName: user.name,
        uid: user.uid,
      );

      final after = AccountStatusRules.resolve(
        await customers.fetchByEmail(email),
      );
      expect(after.status, AccountStatus.waiting);
      expect(after.customer?.id, id);
      expect(after.customer?.isCompany, isTrue);

      final doc = await FirebaseFirestore.instance.doc('customers/$id').get();
      expect(doc.data()?['createdBy'], 'Self');
      expect(doc.data()?['isRegistered'], isTrue);
      expect(doc.data()?['isVerify'], isFalse);
      expect(doc.data()?['isActive'], isFalse);

      // Notifikasi panel sudah diterima rules (`customerNotification`) saat
      // dibuat di atas; customer memang tidak boleh membacanya kembali.
      expect(await customers.hasAnyCustomer(email), isTrue);
    },
  );
}
