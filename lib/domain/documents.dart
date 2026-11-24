/// Dokumen untuk customer (PRD F-05, §9) — port dari aturan web
/// (`customerMayDownload` di rules, `DOC_TYPES` di orderDocuments.js).
/// Murni Dart.
library;

import 'order_models.dart';

enum DocType {
  quotation,
  invoice,
  certificateGas,
  certificateUti,
  certificateKan,
}

/// Pemilik arsip: `orders/{orderId}` atau `invoices/{invoiceId}`.
class DocOwner {
  const DocOwner.order(String id) : path = 'orders/$id', isInvoice = false;
  const DocOwner.invoice(String id) : path = 'invoices/$id', isInvoice = true;

  final String path;
  final bool isInvoice;
}

class CustomerDocument {
  const CustomerDocument({
    required this.type,
    required this.owner,
    required this.docId,
    required this.fileName,
    required this.free,
  });

  final DocType type;
  final DocOwner owner;
  final String docId;
  final String fileName;

  /// `true` = selalu bisa dibuka (Penawaran); lainnya tergantung pembayaran.
  final bool free;

  /// Kunci cache lokal (unik per pemilik + dokumen).
  String get cacheKey => '${owner.path.replaceAll('/', '_')}_$docId';
}

enum PaymentState { none, unpaid, tempo, paid }

abstract final class DocumentRules {
  static const _certTypes = [
    DocType.certificateGas,
    DocType.certificateUti,
    DocType.certificateKan,
  ];

  static String typeKey(DocType t) => t.name;

  /// Daftar dokumen yang ada di order, urutan tampil: Invoice, Penawaran,
  /// Sertifikat Gas/UTI/KAN.
  static List<CustomerDocument> customerDocuments(Order order) {
    final docs = <CustomerDocument>[];
    final inv = order.invoicePdf;
    if (order.invoiceId.isNotEmpty && inv != null && inv.docId.isNotEmpty) {
      docs.add(
        CustomerDocument(
          type: DocType.invoice,
          owner: DocOwner.invoice(order.invoiceId),
          docId: inv.docId,
          fileName: inv.fileName,
          free: false,
        ),
      );
    }
    for (final t in [DocType.quotation, ..._certTypes]) {
      final ref = order.pdfFiles[typeKey(t)];
      if (ref == null || ref.docId.isEmpty) continue;
      docs.add(
        CustomerDocument(
          type: t,
          owner: DocOwner.order(order.id),
          docId: ref.docId,
          fileName: ref.fileName,
          free: t == DocType.quotation,
        ),
      );
    }
    return docs;
  }

  /// BR-05: Penawaran bebas; Invoice & Sertifikat setelah Lunas atau Tempo
  /// (ditegakkan juga oleh rules).
  static bool canDownload(Order order, DocType type) {
    if (type == DocType.quotation) return true;
    return order.invoiceStatus == 'Lunas' || order.invoiceTempo;
  }

  static PaymentState paymentState(Order order) {
    if (order.invoiceStatus == 'Lunas') return PaymentState.paid;
    if (order.invoiceTempo) return PaymentState.tempo;
    if (order.invoiceNo.isNotEmpty || order.invoiceId.isNotEmpty) {
      return PaymentState.unpaid;
    }
    return PaymentState.none;
  }
}
