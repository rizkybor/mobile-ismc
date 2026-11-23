import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'supported_locales.dart';

const kLanguagePrefKey = 'app.language';

/// Instance SharedPreferences yang disuntik dari `main()` (sudah siap pakai).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('override di main()'),
);

/// Bahasa aktif. Pemasangan pertama selalu `id` (abaikan locale perangkat);
/// pilihan customer disimpan di `app.language` dan dipakai lagi saat dibuka.
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final saved = ref
        .read(sharedPreferencesProvider)
        .getString(kLanguagePrefKey);
    return SupportedLocales.fromCode(saved);
  }

  Future<void> setLocale(Locale locale) async {
    if (!SupportedLocales.all.contains(locale)) return;
    state = locale;
    await ref
        .read(sharedPreferencesProvider)
        .setString(kLanguagePrefKey, locale.languageCode);
  }

  Future<void> toggle() => setLocale(
    state == SupportedLocales.id ? SupportedLocales.en : SupportedLocales.id,
  );
}

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);
