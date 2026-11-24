import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/domain/documents.dart';
import 'package:ism_customer/domain/order_models.dart';

import '../fixtures/orders.dart' as fx;

void main() {
  final withDocs = Order.fromMap(
    'o9',
    fx.base(
      status: 'Final Order',
      extra: {
        'pdfFiles': {
          'quotation': {'docId': 'q1', 'fileName': 'Q.pdf'},
          'certificateGas': {'docId': 'c1', 'fileName': 'CG.pdf'},
          'certificateKan': {'docId': 'c3', 'fileName': 'CK.pdf'},
          'inspectionReport': {'docId': 'ir', 'fileName': 'IR.pdf'},
        },
        'invoiceId': 'inv1',
        'invoiceNo': 'INV-1',
        'invoiceStatus': 'Belum Dibayar',
        'invoicePdf': {'docId': 'ip1', 'fileName': 'INV-1.pdf'},
      },
    ),
  );

  test('customerDocuments: urutan Invoice, Penawaran, Sertifikat; lainnya diabaikan', () {
    final docs = DocumentRules.customerDocuments(withDocs);
    expect(docs.map((d) => d.type), [
      DocType.invoice,
      DocType.quotation,
      DocType.certificateGas,
      DocType.certificateKan,
    ]);
    expect(docs[0].owner.path, 'invoices/inv1');
    expect(docs[0].docId, 'ip1');
    expect(docs[1].owner.path, 'orders/o9');
    expect(docs[1].free, isTrue);
    expect(docs[2].free, isFalse);
    expect(docs[1].cacheKey, 'orders_o9_q1');
  });

  test('canDownload: penawaran bebas; lainnya butuh Lunas atau Tempo', () {
    expect(DocumentRules.canDownload(withDocs, DocType.quotation), isTrue);
    expect(DocumentRules.canDownload(withDocs, DocType.invoice), isFalse);
    expect(
      DocumentRules.canDownload(withDocs, DocType.certificateGas),
      isFalse,
    );
    expect(DocumentRules.canDownload(fx.tempo, DocType.certificateGas), isTrue);
    expect(DocumentRules.canDownload(fx.completed, DocType.invoice), isTrue);
  });

  test('paymentState', () {
    expect(DocumentRules.paymentState(fx.o6), PaymentState.none);
    expect(DocumentRules.paymentState(withDocs), PaymentState.unpaid);
    expect(DocumentRules.paymentState(fx.tempo), PaymentState.tempo);
    expect(DocumentRules.paymentState(fx.completed), PaymentState.paid);
  });

  test(
    'tanpa invoiceId → invoice tidak terdaftar; tanpa pdfFiles → kosong',
    () {
      expect(DocumentRules.customerDocuments(fx.o1), isEmpty);
    },
  );
}
