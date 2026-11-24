import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ism_customer/core/i18n/l10n.dart';
import 'package:ism_customer/core/i18n/locale_controller.dart';
import 'package:ism_customer/core/theme/app_theme.dart';
import 'package:ism_customer/domain/account_status.dart';
import 'package:ism_customer/domain/app_user.dart';
import 'package:ism_customer/domain/order_models.dart';
import 'package:ism_customer/features/activation/account_status_provider.dart';
import 'package:ism_customer/features/auth/session_controller.dart';
import 'package:ism_customer/features/home/orders_controller.dart';
import 'package:ism_customer/features/tracking/order_detail_provider.dart';
import 'package:ism_customer/shared/widgets/offline_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';

const testUser = AppUser(
  uid: 'uid-test',
  username: 'samudra.ops',
  name: 'Ops Samudra',
  email: 'ops@samudra.example.com',
  role: 'customer',
);

/// Sesi palsu untuk widget test (tanpa Firebase).
class FakeSessionController extends SessionController {
  FakeSessionController(this.initial);
  final Session initial;

  @override
  Session build() => initial;
}

/// Order palsu untuk widget test (tanpa Firebase).
class FakeOrders extends CustomerOrdersController {
  FakeOrders(this.orders, {this.fail = false});
  final List<Order> orders;
  final bool fail;

  @override
  Future<List<Order>> build() async {
    if (fail) throw Exception('offline');
    return orders;
  }
}

Future<ProviderContainer> makeContainer({
  Map<String, Object> prefs = const {},
  Session session = const Session.ready(testUser),
  AccountStatus account = AccountStatus.active,
  List<Order> orders = const [],
  bool ordersFail = false,
  Future<Order?> Function(String id)? orderDetail,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final overrides = [
    sharedPreferencesProvider.overrideWithValue(sp),
    isOfflineProvider.overrideWith((_) => Stream.value(false)),
    sessionProvider.overrideWith(() => FakeSessionController(session)),
    accountStatusProvider.overrideWith(
      (_) => Stream.value(AccountState(account)),
    ),
    customerOrdersProvider.overrideWith(
      () => FakeOrders(orders, fail: ordersFail),
    ),
    if (orderDetail != null)
      orderDetailProvider.overrideWith((ref, id) => orderDetail(id)),
  ];
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}

/// Membungkus satu layar dengan MaterialApp + l10n untuk widget test.
Widget wrapScreen(ProviderContainer container, Widget child, {Locale? locale}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.light(),
      locale: locale ?? const Locale('id'),
      supportedLocales: const [Locale('id'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );
}
