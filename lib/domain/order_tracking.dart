/// Lacak Order 7 tahap — **port 1:1** dari CSMS `helper/orderTracking.js`
/// (TRACK_STEPS, EVENT_LABELS, eventLabel, stepDoneBy, orderEvents,
/// stepStates, buildTracking, hasCertificate). Label & catatan dikembalikan
/// sebagai [TrackText] (kunci + parameter) dan diterjemahkan di UI (PRD §8).
library;

import 'order_models.dart';

enum TrackStepKey {
  order,
  workform,
  quotation,
  service,
  certificate,
  invoice,
  delivery,
}

/// `done | current | warning | error | todo` di web.
enum TrackState { done, current, warning, error, todo }

/// Teks yang diterjemahkan di UI. [key] adalah nama kunci l10n logis
/// (mis. `noteQuotation`), [params] isinya; [raw] bila teks apa adanya.
class TrackText {
  const TrackText(this.key, {this.params = const {}, this.raw});
  const TrackText.raw(String text) : key = 'raw', params = const {}, raw = text;
  const TrackText.none() : key = '', params = const {}, raw = null;

  final String key;
  final Map<String, String> params;
  final String? raw;

  bool get isEmpty => key.isEmpty && raw == null;
}

class TrackStep {
  const TrackStep({
    required this.key,
    required this.state,
    required this.note,
    required this.at,
  });

  final TrackStepKey key;
  final TrackState state;
  final TrackText note;

  /// Tanggal selesai (state done) atau tanggal selesai tahap sebelumnya.
  final String at;

  int get index => key.index;
}

class TrackEvent {
  const TrackEvent({
    required this.status,
    required this.label,
    this.note = '',
    this.at = '',
    this.by = '',
    this.approx = false,
  });

  final String status;
  final TrackText label;
  final String note;
  final String at;
  final String by;

  /// Disusun dari data dokumen (order lama tanpa `statusHistory`).
  final bool approx;
}

class OrderTracking {
  const OrderTracking({
    required this.steps,
    required this.events,
    required this.progress,
    required this.done,
    required this.hasHistory,
  });

  final List<TrackStep> steps;
  final List<TrackEvent> events;

  /// 0–100.
  final int progress;
  final bool done;
  final bool hasHistory;

  int get doneCount => steps.where((s) => s.state == TrackState.done).length;

  /// Tahap pertama yang belum selesai; `null` bila semua selesai.
  TrackStep? get current {
    for (final s in steps) {
      if (s.state != TrackState.done) return s;
    }
    return null;
  }
}

abstract final class OrderTrackingRules {
  static const awaitingClient = [
    'Waiting for Client to approve Inspection',
    'Waiting for Approval Client',
  ];
  static const approved = ['Inspection is Completed', 'Inspection is Pending'];
  static const serviced = [
    'Final Order',
    'PO not finished yet',
    'Waiting for Certificate process',
    'Done',
    'Rejected',
  ];
  static const certTypes = [
    'certificateGas',
    'certificateUti',
    'certificateKan',
  ];

  /// `EVENT_LABELS` web → kunci l10n `trackingEvent*` (lihat UI).
  static const eventLabelKeys = <String, String>{
    'Waiting for Inspection process': 'orderCreated',
    'Entry': 'workformStarted',
    'Waiting for Client to approve Inspection': 'recommendationSent',
    'Waiting for Approval Client': 'recommendationSent',
    'Inspection is Completed': 'recommendationApproved',
    'Inspection is Pending': 'recommendationPending',
    'Inspection Rejected': 'recommendationRejected',
    'Inspection decision': 'inspectionDecision',
    'Waiting for Certificate process': 'poReceivedCertificate',
    'PO not finished yet': 'serviceDoneWaitingPo',
    'Final Order': 'serviceDoneCertificate',
    'Rejected': 'documentRejected',
    'Quotation': 'quotationCreated',
    'Quotation Updated': 'quotationUpdated',
    'PO Number': 'poRecorded',
    'PO Number Updated': 'poUpdated',
    'PO Number Removed': 'poRemoved',
    'Certificate': 'certificateIssued',
    'Invoice': 'invoiceIssued',
    'Invoice Updated': 'invoiceUpdated',
    'Invoice Paid': 'invoicePaid',
    'Invoice Unpaid': 'invoiceUnpaid',
    'Delivery Order': 'deliveryOrderIssued',
    'Reverted': 'reverted',
  };

  static TrackText eventLabel(StatusEvent ev) {
    if (ev.status == 'Final Order' && ev.note == 'PO dikonfirmasi') {
      return const TrackText('poConfirmedCertificateReady');
    }
    final k = eventLabelKeys[ev.status];
    return k == null ? TrackText.raw(ev.status) : TrackText(k);
  }

  /// Indeks tahap yang ditandai selesai oleh kejadian, atau `null`.
  static int? stepDoneBy(StatusEvent ev) {
    final s = ev.status;
    if (awaitingClient.contains(s)) return 1;
    if (approved.contains(s) || s == 'Inspection decision') return 2;
    if (s == 'Final Order' && ev.note != 'PO dikonfirmasi') return 3;
    if (s == 'PO not finished yet') return 3;
    if (s == 'Certificate') return 4;
    if (s == 'Invoice Paid') return 5;
    if (s == 'Delivery Order') return 6;
    return null;
  }

  static String? firstPdf(Order order, List<String> types) {
    final dates =
        types
            .map((t) => order.pdfFiles[t]?.createdAt)
            .whereType<String>()
            .where((d) => d.isNotEmpty)
            .toList()
          ..sort();
    return dates.isEmpty ? null : dates.first;
  }

  static bool hasCertificate(Order order) => firstPdf(order, certTypes) != null;

  /// Kejadian dari `statusHistory`, atau disusun dari data dokumen untuk
  /// order lama. Terbaru di atas; tanpa tanggal tetap di urutan logisnya.
  static List<TrackEvent> orderEvents(Order order) {
    final List<TrackEvent> events;
    if (order.statusHistory.isNotEmpty) {
      events = [
        for (final h in order.statusHistory)
          TrackEvent(
            status: h.status,
            label: eventLabel(h),
            note: h.note,
            at: h.at,
            by: h.by,
          ),
      ];
    } else {
      final list = <StatusEvent>[];
      void push(
        String status,
        String? at, {
        String note = '',
        String by = '',
      }) => list.add(
        StatusEvent(status: status, at: at ?? '', note: note, by: by),
      );
      if (order.createdAt.isNotEmpty) {
        push(
          'Waiting for Inspection process',
          order.createdAt,
          by: order.createdBy,
        );
      }
      if (order.inspectionDate.isNotEmpty) {
        push(
          'Waiting for Client to approve Inspection',
          order.inspectionDate,
          by: order.inspectionEngineer,
        );
      }
      if (order.quotationNo.isNotEmpty) {
        push(
          'Quotation',
          firstPdf(order, ['quotation']),
          note: order.quotationNo,
        );
      }
      if (order.approvedAt.isNotEmpty) {
        push('Inspection decision', order.approvedAt, by: order.approvedBy);
      }
      if (order.rejectedAt.isNotEmpty) {
        push('Rejected', order.rejectedAt, by: order.rejectedBy);
      }
      if (order.poNumber.isNotEmpty) {
        push('PO Number', '', note: order.poNumber);
      }
      final cert = firstPdf(order, certTypes);
      if (cert != null) push('Certificate', cert);
      if (order.invoiceNo.isNotEmpty) {
        push('Invoice', order.invoiceDate, note: order.invoiceNo);
      }
      if (order.invoiceStatus == 'Lunas') {
        push('Invoice Paid', '', note: order.invoiceNo);
      }
      if (order.deliveryOrderNumber.isNotEmpty) {
        push('Delivery Order', '', note: order.deliveryOrderNumber);
      }
      events = [
        for (final e in list)
          TrackEvent(
            status: e.status,
            label: eventLabel(e),
            note: e.note,
            at: e.at,
            by: e.by,
            approx: true,
          ),
      ];
    }
    final indexed = events.asMap().entries.toList()
      ..sort((a, b) {
        final ea = a.value;
        final eb = b.value;
        if (ea.at.isNotEmpty && eb.at.isNotEmpty) {
          final c = eb.at.compareTo(ea.at);
          return c != 0 ? c : b.key - a.key;
        }
        return b.key - a.key;
      });
    return [for (final e in indexed) e.value];
  }

  static List<({TrackState state, TrackText note})> stepStates(Order order) {
    final st = order.statusDesc;
    final cert = hasCertificate(order);
    final paid = order.invoiceStatus == 'Lunas';
    final tempo = order.invoiceTempo && !paid;
    final quotation =
        order.quotationNo.isNotEmpty || firstPdf(order, ['quotation']) != null;
    final isServiced = serviced.contains(st) || cert;
    final isApproved = approved.contains(st) || isServiced;
    final sent =
        awaitingClient.contains(st) ||
        st == 'Inspection Rejected' ||
        isApproved;
    final done = [
      true,
      sent,
      isApproved,
      isServiced,
      cert,
      paid || tempo,
      order.deliveryOrderNumber.isNotEmpty,
    ];
    final paymentKey = paid
        ? 'paid'
        : tempo
        ? 'tempo'
        : 'unpaid';
    final notes = <TrackText>[
      order.ordersNo.isEmpty
          ? const TrackText.none()
          : TrackText.raw(order.ordersNo),
      st == 'Entry'
          ? const TrackText('noteWorkformEntry')
          : const TrackText.none(),
      quotation
          ? (order.quotationNo.isEmpty
                ? const TrackText('noteQuotationCreated')
                : TrackText('noteQuotation', params: {'no': order.quotationNo}))
          : const TrackText.none(),
      st == 'PO not finished yet'
          ? const TrackText('noteServiceWaitingPo')
          : const TrackText.none(),
      cert && order.poNumber.isEmpty
          ? const TrackText('noteCertNoPo')
          : order.poNumber.isNotEmpty
          ? TrackText('notePo', params: {'no': order.poNumber})
          : const TrackText.none(),
      order.invoiceNo.isNotEmpty
          ? TrackText(
              'noteInvoice',
              params: {'no': order.invoiceNo, 'payment': paymentKey},
            )
          : cert
          ? const TrackText('noteInvoiceNotIssued')
          : const TrackText.none(),
      order.deliveryOrderNumber.isEmpty
          ? const TrackText.none()
          : TrackText.raw(order.deliveryOrderNumber),
    ];
    final cur = done.indexOf(false);
    return List.generate(TrackStepKey.values.length, (i) {
      var state = done[i]
          ? TrackState.done
          : i == cur
          ? TrackState.current
          : TrackState.todo;
      if (i == 2 && st == 'Inspection Rejected') {
        state = TrackState.error;
      } else if (i == 2 && st == 'Inspection is Pending') {
        state = TrackState.warning;
      } else if (i == 4 && st == 'Rejected') {
        state = TrackState.error;
      } else if (i == 4 && !done[i] && st == 'PO not finished yet') {
        state = TrackState.warning;
      } else if (i == 5 && done[i] && tempo) {
        state = TrackState.warning;
      } else if (i == 5 &&
          state == TrackState.current &&
          order.invoiceNo.isNotEmpty) {
        state = TrackState.warning;
      }
      return (state: state, note: notes[i]);
    });
  }

  static OrderTracking buildTracking(Order order) {
    final events = orderEvents(order);
    final doneAt = <int, String>{0: order.createdAt};
    for (final e in events.reversed) {
      final s = stepDoneBy(
        StatusEvent(status: e.status, note: e.note, at: e.at),
      );
      if (s != null && e.at.isNotEmpty && (doneAt[s] ?? '').isEmpty) {
        doneAt[s] = e.at;
      }
    }
    final states = stepStates(order);
    final steps = [
      for (var i = 0; i < states.length; i++)
        TrackStep(
          key: TrackStepKey.values[i],
          state: states[i].state,
          note: states[i].note,
          at: states[i].state == TrackState.done
              ? (doneAt[i] ?? '')
              : (doneAt[i - 1] ?? ''),
        ),
    ];
    final finished = steps.every((s) => s.state == TrackState.done);
    final doneCount = steps.where((s) => s.state == TrackState.done).length;
    return OrderTracking(
      steps: steps,
      events: events,
      progress: (doneCount / steps.length * 100).round(),
      done: finished,
      hasHistory: order.statusHistory.isNotEmpty,
    );
  }
}
