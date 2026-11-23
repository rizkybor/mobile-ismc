import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Status sesi untuk guard navigasi. Tahap 1 memakai **stub** (nilai awal
/// `ready` agar 4 tab bisa dilihat); Tahap 2 menggantinya dengan listener
/// `authStateChanges` + validasi dokumen `users`.
enum SessionStatus { loading, signedOut, needsVerification, ready }

class SessionStub extends Notifier<SessionStatus> {
  @override
  SessionStatus build() => SessionStatus.ready;

  // ignore: use_setters_to_change_properties
  void set(SessionStatus status) => state = status;
}

final sessionStatusProvider = NotifierProvider<SessionStub, SessionStatus>(
  SessionStub.new,
);
