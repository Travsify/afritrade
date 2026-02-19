import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      title: 'Global\nAccounts',
      subtitle: 'BANKING WITHOUT BOUNDARIES',
      description:
          'Open high-limit USD, EUR, and GBP accounts in minutes. Fund locally and trade globally.',
      imagePath: 'assets/images/onboarding_challenge.png',
      icon: '🌍',
      gradientColors: [Color(0xFF4F46E5), Color(0xFF4338CA)],
      accentColor: Color(0xFF2DD4BF),
    ),
    OnboardingData(
      title: 'Supplier\nPayments',
      subtitle: 'CHINA & AFRICA FOCUS',
      description:
          'Pay suppliers in China, Dubai, and across Africa instantly. Transparent rates, zero hidden fees.',
      imagePath: 'assets/images/onboarding_bridge.png',
      icon: '🚢',
      gradientColors: [Color(0xFF4F46E5), Color(0xFF4338CA)],
      accentColor: Color(0xFF2DD4BF),
    ),
    OnboardingData(
      title: 'Virtual\nCards',
      subtitle: 'CORPORATE SPENDING',
      description:
          'Issue unlimited dollar virtual cards for your team\'s global subscriptions and ad spend.',
      imagePath: 'assets/images/onboarding_local.png',
      icon: '💳',
      gradientColors: [Color(0xFF4F46E5), Color(0xFF4338CA)],
      accentColor: Color(0xFF2DD4BF),
    ),
    OnboardingData(
      title: 'Instant\nKYB',
      subtitle: 'VERIFIED IN SECONDS',
      description:
          'Automated business verification using Identity Pass. No paperwork, just fast onboarding.',
      imagePath: 'assets/images/onboarding_global.png',
      icon: '🛡️',
      gradientColors: [Color(0xFF4F46E5), Color(0xFF4338CA)],
      accentColor: Color(0xFF2DD4BF),
    ),
    OnboardingData(
      title: 'Scale Your\nBusiness',
      subtitle: 'JOIN THE REVOLUTION',
      description:
          'Join thousands of African entrepreneurs growing their trade across the globe.',
      imagePath: 'assets/images/onboarding_success.png',
      icon: '🚀',
      gradientColors: [Color(0xFF4F46E5), Color(0xFF4338CA)],
      accentColor: Color(0xFF2DD4BF),
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
                      onTap: () async {
                        // Mark onboarding as completed
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isFirstTime', false);

                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation,
                                    secondaryAnimation) =>
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
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.15),
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: isActive ? 24 : 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: isActive
                            ? _pages[_currentPage].accentColor
                            : Colors.grey.withOpacity(0.3),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 32),

                // Navigation Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: GestureDetector(
                    onTap: () async {
                      if (_currentPage == _pages.length - 1) {
                        // Mark onboarding as completed
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isFirstTime', false);

                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation,
                                    secondaryAnimation) =>
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
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: _pages[_currentPage].accentColor,
                        boxShadow: [
                          BoxShadow(
                            color: _pages[_currentPage]
                                .accentColor
                                .withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
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
                            letterSpacing: 0.5,
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
  final String icon;
  final List<Color> gradientColors;
  final Color accentColor;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
    required this.icon,
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
      color: const Color(0xFF4F46E5), // Indigo background base
      child: Stack(
        children: [
          // Background Image with Gradient Overlay
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.4,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    data.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF4F46E5).withOpacity(0.8),
                        const Color(0xFF4F46E5).withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // White Shape at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  // Icon Box
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          data.icon,
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Title
                  FadeInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      data.title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Subtitle
                  FadeInLeft(
                    delay: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: data.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        data.subtitle,
                        style: GoogleFonts.outfit(
                          color: data.accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Description (inside the white area)
                  FadeInUp(
                    delay: const Duration(milliseconds: 450),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 150),
                      child: Text(
                        data.description,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF1F2937),
                          fontSize: 18,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
