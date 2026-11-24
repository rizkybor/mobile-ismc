/// Pemrosesan foto profil (PRD F-07.2): potong persegi (tengah), resize
/// 256×256, JPEG kualitas 85, lalu data URL untuk `users.photoURL`.
/// Murni Dart (paket `image`).
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class PhotoTooLargeException implements Exception {
  const PhotoTooLargeException(this.bytes);
  final int bytes;
}

class PhotoDecodeException implements Exception {
  const PhotoDecodeException();
}

abstract final class PhotoRules {
  static const maxSourceBytes = 5 * 1024 * 1024;
  static const size = 256;
  static const quality = 85;

  /// Mengembalikan data URL `data:image/jpeg;base64,...`.
  static String toProfileDataUrl(Uint8List source) {
    if (source.length > maxSourceBytes) {
      throw PhotoTooLargeException(source.length);
    }
    final decoded = img.decodeImage(source);
    if (decoded == null) throw const PhotoDecodeException();
    final oriented = img.bakeOrientation(decoded);
    final side = oriented.width < oriented.height
        ? oriented.width
        : oriented.height;
    final cropped = img.copyCrop(
      oriented,
      x: (oriented.width - side) ~/ 2,
      y: (oriented.height - side) ~/ 2,
      width: side,
      height: side,
    );
    final resized = img.copyResize(
      cropped,
      width: size,
      height: size,
      interpolation: img.Interpolation.average,
    );
    final jpeg = img.encodeJpg(resized, quality: quality);
    return 'data:image/jpeg;base64,${base64Encode(jpeg)}';
  }

  /// Byte dari data URL (untuk menampilkan avatar), atau `null`.
  static Uint8List? bytesFromDataUrl(String url) {
    if (!url.startsWith('data:')) return null;
    final i = url.indexOf('base64,');
    if (i < 0) return null;
    try {
      return base64Decode(url.substring(i + 7));
    } on FormatException {
      return null;
    }
  }
}
