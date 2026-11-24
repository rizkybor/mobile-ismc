import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/app/app.dart';
import 'package:ism_customer/features/onboarding/onboarding_controller.dart';
import 'package:ism_customer/features/onboarding/onboarding_overlay.dart';
import 'package:ism_customer/features/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fixtures/orders.dart' as fx;
import 'test_app.dart';

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  bool done = false,
}) async {
  final c = await makeContainer(orders: [fx.o1], onboardingDone: done);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: c, child: const IsmCustomerApp()),
  );
  await tester.pump();
  await tester.pump(
    SplashScreen.minimumDuration + const Duration(milliseconds: 100),
  );
  await tester.pumpAndSettle();
  return c;
}

void main() {
  testWidgets(
    'login pertama: panduan tampil, Lanjut sampai Selesai, flag tersimpan',
    (tester) async {
      await pumpApp(tester);
      expect(find.byType(OnboardingOverlay), findsOneWidget);
      expect(find.text('Beranda'), findsWidgets);
      expect(find.text('Lewati'), findsOneWidget);
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Lanjut'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Profil & bahasa'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Selesai'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Selesai'));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingOverlay), findsNothing);
      final sp = await SharedPreferences.getInstance();
      expect(sp.getBool(OnboardingController.prefKey(testUser.uid)), isTrue);
    },
  );

  testWidgets('Lewati di langkah 2 → selesai & tidak muncul lagi', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    expect(find.text('Lacak Order'), findsOneWidget);
    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingOverlay), findsNothing);
    final sp = await SharedPreferences.getInstance();
    expect(sp.getBool(OnboardingController.prefKey(testUser.uid)), isTrue);
  });

  testWidgets(
    'sudah selesai sebelumnya → tidak tampil; bisa dibuka dari Profil',
    (tester) async {
      final c = await pumpApp(tester, done: true);
      expect(find.byType(OnboardingOverlay), findsNothing);
      c.read(onboardingProvider.notifier).reopen();
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingOverlay), findsOneWidget);
    },
  );
}
