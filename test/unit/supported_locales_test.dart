import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/core/i18n/supported_locales.dart';

void main() {
  test('default & fallback ke id', () {
    expect(SupportedLocales.defaultLocale.languageCode, 'id');
    expect(SupportedLocales.fromCode(null).languageCode, 'id');
    expect(SupportedLocales.fromCode('fr').languageCode, 'id');
    expect(SupportedLocales.fromCode('en').languageCode, 'en');
  });
}
