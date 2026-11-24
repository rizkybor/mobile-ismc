/// Merakit PDF dari potongan base64 di Firestore (PRD §9). Murni Dart.
library;

import 'dart:convert';
import 'dart:typed_data';

class PdfChunk {
  const PdfChunk(this.n, this.data);
  final int n;
  final String data;
}

/// Jumlah potongan tidak sesuai catatan arsip.
class PdfIncompleteException implements Exception {
  const PdfIncompleteException(this.expected, this.actual);
  final int expected;
  final int actual;
  @override
  String toString() =>
      'PdfIncompleteException(expected $expected, got $actual)';
}

/// Arsip lama berformat Cloud Storage (`path` tanpa `chunks`).
class PdfLegacyException implements Exception {
  const PdfLegacyException();
}

abstract final class PdfAssembler {
  /// Urutkan `n`, pastikan jumlah = [expectedChunks] dan tidak ada nomor yang
  /// hilang/ganda, gabungkan base64, decode ke byte.
  static Uint8List assemble(int expectedChunks, List<PdfChunk> chunks) {
    final sorted = [...chunks]..sort((a, b) => a.n.compareTo(b.n));
    if (sorted.length != expectedChunks) {
      throw PdfIncompleteException(expectedChunks, sorted.length);
    }
    for (var i = 0; i < sorted.length; i++) {
      if (sorted[i].n != i) throw PdfIncompleteException(expectedChunks, i);
    }
    final b64 = sorted.map((c) => c.data).join();
    return base64Decode(base64.normalize(b64));
  }

  static bool looksLikePdf(Uint8List bytes) =>
      bytes.length >= 4 &&
      bytes[0] == 0x25 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x44 &&
      bytes[3] == 0x46; // %PDF
}
