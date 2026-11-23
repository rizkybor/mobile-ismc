import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/core/formatters.dart';

void main() {
  // 22 Nov 2026 07:30 UTC = 14:30 WIB
  final dt = DateTime.utc(2026, 11, 22, 7, 30);

  group('formatDate', () {
    test('ID', () => expect(Formatters.formatDate(dt, 'id'), '22 Nov 2026'));
    test('EN', () => expect(Formatters.formatDate(dt, 'en'), '22 Nov 2026'));
    test('bulan Mei/Agu/Okt/Des berbeda dari EN', () {
      expect(
        Formatters.formatDate(DateTime.utc(2026, 5, 1, 12), 'id'),
        '1 Mei 2026',
      );
      expect(
        Formatters.formatDate(DateTime.utc(2026, 5, 1, 12), 'en'),
        '1 May 2026',
      );
      expect(
        Formatters.formatDate(DateTime.utc(2026, 8, 1, 12), 'id'),
        '1 Agu 2026',
      );
      expect(
        Formatters.formatDate(DateTime.utc(2026, 12, 1, 12), 'id'),
        '1 Des 2026',
      );
    });
    test('lintas hari karena WIB', () {
      // 21 Nov 20:00 UTC = 22 Nov 03:00 WIB
      expect(
        Formatters.formatDate(DateTime.utc(2026, 11, 21, 20), 'id'),
        '22 Nov 2026',
      );
    });
  });

  group('formatDateTime', () {
    test('ID 24 jam dengan titik', () {
      expect(Formatters.formatDateTime(dt, 'id'), '22 Nov 2026, 14.30 WIB');
    });
    test('EN 12 jam AM/PM', () {
      expect(Formatters.formatDateTime(dt, 'en'), '22 Nov 2026, 2:30 PM WIB');
      expect(
        Formatters.formatDateTime(DateTime.utc(2026, 11, 22, 17, 5), 'en'),
        '23 Nov 2026, 12:05 AM WIB',
      );
    });
  });

  group('formatMoney', () {
    test('ID titik ribuan', () {
      expect(Formatters.formatMoney(1250000, 'id'), 'IDR 1.250.000');
    });
    test('EN koma ribuan', () {
      expect(Formatters.formatMoney(1250000, 'en'), 'IDR 1,250,000');
    });
    test('desimal dibulatkan', () {
      expect(Formatters.formatMoney(2450000.4, 'id'), 'IDR 2.450.000');
    });
  });

  group('relative', () {
    final now = DateTime.utc(2026, 11, 22, 7, 30);
    test('baru saja', () {
      expect(
        Formatters.relative(
          now.subtract(const Duration(seconds: 20)),
          now: now,
        ).kind,
        RelativeKind.justNow,
      );
    });
    test('menit', () {
      final r = Formatters.relative(
        now.subtract(const Duration(minutes: 5)),
        now: now,
      );
      expect(r.kind, RelativeKind.minutes);
      expect(r.value, 5);
    });
    test('jam', () {
      final r = Formatters.relative(
        now.subtract(const Duration(hours: 3)),
        now: now,
      );
      expect(r.kind, RelativeKind.hours);
      expect(r.value, 3);
    });
    test('kemarin (hari kalender WIB)', () {
      // now = 22 Nov 14:30 WIB; 21 Nov 02:00 WIB = 20 Nov 19:00 UTC → "kemarin"
      final r = Formatters.relative(DateTime.utc(2026, 11, 20, 19), now: now);
      expect(r.kind, RelativeKind.yesterday);
    });
    test('lebih lama → tanggal', () {
      expect(
        Formatters.relative(
          now.subtract(const Duration(days: 5)),
          now: now,
        ).kind,
        RelativeKind.date,
      );
    });
  });

  group('parseIso', () {
    test('string ISO', () {
      expect(
        Formatters.parseIso('2026-11-22T07:30:00.000Z'),
        DateTime.utc(2026, 11, 22, 7, 30),
      );
    });
    test('kosong/null/tidak valid → null', () {
      expect(Formatters.parseIso(''), isNull);
      expect(Formatters.parseIso(null), isNull);
      expect(Formatters.parseIso('abc'), isNull);
    });
  });
}
