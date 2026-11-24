import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/env.dart';
import 'google_credential_source.dart';

/// `true` bila [initFirebase] berhasil; di-override dari `main()`.
final firebaseReadyProvider = Provider<bool>((_) => false);

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (_) => FirebaseAuth.instance,
);
final firestoreProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);

/// Google asli bila dikonfigurasi; palsu untuk Emulator saat pengembangan.
final googleCredentialSourceProvider = Provider<GoogleCredentialSource>(
  (_) => Env.isGoogleConfigured || !Env.useEmulator
      ? GoogleSignInSource()
      : const FakeGoogleCredentialSource(),
);
