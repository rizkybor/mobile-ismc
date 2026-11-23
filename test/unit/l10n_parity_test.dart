import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// PRD §5A: `app_id.arb` dan `app_en.arb` harus punya kunci yang sama dan
/// tidak ada nilai kosong.
void main() {
  Map<String, Object?> load(String name) =>
      jsonDecode(File('lib/l10n/$name').readAsStringSync())
          as Map<String, Object?>;

  Set<String> messageKeys(Map<String, Object?> arb) =>
      arb.keys.where((k) => !k.startsWith('@')).toSet();

  test('kunci ID == kunci EN', () {
    final id = messageKeys(load('app_id.arb'));
    final en = messageKeys(load('app_en.arb'));
    expect(en.difference(id), isEmpty, reason: 'hanya ada di EN');
    expect(id.difference(en), isEmpty, reason: 'hanya ada di ID');
  });

  test('tidak ada nilai kosong', () {
    for (final name in ['app_id.arb', 'app_en.arb']) {
      final arb = load(name);
      for (final key in messageKeys(arb)) {
        final v = arb[key];
        expect(v, isA<String>(), reason: '$name: $key');
        expect((v! as String).trim(), isNotEmpty, reason: '$name: $key');
      }
    }
  });

  test('placeholder sama di kedua bahasa', () {
    final id = load('app_id.arb');
    final en = load('app_en.arb');
    final re = RegExp(r'\{(\w+)\}');
    for (final key in messageKeys(id)) {
      final pid = re.allMatches(id[key]! as String).map((m) => m[1]).toSet();
      final pen = re.allMatches(en[key]! as String).map((m) => m[1]).toSet();
      expect(pen, equals(pid), reason: key);
    }
  });
}
