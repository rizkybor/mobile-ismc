import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/core/i18n/locale_controller.dart';
import 'package:ism_customer/domain/account_status.dart';
import 'package:ism_customer/features/profile/screens/change_password_screen.dart';
import 'package:ism_customer/features/profile/screens/delete_account_screen.dart';
import 'package:ism_customer/features/profile/screens/profile_screen.dart';

import 'test_app.dart';

void main() {
  testWidgets('profil: data akun, perusahaan (baca saja), menu bahasa', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = await makeContainer(
      customer: const CustomerProfile(
        id: 'c1',
        customerName: 'PT Samudra Bahari Lines',
        email: 'ops@samudra.example.com',
        isCompany: true,
        phone: '0812',
        address: 'Jl. Pelabuhan No. 1',
        isRegistered: true,
        isVerify: true,
        isActive: true,
        isDeleted: false,
      ),
    );
    await tester.pumpWidget(wrapScreen(c, const ProfileScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Ops Samudra'), findsOneWidget);
    expect(find.text('PT Samudra Bahari Lines'), findsOneWidget);
    expect(find.text('Jl. Pelabuhan No. 1'), findsOneWidget);
    expect(
      find.text('Perubahan data perusahaan: hubungi admin ISM.'),
      findsOneWidget,
    );
    expect(find.text('Ganti password'), findsOneWidget);
    expect(find.text('Hapus akun'), findsOneWidget);

    await tester.tap(find.text('Bahasa'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih bahasa'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    // wrapScreen memakai locale tetap; pastikan pilihan tersimpan di provider
    // (MaterialApp.router di aplikasi nyata mengikuti provider ini).
    expect(c.read(localeProvider).languageCode, 'en');
  });

  testWidgets('ganti password: validasi syarat & ulangi', (tester) async {
    final c = await makeContainer();
    await tester.pumpWidget(wrapScreen(c, const ChangePasswordScreen()));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'lama');
    await tester.enterText(fields.at(1), 'lemah');
    await tester.enterText(fields.at(2), 'beda');
    await tester.ensureVisible(find.text('Simpan password'));
    await tester.tap(find.text('Simpan password'));
    await tester.pumpAndSettle();
    expect(find.text('Password belum memenuhi syarat.'), findsOneWidget);
    expect(find.text('Password tidak sama.'), findsOneWidget);
  });

  testWidgets('hapus akun: tombol aktif hanya setelah mengetik HAPUS', (
    tester,
  ) async {
    final c = await makeContainer();
    await tester.pumpWidget(wrapScreen(c, const DeleteAccountScreen()));
    await tester.pumpAndSettle();
    final button = find.widgetWithText(FilledButton, 'Hapus akun saya');
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    await tester.enterText(find.byType(TextFormField).at(0), 'hapus');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    await tester.enterText(find.byType(TextFormField).at(0), 'HAPUS');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
  });
}
