import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/security_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/kyc_provider.dart';
import 'pin_pad.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinVerificationModal extends StatefulWidget {
  final Function(String) onVerified;

  const PinVerificationModal({super.key, required this.onVerified});

  @override
  State<PinVerificationModal> createState() => _PinVerificationModalState();
}

class _PinVerificationModalState extends State<PinVerificationModal> {
  final _securityService = SecurityService();
  final _localAuth = LocalAuthentication();
  String _pin = "";
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final kycProvider = context.read<KYCProvider>();
    if (kycProvider.biometricsEnabled) {
      // Small delay to allow modal to open smoothly before prompting
      await Future.delayed(const Duration(milliseconds: 500));
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (canAuthenticate) {
        final bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to proceed',
          options: const AuthenticationOptions(biometricOnly: false),
        );

        if (didAuthenticate && mounted) {
          _onBiometricSuccess();
        }
      }
    } catch (e) {
      debugPrint("Biometric Error: $e");
    }
  }

  Future<void> _onBiometricSuccess() async {
    setState(() => _isLoading = true);
    // Retrieve PIN securely (simulated here from Prefs as per SecurityService)
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString('user_pin');

    if (mounted) {
      setState(() => _isLoading = false);
      if (storedPin != null) {
        Navigator.pop(context);
        widget.onVerified(storedPin);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Biometrics verified but no PIN found. Please enter PIN.")),
        );
      }
    }
  }
  
  void _onNumberPressed(String number) {
    if (_pin.length < 4) {
      setState(() {
        _hasError = false; // Reset error on typing
        _pin += number;
      });
      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _hasError = false;
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);

    final res = await _securityService.verifyPin(_pin);
    final isValid = res['status'] == 'success';

    if (mounted) {
      setState(() => _isLoading = false);
      if (isValid) {
        Navigator.pop(context); // Close modal
        widget.onVerified(_pin); // Callback success
      } else {
        setState(() {
          _hasError = true;
          _pin = ""; // Clear for retry
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if biometrics is enabled in settings
    final showBiometrics = context.watch<KYCProvider>().biometricsEnabled;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "Enter PIN",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Enter your 4-digit PIN to authorize payment",
            style: GoogleFonts.outfit(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 48),
          
          // PIN Circles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => _buildCircle(index)),
          ),
          
          if (_hasError) ...[
            const SizedBox(height: 24),
            Text(
              "Incorrect PIN",
              style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
          
          if (_isLoading) ...[
             const SizedBox(height: 24),
             CircularProgressIndicator(color: AppColors.primary),
          ],

          const Spacer(),
          
          // Keypad
          PinPad(
            onDigitPressed: _onNumberPressed,
            onBackspace: _onBackspace,
            showBiometrics: showBiometrics,
            onBiometricsPressed: _authenticate,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCircle(int index) {
    bool filled = _pin.length > index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      height: 16,
      width: 16,
      decoration: BoxDecoration(
        color: filled ? (_hasError ? Colors.red : AppColors.primary) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: filled 
            ? (_hasError ? Colors.red : AppColors.primary) 
            : AppColors.textMuted,
          width: 2
        ),
      ),
    );
  }
}
