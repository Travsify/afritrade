import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afritrad_mobile/features/auth/presentation/pages/auth_wrapper.dart'; // For navigation

import '../../../../core/constants/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import 'otp_verification_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  int _currentStep = 1;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _businessController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedCountry = "Nigeria";

  final List<String> _countries = [
    "Nigeria", "South Africa", "Kenya", "Ghana", "Rwanda", "Uganda", "Cameroon", "Côte d'Ivoire"
  ];

  bool _isLoading = false;
  bool _obscurePassword = true;

  void _nextStep() {
    if (_currentStep == 1) {
       // Validate name & country
       if (_nameController.text.isEmpty) {
          _showError("Full Name is required");
          return;
       }
       setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
       // Validate business name
       if (_businessController.text.isEmpty) {
          _showError("Business Name is required");
          return;
       }
       setState(() => _currentStep = 3);
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
       setState(() => _currentStep--);
    } else {
       Navigator.pop(context);
    }
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse(AppApiConfig.register),
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'country': _selectedCountry,
          'business_name': _businessController.text.trim(),
        }),
        headers: AppApiConfig.getHeaders(null),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['status'] == 'success') {
         if (mounted) {
            final user = data['user'];
            final otp = data['user']['otp_debug']; // Keep for easy testing as per plan
            
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OTPVerificationScreen(
                email: _emailController.text.trim(),
                phone: "", // Keep for API compatibility in OTP screen if needed, but email is target
                password: _passwordController.text.trim(),
              )),
            );
         }
      } else {
        _showError(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      _showError('Connection error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
          onPressed: _prevStep,
        ),
      ),
      body: Stack(
        children: [
          _buildBackgroundDecoration(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  FadeInDown(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                              ),
                              child: Text(
                                "STEP $_currentStep/3",
                                style: GoogleFonts.outfit(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Create your Account",
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Join thousands of traders moving money globally.",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        if (_currentStep == 1) ...[
                          _buildInputField(
                            controller: _nameController,
                            label: "Full Name",
                            hint: "John Doe",
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 24),
                          _buildCountryPicker(),
                        ],
                        if (_currentStep == 2) ...[
                          _buildInputField(
                            controller: _businessController,
                            label: "Business Name",
                            hint: "Afritrade Ventures",
                            icon: Icons.business_rounded,
                          ),
                        ],
                        if (_currentStep == 3) ...[
                           _buildInputField(
                            controller: _emailController,
                            label: "Email Address",
                            hint: "name@example.com",
                            icon: Icons.alternate_email_rounded,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            controller: _passwordController,
                            label: "Create Password",
                            hint: "••••••••",
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            controller: _confirmPasswordController,
                            label: "Confirm Password",
                            hint: "••••••••",
                            icon: Icons.lock_clock,
                            isPassword: true,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Must be at least 8 characters long",
                                  style: GoogleFonts.outfit(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : (_currentStep < 3 ? _nextStep : _register),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _currentStep < 3 ? "Continue" : "Create Account",
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_rounded, size: 20),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
                              children: [
                                const TextSpan(text: "By continuing, you agree to our "),
                                TextSpan(
                                  text: "Terms of Service",
                                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: " and "),
                                TextSpan(
                                  text: "Privacy Policy",
                                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
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

  Widget _buildBackgroundDecoration() {
    return Positioned(
      top: -50,
      left: -50,
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.05),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: TextField(
                controller: controller,
                obscureText: isPassword && _obscurePassword,
                keyboardType: keyboardType,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 15),
                  prefixIcon: Icon(icon, color: AppColors.textMuted, size: 22),
                  suffixIcon: isPassword
                      ? IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildCountryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Country",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCountry,
              dropdownColor: AppColors.surface,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
              isExpanded: true,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
              items: _countries.map((String country) {
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCountry = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

