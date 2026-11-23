/// Status akun customer (PRD F-02.1, BRD §8 butir 6) — port dari CSMS
/// `customerLayout.vue` `applyStatus`. Murni Dart.
library;

enum AccountStatus { unregistered, waiting, inactive, active }

/// Dokumen `customers` milik akun (hanya field yang dipakai aplikasi).
class CustomerProfile {
  const CustomerProfile({
    required this.id,
    required this.customerName,
    required this.email,
    required this.isCompany,
    this.address = '',
    this.phone = '',
    this.telp = '',
    required this.isRegistered,
    required this.isVerify,
    required this.isActive,
    required this.isDeleted,
    this.createdAt = '',
  });

  final String id;
  final String customerName;
  final String email;

  /// `statusCustomer`: true = perusahaan (B2B), false = perorangan.
  /// Data lama tanpa field dianggap perusahaan (CSMS `isB2B`).
  final bool isCompany;
  final String address;
  final String phone;
  final String telp;
  final bool isRegistered;
  final bool isVerify;
  final bool isActive;
  final bool isDeleted;
  final String createdAt;

  factory CustomerProfile.fromMap(String id, Map<String, Object?> m) =>
      CustomerProfile(
        id: id,
        customerName: (m['customerName'] as String?) ?? '',
        email: (m['email'] as String?) ?? '',
        isCompany: m['statusCustomer'] != false,
        address: (m['address'] as String?) ?? '',
        phone: (m['phone'] as String?) ?? '',
        telp: (m['telp'] as String?) ?? '',
        isRegistered: m['isRegistered'] == true,
        isVerify: m['isVerify'] == true,
        isActive: m['isActive'] == true,
        isDeleted: m['isDeleted'] == true,
        createdAt: (m['createdAt'] as String?) ?? '',
      );
}

class AccountState {
  const AccountState(this.status, {this.customer});
  final AccountStatus status;
  final CustomerProfile? customer;

  bool get isActive => status == AccountStatus.active;
}

abstract final class AccountStatusRules {
  /// Pilih dokumen `isDeleted == false` terbaru (`createdAt` ISO string),
  /// lalu tentukan status seperti web.
  static AccountState resolve(Iterable<CustomerProfile> docs) {
    final live = docs.where((d) => !d.isDeleted).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (live.isEmpty) return const AccountState(AccountStatus.unregistered);
    final c = live.first;
    return AccountState(statusOf(c), customer: c);
  }

  static AccountStatus statusOf(CustomerProfile c) {
    if (c.isRegistered && !c.isVerify && !c.isActive) {
      return AccountStatus.waiting;
    }
    if (c.isRegistered && c.isVerify && !c.isActive) {
      return AccountStatus.inactive;
    }
    return AccountStatus.active;
  }

  /// No. HP hanya angka (web: `/^\d+$/`).
  static bool validatePhone(String v) => RegExp(r'^\d+$').hasMatch(v.trim());
}
