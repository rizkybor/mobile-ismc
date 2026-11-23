import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/app/app.dart';
import 'package:ism_customer/core/i18n/locale_controller.dart';
import 'package:ism_customer/core/i18n/supported_locales.dart';
import 'package:ism_customer/features/auth/screens/auth_screens.dart';
import 'package:ism_customer/features/auth/session_controller.dart';
import 'package:ism_customer/features/splash/splash_screen.dart';
import 'package:ism_customer/shared/widgets/brand_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_app.dart';

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  Session session = const Session.ready(testUser),
}) async {
  final container = await makeContainer(prefs: prefs, session: session);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const IsmCustomerApp(),
    ),
  );
  // Lewati splash (animasi loader berulang tidak pernah "settle").
  await tester.pump();
  await tester.pump(
    SplashScreen.minimumDuration + const Duration(milliseconds: 100),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('splash tampil dulu lalu masuk ke aplikasi', (tester) async {
    final container = await makeContainer();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const IsmCustomerApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('ISM Customer'), findsOneWidget);
    await tester.pump(SplashScreen.minimumDuration);
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('sesi ready: 4 tab dalam Bahasa Indonesia', (tester) async {
    await pumpApp(tester);
    expect(find.text('Beranda'), findsWidgets);
    expect(find.text('Lacak'), findsOneWidget);
    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });

  testWidgets('belum login → Welcome, dan tab tidak bisa diakses', (
    tester,
  ) async {
    await pumpApp(tester, session: const Session.signedOut());
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('email belum diverifikasi → layar verifikasi', (tester) async {
    await pumpApp(tester, session: const Session.needsVerification('x@y.com'));
    expect(find.byType(VerifyEmailScreen), findsOneWidget);
    expect(find.textContaining('x@y.com'), findsOneWidget);
  });

  testWidgets('pilihan bahasa tersimpan dipakai saat dibuka', (tester) async {
    await pumpApp(tester, prefs: {kLanguagePrefKey: 'en'});
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Track'), findsOneWidget);
  });

  testWidgets('ganti bahasa mengubah tab seketika & tersimpan', (tester) async {
    final container = await pumpApp(tester);
    await container
        .read(localeProvider.notifier)
        .setLocale(SupportedLocales.en);
    await tester.pumpAndSettle();
    expect(find.text('Track'), findsOneWidget);
    expect(find.text('Lacak'), findsNothing);
    final sp = await SharedPreferences.getInstance();
    expect(sp.getString(kLanguagePrefKey), 'en');
  });

  testWidgets('tap tab Profil membuka layar Profil dengan data akun', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.byType(BrandHeader), findsOneWidget);
    expect(find.text('Ops Samudra'), findsOneWidget);
    expect(find.text('ops@samudra.example.com'), findsOneWidget);
  });
}
