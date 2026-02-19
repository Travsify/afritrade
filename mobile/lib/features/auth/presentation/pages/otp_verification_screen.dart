import 'dart:async';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:afritrad_mobile/core/theme/app_colors.dart';
import 'package:afritrad_mobile/features/auth/presentation/pages/identity_info_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:afritrad_mobile/core/constants/api_config.dart';
import 'package:afritrad_mobile/features/auth/data/kyc_provider.dart';
import 'auth_wrapper.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String phone;
  final String password;

  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;
  int _counter = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Simulate sending OTP on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSimulatedOTP();
    });
  }

  void _showSimulatedOTP() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.mark_email_read_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Verification Code Sent",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "DEBUG: Use code '1234' to proceed",
                    style: GoogleFonts.outfit(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _startTimer() {
    _counter = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        setState(() => _counter--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    String otp = _controllers.map((e) => e.text).join();
    if (otp.length < 4) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(AppApiConfig.baseUrl + "/verify-otp"),
        body: jsonEncode({
          'email': widget.email,
          'otp': otp,
        }),
        headers: AppApiConfig.getHeaders(null),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
         final prefs = await SharedPreferences.getInstance();
         final user = data['user'];
         
         await prefs.setString('user_id', user['id'].toString());
         await prefs.setString('user_name', user['name'] ?? "");
         await prefs.setString('user_email', user['email']);
         if (data['token'] != null) {
            await prefs.setString('auth_token', data['token']);
         }
         await prefs.setBool('is_logged_in', true);

         if (mounted) {
            context.read<KYCProvider>().setLoggedIn(true);
            
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AuthWrapper()),
              (route) => false,
            );
         }
      } else {
        _showError(data['message'] ?? "Verification failed");
      }
    } catch (e) {
      _showError("Connection error. Please try again.");
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          _buildBackgroundDecoration(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  FadeInDown(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Text(
                            "STEP 2/4",
                            style: GoogleFonts.outfit(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Verify your Email",
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "We've sent a 4-digit code to\n${widget.email}",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  
                  // OTP Input Fields
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(4, (index) => _buildOTPField(index)),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyOTP,
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
                                : Text(
                                    "Verify & Continue",
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                "Didn't receive the code?",
                                style: GoogleFonts.outfit(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _counter == 0 ? () {
                                  _startTimer();
                                  _showSimulatedOTP();
                                } : null,
                                child: Text(
                                  _counter > 0 
                                      ? "Resend code in ${_counter}s"
                                      : "Resend Code",
                                  style: GoogleFonts.outfit(
                                    color: _counter == 0 ? AppColors.primary : AppColors.textMuted,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildOTPField(int index) {
    return Container(
      width: 70,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _controllers[index].text.isNotEmpty 
              ? AppColors.primary.withOpacity(0.5) 
              : AppColors.glassBorder
        ),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            counterText: "",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (index < 3) {
                _focusNodes[index + 1].requestFocus();
              } else {
                _focusNodes[index].unfocus();
                _verifyOTP();
              }
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned(
      bottom: -100,
      right: -100,
      child: Container(
        height: 300,
        width: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.03),
        ),
      ),
    );
  }
}
