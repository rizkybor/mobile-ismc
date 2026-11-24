import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:ism_customer/domain/photo.dart';

Uint8List png(int w, int h) => Uint8List.fromList(
  img.encodePng(
    img.Image(width: w, height: h)..clear(img.ColorRgb8(10, 72, 143)),
  ),
);

void main() {
  test('landscape → data URL JPEG 256×256', () {
    final url = PhotoRules.toProfileDataUrl(png(640, 320));
    expect(url, startsWith('data:image/jpeg;base64,'));
    final bytes = PhotoRules.bytesFromDataUrl(url)!;
    final out = img.decodeJpg(bytes)!;
    expect(out.width, 256);
    expect(out.height, 256);
    expect(bytes.length, lessThan(60 * 1024));
  });

  test('portrait kecil tetap 256×256', () {
    final out = img.decodeJpg(
      PhotoRules.bytesFromDataUrl(PhotoRules.toProfileDataUrl(png(100, 300)))!,
    )!;
    expect(out.width, 256);
    expect(out.height, 256);
  });

  test('> 5 MB ditolak', () {
    expect(
      () =>
          PhotoRules.toProfileDataUrl(Uint8List(PhotoRules.maxSourceBytes + 1)),
      throwsA(isA<PhotoTooLargeException>()),
    );
  });

  test('bukan gambar → PhotoDecodeException', () {
    expect(
      () => PhotoRules.toProfileDataUrl(Uint8List.fromList([1, 2, 3])),
      throwsA(isA<PhotoDecodeException>()),
    );
  });

  test('bytesFromDataUrl: bukan data URL → null', () {
    expect(PhotoRules.bytesFromDataUrl('https://x/y.png'), isNull);
    expect(PhotoRules.bytesFromDataUrl('data:image/jpeg;base64,***'), isNull);
  });
}
