import '../../core/i18n/l10n.dart';
import '../../domain/auth_rules.dart';

/// Peta [AuthErrorKind] → teks l10n (teks ID disalin dari CSMS
/// `helper/authErrors.js`).
String authErrorText(AppLocalizations l10n, Object error) {
  final kind = error is AuthFailure ? error.kind : AuthErrorKind.unknown;
  return switch (kind) {
    AuthErrorKind.invalidEmail => l10n.authErrorInvalidEmail,
    AuthErrorKind.wrongCredentials => l10n.authErrorWrongCredentials,
    AuthErrorKind.userDisabled => l10n.authErrorUserDisabled,
    AuthErrorKind.tooManyRequests => l10n.authErrorTooManyRequests,
    AuthErrorKind.network => l10n.authErrorNetwork,
    AuthErrorKind.emailInUse => l10n.authErrorEmailInUse,
    AuthErrorKind.weakPassword => l10n.authErrorWeakPassword,
    AuthErrorKind.passwordRequirements => l10n.authErrorPasswordRequirements,
    AuthErrorKind.requiresRecentLogin => l10n.authErrorRequiresRecentLogin,
    AuthErrorKind.notRegistered => l10n.authErrorNotRegistered,
    AuthErrorKind.notCustomer => l10n.authErrorNotCustomer,
    AuthErrorKind.accountDisabled => l10n.authErrorAccountDisabled,
    AuthErrorKind.usernameTaken => l10n.authErrorUsernameTaken,
    AuthErrorKind.unknown => l10n.authErrorGeneric,
  };
}
