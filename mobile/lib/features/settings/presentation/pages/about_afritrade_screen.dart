import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class AboutAfritradeScreen extends StatelessWidget {
  const AboutAfritradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackgroundDecoration(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        FadeInDown(
                          child: Hero(
                            tag: 'app_logo',
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: AppColors.glowShadow(AppColors.primary),
                              ),
                              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 50),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInDown(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            "Afritrade",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        FadeInDown(
                          delay: const Duration(milliseconds: 300),
                          child: Text(
                            "v1.4.2 (Elite Build)",
                            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 48),
                        
                        _buildInfoCard(
                          "Our Mission",
                          "To democratize global trade for African businesses through seamless, transparent, and secure cross-border payment solutions.",
                          Icons.rocket_launch_rounded,
                        ),
                        const SizedBox(height: 24),
                        
                        _buildInfoCard(
                          "Security First",
                          "Your transactions are protected by bank-grade 256-bit encryption and multi-factor authentication protocols.",
                          Icons.security_rounded,
                        ),
                        const SizedBox(height: 24),

                        _buildSocialLinks(),
                        const SizedBox(height: 60),
                        
                        Text(
                          "© 2026 Afritrade Technologies Inc.",
                          style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text("About Us", style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              content,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinks() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _socialIcon(Icons.language),
          const SizedBox(width: 24),
          _socialIcon(Icons.alternate_email_rounded),
          const SizedBox(width: 24),
          _socialIcon(Icons.share_rounded),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Icon(icon, color: Colors.white70, size: 22),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.03),
            ),
          ),
        ),
      ],
    );
  }
}
