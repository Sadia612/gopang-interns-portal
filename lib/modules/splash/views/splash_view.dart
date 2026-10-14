
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _visible = true);
      }
    });

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) {
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBFF),
      body: Stack(
        children: [
          // Soft background accents
          Positioned(
            top: -100,
            right: -90,
            child: _circle(260, const Color(0xFFF0EAFF)),
          ),
          Positioned(
            bottom: -120,
            left: -100,
            child: _circle(260, const Color(0xFFF3EFFF)),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = MediaQuery.sizeOf(context).height;
                final compact = height < 700;

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Brand header
                          Padding(
                            padding: const EdgeInsets.only(top: 22),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary.withValues(
                                          alpha: 0.20,
                                        ),
                                        blurRadius: 14,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.workspaces_rounded,
                                    color: Colors.white,
                                    size: 23,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GOPANG',
                                      style: TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.3,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'IT SOLUTION',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Main hero section
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: compact ? 42 : 64,
                            ),
                            child: AnimatedOpacity(
                              opacity: _visible ? 1 : 0,
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOut,
                              child: AnimatedSlide(
                                offset: _visible
                                    ? Offset.zero
                                    : const Offset(0, 0.07),
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutCubic,
                                child: Column(
                                  children: [
                                    // Layered app icon
                                    Container(
                                      width: 154,
                                      height: 154,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0EAFF),
                                        borderRadius: BorderRadius.circular(46),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 106,
                                          height: 106,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFFA78BFA),
                                                Color(0xFF7652E8),
                                                Color(0xFF5B3CC4),
                                              ],
                                            ),
                                            borderRadius:
                                            BorderRadius.circular(32),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.primary
                                                    .withValues(alpha: 0.22),
                                                blurRadius: 24,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.dashboard_rounded,
                                            size: 47,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: compact ? 32 : 42),

                                    const Text(
                                      'Gopang Interns',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 32,
                                        height: 1.2,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1.1,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'PORTAL',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 27,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 3.5,
                                      ),
                                    ),

                                    const SizedBox(height: 17),

                                    const Padding(
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        'Your attendance. Your daily work. '
                                            'Your progress.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 14,
                                          height: 1.7,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 25),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: AppTheme.border,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.verified_user_outlined,
                                            size: 16,
                                            color: AppTheme.primary,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Your professional workspace',
                                            style: TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Minimal footer
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24, top: 8),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 36,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: const LinearProgressIndicator(
                                      minHeight: 3,
                                      backgroundColor: Color(0xFFE8E0FF),
                                      valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                        AppTheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                const Text(
                                  'GOPANG IT SOLUTION',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.6,
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
