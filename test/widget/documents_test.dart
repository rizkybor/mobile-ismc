import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/domain/order_models.dart';
import 'package:ism_customer/features/documents/widgets/documents_card.dart';

import '../fixtures/orders.dart' as fx;
import 'test_app.dart';

void main() {
  final unpaid = Order.fromMap(
    'o6',
    fx.base(
      status: 'Final Order',
      extra: {
        'pdfFiles': {
          'quotation': {'docId': 'q1', 'fileName': 'Quotation.pdf'},
          'certificateGas': {'docId': 'c1', 'fileName': 'Cert.pdf'},
        },
        'invoiceNo': 'INV-1',
        'invoiceStatus': 'Belum Dibayar',
      },
    ),
  );

  testWidgets(
    'belum bayar: Penawaran terbuka, Sertifikat terkunci, chip Belum Dibayar',
    (tester) async {
      final c = await makeContainer();
      await tester.pumpWidget(
        wrapScreen(
          c,
          Scaffold(
            body: ListView(children: [DocumentsCard(order: unpaid)]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Penawaran (Quotation)'), findsOneWidget);
      expect(find.text('Quotation.pdf'), findsOneWidget);
      expect(find.text('Sertifikat Kalibrasi Gas Meter'), findsOneWidget);
      expect(
        find.text('Bisa diunduh setelah pembayaran dikonfirmasi'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      expect(find.text('Belum Dibayar'), findsOneWidget);
    },
  );

  testWidgets('Lunas: semua terbuka', (tester) async {
    final c = await makeContainer();
    await tester.pumpWidget(
      wrapScreen(
        c,
        Scaffold(
          body: ListView(children: [DocumentsCard(order: fx.completed)]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    expect(find.text('Lunas'), findsOneWidget);
  });

  testWidgets('tanpa dokumen', (tester) async {
    final c = await makeContainer();
    await tester.pumpWidget(
      wrapScreen(
        c,
        Scaffold(
          body: ListView(children: [DocumentsCard(order: fx.o1)]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Belum ada dokumen untuk order ini.'), findsOneWidget);
  });
}
