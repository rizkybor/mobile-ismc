import 'package:flutter/material.dart';

import 'app_radius.dart';

abstract final class AppShapes {
  static final card = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.lg),
    side: const BorderSide(color: Color(0xFFEDF1F6)),
  );
  static final button = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
  );
  static final chip = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(999),
  );
  static OutlineInputBorder inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: color, width: width),
      );
}
