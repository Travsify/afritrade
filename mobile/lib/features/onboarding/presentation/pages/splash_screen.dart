import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:afritrad_mobile/features/auth/presentation/pages/auth_wrapper.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Particle animation controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Pulse animation for logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Navigate after delay
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AuthWrapper(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Deep blue
              Color(0xFF1E293B), // Slightly lighter blue
              Color(0xFF0F172A), // Deep blue
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles background
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    animation: _particleController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo with pulse
                  ZoomIn(
                    duration: const Duration(milliseconds: 1200),
                    child: ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        height: 140,
                        width: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 15,
                            ),
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withOpacity(0.15),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/icon/icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App Name with typewriter effect
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    duration: const Duration(milliseconds: 800),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Colors.white,
                          Color(0xFF10B981),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        "AFRITRADE",
                        style: GoogleFonts.outfit(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tagline
                  FadeInUp(
                    delay: const Duration(milliseconds: 1000),
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      "Global Payments, Local Currency",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Secondary message
                  FadeInUp(
                    delay: const Duration(milliseconds: 1400),
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        "Connecting Africa to the World",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom loading indicator
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: FadeIn(
                delay: const Duration(milliseconds: 2000),
                child: Column(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF10B981).withOpacity(0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Loading your experience...",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Particle painter for animated background
class ParticlePainter extends CustomPainter {
  final double animation;
  final Random random = Random(42); // Fixed seed for consistent particles

  ParticlePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw connection lines and particles
    for (int i = 0; i < 30; i++) {
      final baseX = (random.nextDouble() * size.width);
      final baseY = (random.nextDouble() * size.height);

      // Animate position
      final x = baseX + sin((animation * 2 * pi) + i) * 20;
      final y = baseY + cos((animation * 2 * pi) + i * 0.5) * 15;

      // Particle size based on position
      final particleSize = 2.0 + random.nextDouble() * 3;

      // Color variation
      final isGreen = i % 3 == 0;
      final isOrange = i % 5 == 0;

      paint.color = isOrange
          ? const Color(0xFFF59E0B).withOpacity(0.3 + random.nextDouble() * 0.2)
          : isGreen
              ? const Color(0xFF10B981)
                  .withOpacity(0.3 + random.nextDouble() * 0.2)
              : Colors.white
                  .withOpacity(0.1 + random.nextDouble() * 0.15);

      canvas.drawCircle(Offset(x, y), particleSize, paint);

      // Draw subtle connection lines between nearby particles
      if (i > 0 && i % 4 == 0) {
        final prevX = (random.nextDouble() * size.width) +
            sin((animation * 2 * pi) + (i - 1)) * 20;
        final prevY = (random.nextDouble() * size.height) +
            cos((animation * 2 * pi) + (i - 1) * 0.5) * 15;

        paint.strokeWidth = 0.5;
        paint.color = const Color(0xFF10B981).withOpacity(0.1);
        canvas.drawLine(Offset(x, y), Offset(prevX, prevY), paint);
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) =>
      animation != oldDelegate.animation;
}
