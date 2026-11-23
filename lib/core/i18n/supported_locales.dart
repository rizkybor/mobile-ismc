import 'package:flutter/material.dart';

/// Bahasa yang didukung (PRD §5A). Urutan: default lebih dulu.
abstract final class SupportedLocales {
  static const id = Locale('id');
  static const en = Locale('en');
  static const all = [id, en];
  static const defaultLocale = id;

  static Locale fromCode(String? code) =>
      code == 'en' ? en : id; // tak dikenal → default `id`
}
