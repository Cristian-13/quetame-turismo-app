import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quetame_turismo/core/content/quetame_municipal_facts.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

/// Insight Card premium con [PageView] automático y puntos indicadores.
class QuetameFactCycler extends StatefulWidget {
  final EdgeInsetsGeometry? padding;
  final double height;

  const QuetameFactCycler({
    super.key,
    this.padding,
    this.height = 148,
  });

  @override
  State<QuetameFactCycler> createState() => _QuetameFactCyclerState();
}

class _QuetameFactCyclerState extends State<QuetameFactCycler> {
  static const _deepBlack = Color(0xFF0D0D0F);
  static const _carbonGray = Color(0xFF2A2A2E);

  final PageController _pageController = PageController();
  Timer? _autoTimer;
  int _activePage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoCycle();
  }

  @override
  void activate() {
    super.activate();
    _startAutoCycle();
  }

  @override
  void deactivate() {
    _autoTimer?.cancel();
    _autoTimer = null;
    super.deactivate();
  }

  void _startAutoCycle() {
    if (_autoTimer != null) return;
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (_) => _nextPage());
  }

  void _nextPage() {
    if (!mounted || !_pageController.hasClients) return;
    final count = QuetameMunicipalFacts.items.length;
    if (count <= 1) return;
    final next = (_activePage + 1) % count;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facts = QuetameMunicipalFacts.items;

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_deepBlack, _carbonGray],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: facts.length,
                  onPageChanged: (index) {
                    setState(() => _activePage = index);
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.goldPrimary.withValues(
                                  alpha: 0.65,
                                ),
                                width: 1.2,
                              ),
                              color: AppColors.goldPrimary.withValues(
                                alpha: 0.12,
                              ),
                            ),
                            child: const Text(
                              '✨ SABÍAS QUÉ...',
                              style: TextStyle(
                                color: AppColors.goldPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                facts[index],
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
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
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(facts.length, (index) {
                    final active = index == _activePage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        color: active
                            ? AppColors.goldPrimary
                            : Colors.white.withValues(alpha: 0.28),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
