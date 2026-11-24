// Login Google terhadap Firebase Auth Emulator (ID token JSON palsu).
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ism_customer/core/config/env.dart';
import 'package:ism_customer/data/auth_repository.dart';
import 'package:ism_customer/data/firebase.dart';
import 'package:ism_customer/data/google_credential_source.dart';
import 'package:ism_customer/data/users_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late AuthRepository auth;
  late UsersRepository users;

  setUpAll(() async {
    expect(Env.useEmulator, isTrue);
    expect(await initFirebase(), isTrue);
    users = UsersRepository(FirebaseFirestore.instance);
    auth = AuthRepository(FirebaseAuth.instance, users);
  });

  tearDown(() async => FirebaseAuth.instance.signOut());

  testWidgets(
    'akun Google baru → users doc createdBy Google, roles/{uid}, login ulang dikenali',
    (tester) async {
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final src = FakeGoogleCredentialSource(
        email: 'google.$stamp@example.com',
        displayName: 'Budi Santoso',
        googleId: 'g-$stamp',
      );
      final r = await auth.signInWithGoogle(src);
      expect(r, isA<SignInReady>());
      final u = (r! as SignInReady).user;
      expect(u.username, 'Budi');
      expect(u.name, 'Budi Santoso');
      final found = await users.findByEmail(src.email);
      expect(found, isNotNull);
      expect(found!.$2['createdBy'], 'Google');
      expect(found.$2['userId'], u.uid);
      expect(
        (await FirebaseFirestore.instance.doc('roles/${u.uid}').get()).exists,
        isTrue,
      );

      await FirebaseAuth.instance.signOut();
      final again = await auth.signInWithGoogle(src);
      expect((again! as SignInReady).user.uid, u.uid);
    },
  );

  testWidgets(
    'email seed (akun password) masuk lewat Google → profil seed dikenali',
    (tester) async {
      const src = FakeGoogleCredentialSource(
        email: 'ops@samudra.example.com',
        displayName: 'Ops Samudra',
        googleId: 'g-seed',
      );
      final r = await auth.signInWithGoogle(src);
      expect(r, isA<SignInReady>());
      expect((r! as SignInReady).user.username, 'samudra.ops');
    },
  );

  testWidgets(
    'email akun Staff lewat Google → ditolak bukan customer & keluar',
    (tester) async {
      const src = FakeGoogleCredentialSource(
        email: 'staff@ism.id',
        displayName: 'Dimas Saputra',
        googleId: 'g-staff',
      );
      await expectLater(
        auth.signInWithGoogle(src),
        throwsA(
          isA<Object>().having(
            (e) => e.toString(),
            'kind',
            contains('notCustomer'),
          ),
        ),
      );
      expect(FirebaseAuth.instance.currentUser, isNull);
    },
  );
}
