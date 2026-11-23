import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/activation/screens/activation_screen.dart';
import '../features/auth/screens/auth_screens.dart';
import '../features/auth/session_stub.dart';
import '../features/debug/debug_screen.dart';
import '../features/documents/screens/pdf_viewer_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/tracking/screens/order_detail_screen.dart';
import '../features/tracking/screens/tracking_screen.dart';
import 'app_shell.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Router aplikasi. Guard (`redirect`) urutan PRD §3:
/// belum login → (auth); login belum verifikasi → verify-email; `ready` → (app).
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _SessionListenable(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: notifier,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final status = ref.read(sessionStatusProvider);
      final path = state.uri.path;
      final inAuth = Routes.authRoutes.contains(path);
      if (path == Routes.debug || path == Routes.splash) return null;
      switch (status) {
        case SessionStatus.loading:
          return null;
        case SessionStatus.signedOut:
          return inAuth ? null : Routes.welcome;
        case SessionStatus.needsVerification:
          return path == Routes.verifyEmail ? null : Routes.verifyEmail;
        case SessionStatus.ready:
          return inAuth ? Routes.home : null;
      }
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.welcome, builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: Routes.verifyEmail,
        builder: (_, _) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.tracking,
                builder: (_, _) => const TrackingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.notifications,
                builder: (_, _) => const NotificationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/order/:orderId',
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            OrderDetailScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: Routes.activation,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ActivationScreen(),
      ),
      GoRoute(
        path: Routes.pdfViewer,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const PdfViewerScreen(),
      ),
      if (kDebugMode)
        GoRoute(
          path: Routes.debug,
          parentNavigatorKey: _rootKey,
          builder: (_, _) => const DebugScreen(),
        ),
    ],
  );
});

/// Menjembatani perubahan provider sesi ke `refreshListenable` go_router.
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    _sub = ref.listen<SessionStatus>(
      sessionStatusProvider,
      (_, _) => notifyListeners(),
    );
  }
  late final ProviderSubscription<SessionStatus> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
