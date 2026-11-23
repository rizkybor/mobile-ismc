import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_providers.dart';

/// Akses koleksi `orders`. Bentuk query **harus** persis PRD §6 agar lolos
/// Security Rules: `isDeleted == false && customerEmail == <email>`.
class OrdersRepository {
  OrdersRepository(this._db);
  final FirebaseFirestore _db;

  Query<Map<String, dynamic>> customerOrdersQuery(String email) => _db
      .collection('orders')
      .where('isDeleted', isEqualTo: false)
      .where('customerEmail', isEqualTo: email);

  Future<List<Map<String, dynamic>>> fetchCustomerOrders(String email) async {
    final snap = await customerOrdersQuery(email).get();
    return snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
  }
}

final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => OrdersRepository(ref.watch(firestoreProvider)),
);
