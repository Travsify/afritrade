import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/kyc_provider.dart';

class KYCRequiredScreen extends StatefulWidget {
  const KYCRequiredScreen({super.key});

  @override
  State<KYCRequiredScreen> createState() => _KYCRequiredScreenState();
}

class _KYCRequiredScreenState extends State<KYCRequiredScreen> {
  bool _isSubmitting = false;

  void _submitKYC() {
    setState(() => _isSubmitting = true);
    // Simulate KYC submission
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.read<KYCProvider>().updateStatus(KYCStatus.pending);
        setState(() => _isSubmitting = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final kycProvider = context.watch<KYCProvider>();
    final isPending = kycProvider.status == KYCStatus.pending;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackgroundDecoration(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Icon(
                        isPending ? Icons.hourglass_empty_rounded : Icons.verified_user_rounded,
                        color: AppColors.primary,
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeInUp(
                    child: Text(
                      isPending ? "Verification Pending" : "Identity Verification Required",
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      isPending
                          ? "We are reviewing your documents. This usually takes less than 24 hours. Hold tight!"
                          : "To ensure a secure trading environment, all traders must verify their identity before accessing the platform.",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  if (!isPending)
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Column(
                        children: [
                          _buildKYCStep(1, "Upload Government ID", Icons.badge_outlined),
                          const SizedBox(height: 16),
                          _buildKYCStep(2, "Facial Recognition Scan", Icons.face_retouching_natural_rounded),
                          const SizedBox(height: 16),
                          _buildKYCStep(3, "Proof of Address", Icons.home_work_outlined),
                          const SizedBox(height: 48),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitKYC,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 0,
                              ),
                              child: _isSubmitting
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      "Start Verification",
                                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                  
                  // Debug Bypass for User Testing
                  FadeIn(
                    delay: const Duration(seconds: 1),
                    child: TextButton(
                      onPressed: () => context.read<KYCProvider>().debugForceVerify(),
                      child: Text(
                        "DEBUG: Bypass for Preview",
                        style: GoogleFonts.outfit(color: AppColors.primary.withOpacity(0.5), fontSize: 12),
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

  Widget _buildKYCStep(int step, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        height: 300,
        width: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.05),
        ),
      ),
    );
  }
}
