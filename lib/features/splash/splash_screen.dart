import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/i18n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_loader.dart';
import '../auth/session_controller.dart';

/// Splash dalam aplikasi: melanjutkan splash native (kartu logo di atas
/// gradien), menganimasikan logo & tagline, menampilkan loader, lalu
/// mengarahkan ke Beranda / Welcome sesuai sesi. Tampil minimal
/// [minimumDuration] agar transisi tidak berkedip.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const minimumDuration = Duration(milliseconds: 1600);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _c,
    curve: const Interval(0, 0.7, curve: Curves.easeOutBack),
  );
  late final Animation<double> _textFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.45, 1, curve: Curves.easeOut),
  );
  late final Animation<Offset> _textSlide = Tween(
    begin: const Offset(0, 0.4),
    end: Offset.zero,
  ).animate(_textFade);

  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashScreen.minimumDuration, _tryNavigate);
  }

  void _tryNavigate() {
    if (!mounted || _navigated) return;
    final status = ref.read(sessionStatusProvider);
    if (status == SessionStatus.loading) {
      // Sesi belum ditentukan (Tahap 2): tunggu lalu coba lagi.
      _timer = Timer(const Duration(milliseconds: 300), _tryNavigate);
      return;
    }
    _navigated = true;
    context.go(switch (status) {
      SessionStatus.ready => Routes.home,
      SessionStatus.needsVerification => Routes.verifyEmail,
      SessionStatus.signedOut || SessionStatus.loading => Routes.welcome,
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          child: Stack(
            children: [
              Positioned(right: -90, top: -60, child: _orb(260)),
              Positioned(left: -70, bottom: 120, child: _orb(200)),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: Tween(begin: 0.82, end: 1.0).animate(_logoScale),
                      child: FadeTransition(
                        opacity: _logoScale,
                        child: Container(
                          width: 128,
                          height: 128,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 36,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Image.asset('assets/images/logo-ism.png'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          children: [
                            Text(
                              l10n.appName,
                              style: t.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.splashTagline.toUpperCase(),
                              style: t.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                letterSpacing: 2.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 56,
                child: FadeTransition(
                  opacity: _textFade,
                  child: Center(
                    child: AppLoader(
                      color: Colors.white,
                      label: l10n.splashLoading,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orb(double size) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.06),
      ),
    ),
  );
}
