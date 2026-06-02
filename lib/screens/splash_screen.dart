import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quetame_turismo/core/widgets/quetame_fact_cycler.dart';
import 'package:quetame_turismo/screens/main_screen.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const String _logoBicentenarioImagePath =
      'assets/images/Logo Bicentenario Quetame.png';
  static const String _escudoImagePath = 'assets/images/escudo_quetame.png';

  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startBootSequence());
  }

  Future<void> _startBootSequence() async {
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2900)),
      _precacheCriticalImages(),
    ]);
    _navigateToMain();
  }

  Future<void> _precacheCriticalImages() async {
    if (!mounted) return;
    final tasks = <Future<void>>[
      precacheImage(const AssetImage(_escudoImagePath), context),
      precacheImage(const AssetImage(_logoBicentenarioImagePath), context),
      precacheImage(
        const NetworkImage(
          'https://images.unsplash.com/photo-1516738901171-8eb4fc13bd20?auto=format&fit=crop&w=1400&q=80',
        ),
        context,
      ),
    ];
    await Future.wait(
      tasks.map(
        (task) => task.catchError((_) {
          return;
        }),
      ),
    ).timeout(
      const Duration(seconds: 5),
      onTimeout: () => <void>[],
    );
  }

  void _navigateToMain() {
    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF150F0C),
              Color(0xFF2D1B12),
              Color(0xFF0F0A08),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final escudoSize = constraints.maxWidth.clamp(
                            280.0,
                            440.0,
                          );
                          return SizedBox(
                            width: escudoSize,
                            height: escudoSize,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(36),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 10,
                                        sigmaY: 10,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(36),
                                          border: Border.all(
                                            color: AppColors.goldPrimary
                                                .withValues(alpha: 0.58),
                                          ),
                                          color: Colors.white.withValues(alpha: 0.08),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.goldPrimary
                                                  .withValues(alpha: 0.22),
                                              blurRadius: 26,
                                              offset: const Offset(0, 12),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(14),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(26),
                                          child: Image.asset(
                                            _logoBicentenarioImagePath,
                                            fit: BoxFit.contain,
                                            filterQuality: FilterQuality.medium,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const ColoredBox(
                                                color: Color(0xFF2A1B13),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.shield_rounded,
                                                    color: AppColors.goldPrimary,
                                                    size: 84,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -10,
                                  top: -10,
                                  child: Container(
                                    width: 96,
                                    height: 96,
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.goldPrimary
                                            .withValues(alpha: 0.82),
                                        width: 2,
                                      ),
                                      color: const Color(0xFF24170F),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        _escudoImagePath,
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.low,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const ColoredBox(
                                            color: Color(0xFF3A261A),
                                            child: Icon(
                                              Icons.image_rounded,
                                              color: AppColors.goldPrimary,
                                              size: 32,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando experiencia turística...',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.8,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Quetame 200 Años',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bicentenario 1826 - 2026',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.goldPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const QuetameFactCycler(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
