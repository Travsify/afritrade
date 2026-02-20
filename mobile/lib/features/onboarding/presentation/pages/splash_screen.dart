import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';
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
    Future.delayed(const Duration(seconds: 4), () async {
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

        if (isFirstTime) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const OnboardingScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        } else {
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
                  painter: TradeNetworkPainter(
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

// Cinematic Trade Route Painter
class TradeNetworkPainter extends CustomPainter {
  final double animation;
  final Random random = Random(42); // Fixed seed

  TradeNetworkPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.stroke;

    // 1. Draw Radar Waves (concentric circles extending from center)
    for (int i = 0; i < 3; i++) {
      final waveProgress = (animation + (i * 0.33)) % 1.0;
      final radius = waveProgress * size.width * 0.8;
      final opacity = (1.0 - waveProgress).clamp(0.0, 1.0);
      
      paint.color = const Color(0xFF10B981).withOpacity(opacity * 0.1);
      paint.strokeWidth = 1;
      paint.style = PaintingStyle.stroke;
      canvas.drawCircle(center, radius, paint);
    }

    // 2. Draw "Trade Routes" (Curved lines from center to random points)
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.round;
    
    for (int i = 0; i < 12; i++) {
      // Destination points on a virtual globe/circle
      final angle = (i * (360 / 12)) * (pi / 180);
      final dist = size.width * 0.4 + (random.nextDouble() * 50);
      final destX = center.dx + cos(angle) * dist;
      final destY = center.dy + sin(angle) * dist;
      final dest = Offset(destX, destY);

      // Draw faint route line
      paint.color = Colors.white.withOpacity(0.05);
      paint.strokeWidth = 1;
      canvas.drawLine(center, dest, paint);

      // Draw moving packet/ship along the route
      final routeProgress = (animation * (1.0 + random.nextDouble())) % 1.0;
      // Calculate current position on the line
      final currX = center.dx + (destX - center.dx) * routeProgress;
      final currY = center.dy + (destY - center.dy) * routeProgress;
      
      // Draw packet
      paint.style = PaintingStyle.fill;
      paint.color = i % 2 == 0 ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
      paint.color = paint.color.withOpacity(0.6 * (1.0 - routeProgress)); // Fade as it goes out
      canvas.drawCircle(Offset(currX, currY), 3, paint);
      
      // Draw destination node
      paint.color = Colors.white.withOpacity(0.2);
      canvas.drawCircle(dest, 4, paint);
    }

    // 3. Ambient Particles (Stars/City Lights)
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      // Parallax-ish movement
      final shiftY = (animation * 50 * (i % 2 == 0 ? 1 : -1)); 
      final dy = (y + shiftY) % size.height;

      paint.color = Colors.white.withOpacity(random.nextDouble() * 0.15);
      canvas.drawCircle(Offset(x, dy), random.nextDouble() * 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(TradeNetworkPainter oldDelegate) =>
      animation != oldDelegate.animation;
}
