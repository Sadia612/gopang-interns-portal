import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1A5490);
  static const Color mediumBlue = Color(0xFF178FB4);
  static const Color cyan = Color(0xFF2BB6C6);
  static const Color background = Color(0xFFF5F8FC);
  static const Color mutedText = Color(0xFF71839A);

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    String? token;

    try {
      token = await _storage.read(key: 'auth_token');
    } catch (_) {
      token = null;
    }

    if (!mounted) return;

    if (token != null && token.trim().isNotEmpty) {
      Get.offAllNamed('/dashboard');
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 700;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 28,
            vertical: compact ? 20 : 32,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildHero(compact),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(bool compact) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 104 : 122,
          height: compact ? 104 : 122,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withValues(alpha: 0.12),
                blurRadius: 35,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: _companyLogo(),
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'WorkHub',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: primaryBlue,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'All work in one place',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: mutedText,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 28),
        Container(
          width: 58,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [mediumBlue, cyan],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Your workplace, simplified.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF52667D),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _companyLogo() {
    return Image.asset(
      'assets/images/gopang_logo.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryBlue, mediumBlue, cyan],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.work_rounded,
              size: 53,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: cyan,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 9),
            const Text(
              'GOPANG IT SOLUTION',
              style: TextStyle(
                color: primaryBlue,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Preparing your workspace...',
          style: TextStyle(
            color: mutedText,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 18),
        const SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: mediumBlue,
            backgroundColor: Color(0xFFE2EDF5),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'VERSION 1.0.0',
          style: TextStyle(
            color: Color(0xFF9AA9B9),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}