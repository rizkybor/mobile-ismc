import 'package:intl/intl.dart';

/// Pemformat tanggal/angka yang mengikuti bahasa aktif dan selalu memakai
/// zona waktu WIB (`Asia/Jakarta`, UTC+7, tanpa DST). Murni, tanpa Flutter.
abstract final class Formatters {
  static const wibOffset = Duration(hours: 7);

  static const _monthsId = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  static const _monthsEn = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Konversi waktu apa pun ke jam dinding WIB (dikembalikan sebagai UTC agar
  /// komponen jam/menitnya langsung bisa dibaca).
  static DateTime toWib(DateTime dt) => dt.toUtc().add(wibOffset);

  /// Parse ISO string dari Firestore (`createdAt`, `statusHistory[].at`).
  /// Mengembalikan `null` bila kosong/tidak valid.
  static DateTime? parseIso(Object? value) {
    if (value is DateTime) return value;
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  /// `22 Nov 2026` (ID & EN sama, hanya nama bulan yang berbeda).
  static String formatDate(DateTime dt, String lang) {
    final w = toWib(dt);
    final months = lang == 'en' ? _monthsEn : _monthsId;
    return '${w.day} ${months[w.month - 1]} ${w.year}';
  }

  /// ID: `22 Nov 2026, 14.30 WIB` · EN: `22 Nov 2026, 2:30 PM WIB`.
  static String formatDateTime(DateTime dt, String lang) {
    final w = toWib(dt);
    final mm = w.minute.toString().padLeft(2, '0');
    final String time;
    if (lang == 'en') {
      final h12 = w.hour % 12 == 0 ? 12 : w.hour % 12;
      final ampm = w.hour < 12 ? 'AM' : 'PM';
      time = '$h12:$mm $ampm';
    } else {
      time = '${w.hour.toString().padLeft(2, '0')}.$mm';
    }
    return '${formatDate(dt, lang)}, $time WIB';
  }

  /// ID: `IDR 1.250.000` · EN: `IDR 1,250,000`. Desimal dibuang (rupiah).
  static String formatMoney(
    num amount,
    String lang, {
    String currency = 'IDR',
  }) {
    final en = NumberFormat.decimalPattern('en_US').format(amount.round());
    final digits = lang == 'en' ? en : en.replaceAll(',', '.');
    return '$currency $digits';
  }

  /// Nilai relatif mentah; terjemahan ("5 mnt lalu") dilakukan di UI lewat
  /// l10n agar teks tidak ditulis di sini.
  static RelativeTime relative(DateTime dt, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final diff = n.difference(dt);
    if (diff.inMinutes < 1) return const RelativeTime.justNow();
    if (diff.inMinutes < 60) return RelativeTime.minutes(diff.inMinutes);
    if (diff.inHours < 24) return RelativeTime.hours(diff.inHours);
    final nowWib = toWib(n);
    final dtWib = toWib(dt);
    final dayDiff = DateTime.utc(
      nowWib.year,
      nowWib.month,
      nowWib.day,
    ).difference(DateTime.utc(dtWib.year, dtWib.month, dtWib.day)).inDays;
    if (dayDiff == 1) return const RelativeTime.yesterday();
    return const RelativeTime.date();
  }
}

enum RelativeKind { justNow, minutes, hours, yesterday, date }

class RelativeTime {
  const RelativeTime._(this.kind, this.value);
  const RelativeTime.justNow() : this._(RelativeKind.justNow, 0);
  const RelativeTime.minutes(int n) : this._(RelativeKind.minutes, n);
  const RelativeTime.hours(int n) : this._(RelativeKind.hours, n);
  const RelativeTime.yesterday() : this._(RelativeKind.yesterday, 0);
  const RelativeTime.date() : this._(RelativeKind.date, 0);

  final RelativeKind kind;
  final int value;
}
