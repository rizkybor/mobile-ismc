// Tahap 2 — alur autentikasi terhadap Firebase Emulator (seed CSMS).
//   flutter test integration_test/auth_emulator_test.dart -d <device> \
//     --dart-define-from-file=env/dev.json
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ism_customer/core/config/env.dart';
import 'package:ism_customer/data/auth_repository.dart';
import 'package:ism_customer/data/firebase.dart';
import 'package:ism_customer/data/users_repository.dart';
import 'package:ism_customer/domain/auth_rules.dart';

// Akun seed emulator (repo CSMS qa/automation/seed/seed.mjs) — bukan kredensial nyata.
const seedCustomer = ('ops@samudra.example.com', 'Cust#2026!');
const seedStaff = ('staff@ism.id', 'Staff#2026!');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AuthRepository repo;

  setUpAll(() async {
    expect(Env.useEmulator, isTrue);
    expect(await initFirebase(), isTrue);
    repo = AuthRepository(
      FirebaseAuth.instance,
      UsersRepository(FirebaseFirestore.instance),
    );
  });

  tearDown(() async => FirebaseAuth.instance.signOut());

  testWidgets('akun customer seed → SignInReady dengan data users', (
    tester,
  ) async {
    final r = await repo.signIn(seedCustomer.$1, seedCustomer.$2);
    expect(r, isA<SignInReady>());
    final u = (r as SignInReady).user;
    expect(u.email, seedCustomer.$1);
    expect(u.username, 'samudra.ops');
    expect(AuthRules.isCustomerRole(u.role), isTrue);
    // roles/{uid} ada (dibuat seed atau ensureCustomerRole)
    final role = await FirebaseFirestore.instance.doc('roles/${u.uid}').get();
    expect(role.exists, isTrue);
  });

  testWidgets('akun Staff ditolak "bukan akun customer" dan keluar', (
    tester,
  ) async {
    await expectLater(
      repo.signIn(seedStaff.$1, seedStaff.$2),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.kind,
          'kind',
          AuthErrorKind.notCustomer,
        ),
      ),
    );
    expect(FirebaseAuth.instance.currentUser, isNull);
  });

  testWidgets('password salah → wrongCredentials', (tester) async {
    await expectLater(
      repo.signIn(seedCustomer.$1, 'salah'),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.kind,
          'kind',
          AuthErrorKind.wrongCredentials,
        ),
      ),
    );
  });

  testWidgets('daftar akun baru: users & roles terbentuk, lalu keluar', (
    tester,
  ) async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final username = 'mobile.test.$stamp';
    final email = 'mobile.test.$stamp@example.com';
    await repo.register(
      name: 'Mobile Test',
      username: username,
      email: email,
      password: 'Mobile#2026!',
    );
    expect(
      FirebaseAuth.instance.currentUser,
      isNull,
      reason: 'signOut setelah daftar',
    );

    // Email belum diverifikasi → masuk menghasilkan SignInNeedsVerification
    final r = await repo.signIn(email, 'Mobile#2026!');
    expect(r, isA<SignInNeedsVerification>());
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance
        .doc('users/$username')
        .get();
    expect(userDoc.data()?['role'], 'customer');
    expect(userDoc.data()?['createdBy'], 'Customer');
    expect(userDoc.data()?['userId'], uid);
    final roleDoc = await FirebaseFirestore.instance.doc('roles/$uid').get();
    expect(roleDoc.data()?['role'], 'customer');

    // Username yang sama ditolak (rules: get ditolak = sudah dipakai)
    await expectLater(
      repo.register(
        name: 'X',
        username: username,
        email: 'lain.$stamp@example.com',
        password: 'Mobile#2026!',
      ),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.kind,
          'kind',
          AuthErrorKind.usernameTaken,
        ),
      ),
    );
  });
}
