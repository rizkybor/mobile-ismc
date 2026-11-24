import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/domain/pdf_assembler.dart';

void main() {
  final pdf = utf8.encode('%PDF-1.4\n1 0 obj<<>>endobj\n%%EOF\n');
  final b64 = base64Encode(pdf);
  // potong per 10 karakter (seperti CHUNK_CHARS web, hanya lebih kecil)
  final parts = [
    for (var i = 0; i < b64.length; i += 10)
      b64.substring(i, (i + 10).clamp(0, b64.length)),
  ];
  final chunks = [for (var i = 0; i < parts.length; i++) PdfChunk(i, parts[i])];

  test('gabung potongan (urutan acak) → byte PDF', () {
    final shuffled = [...chunks]..shuffle();
    final bytes = PdfAssembler.assemble(chunks.length, shuffled);
    expect(bytes, pdf);
    expect(PdfAssembler.looksLikePdf(bytes), isTrue);
  });

  test('jumlah kurang → PdfIncompleteException', () {
    expect(
      () => PdfAssembler.assemble(chunks.length, chunks.sublist(1)),
      throwsA(isA<PdfIncompleteException>()),
    );
  });

  test('nomor ganda/hilang → PdfIncompleteException', () {
    final bad = [...chunks]..[1] = PdfChunk(0, parts[1]);
    expect(
      () => PdfAssembler.assemble(chunks.length, bad),
      throwsA(isA<PdfIncompleteException>()),
    );
  });

  test('bukan PDF terdeteksi', () {
    expect(PdfAssembler.looksLikePdf(utf8.encode('hello')), isFalse);
  });
}
