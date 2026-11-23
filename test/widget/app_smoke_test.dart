import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/app/app.dart';
import 'package:ism_customer/core/i18n/locale_controller.dart';
import 'package:ism_customer/core/i18n/supported_locales.dart';
import 'package:ism_customer/features/splash/splash_screen.dart';
import 'package:ism_customer/shared/widgets/brand_header.dart';
import 'package:ism_customer/shared/widgets/offline_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      isOfflineProvider.overrideWith((_) => Stream.value(false)),
    ],
  );
  addTearDown(container.dispose);
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
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        isOfflineProvider.overrideWith((_) => Stream.value(false)),
      ],
    );
    addTearDown(container.dispose);
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

  testWidgets('pemasangan baru mulai dalam Bahasa Indonesia dengan 4 tab', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Beranda'), findsWidgets);
    expect(find.text('Lacak'), findsOneWidget);
    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
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

  testWidgets('tap tab Profil membuka layar Profil', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.byType(BrandHeader), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BrandHeader),
        matching: find.text('Profil'),
      ),
      findsOneWidget,
    );
  });
}
