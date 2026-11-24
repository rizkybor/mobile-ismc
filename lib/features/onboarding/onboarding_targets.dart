import 'package:flutter/widgets.dart';

/// Kunci widget yang disorot panduan. Dipasang pada widget nyata agar
/// sorotan mengikuti tata letak sebenarnya.
abstract final class OnboardingTargets {
  static final homeStats = GlobalKey(debugLabel: 'onb-home-stats');
  static final tabTracking = GlobalKey(debugLabel: 'onb-tab-tracking');
  static final tabNotifications = GlobalKey(
    debugLabel: 'onb-tab-notifications',
  );
  static final tabProfile = GlobalKey(debugLabel: 'onb-tab-profile');
}
