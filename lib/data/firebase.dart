import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../core/config/env.dart';

/// Inisialisasi Firebase dari variabel `--dart-define` (bukan
/// `firebase_options.dart`) dan, bila diminta, arahkan ke Emulator Suite.
/// Mengembalikan `false` bila konfigurasi tidak tersedia (mis. saat test).
Future<bool> initFirebase() async {
  if (!Env.isFirebaseConfigured) {
    debugPrint('[firebase] tidak dikonfigurasi — lewati inisialisasi');
    return false;
  }

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: Env.firebaseApiKey,
      appId: Env.firebaseAppId,
      messagingSenderId: Env.firebaseMessagingSenderId,
      projectId: Env.firebaseProjectId,
      storageBucket: Env.firebaseStorageBucket,
    ),
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  if (Env.useEmulator) {
    final host = Env.emulatorHost;
    await FirebaseAuth.instance.useAuthEmulator(host, Env.authEmulatorPort);
    FirebaseFirestore.instance.useFirestoreEmulator(
      host,
      Env.firestoreEmulatorPort,
    );
    debugPrint(
      '[firebase] emulator $host:${Env.authEmulatorPort}/'
      '${Env.firestoreEmulatorPort}',
    );
  }
  return true;
}
