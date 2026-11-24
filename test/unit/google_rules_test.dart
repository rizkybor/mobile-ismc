import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/domain/auth_rules.dart';

void main() {
  test('usernameFromGoogle: nama depan, dibersihkan, fallback email', () {
    expect(
      AuthRules.usernameFromGoogle(
        displayName: 'Budi Santoso',
        email: 'b@x.com',
      ),
      'Budi',
    );
    expect(
      AuthRules.usernameFromGoogle(displayName: "O'Neil Jr", email: 'b@x.com'),
      'ONeil',
    );
    expect(
      AuthRules.usernameFromGoogle(displayName: '', email: 'ops.samudra@x.com'),
      'ops.samudra',
    );
    expect(
      AuthRules.usernameFromGoogle(displayName: '   ', email: '@@'),
      'customer',
    );
    expect(
      AuthRules.validateUsername(
        AuthRules.usernameFromGoogle(
          displayName: 'Budi Santoso',
          email: 'b@x.com',
        ),
      ),
      isTrue,
    );
  });
}
