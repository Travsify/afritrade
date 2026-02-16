import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/presentation/pages/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'The Challenge',
      subtitle: 'We understand your struggle',
      description:
          'Paying international suppliers is hard for African businesses. High fees, slow transfers, and currency volatility create barriers to growth.',
      imagePath: 'assets/images/onboarding_challenge.png',
      gradientColors: [
        const Color(0xFF0F172A),
        const Color(0xFF1E3A5F),
      ],
      accentColor: const Color(0xFFF59E0B),
    ),
    OnboardingData(
      title: 'Our Solution',
      subtitle: 'Bridging the gap',
      description:
          'Afritrade connects African businesses to global markets using stablecoin technology. Fast, secure, and transparent payments.',
      imagePath: 'assets/images/onboarding_bridge.png',
      gradientColors: [
        const Color(0xFF0F172A),
        const Color(0xFF064E3B),
      ],
      accentColor: const Color(0xFF10B981),
    ),
    OnboardingData(
      title: 'Fund Locally',
      subtitle: 'Pay in your currency',
      description:
          'Fund your wallet in Naira, Cedis, Shillings, or any local currency. We handle the conversion seamlessly.',
      imagePath: 'assets/images/onboarding_local.png',
      gradientColors: [
        const Color(0xFF0F172A),
        const Color(0xFF1E3A5F),
      ],
      accentColor: const Color(0xFF3B82F6),
    ),
    OnboardingData(
      title: 'Global Reach',
      subtitle: 'Pay suppliers worldwide',
      description:
          'Send payments to China, India, UAE, Europe, and beyond in minutes. No more waiting days for transfers.',
      imagePath: 'assets/images/onboarding_global.png',
      gradientColors: [
        const Color(0xFF0F172A),
        const Color(0xFF134E4A),
      ],
      accentColor: const Color(0xFF10B981),
    ),
    OnboardingData(
      title: 'Start Your Journey',
      subtitle: 'Join the revolution',
      description:
          'Join thousands of African traders growing their businesses globally. Your success story starts here.',
      imagePath: 'assets/images/onboarding_success.png',
      gradientColors: [
        const Color(0xFF0F172A),
        const Color(0xFF1E293B),
      ],
      accentColor: const Color(0xFFF59E0B),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingPage(data: _pages[index]);
            },
          ),

          // Top Skip Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < _pages.length - 1)
                    GestureDetector(
                      onTap: () {
                        _controller.animateToPage(
                          _pages.length - 1,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Navigation
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page Indicator with story progress
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;
                      final isPast = index < _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: isActive ? 32 : 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: isActive
                              ? _pages[_currentPage].accentColor
                              : isPast
                                  ? _pages[index]
                                      .accentColor
                                      .withOpacity(0.5)
                                  : Colors.white24,
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 30),

                // Navigation Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GestureDetector(
                    onTap: () {
                      if (_currentPage == _pages.length - 1) {
                        // Navigate to Login
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const LoginScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                            transitionDuration:
                                const Duration(milliseconds: 500),
                          ),
                        );
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            _pages[_currentPage].accentColor,
                            _pages[_currentPage].accentColor.withOpacity(0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _pages[_currentPage]
                                .accentColor
                                .withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Continue',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;
  final List<Color> gradientColors;
  final Color accentColor;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
    required this.gradientColors,
    required this.accentColor,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: data.gradientColors,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Illustration
              Expanded(
                flex: 5,
                child: FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: data.accentColor.withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        data.imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Text Content
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Subtitle
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: data.accentColor.withOpacity(0.15),
                        ),
                        child: Text(
                          data.subtitle.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: data.accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        data.description,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Space for navigation
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
