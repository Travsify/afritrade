import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/services/anchor_service.dart';

class TaxReportScreen extends StatefulWidget {
  const TaxReportScreen({super.key});

  @override
  State<TaxReportScreen> createState() => _TaxReportScreenState();
}

class _TaxReportScreenState extends State<TaxReportScreen> {
  final AnchorService _anchorService = AnchorService();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Compliance Reporter", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(child: _buildHeaderCard()),
            const SizedBox(height: 32),
            FadeInUp(child: _buildSectionTitle("Available Reports")),
            const SizedBox(height: 16),
            FadeInUp(child: _buildSectionTitle("Available Reports")),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _anchorService.getTaxReports(),
              builder: (context, snapshot) {
                 if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No documents found", style: GoogleFonts.outfit(color: AppColors.textMuted)));
                }
                return Column(
                  children: snapshot.data!.map((rpt) => 
                    FadeInUp(child: _buildReportItem(rpt['name'], rpt['status']))
                  ).toList(),
                );
              },
            ),
            const SizedBox(height: 48),
            FadeInUp(delay: const Duration(milliseconds: 400), child: _buildComplianceTip()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Generating Q1 2026 Report...", style: GoogleFonts.outfit(color: Colors.white)),
              backgroundColor: AppColors.primary,
            ),
          );
          await _anchorService.generateTaxReport("Quarterly Summary");
          setState(() {}); // Refresh
          if(mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Report Generated!"), backgroundColor: AppColors.success),
            );
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text("Generate New Report"),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            "Standard Tier Compliance",
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Your trade history is fully documented.",
            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
    );
  }

  Widget _buildReportItem(String name, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(status, style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.download_rounded, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }

  Widget _buildComplianceTip() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.amber.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.amber),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Keep your trade reports updated to maintain your 'Gold Tier' trader status.",
              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
