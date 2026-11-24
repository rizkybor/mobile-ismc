import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/config/env.dart';
import '../domain/auth_rules.dart';

/// Profil + ID token dari Google (sebelum ditukar ke kredensial Firebase).
class GoogleProfileCredential {
  const GoogleProfileCredential({
    required this.idToken,
    required this.email,
    required this.displayName,
    required this.googleId,
    this.photoUrl = '',
  });

  final String idToken;
  final String email;
  final String displayName;
  final String googleId;
  final String photoUrl;
}

/// Sumber kredensial Google; dipisah agar bisa diganti palsu di emulator/test.
abstract class GoogleCredentialSource {
  /// `null` bila pengguna membatalkan.
  Future<GoogleProfileCredential?> obtain();
  Future<void> signOut();
}

/// Google Sign-In asli (paket `google_sign_in` 7).
class GoogleSignInSource implements GoogleCredentialSource {
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    if (!Env.isGoogleConfigured) {
      throw const AuthFailure(AuthErrorKind.googleNotConfigured);
    }
    await GoogleSignIn.instance.initialize(
      clientId: defaultTargetPlatform == TargetPlatform.iOS
          ? Env.googleClientIdIos
          : null,
      serverClientId: Env.googleServerClientId,
    );
    _initialized = true;
  }

  @override
  Future<GoogleProfileCredential?> obtain() async {
    await _init();
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) throw const AuthFailure(AuthErrorKind.unknown);
      return GoogleProfileCredential(
        idToken: idToken,
        email: account.email,
        displayName: account.displayName ?? '',
        googleId: account.id,
        photoUrl: account.photoUrl ?? '',
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw AuthFailure(AuthErrorKind.unknown, code: 'google/${e.code.name}');
    }
  }

  @override
  Future<void> signOut() async {
    if (_initialized) await GoogleSignIn.instance.signOut();
  }
}

/// Kredensial Google **palsu** untuk Firebase Auth Emulator: emulator
/// menerima ID token berupa JSON tanpa tanda tangan. Hanya dipakai saat
/// `USE_EMULATOR=true` dan Google belum dikonfigurasi (mode pengembangan).
class FakeGoogleCredentialSource implements GoogleCredentialSource {
  const FakeGoogleCredentialSource({
    this.email = 'google.test@example.com',
    this.displayName = 'Google Test',
    this.googleId = 'google-test-0001',
  });

  final String email;
  final String displayName;
  final String googleId;

  @override
  Future<GoogleProfileCredential?> obtain() async => GoogleProfileCredential(
    idToken: jsonEncode({
      'sub': googleId,
      'email': email,
      'email_verified': true,
      'name': displayName,
      'picture': '',
    }),
    email: email,
    displayName: displayName,
    googleId: googleId,
  );

  @override
  Future<void> signOut() async {}
}
