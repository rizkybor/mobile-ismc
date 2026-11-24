// Tahap 6 — dokumen PDF terhadap Firebase Emulator (seed CSMS: order o6
// punya Penawaran qtn1 dengan 1 potongan).
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ism_customer/core/config/env.dart';
import 'package:ism_customer/data/documents_repository.dart';
import 'package:ism_customer/data/firebase.dart';
import 'package:ism_customer/data/orders_repository.dart';
import 'package:ism_customer/domain/documents.dart';
import 'package:ism_customer/domain/pdf_assembler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Akun seed emulator — bukan kredensial nyata.
const seedEmail = 'ops@samudra.example.com';
const seedPassword = 'Cust#2026!';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late OrdersRepository orders;
  late DocumentsRepository docs;

  setUpAll(() async {
    expect(Env.useEmulator, isTrue);
    expect(await initFirebase(), isTrue);
    orders = OrdersRepository(
      FirebaseFirestore.instance,
      await SharedPreferences.getInstance(),
    );
    docs = DocumentsRepository(FirebaseFirestore.instance);
    await docs.clearCache();
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: seedEmail,
      password: seedPassword,
    );
  });

  tearDownAll(() => FirebaseAuth.instance.signOut());

  testWidgets(
    'o6: Penawaran terbuka, dirakit jadi PDF valid, lalu dari cache',
    (tester) async {
      final o = (await orders.fetchOrder('o6'))!;
      final list = DocumentRules.customerDocuments(o);
      expect(list.map((d) => d.type), [DocType.quotation]);
      expect(DocumentRules.canDownload(o, DocType.quotation), isTrue);
      expect(DocumentRules.canDownload(o, DocType.certificateGas), isFalse);

      final progress = <int>[];
      final file = await docs.fetchPdf(
        list.first,
        onProgress: (d, _) => progress.add(d),
      );
      expect(progress, [0, 1]);
      final bytes = await file.readAsBytes();
      expect(PdfAssembler.looksLikePdf(bytes), isTrue);
      expect(file.path, endsWith('orders_o6_qtn1.pdf'));

      expect(await docs.cached(list.first), isNotNull);
      final again = await docs.fetchPdf(
        list.first,
        onProgress: (_, _) => fail('tidak boleh unduh lagi'),
      );
      expect(again.path, file.path);
    },
  );

  testWidgets('dokumen terkunci dibaca langsung lewat SDK → ditolak rules', (
    tester,
  ) async {
    // Tulis arsip sertifikat palsu untuk o6 lewat emulator REST tidak
    // tersedia dari sini; cukup pastikan rules menolak pembacaan subkoleksi
    // documents milik order customer lain (o3).
    await expectLater(
      FirebaseFirestore.instance.collection('orders/o3/documents').get(),
      throwsA(
        isA<FirebaseException>().having(
          (e) => e.code,
          'code',
          'permission-denied',
        ),
      ),
    );
  });

  testWidgets('clearCache menghapus file', (tester) async {
    await docs.clearCache();
    final o = (await orders.fetchOrder('o6'))!;
    expect(await docs.cached(DocumentRules.customerDocuments(o).first), isNull);
  });
}
