// Tahap 8 — ganti password & hapus akun terhadap Firebase Emulator.
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ism_customer/core/config/env.dart';
import 'package:ism_customer/data/auth_repository.dart';
import 'package:ism_customer/data/firebase.dart';
import 'package:ism_customer/data/users_repository.dart';
import 'package:ism_customer/domain/auth_rules.dart';

Future<void> markEmailVerified(String uid) async {
  final client = HttpClient();
  final req = await client.postUrl(
    Uri.parse(
      'http://${Env.emulatorHost}:${Env.authEmulatorPort}/identitytoolkit.googleapis.com/v1/accounts:update',
    ),
  );
  req.headers.set('Authorization', 'Bearer owner');
  req.headers.contentType = ContentType.json;
  req.write(jsonEncode({'localId': uid, 'emailVerified': true}));
  expect((await req.close()).statusCode, 200);
  client.close();
}

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

  testWidgets('foto profil, ganti password, lalu hapus akun → login gagal', (
    tester,
  ) async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final username = 'profil.$stamp';
    final email = 'profil.$stamp@example.com';
    const pw1 = 'Profil#2026!';
    const pw2 = 'Baru#2026!!';
    await auth.register(
      name: 'Profil Test',
      username: username,
      email: email,
      password: pw1,
    );
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: pw1,
    );
    await markEmailVerified(cred.user!.uid);
    await FirebaseAuth.instance.signOut();
    final r = await auth.signIn(email, pw1);
    expect(r, isA<SignInReady>());

    // F-07.2 foto (rules: hanya photoURL/updatedAt/updatedBy)
    await users.updatePhoto(
      username: username,
      photoDataUrl: 'data:image/jpeg;base64,AAAA',
      updatedBy: 'Profil Test',
    );
    expect(
      (await users.findByUid(cred.user!.uid))?['photoURL'],
      'data:image/jpeg;base64,AAAA',
    );

    // F-07.3 ganti password: password lama salah ditolak, lalu berhasil
    await expectLater(
      auth.changePassword(currentPassword: 'salah', newPassword: pw2),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.kind,
          'kind',
          AuthErrorKind.wrongCredentials,
        ),
      ),
    );
    await auth.changePassword(currentPassword: pw1, newPassword: pw2);
    await FirebaseAuth.instance.signOut();
    expect(await auth.signIn(email, pw2), isA<SignInReady>());

    // F-07.4 hapus akun
    final marked = await auth.deleteAccount(
      password: pw2,
      username: username,
      name: 'Profil Test',
    );
    // Rules CSMS saat ini belum mengizinkan deletionRequestedAt → false (PRD §12)
    expect(marked, isFalse);
    expect(FirebaseAuth.instance.currentUser, isNull);
    await expectLater(
      auth.signIn(email, pw2),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.kind,
          'kind',
          AuthErrorKind.wrongCredentials,
        ),
      ),
    );
  });
}
