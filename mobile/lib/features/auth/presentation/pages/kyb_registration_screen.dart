import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/anchor_service.dart';
import '../../../auth/data/kyc_provider.dart';

class KYBRegistrationScreen extends StatefulWidget {
  const KYBRegistrationScreen({super.key});

  @override
  State<KYBRegistrationScreen> createState() => _KYBRegistrationScreenState();
}

class _KYBRegistrationScreenState extends State<KYBRegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form Controllers
  final _nameController = TextEditingController();
  final _regController = TextEditingController();
  final _industryController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isSubmitting = false;

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitKYB();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submitKYB() async {
    setState(() => _isSubmitting = true);
    
    final anchorService = AnchorService();
    final response = await anchorService.submitKYB(
      businessName: _nameController.text,
      regNumber: _regController.text,
      industry: _industryController.text,
    );

    if (mounted) {
      context.read<KYCProvider>().updateKybStatus(KYBStatus.pending);
      setState(() => _isSubmitting = false);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FadeInUp(
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.success, size: 64),
              const SizedBox(height: 24),
              Text(
                "Application Submitted",
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Our compliance team will review your business documents within 24-48 hours.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Back to Profile
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("Back to Profile", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _prevStep,
        ),
        title: Text(
          "Business Identity",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (idx) => setState(() => _currentStep = idx),
              children: [
                _buildBasicInfoStep(),
                _buildIndustryStep(),
                _buildAddressStep(),
                _buildDocsStep(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          bool isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return _buildStepContainer(
      title: "Business Details",
      subtitle: "Please enter your registered legal business name and certificate number.",
      children: [
        _buildTextField("Legal Business Name", _nameController, Icons.business),
        const SizedBox(height: 20),
        _buildTextField("Registration Number (RC/BN)", _regController, Icons.numbers),
      ],
    );
  }

  Widget _buildIndustryStep() {
    return _buildStepContainer(
      title: "Nature of Business",
      subtitle: "Help us understand your business sector and typical trade volume.",
      children: [
        _buildTextField("Industry Sector", _industryController, Icons.category),
        const SizedBox(height: 20),
        _buildDropdownField("Est. Monthly Volume", ["Below \$10k", "\$10k - \$50k", "\$50k - \$200k", "Above \$200k"]),
      ],
    );
  }

  Widget _buildAddressStep() {
    return _buildStepContainer(
      title: "Operations HQ",
      subtitle: "Where is your business physically located?",
      children: [
        _buildTextField("Registered Office Address", _addressController, Icons.location_on, maxLines: 3),
        const SizedBox(height: 20),
        _buildTextField("City / State", TextEditingController(), Icons.map),
      ],
    );
  }

  Widget _buildDocsStep() {
    return _buildStepContainer(
      title: "Document Upload",
      subtitle: "Submit scan of your registration certificate and proof of address.",
      children: [
        _buildDocUploadItem("CAC Certificate / Inc. Papers", true),
        const SizedBox(height: 16),
        _buildDocUploadItem("Utility Bill / Office Lease", false),
      ],
    );
  }

  Widget _buildStepContainer({required String title, required String subtitle, required List<Widget> children}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              title,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              subtitle,
              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
          const SizedBox(height: 40),
          ...children.map((child) => FadeInUp(delay: const Duration(milliseconds: 200), child: child)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.outfit(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.glassBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.glassBorder)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              dropdownColor: AppColors.surface,
              value: items[0],
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.outfit(color: Colors.white)))).toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocUploadItem(String label, bool isUploaded) {
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.file_copy_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          Text(
            isUploaded ? "Selected" : "Browse",
            style: GoogleFonts.outfit(color: isUploaded ? AppColors.success : AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: _isSubmitting 
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  _currentStep == _totalSteps - 1 ? "Submit Application" : "Continue",
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
