import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/features/auth/screens/auth_screens.dart';
import 'package:ism_customer/features/auth/session_controller.dart';

import 'test_app.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('validasi wajib isi & format email', (tester) async {
      final c = await makeContainer(session: const Session.signedOut());
      await tester.pumpWidget(wrapScreen(c, const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.pumpAndSettle();
      expect(find.text('Wajib diisi.'), findsNWidgets(2));

      await tester.enterText(find.byType(TextFormField).first, 'bukan-email');
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.pumpAndSettle();
      expect(find.text('Format email tidak valid.'), findsOneWidget);
    });

    testWidgets('teks EN', (tester) async {
      final c = await makeContainer(session: const Session.signedOut());
      await tester.pumpWidget(
        wrapScreen(c, const LoginScreen(), locale: const Locale('en')),
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
    });
  });

  group('RegisterScreen', () {
    testWidgets('checklist password berubah saat mengetik', (tester) async {
      final c = await makeContainer(session: const Session.signedOut());
      await tester.pumpWidget(wrapScreen(c, const RegisterScreen()));
      await tester.pumpAndSettle();

      Finder okIcons() => find.byIcon(Icons.check_circle_rounded);
      expect(okIcons(), findsNothing);

      final passwordField = find.byType(TextFormField).at(3);
      await tester.enterText(passwordField, 'Cust#2026!');
      await tester.pumpAndSettle();
      expect(okIcons(), findsNWidgets(4));
      expect(find.byType(PasswordChecklist), findsOneWidget);
    });

    testWidgets('password tidak sama & username tidak valid', (tester) async {
      final c = await makeContainer(session: const Session.signedOut());
      await tester.pumpWidget(wrapScreen(c, const RegisterScreen()));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Ops');
      await tester.enterText(fields.at(1), 'ops samudra');
      await tester.enterText(fields.at(2), 'ops@samudra.example.com');
      await tester.enterText(fields.at(3), 'Cust#2026!');
      await tester.enterText(fields.at(4), 'Beda#2026!');
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Daftar'));
      await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
      await tester.pumpAndSettle();
      expect(find.text('Password tidak sama.'), findsOneWidget);
      expect(
        find.text('Tanpa spasi; hanya huruf, angka, titik, - atau _.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('ForgotPasswordScreen validasi email', (tester) async {
    final c = await makeContainer(session: const Session.signedOut());
    await tester.pumpWidget(wrapScreen(c, const ForgotPasswordScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Kirim tautan'));
    await tester.pumpAndSettle();
    expect(find.text('Wajib diisi.'), findsOneWidget);
  });
}
