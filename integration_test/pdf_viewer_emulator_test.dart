// Tahap 6 — layar pratinjau PDF merender dokumen seed (o6/qtn1) di perangkat.
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ism_customer/core/i18n/l10n.dart';
import 'package:ism_customer/core/i18n/locale_controller.dart';
import 'package:ism_customer/core/theme/app_theme.dart';
import 'package:ism_customer/data/documents_repository.dart';
import 'package:ism_customer/data/firebase.dart';
import 'package:ism_customer/data/firebase_providers.dart';
import 'package:ism_customer/data/orders_repository.dart';
import 'package:ism_customer/domain/documents.dart';
import 'package:ism_customer/features/documents/document_ui.dart';
import 'package:ism_customer/features/documents/screens/pdf_viewer_screen.dart';
import 'package:pdfx/pdfx.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Akun seed emulator — bukan kredensial nyata.
const seedEmail = 'ops@samudra.example.com';
const seedPassword = 'Cust#2026!';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PdfViewerScreen: unduh → PdfViewPinch tampil → tombol bagikan', (
    tester,
  ) async {
    expect(await initFirebase(), isTrue);
    final prefs = await SharedPreferences.getInstance();
    await DocumentsRepository(FirebaseFirestore.instance).clearCache();
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: seedEmail,
      password: seedPassword,
    );
    final order = (await OrdersRepository(
      FirebaseFirestore.instance,
      prefs,
    ).fetchOrder('o6'))!;
    final doc = DocumentRules.customerDocuments(order).first;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          firebaseReadyProvider.overrideWithValue(true),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('id'),
          supportedLocales: const [Locale('id'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: PdfViewerScreen(
            request: PdfViewRequest(
              document: doc,
              title: 'Penawaran (Quotation)',
            ),
          ),
        ),
      ),
    );
    // Loader beranimasi terus → pump bertahap sampai viewer muncul.
    for (
      var i = 0;
      i < 40 && find.byType(PdfViewPinch).evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    expect(find.byType(PdfViewPinch), findsOneWidget);
    expect(find.text('Bagikan / Simpan'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await FirebaseAuth.instance.signOut();
  });
}
