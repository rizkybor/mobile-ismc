import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/domain/account_status.dart';

CustomerProfile c({
  String id = 'c',
  bool registered = true,
  bool verify = false,
  bool active = false,
  bool deleted = false,
  String createdAt = '2026-11-01T00:00:00.000Z',
}) => CustomerProfile(
  id: id,
  customerName: 'PT X',
  email: 'x@y.com',
  isCompany: true,
  isRegistered: registered,
  isVerify: verify,
  isActive: active,
  isDeleted: deleted,
  createdAt: createdAt,
);

void main() {
  group('AccountStatusRules.resolve (PRD F-02.1)', () {
    test('tidak ada dokumen → unregistered', () {
      expect(AccountStatusRules.resolve([]).status, AccountStatus.unregistered);
    });
    test('isRegistered && !isVerify && !isActive → waiting', () {
      expect(AccountStatusRules.resolve([c()]).status, AccountStatus.waiting);
    });
    test('isRegistered && isVerify && !isActive → inactive', () {
      expect(
        AccountStatusRules.resolve([c(verify: true)]).status,
        AccountStatus.inactive,
      );
    });
    test('lainnya → active (termasuk data lama tanpa isRegistered)', () {
      expect(
        AccountStatusRules.resolve([c(verify: true, active: true)]).status,
        AccountStatus.active,
      );
      expect(
        AccountStatusRules.resolve([
          c(registered: false, verify: true, active: true),
        ]).status,
        AccountStatus.active,
      );
    });
    test('dokumen yang dihapus diabaikan', () {
      final r = AccountStatusRules.resolve([
        c(id: 'del', deleted: true, verify: true, active: true),
      ]);
      expect(r.status, AccountStatus.unregistered);
      expect(r.customer, isNull);
    });
    test('data ganda: pakai yang terbaru (createdAt)', () {
      final r = AccountStatusRules.resolve([
        c(
          id: 'lama',
          createdAt: '2026-01-01T00:00:00Z',
          verify: true,
          active: true,
        ),
        c(id: 'baru', createdAt: '2026-11-20T00:00:00Z'),
      ]);
      expect(r.status, AccountStatus.waiting);
      expect(r.customer?.id, 'baru');
    });
  });

  group('CustomerProfile.fromMap', () {
    test('statusCustomer tanpa field → perusahaan; false → perorangan', () {
      expect(CustomerProfile.fromMap('a', {}).isCompany, isTrue);
      expect(
        CustomerProfile.fromMap('a', {'statusCustomer': false}).isCompany,
        isFalse,
      );
    });
    test('field null aman', () {
      final p = CustomerProfile.fromMap('a', {
        'customerName': null,
        'isDeleted': null,
      });
      expect(p.customerName, '');
      expect(p.isDeleted, isFalse);
    });
  });

  test('validatePhone hanya angka', () {
    expect(AccountStatusRules.validatePhone('081234'), isTrue);
    expect(AccountStatusRules.validatePhone('0812-34'), isFalse);
    expect(AccountStatusRules.validatePhone(''), isFalse);
  });
}
