import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/documents.dart';
import '../domain/pdf_assembler.dart';
import 'firebase_providers.dart';

typedef ProgressCallback = void Function(int done, int total);

/// Membaca arsip PDF (`{owner}/documents/{docId}` + `chunks`) dan menulisnya
/// ke cache aplikasi: `<cache>/documents/<key>.pdf` (PRD F-05.2, F-05.4).
class DocumentsRepository {
  DocumentsRepository(this._db);
  final FirebaseFirestore _db;

  static const _dirName = 'documents';

  Future<Directory> cacheDir() async {
    final base = await getTemporaryDirectory();
    final dir = Directory('${base.path}/$_dirName');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> cacheFile(CustomerDocument doc) async =>
      File('${(await cacheDir()).path}/${doc.cacheKey}.pdf');

  /// File cache bila sudah ada & tidak kosong.
  Future<File?> cached(CustomerDocument doc) async {
    final f = await cacheFile(doc);
    if (f.existsSync() && f.lengthSync() > 0) return f;
    return null;
  }

  /// Ambil (atau pakai cache) PDF. [onProgress] dipanggil per potongan.
  Future<File> fetchPdf(
    CustomerDocument doc, {
    ProgressCallback? onProgress,
  }) async {
    final existing = await cached(doc);
    if (existing != null) return existing;

    final ref = _db.doc('${doc.owner.path}/documents/${doc.docId}');
    final meta = (await ref.get()).data();
    if (meta == null) throw const PdfIncompleteException(0, 0);
    final chunksCount = meta['chunks'];
    if (chunksCount is! int || chunksCount <= 0) {
      if ((meta['path'] as String?)?.isNotEmpty ?? false) {
        throw const PdfLegacyException();
      }
      throw const PdfIncompleteException(0, 0);
    }
    onProgress?.call(0, chunksCount);
    final snap = await ref.collection('chunks').orderBy('n').get();
    final chunks = <PdfChunk>[];
    for (final d in snap.docs) {
      final data = d.data();
      chunks.add(
        PdfChunk(
          (data['n'] as num?)?.toInt() ?? -1,
          (data['data'] as String?) ?? '',
        ),
      );
      onProgress?.call(chunks.length, chunksCount);
    }
    final bytes = PdfAssembler.assemble(chunksCount, chunks);
    final file = await cacheFile(doc);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Hapus seluruh cache dokumen (saat keluar akun).
  Future<void> clearCache() async {
    final base = await getTemporaryDirectory();
    final dir = Directory('${base.path}/$_dirName');
    if (dir.existsSync()) await dir.delete(recursive: true);
  }
}

final documentsRepositoryProvider = Provider<DocumentsRepository>(
  (ref) => DocumentsRepository(ref.watch(firestoreProvider)),
);
