/// Aturan autentikasi — port dari CSMS `Register_Customers_view.vue`,
/// `Login_Customers_view.vue`, `helper/accounts.js`, `helper/authErrors.js`.
/// Murni Dart, tanpa Firebase.
library;

/// Hasil pemeriksaan password (ditampilkan sebagai checklist di form).
class PasswordChecks {
  const PasswordChecks({
    required this.minLength,
    required this.upperAndLower,
    required this.digit,
    required this.symbol,
  });

  final bool minLength;
  final bool upperAndLower;
  final bool digit;
  final bool symbol;

  bool get isValid => minLength && upperAndLower && digit && symbol;
}

abstract final class AuthRules {
  static final _username = RegExp(r'^[A-Za-z0-9._-]+$');
  static final _email = RegExp(r'.+@.+\..+');
  static final _symbol = RegExp(r'[!@#$%^&*]');

  /// Syarat sama dengan web: 8+ karakter, huruf besar & kecil, angka,
  /// simbol `!@#$%^&*`.
  static PasswordChecks validatePassword(String password) => PasswordChecks(
    minLength: password.length >= 8,
    upperAndLower:
        password.contains(RegExp('[a-z]')) &&
        password.contains(RegExp('[A-Z]')),
    digit: password.contains(RegExp('[0-9]')),
    symbol: password.contains(_symbol),
  );

  static bool isPasswordValid(String password) =>
      validatePassword(password).isValid;

  /// Username = ID dokumen `users/{username}`: tanpa spasi; huruf, angka,
  /// titik, `-`, `_`.
  static bool validateUsername(String username) =>
      username.isNotEmpty && _username.hasMatch(username);

  static bool validateEmail(String email) => _email.hasMatch(email.trim());

  /// Username untuk akun Google baru: nama depan (web: `given_name`),
  /// fallback bagian lokal email; dibersihkan agar lolos aturan username.
  static String usernameFromGoogle({
    required String displayName,
    required String email,
  }) {
    final first = displayName.trim().split(RegExp(r'\s+')).first;
    final base = first.isNotEmpty ? first : email.split('@').first;
    final clean = base.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '');
    return clean.isEmpty ? 'customer' : clean;
  }

  /// Role customer ditulis `customer` atau `Customer` di data lama.
  static bool isCustomerRole(Object? role) =>
      role is String && role.trim().toLowerCase() == 'customer';
}

/// Jenis kegagalan auth yang dipahami aplikasi (dipetakan ke teks l10n).
enum AuthErrorKind {
  invalidEmail,
  wrongCredentials,
  userDisabled,
  tooManyRequests,
  network,
  emailInUse,
  weakPassword,
  passwordRequirements,
  requiresRecentLogin,
  notRegistered,
  notCustomer,
  accountDisabled,
  usernameTaken,
  googleUnverified,
  googleNotConfigured,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.kind, {this.code});
  final AuthErrorKind kind;
  final String? code;

  @override
  String toString() => 'AuthFailure($kind${code == null ? '' : ', $code'})';
}

abstract final class AuthErrorMapper {
  static const _byCode = <String, AuthErrorKind>{
    'invalid-email': AuthErrorKind.invalidEmail,
    'user-not-found': AuthErrorKind.wrongCredentials,
    'wrong-password': AuthErrorKind.wrongCredentials,
    'invalid-credential': AuthErrorKind.wrongCredentials,
    'invalid-login-credentials': AuthErrorKind.wrongCredentials,
    'user-disabled': AuthErrorKind.userDisabled,
    'too-many-requests': AuthErrorKind.tooManyRequests,
    'network-request-failed': AuthErrorKind.network,
    'email-already-in-use': AuthErrorKind.emailInUse,
    'weak-password': AuthErrorKind.weakPassword,
    'password-does-not-meet-requirements': AuthErrorKind.passwordRequirements,
    'requires-recent-login': AuthErrorKind.requiresRecentLogin,
  };

  /// Kode mentah yang kadang muncul di `message` (CSMS `RAW_CODES`).
  static const _byRawMessage = <String, AuthErrorKind>{
    'INVALID_LOGIN_CREDENTIALS': AuthErrorKind.wrongCredentials,
    'INVALID_PASSWORD': AuthErrorKind.wrongCredentials,
    'EMAIL_NOT_FOUND': AuthErrorKind.wrongCredentials,
    'USER_DISABLED': AuthErrorKind.userDisabled,
    'EMAIL_EXISTS': AuthErrorKind.emailInUse,
  };

  /// [code] dari `FirebaseAuthException.code` (dengan atau tanpa prefiks
  /// `auth/`), [message] opsional untuk kode mentah.
  static AuthErrorKind fromCode(String? code, {String? message}) {
    final c = (code ?? '').replaceFirst('auth/', '');
    final k = _byCode[c];
    if (k != null) return k;
    if (message != null) {
      for (final e in _byRawMessage.entries) {
        if (message.contains(e.key)) return e.value;
      }
    }
    return AuthErrorKind.unknown;
  }
}
