import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/company_info.dart';
import '../providers/bill_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ripple_rings.dart';
import '../widgets/water_wave_loader.dart';
import 'home_screen.dart';

/// First screen shown on launch: plays a brief water-fill animation while
/// [BillProvider] loads saved rates, then fades into [HomeScreen].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _iconScale;
  late final Animation<double> _titleOpacity;
  late final AnimationController _bobController;
  late final Animation<double> _bobOffset;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _iconScale = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    );
    _titleOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _bobOffset = Tween<double>(
      begin: -4,
      end: 4,
    ).animate(CurvedAnimation(parent: _bobController, curve: Curves.easeInOut));

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final provider = context.read<BillProvider>();
    final minimumSplash = Future<void>.delayed(
      const Duration(milliseconds: 1400),
    );
    final loading = provider.isLoaded
        ? Future<void>.value()
        : provider.loadDefaults();
    await Future.wait([minimumSplash, loading]);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.soilDeep, AppColors.soil],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _iconScale,
                child: AnimatedBuilder(
                  animation: _bobOffset,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, _bobOffset.value),
                    child: child,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const RippleRings(size: 176),
                      Container(
                        width: 140,
                        height: 140,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 2,
                          ),
                        ),
                        child: const WaterWaveLoader(size: 132),
                      ),
                      const Icon(
                        Icons.water_drop_rounded,
                        size: 46,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _titleOpacity,
                child: Column(
                  children: [
                    const Text(
                      kCompanyName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Borewell Bill Calculator',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
