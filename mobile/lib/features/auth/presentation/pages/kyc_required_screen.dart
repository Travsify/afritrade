import 'dart:io';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/kyc_provider.dart';

class KYCRequiredScreen extends StatefulWidget {
  const KYCRequiredScreen({super.key});

  @override
  State<KYCRequiredScreen> createState() => _KYCRequiredScreenState();
}

class _KYCRequiredScreenState extends State<KYCRequiredScreen> {
  final ImagePicker _picker = ImagePicker();
  
  Map<int, String> _stepStatus = {
    1: 'awaiting', // Government ID
    2: 'awaiting', // Facial Scan
    3: 'awaiting', // Proof of Address
  };

  bool _isProcessing = false;

  Future<void> _pickAndUpload(int step, String docType) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: step == 2 ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70,
      );

      if (file == null) return;

      setState(() {
        _isProcessing = true;
        _stepStatus[step] = 'uploading';
      });

      final result = await context.read<KYCProvider>().submitKYC(
        docType: docType,
        filePath: file.path,
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
          if (result['status'] == 'success') {
            _stepStatus[step] = 'completed';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$docType uploaded successfully!")),
            );
          } else {
            _stepStatus[step] = 'error';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'] ?? "Upload failed"), backgroundColor: Colors.red),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _stepStatus[step] = 'error';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kycProvider = context.watch<KYCProvider>();
    final isPending = kycProvider.status == KYCStatus.pending;
    final allCompleted = !_stepStatus.values.contains('awaiting') && 
                         !_stepStatus.values.contains('uploading') && 
                         !_stepStatus.values.contains('error');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          _buildBackgroundDecoration(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                children: [
                  FadeInDown(
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Icon(
                        isPending ? Icons.hourglass_empty_rounded : Icons.verified_user_rounded,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    child: Text(
                      isPending ? "Verification Pending" : "Identity Verification",
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      isPending
                          ? "We are reviewing your documents. This usually takes less than 24 hours."
                          : "Upload the following documents to fully unlock your account features.",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  if (!isPending) ...[
                    _buildKYCStepItem(
                      step: 1,
                      title: "Government Issued ID",
                      subtitle: "Passport or Driver's License",
                      icon: Icons.badge_outlined,
                      docType: "GOVT_ID",
                    ),
                    const SizedBox(height: 16),
                    _buildKYCStepItem(
                      step: 2,
                      title: "Facial Scan",
                      subtitle: "Live selfie verification",
                      icon: Icons.face_retouching_natural_rounded,
                      docType: "SELFIE",
                    ),
                    const SizedBox(height: 16),
                    _buildKYCStepItem(
                      step: 3,
                      title: "Proof of Address",
                      subtitle: "Utility bill or Bank statement",
                      icon: Icons.home_work_outlined,
                      docType: "ADDRESS_PROOF",
                    ),
                    const SizedBox(height: 40),
                    
                    if (allCompleted)
                      FadeInUp(
                        child: Text(
                          "All documents uploaded! Our team will review them shortly.",
                          style: GoogleFonts.outfit(color: AppColors.success, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ] else ...[
                     Container(
                       padding: const EdgeInsets.all(24),
                       decoration: BoxDecoration(
                         color: AppColors.surface,
                         borderRadius: BorderRadius.circular(20),
                         border: Border.all(color: AppColors.glassBorder),
                       ),
                       child: Column(
                         children: [
                           const CircularProgressIndicator(color: AppColors.primary),
                           const SizedBox(height: 24),
                           Text(
                             "Review in Progress",
                             style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                           ),
                           const SizedBox(height: 8),
                           Text(
                             "You can still browse the app, but some financial features remain restricted until verification is complete.",
                             style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
                             textAlign: TextAlign.center,
                           ),
                         ],
                       ),
                     ),
                  ],

                  const SizedBox(height: 32),
                  
                  // Debug Bypass for User Testing
                  TextButton(
                    onPressed: () => context.read<KYCProvider>().debugForceVerify(),
                    child: Text(
                      "DEBUG: Bypass for Preview",
                      style: GoogleFonts.outfit(color: AppColors.primary.withOpacity(0.3), fontSize: 10),
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

  Widget _buildKYCStepItem({
    required int step,
    required String title,
    required String subtitle,
    required IconData icon,
    required String docType,
  }) {
    final status = _stepStatus[step];
    bool isCompleted = status == 'completed';
    bool isUploading = status == 'uploading';

    return GestureDetector(
      onTap: (isCompleted || _isProcessing) ? null : () => _pickAndUpload(step, docType),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? AppColors.success.withOpacity(0.5) : AppColors.glassBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: (isCompleted ? AppColors.success : AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle_rounded : icon,
                color: isCompleted ? AppColors.success : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isUploading ? "Uploading..." : subtitle,
                    style: GoogleFonts.outfit(
                      color: isUploading ? AppColors.primary : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isUploading)
              const SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              )
            else
              Icon(
                isCompleted ? Icons.verified : Icons.add_a_photo_outlined,
                color: isCompleted ? AppColors.success : AppColors.textMuted,
                size: 20,
              ),
          ],
        ),
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
