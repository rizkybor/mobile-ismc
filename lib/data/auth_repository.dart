import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_user.dart';
import '../domain/auth_rules.dart';
import 'firebase_providers.dart';
import 'google_credential_source.dart';
import 'users_repository.dart';

/// Hasil masuk: sudah tervalidasi, atau email belum diverifikasi.
sealed class SignInResult {
  const SignInResult();
}

class SignInReady extends SignInResult {
  const SignInReady(this.user);
  final AppUser user;
}

class SignInNeedsVerification extends SignInResult {
  const SignInNeedsVerification(this.email);
  final String email;
}

/// Alur Firebase Auth + validasi dokumen `users` (PRD F-01, flowchart §2–3).
class AuthRepository {
  AuthRepository(this._auth, this._users);

  /// Batas waktu panggilan jaringan auth agar UI tidak menggantung bila
  /// host (mis. emulator di LAN) tidak terjangkau.
  static const networkTimeout = Duration(seconds: 20);
  final FirebaseAuth _auth;
  final UsersRepository _users;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get userChanges => _auth.userChanges();

  /// Daftar: cek username → buat akun → `users/{username}` → `roles/{uid}`
  /// → kirim email verifikasi → keluar (customer masuk lewat form login).
  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    if (await _users.isUsernameTaken(username)) {
      throw const AuthFailure(AuthErrorKind.usernameTaken);
    }
    final UserCredential cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(
        AuthErrorMapper.fromCode(e.code, message: e.message),
        code: e.code,
      );
    }
    final uid = cred.user!.uid;
    try {
      await _users.createCustomerUser(
        uid: uid,
        username: username,
        name: name,
        email: email,
      );
      await _users.ensureCustomerRole(uid, email).catchError((_) {});
      await cred.user!.sendEmailVerification().catchError((_) {});
    } finally {
      await _auth.signOut().catchError((_) {});
    }
  }

  /// Masuk dengan email & password lalu validasi seperti portal web.
  /// Gagal validasi → keluar lagi dan lempar [AuthFailure].
  Future<SignInResult> signIn(String email, String password) async {
    final UserCredential cred;
    try {
      cred = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(networkTimeout);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(
        AuthErrorMapper.fromCode(e.code, message: e.message),
        code: e.code,
      );
    } on TimeoutException {
      throw const AuthFailure(AuthErrorKind.network, code: 'timeout');
    }
    return validateCurrentUser(cred.user!);
  }

  /// Masuk dengan Google (web `loginWithGoogle`): tukar ID token →
  /// Firebase; email wajib terverifikasi; `users where email ==` → buat
  /// dokumen `createdBy: "Google"` bila belum ada, atau validasi role/aktif
  /// dan samakan `userId`. `null` bila pengguna membatalkan.
  Future<SignInResult?> signInWithGoogle(GoogleCredentialSource source) async {
    final g = await source.obtain();
    if (g == null) return null;
    final UserCredential cred;
    try {
      cred = await _auth
          .signInWithCredential(
            GoogleAuthProvider.credential(idToken: g.idToken),
          )
          .timeout(networkTimeout);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(
        AuthErrorMapper.fromCode(e.code, message: e.message),
        code: e.code,
      );
    } on TimeoutException {
      throw const AuthFailure(AuthErrorKind.network, code: 'timeout');
    }
    final user = cred.user!;
    try {
      if (!user.emailVerified) {
        throw const AuthFailure(AuthErrorKind.googleUnverified);
      }
      final uid = user.uid;
      final email = user.email ?? g.email;
      final found = await _users.findByEmail(email);
      final AppUser appUser;
      if (found == null) {
        final username = AuthRules.usernameFromGoogle(
          displayName: g.displayName,
          email: email,
        );
        await _users.createGoogleUser(
          uid: uid,
          name: g.displayName.isEmpty ? username : g.displayName,
          username: username,
          email: email,
          photoUrl: g.photoUrl,
        );
        appUser = AppUser(
          uid: uid,
          username: username,
          name: g.displayName.isEmpty ? username : g.displayName,
          email: email,
          role: 'customer',
          photoUrl: g.photoUrl,
        );
      } else {
        final (docId, data) = found;
        if (!AuthRules.isCustomerRole(data['role'])) {
          throw const AuthFailure(AuthErrorKind.notCustomer);
        }
        if (data['isActive'] == false) {
          throw const AuthFailure(AuthErrorKind.accountDisabled);
        }
        if (data['userId'] != uid) {
          await _users.alignUserId(docId, uid: uid, googleId: g.googleId);
        }
        appUser = AppUser.fromMap(uid, data);
      }
      await _users.ensureCustomerRole(uid, email).catchError((_) {});
      return SignInReady(appUser);
    } on AuthFailure {
      await _auth.signOut().catchError((_) {});
      await source.signOut().catchError((_) {});
      rethrow;
    }
  }

  /// Dipakai saat masuk dan saat aplikasi dibuka dengan sesi tersimpan.
  Future<SignInResult> validateCurrentUser(User user) async {
    if (!user.emailVerified) {
      return SignInNeedsVerification(user.email ?? '');
    }
    try {
      final appUser = await _users.loadCustomer(user.uid);
      await _users
          .ensureCustomerRole(user.uid, appUser.email)
          .catchError((_) {});
      return SignInReady(appUser);
    } on AuthFailure {
      await _auth.signOut().catchError((_) {});
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // Pesan ke pengguna selalu netral; hanya galat jaringan yang diteruskan.
      final kind = AuthErrorMapper.fromCode(e.code, message: e.message);
      if (kind == AuthErrorKind.network ||
          kind == AuthErrorKind.tooManyRequests) {
        throw AuthFailure(kind, code: e.code);
      }
    }
  }

  Future<void> resendVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthFailure(AuthErrorKind.unknown);
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(
        AuthErrorMapper.fromCode(e.code, message: e.message),
        code: e.code,
      );
    }
  }

  /// `user.reload()` lalu kembalikan user terbaru (emailVerified bisa berubah).
  Future<User?> reloadUser() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser;
  }

  Future<void> signOut() => _auth.signOut();

  /// Re-autentikasi dengan password saat ini (ganti password, hapus akun).
  Future<User> reauthenticate(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw const AuthFailure(AuthErrorKind.requiresRecentLogin);
    }
    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: password),
      );
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(
        AuthErrorMapper.fromCode(e.code, message: e.message),
        code: e.code,
      );
    }
  }

  /// F-07.3: password lama → `updatePassword` (syarat sama dengan daftar).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!AuthRules.isPasswordValid(newPassword)) {
      throw const AuthFailure(AuthErrorKind.passwordRequirements);
    }
    final user = await reauthenticate(currentPassword);
    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(
        AuthErrorMapper.fromCode(e.code, message: e.message),
        code: e.code,
      );
    }
  }

  /// F-07.4: re-autentikasi → tandai permintaan hapus (bila rules
  /// mengizinkan) → `user.delete()`. Mengembalikan `true` bila penanda
  /// `deletionRequestedAt` berhasil ditulis.
  Future<bool> deleteAccount({
    required String password,
    required String username,
    required String name,
  }) async {
    final user = await reauthenticate(password);
    final marked = await _users.requestDeletion(
      username: username,
      updatedBy: name,
    );
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(
        AuthErrorMapper.fromCode(e.code, message: e.message),
        code: e.code,
      );
    }
    return marked;
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(usersRepositoryProvider),
  ),
);
