// Fixture order dari seed CSMS `qa/automation/seed/seed.mjs` + variasi
// yang dibutuhkan PRD §8 (sertifikat, invoice, tempo, DO).
import 'package:ism_customer/domain/order_models.dart';

const now = '2026-11-21T03:00:00.000Z';

Map<String, Object?> base({
  String id = 'o1',
  String no = 'OR/20261121/001',
  String status = 'Waiting for Inspection process',
  Map<String, Object?> extra = const {},
}) => {
  'ordersNo': no,
  'createdAt': now,
  'createdBy': 'Rina Pratiwi',
  'customerName': 'PT Samudra Bahari Lines',
  'customerEmail': 'ops@samudra.example.com',
  'vesselName': 'MT Bahari Jaya',
  'products': 'Gas Meter',
  'productsList': [
    {
      'orderProduct': 'Gas Meter',
      'orderProductType': 'Riken Keiki',
      'orderProductSeries': 'GX-2009',
      'orderProductSN': 'GX-A0',
    },
  ],
  'statusDesc': status,
  'statusHistory': <Object?>[],
  'isDeleted': false,
  ...extra,
};

Order order(Map<String, Object?> m, {String id = 'o'}) => Order.fromMap(id, m);

/// Seed 001: baru dibuat.
final o1 = order(base());

/// Seed 003: menunggu persetujuan client + penawaran.
final o3 = order(
  base(
    no: 'OR/20261121/003',
    status: 'Waiting for Client to approve Inspection',
    extra: {'quotationNo': 'QTN-2611-0003'},
  ),
);

/// Seed 005: Final Order tanpa PO, tanpa sertifikat.
final o5 = order(
  base(no: 'OR/20261121/005', status: 'Final Order', extra: {'poNumber': ''}),
);

/// Seed 006: Final Order + PO, tanpa sertifikat.
final o6 = order(
  base(
    no: 'OR/20261121/006',
    status: 'Final Order',
    extra: {'poNumber': 'PO-2611-77'},
  ),
);

final certGas = {
  'certificateGas': {
    'docId': 'c1',
    'fileName': 'Cert.pdf',
    'revision': 0,
    'createdAt': '2026-11-22T01:00:00.000Z',
  },
};

/// Sertifikat tanpa PO, invoice terbit belum dibayar.
final certNoPoUnpaid = order(
  base(
    status: 'Final Order',
    extra: {
      'poNumber': '',
      'pdfFiles': certGas,
      'invoiceNo': 'INV-2611-0001',
      'invoiceStatus': 'Belum Dibayar',
      'invoiceDate': '2026-11-23T01:00:00.000Z',
    },
  ),
);

/// Tempo.
final tempo = order(
  base(
    status: 'Final Order',
    extra: {
      'poNumber': 'PO-1',
      'pdfFiles': certGas,
      'invoiceNo': 'INV-2611-0002',
      'invoiceStatus': 'Belum Dibayar',
      'invoiceTempo': true,
    },
  ),
);

/// Lunas + DO → semua selesai.
final completed = order(
  base(
    status: 'Final Order',
    extra: {
      'poNumber': 'PO-1',
      'pdfFiles': certGas,
      'invoiceNo': 'INV-2611-0003',
      'invoiceStatus': 'Lunas',
      'deliveryOrderNumber': 'DO-2611-0001',
      'statusHistory': [
        {
          'status': 'Waiting for Inspection process',
          'note': '',
          'at': now,
          'by': 'Rina',
        },
        {
          'status': 'Waiting for Client to approve Inspection',
          'note': '',
          'at': '2026-11-21T05:00:00.000Z',
          'by': 'Andi',
        },
        {
          'status': 'Inspection is Completed',
          'note': '',
          'at': '2026-11-21T06:00:00.000Z',
          'by': 'client',
        },
        {
          'status': 'Final Order',
          'note': '',
          'at': '2026-11-21T08:00:00.000Z',
          'by': 'Andi',
        },
        {
          'status': 'Certificate',
          'note': '',
          'at': '2026-11-22T01:00:00.000Z',
          'by': 'Rina',
        },
        {
          'status': 'Invoice',
          'note': 'INV-2611-0003',
          'at': '2026-11-23T01:00:00.000Z',
          'by': 'Rina',
        },
        {
          'status': 'Invoice Paid',
          'note': 'INV-2611-0003',
          'at': '2026-11-24T01:00:00.000Z',
          'by': 'Rina',
        },
        {
          'status': 'Delivery Order',
          'note': 'DO-2611-0001',
          'at': '2026-11-25T01:00:00.000Z',
          'by': 'Rina',
        },
      ],
    },
  ),
);

final inspectionRejected = order(base(status: 'Inspection Rejected'));
final rejected = order(base(status: 'Rejected'));
