import 'dart:io' show Platform;

/// Konfigurasi build yang dibaca dari `--dart-define-from-file=env/<nama>.json`.
/// Lihat `env/example.json`. Tidak ada nilai rahasia yang ditulis di repo.
abstract final class Env {
  static const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );
  static const firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const firebaseAppIdAndroid = String.fromEnvironment(
    'FIREBASE_APP_ID_ANDROID',
  );
  static const firebaseAppIdIos = String.fromEnvironment('FIREBASE_APP_ID_IOS');
  static const firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );
  static const useEmulator = bool.fromEnvironment('USE_EMULATOR');
  static const _emulatorHostOverride = String.fromEnvironment('EMULATOR_HOST');
  static const pushEnabled = bool.fromEnvironment('PUSH_ENABLED');
  static const privacyPolicyUrl = String.fromEnvironment('PRIVACY_POLICY_URL');

  static const authEmulatorPort = 9099;
  static const firestoreEmulatorPort = 8086;

  /// Firebase hanya diinisialisasi bila kunci minimum tersedia.
  static bool get isFirebaseConfigured =>
      firebaseApiKey.isNotEmpty && firebaseProjectId.isNotEmpty;

  /// Host emulator: emulator Android memakai `10.0.2.2` untuk mencapai mesin
  /// host; simulator iOS memakai `localhost`; HP fisik diisi lewat
  /// `EMULATOR_HOST` (IP komputer di jaringan yang sama).
  static String get emulatorHost {
    if (_emulatorHostOverride.isNotEmpty) return _emulatorHostOverride;
    return Platform.isAndroid ? '10.0.2.2' : 'localhost';
  }

  static String get firebaseAppId =>
      Platform.isIOS ? firebaseAppIdIos : firebaseAppIdAndroid;
}
