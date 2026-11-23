import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/domain/auth_rules.dart';

void main() {
  group('validatePassword (sama dengan PASSWORD_PATTERN web)', () {
    test('valid', () {
      final c = AuthRules.validatePassword('Cust#2026!');
      expect(c.minLength, isTrue);
      expect(c.upperAndLower, isTrue);
      expect(c.digit, isTrue);
      expect(c.symbol, isTrue);
      expect(c.isValid, isTrue);
    });
    test('kurang dari 8', () {
      expect(AuthRules.validatePassword('Ab1!').minLength, isFalse);
      expect(AuthRules.isPasswordValid('Ab1!'), isFalse);
    });
    test('tanpa huruf besar', () {
      expect(AuthRules.validatePassword('password1!').upperAndLower, isFalse);
    });
    test('tanpa angka', () {
      expect(AuthRules.validatePassword('Password!!').digit, isFalse);
    });
    test('simbol di luar !@#\$%^&* tidak dihitung', () {
      expect(AuthRules.validatePassword('Password1.').symbol, isFalse);
      expect(AuthRules.validatePassword('Password1*').symbol, isTrue);
    });
  });

  group('validateUsername', () {
    test('huruf, angka, titik, -, _', () {
      expect(AuthRules.validateUsername('samudra.ops'), isTrue);
      expect(AuthRules.validateUsername('user_01-x'), isTrue);
    });
    test('spasi / kosong / karakter lain ditolak', () {
      expect(AuthRules.validateUsername('ops samudra'), isFalse);
      expect(AuthRules.validateUsername(''), isFalse);
      expect(AuthRules.validateUsername('ops@x'), isFalse);
    });
  });

  group('validateEmail', () {
    test('format dasar', () {
      expect(AuthRules.validateEmail('ops@samudra.example.com'), isTrue);
      expect(AuthRules.validateEmail(' a@b.co '), isTrue);
      expect(AuthRules.validateEmail('ops@samudra'), isFalse);
      expect(AuthRules.validateEmail(''), isFalse);
    });
  });

  group('isCustomerRole', () {
    test('customer & Customer diterima, lainnya ditolak', () {
      expect(AuthRules.isCustomerRole('customer'), isTrue);
      expect(AuthRules.isCustomerRole('Customer'), isTrue);
      expect(AuthRules.isCustomerRole('Staff'), isFalse);
      expect(AuthRules.isCustomerRole(null), isFalse);
      expect(AuthRules.isCustomerRole(1), isFalse);
    });
  });

  group('AuthErrorMapper', () {
    test('kode Firebase dengan/tanpa prefiks auth/', () {
      expect(
        AuthErrorMapper.fromCode('wrong-password'),
        AuthErrorKind.wrongCredentials,
      );
      expect(
        AuthErrorMapper.fromCode('auth/invalid-credential'),
        AuthErrorKind.wrongCredentials,
      );
      expect(
        AuthErrorMapper.fromCode('user-not-found'),
        AuthErrorKind.wrongCredentials,
      );
      expect(
        AuthErrorMapper.fromCode('too-many-requests'),
        AuthErrorKind.tooManyRequests,
      );
      expect(
        AuthErrorMapper.fromCode('network-request-failed'),
        AuthErrorKind.network,
      );
      expect(
        AuthErrorMapper.fromCode('email-already-in-use'),
        AuthErrorKind.emailInUse,
      );
      expect(
        AuthErrorMapper.fromCode('weak-password'),
        AuthErrorKind.weakPassword,
      );
      expect(
        AuthErrorMapper.fromCode('invalid-email'),
        AuthErrorKind.invalidEmail,
      );
      expect(
        AuthErrorMapper.fromCode('user-disabled'),
        AuthErrorKind.userDisabled,
      );
    });
    test('kode mentah di message', () {
      expect(
        AuthErrorMapper.fromCode(
          'unknown',
          message: '{"error":"INVALID_LOGIN_CREDENTIALS"}',
        ),
        AuthErrorKind.wrongCredentials,
      );
      expect(
        AuthErrorMapper.fromCode(null, message: 'EMAIL_EXISTS'),
        AuthErrorKind.emailInUse,
      );
    });
    test('tidak dikenal → unknown', () {
      expect(AuthErrorMapper.fromCode('something-else'), AuthErrorKind.unknown);
      expect(AuthErrorMapper.fromCode(null), AuthErrorKind.unknown);
    });
  });
}
