// Mendeteksi teks UI yang ditulis langsung di widget (PRD §5A: semua teks
// lewat l10n). Dipanggil di CI: `dart run tool/check_hardcoded_text.dart`.
//
// Aturan sederhana: di dalam `lib/` (kecuali `l10n/`), argumen pertama
// `Text(` / `Text.rich(` / `label:` / `hintText:` / `title:` tidak boleh
// berupa string literal yang mengandung huruf. Kecualian: baris dengan
// `// l10n-ignore`.
import 'dart:io';

final _patterns = [
  RegExp(r'''\bText\(\s*['"][^'"]*[A-Za-z]{2,}[^'"]*['"]'''),
  RegExp(
    r'''\b(label|hintText|title|tooltip|semanticLabel):\s*(const\s+)?(Text\(\s*)?['"][^'"]*[A-Za-z]{2,}[^'"]*['"]''',
  ),
];

void main() {
  final root = Directory('lib');
  final offenders = <String>[];
  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.contains('/l10n/')) continue;
    final lines = entity.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains('l10n-ignore')) continue;
      if (line.trimLeft().startsWith('//')) continue;
      if (_patterns.any((p) => p.hasMatch(line))) {
        offenders.add('${entity.path}:${i + 1}: ${line.trim()}');
      }
    }
  }
  if (offenders.isEmpty) {
    stdout.writeln('OK: tidak ada teks UI hard-code.');
    return;
  }
  stderr.writeln('Teks UI hard-code ditemukan (pakai context.l10n):');
  offenders.forEach(stderr.writeln);
  exitCode = 1;
}
