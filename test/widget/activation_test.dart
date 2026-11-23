import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/app/app.dart';
import 'package:ism_customer/domain/account_status.dart';
import 'package:ism_customer/features/activation/screens/activation_screen.dart';
import 'package:ism_customer/features/activation/widgets/account_status_card.dart';
import 'package:ism_customer/features/splash/splash_screen.dart';
import 'package:ism_customer/shared/widgets/stage_placeholder.dart';

import 'test_app.dart';

Future<ProviderContainer> pumpWithAccount(
  WidgetTester tester,
  AccountStatus status,
) async {
  final container = await makeContainer(account: status);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const IsmCustomerApp(),
    ),
  );
  await tester.pump();
  await tester.pump(
    SplashScreen.minimumDuration + const Duration(milliseconds: 100),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('belum lengkap → kartu stepper + tombol aktivasi, tab terkunci', (
    tester,
  ) async {
    await pumpWithAccount(tester, AccountStatus.unregistered);
    expect(find.byType(AccountStatusCard), findsOneWidget);
    expect(find.text('Lengkapi sekarang'), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsNWidgets(2));

    // Tab Lacak terkunci → snackbar, tetap di Beranda
    await tester.tap(find.text('Lacak'));
    await tester.pumpAndSettle();
    expect(
      find.text('Tersedia setelah akun diverifikasi admin ISM.'),
      findsOneWidget,
    );
    expect(find.byType(AccountStatusCard), findsOneWidget);

    // Tombol aktivasi membuka form
    await tester.tap(find.text('Lengkapi sekarang'));
    await tester.pumpAndSettle();
    expect(find.byType(ActivationScreen), findsOneWidget);
  });

  testWidgets('menunggu verifikasi → stepper langkah 3, tanpa tombol', (
    tester,
  ) async {
    await pumpWithAccount(tester, AccountStatus.waiting);
    expect(find.text('Menunggu verifikasi admin'), findsOneWidget);
    expect(find.text('Lengkapi sekarang'), findsNothing);
  });

  testWidgets('nonaktif → kartu merah dengan Telepon & Email', (tester) async {
    await pumpWithAccount(tester, AccountStatus.inactive);
    expect(find.text('Akun Anda tidak aktif'), findsOneWidget);
    expect(find.text('Telepon'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('aktif → tidak ada kartu status, tab terbuka', (tester) async {
    await pumpWithAccount(tester, AccountStatus.active);
    expect(find.byType(AccountStatusCard), findsNothing);
    expect(find.byType(StagePlaceholder), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsNothing);
    await tester.tap(find.text('Lacak'));
    await tester.pumpAndSettle();
    expect(find.text('Lacak Order'), findsOneWidget);
  });

  testWidgets('form aktivasi: validasi wajib & No. HP angka', (tester) async {
    final c = await makeContainer();
    await tester.pumpWidget(wrapScreen(c, const ActivationScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), '0812-abc');
    await tester.ensureVisible(find.text('Kirim permintaan aktivasi'));
    await tester.tap(find.text('Kirim permintaan aktivasi'));
    await tester.pumpAndSettle();
    expect(
      find.text('Wajib diisi.'),
      findsNWidgets(2),
    ); // nama perusahaan, alamat
    expect(find.text('Nomor HP hanya boleh angka.'), findsOneWidget);

    // Perorangan: field nama perusahaan hilang
    await tester.ensureVisible(find.text('Perorangan'));
    await tester.tap(find.text('Perorangan'));
    await tester.pumpAndSettle();
    expect(find.text('Nama perusahaan'), findsNothing);
  });
}
