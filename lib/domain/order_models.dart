/// Model order (PRD §6) — `fromMap` toleran terhadap field kosong/null/
/// tipe lama. Murni Dart.
library;

String _s(Object? v) => v is String ? v : (v == null ? '' : v.toString());
bool _b(Object? v) => v == true;

class OrderProduct {
  const OrderProduct({
    required this.product,
    required this.type,
    required this.series,
    required this.serialNumber,
  });

  final String product;
  final String type;
  final String series;
  final String serialNumber;

  factory OrderProduct.fromMap(Map<String, Object?> m) => OrderProduct(
    product: _s(m['orderProduct']),
    type: _s(m['orderProductType']),
    series: _s(m['orderProductSeries']),
    serialNumber: _s(m['orderProductSN']),
  );
}

class StatusEvent {
  const StatusEvent({
    required this.status,
    this.note = '',
    this.at = '',
    this.by = '',
  });

  final String status;
  final String note;

  /// ISO datetime, boleh kosong.
  final String at;
  final String by;

  factory StatusEvent.fromMap(Map<String, Object?> m) => StatusEvent(
    status: _s(m['status']),
    note: _s(m['note']),
    at: _s(m['at']),
    by: _s(m['by']),
  );

  Map<String, Object?> toMap() => {
    'status': status,
    'note': note,
    'at': at,
    'by': by,
  };
}

class PdfRef {
  const PdfRef({
    required this.docId,
    required this.fileName,
    this.revision = 0,
    this.createdAt = '',
  });

  final String docId;
  final String fileName;
  final int revision;
  final String createdAt;

  factory PdfRef.fromMap(Map<String, Object?> m) => PdfRef(
    docId: _s(m['docId']),
    fileName: _s(m['fileName']),
    revision: (m['revision'] is num) ? (m['revision'] as num).toInt() : 0,
    createdAt: _s(m['createdAt']),
  );

  Map<String, Object?> toMap() => {
    'docId': docId,
    'fileName': fileName,
    'revision': revision,
    'createdAt': createdAt,
  };
}

class Order {
  const Order({
    required this.id,
    required this.ordersNo,
    required this.createdAt,
    this.createdBy = '',
    this.customerName = '',
    this.customerEmail = '',
    this.vesselName = '',
    this.products = '',
    this.productsList = const [],
    this.statusDesc = '',
    this.statusHistory = const [],
    this.quotationNo = '',
    this.poNumber = '',
    this.pdfFiles = const {},
    this.invoiceId = '',
    this.invoiceNo = '',
    this.invoiceDate = '',
    this.invoiceTotal = 0,
    this.invoiceStatus = '',
    this.invoiceTempo = false,
    this.invoicePdf,
    this.deliveryOrderNumber = '',
    this.inspectionDate = '',
    this.inspectionEngineer = '',
    this.approvedAt = '',
    this.approvedBy = '',
    this.rejectedAt = '',
    this.rejectedBy = '',
  });

  final String id;
  final String ordersNo;
  final String createdAt;
  final String createdBy;
  final String customerName;
  final String customerEmail;
  final String vesselName;

  /// Daftar produk dipisah koma, mis. `Gas Meter,UTI Meter`.
  final String products;
  final List<OrderProduct> productsList;
  final String statusDesc;
  final List<StatusEvent> statusHistory;
  final String quotationNo;
  final String poNumber;

  /// `pdfFiles.{type}` → penanda PDF (quotation, certificateGas, …).
  final Map<String, PdfRef> pdfFiles;
  final String invoiceId;
  final String invoiceNo;
  final String invoiceDate;
  final num invoiceTotal;

  /// `"Belum Dibayar"` / `"Lunas"`.
  final String invoiceStatus;
  final bool invoiceTempo;
  final PdfRef? invoicePdf;
  final String deliveryOrderNumber;
  final String inspectionDate;
  final String inspectionEngineer;
  final String approvedAt;
  final String approvedBy;
  final String rejectedAt;
  final String rejectedBy;

  /// Nama produk terpisah (dari `products`), tanpa spasi berlebih.
  List<String> get productNames => products
      .split(',')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();

  factory Order.fromMap(String id, Map<String, Object?> m) {
    final rawFiles = m['pdfFiles'];
    final files = <String, PdfRef>{};
    if (rawFiles is Map) {
      rawFiles.forEach((k, v) {
        if (v is Map) {
          files[_s(k)] = PdfRef.fromMap(Map<String, Object?>.from(v));
        }
      });
    }
    final rawList = m['productsList'];
    final rawHistory = m['statusHistory'];
    final rawInvoicePdf = m['invoicePdf'];
    return Order(
      id: id,
      ordersNo: _s(m['ordersNo']),
      createdAt: _s(m['createdAt']),
      createdBy: _s(m['createdBy']),
      customerName: _s(m['customerName']),
      customerEmail: _s(m['customerEmail']),
      vesselName: _s(m['vesselName']),
      products: _s(m['products']),
      productsList: rawList is List
          ? rawList
                .whereType<Map<Object?, Object?>>()
                .map((e) => OrderProduct.fromMap(Map<String, Object?>.from(e)))
                .toList()
          : const [],
      statusDesc: _s(m['statusDesc']),
      statusHistory: rawHistory is List
          ? rawHistory
                .whereType<Map<Object?, Object?>>()
                .map((e) => StatusEvent.fromMap(Map<String, Object?>.from(e)))
                .toList()
          : const [],
      quotationNo: _s(m['quotationNo']),
      poNumber: _s(m['poNumber']),
      pdfFiles: files,
      invoiceId: _s(m['invoiceId']),
      invoiceNo: _s(m['invoiceNo']),
      invoiceDate: _s(m['invoiceDate']),
      invoiceTotal: m['invoiceTotal'] is num ? m['invoiceTotal']! as num : 0,
      invoiceStatus: _s(m['invoiceStatus']),
      invoiceTempo: _b(m['invoiceTempo']),
      invoicePdf: rawInvoicePdf is Map
          ? PdfRef.fromMap(Map<String, Object?>.from(rawInvoicePdf))
          : null,
      deliveryOrderNumber: _s(m['deliveryOrderNumber']),
      inspectionDate: _s(m['inspectionDate']),
      inspectionEngineer: _s(m['inspectionEngineer']),
      approvedAt: _s(m['approvedAt']),
      approvedBy: _s(m['approvedBy']),
      rejectedAt: _s(m['rejectedAt']),
      rejectedBy: _s(m['rejectedBy']),
    );
  }

  /// Bentuk ringkas untuk cache lokal (hanya field yang dipakai aplikasi).
  Map<String, Object?> toMap() => {
    'ordersNo': ordersNo,
    'createdAt': createdAt,
    'createdBy': createdBy,
    'customerName': customerName,
    'customerEmail': customerEmail,
    'vesselName': vesselName,
    'products': products,
    'productsList': [
      for (final p in productsList)
        {
          'orderProduct': p.product,
          'orderProductType': p.type,
          'orderProductSeries': p.series,
          'orderProductSN': p.serialNumber,
        },
    ],
    'statusDesc': statusDesc,
    'statusHistory': [for (final e in statusHistory) e.toMap()],
    'quotationNo': quotationNo,
    'poNumber': poNumber,
    'pdfFiles': {for (final e in pdfFiles.entries) e.key: e.value.toMap()},
    'invoiceId': invoiceId,
    'invoiceNo': invoiceNo,
    'invoiceDate': invoiceDate,
    'invoiceTotal': invoiceTotal,
    'invoiceStatus': invoiceStatus,
    'invoiceTempo': invoiceTempo,
    'invoicePdf': invoicePdf?.toMap(),
    'deliveryOrderNumber': deliveryOrderNumber,
    'inspectionDate': inspectionDate,
    'inspectionEngineer': inspectionEngineer,
    'approvedAt': approvedAt,
    'approvedBy': approvedBy,
    'rejectedAt': rejectedAt,
    'rejectedBy': rejectedBy,
  };

  /// Urut `createdAt` menurun (terbaru dulu), seperti portal web.
  static List<Order> sortNewest(Iterable<Order> orders) =>
      orders.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
