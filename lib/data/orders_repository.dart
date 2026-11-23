import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/i18n/locale_controller.dart';
import '../domain/order_models.dart';
import 'firebase_providers.dart';

/// Akses koleksi `orders`. Bentuk query **harus** persis PRD §6 agar lolos
/// Security Rules: `isDeleted == false && customerEmail == <email>`.
/// Hasil terakhir disimpan di `shared_preferences` (`cache.orders.<email>`)
/// sebagai cadangan mode offline selain cache Firestore.
class OrdersRepository {
  OrdersRepository(this._db, this._prefs);
  final FirebaseFirestore _db;
  final SharedPreferences _prefs;

  static String cacheKey(String email) => 'cache.orders.$email';

  Query<Map<String, dynamic>> customerOrdersQuery(String email) => _db
      .collection('orders')
      .where('isDeleted', isEqualTo: false)
      .where('customerEmail', isEqualTo: email);

  Future<List<Order>> fetchCustomerOrders(String email) async {
    final snap = await customerOrdersQuery(email).get();
    final orders = Order.sortNewest(
      snap.docs.map((d) => Order.fromMap(d.id, d.data())),
    );
    await _saveCache(email, orders);
    return orders;
  }

  Future<Order?> fetchOrder(String id) async {
    final doc = await _db.collection('orders').doc(id).get();
    final data = doc.data();
    return data == null ? null : Order.fromMap(doc.id, data);
  }

  Future<void> _saveCache(String email, List<Order> orders) async {
    final payload = jsonEncode({
      'savedAt': DateTime.now().toUtc().toIso8601String(),
      'orders': [
        for (final o in orders) {'id': o.id, ...o.toMap()},
      ],
    });
    await _prefs.setString(cacheKey(email), payload);
  }

  /// Order dari cache lokal, atau `null` bila belum ada.
  List<Order>? readCache(String email) {
    final raw = _prefs.getString(cacheKey(email));
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, Object?>;
      final list = decoded['orders'] as List<Object?>;
      return [
        for (final item in list.whereType<Map<Object?, Object?>>())
          Order.fromMap(
            (item['id'] as String?) ?? '',
            Map<String, Object?>.from(item),
          ),
      ];
    } on Object {
      return null;
    }
  }

  Future<void> clearCache(String email) => _prefs.remove(cacheKey(email));
}

final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => OrdersRepository(
    ref.watch(firestoreProvider),
    ref.watch(sharedPreferencesProvider),
  ),
);
