import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../data/firebase_providers.dart';
import '../../domain/app_user.dart';

/// Push notification (PRD F-06.4, **Fase 2**) — dimatikan lewat
/// `PUSH_ENABLED=false` di env. Saat aktif: minta izin, ambil token FCM,
/// simpan `pushTokens/{token}` (`uid, email, role: "customer", panel: false,
/// platform, updatedAt`), hapus saat keluar. Pengiriman membutuhkan Cloud
/// Function `sendPushOnNotification` (repo CSMS, paket Blaze) yang
/// diperluas untuk token mobile, serta GoogleService-Info.plist /
/// google-services.json (APNs/FCM) di build rilis.
class PushService {
  PushService(this._db);
  final FirebaseFirestore _db;
  String? _token;

  bool get enabled => Env.pushEnabled;

  Future<void> register(AppUser user) async {
    if (!enabled) return;
    try {
      final fm = FirebaseMessaging.instance;
      final perm = await fm.requestPermission();
      if (perm.authorizationStatus == AuthorizationStatus.denied) return;
      // API baru firebase_messaging: register() lalu token lewat onRegistered.
      final tokenFuture = fm.onRegistered.first.timeout(
        const Duration(seconds: 15),
      );
      await fm.register();
      final token = await tokenFuture;
      _token = token;
      await _db.doc('pushTokens/$token').set({
        'uid': user.uid,
        'email': user.email,
        'role': 'customer',
        'panel': false,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      });
    } on Object catch (e) {
      debugPrint('[push] register gagal: $e');
    }
  }

  Future<void> unregister() async {
    if (!enabled || _token == null) return;
    try {
      await _db.doc('pushTokens/$_token').delete();
      await FirebaseMessaging.instance.unregister();
    } on Object catch (e) {
      debugPrint('[push] unregister gagal: $e');
    }
    _token = null;
  }

  /// `orderId` dari data push → dipakai untuk deep link detail order.
  static String? orderIdFrom(RemoteMessage m) => m.data['orderId'] as String?;
}

final pushServiceProvider = Provider<PushService>(
  (ref) => PushService(ref.watch(firestoreProvider)),
);
