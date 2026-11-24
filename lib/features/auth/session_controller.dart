import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/auth_repository.dart';
import '../../data/documents_repository.dart';
import '../../data/firebase_providers.dart';
import '../../domain/app_user.dart';
import '../../domain/auth_rules.dart';
import '../notifications/push_service.dart';

/// Status sesi untuk guard navigasi (PRD §3).
enum SessionStatus { loading, signedOut, needsVerification, ready }

@immutable
class Session {
  const Session._(this.status, {this.user, this.pendingEmail, this.lastError});
  const Session.loading() : this._(SessionStatus.loading);
  const Session.signedOut({AuthFailure? error})
    : this._(SessionStatus.signedOut, lastError: error);
  const Session.needsVerification(String email)
    : this._(SessionStatus.needsVerification, pendingEmail: email);
  const Session.ready(AppUser user) : this._(SessionStatus.ready, user: user);

  final SessionStatus status;
  final AppUser? user;

  /// Email akun yang menunggu verifikasi.
  final String? pendingEmail;

  /// Alasan sesi tersimpan ditolak saat aplikasi dibuka (akun nonaktif, dsb.).
  final AuthFailure? lastError;

  bool get isReady => status == SessionStatus.ready;
}

/// Sumber kebenaran sesi: mendengarkan `userChanges()` Firebase Auth dan
/// memvalidasi dokumen `users` setiap kali ada pengguna (termasuk sesi
/// tersimpan saat aplikasi dibuka). Tahap 1 memakai stub; ini versi nyata.
class SessionController extends Notifier<Session> {
  StreamSubscription<User?>? _sub;

  /// Selama alur masuk/daftar berjalan, event stream diabaikan agar tidak
  /// terjadi validasi ganda / redirect prematur.
  bool _busy = false;

  @override
  Session build() {
    if (!ref.watch(firebaseReadyProvider)) return const Session.signedOut();
    final repo = ref.watch(authRepositoryProvider);
    _sub?.cancel();
    _sub = repo.userChanges.listen(_onUserChanged);
    ref.onDispose(() => _sub?.cancel());
    return const Session.loading();
  }

  Future<void> _onUserChanged(User? user) async {
    if (_busy) return;
    if (user == null) {
      if (state.status != SessionStatus.signedOut) {
        state = const Session.signedOut();
      }
      return;
    }
    // Sudah tervalidasi untuk uid yang sama → cukup perbarui data ringan.
    if (state.isReady && state.user?.uid == user.uid) return;
    try {
      _apply(await ref.read(authRepositoryProvider).validateCurrentUser(user));
    } on AuthFailure catch (e) {
      state = Session.signedOut(error: e);
    } on Object catch (e) {
      debugPrint('[session] validasi gagal: $e');
      state = const Session.signedOut(
        error: AuthFailure(AuthErrorKind.unknown),
      );
    }
  }

  void _apply(SignInResult result) {
    state = switch (result) {
      SignInReady(:final user) => Session.ready(user),
      SignInNeedsVerification(:final email) => Session.needsVerification(email),
    };
    if (result is SignInReady) {
      // Fase 2: daftarkan token push (tidak berbuat apa-apa bila PUSH_ENABLED=false).
      unawaited(ref.read(pushServiceProvider).register(result.user));
    }
  }

  Future<void> signIn(String email, String password) async {
    _busy = true;
    try {
      _apply(await ref.read(authRepositoryProvider).signIn(email, password));
    } finally {
      _busy = false;
    }
  }

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    _busy = true;
    try {
      await ref
          .read(authRepositoryProvider)
          .register(
            name: name,
            username: username,
            email: email,
            password: password,
          );
      state = const Session.signedOut();
    } finally {
      _busy = false;
    }
  }

  /// "Saya sudah verifikasi": muat ulang user; bila sudah terverifikasi,
  /// lanjutkan validasi dokumen `users`. Mengembalikan `true` bila berhasil.
  Future<bool> refreshVerification() async {
    _busy = true;
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.reloadUser();
      if (user == null) {
        state = const Session.signedOut();
        return false;
      }
      if (!user.emailVerified) return false;
      _apply(await repo.validateCurrentUser(user));
      return state.isReady;
    } finally {
      _busy = false;
    }
  }

  Future<void> resendVerification() =>
      ref.read(authRepositoryProvider).resendVerification();

  Future<void> signOut() async {
    _busy = true;
    try {
      await ref.read(pushServiceProvider).unregister();
      await ref.read(authRepositoryProvider).signOut();
      // Cache lokal milik sesi (ringkasan order dsb.) dibersihkan di sini;
      // pilihan bahasa `app.language` sengaja dipertahankan.
      final prefs = await SharedPreferences.getInstance();
      for (final k in prefs.getKeys().where((k) => k.startsWith('cache.'))) {
        await prefs.remove(k);
      }
      await ref
          .read(documentsRepositoryProvider)
          .clearCache()
          .catchError((_) {});
      state = const Session.signedOut();
    } finally {
      _busy = false;
    }
  }

  /// Perbarui foto di sesi setelah tersimpan di Firestore.
  void setPhoto(String photoUrl) {
    final u = state.user;
    if (u != null) state = Session.ready(u.copyWith(photoUrl: photoUrl));
  }

  /// Hapus akun lalu bersihkan sesi & cache (F-07.4).
  Future<bool> deleteAccount(String password) async {
    final u = state.user;
    if (u == null) return false;
    _busy = true;
    try {
      final marked = await ref
          .read(authRepositoryProvider)
          .deleteAccount(
            password: password,
            username: u.username,
            name: u.name,
          );
      await ref.read(pushServiceProvider).unregister();
      final prefs = await SharedPreferences.getInstance();
      for (final k in prefs.getKeys().where((k) => k.startsWith('cache.'))) {
        await prefs.remove(k);
      }
      await ref
          .read(documentsRepositoryProvider)
          .clearCache()
          .catchError((_) {});
      state = const Session.signedOut();
      return marked;
    } finally {
      _busy = false;
    }
  }

  /// Hapus pesan galat sesi tersimpan setelah ditampilkan.
  void clearError() {
    if (state.lastError != null) state = const Session.signedOut();
  }
}

final sessionProvider = NotifierProvider<SessionController, Session>(
  SessionController.new,
);

/// Turunan ringan untuk router & splash.
final sessionStatusProvider = Provider<SessionStatus>(
  (ref) => ref.watch(sessionProvider).status,
);
