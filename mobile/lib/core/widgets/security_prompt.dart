import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/security_service.dart';
import '../theme/app_colors.dart';

class SecurityPrompt extends StatefulWidget {
  final String title;
  final Function(bool) onAuthenticated;

  const SecurityPrompt({
    super.key, 
    this.title = "Confirm Transaction",
    required this.onAuthenticated,
  });

  @override
  State<SecurityPrompt> createState() => _SecurityPromptState();
}

class _SecurityPromptState extends State<SecurityPrompt> {
  final List<String> _pin = [];
  final SecurityService _security = SecurityService();
  bool _canBiometric = false;
  bool _isLoading = false;
  String _error = "";

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final can = await _security.canCheckBiometrics();
    setState(() => _canBiometric = can);
    if (can) {
      _authenticateBiometrics();
    }
  }

  Future<void> _authenticateBiometrics() async {
    final success = await _security.authenticateBiometrics();
    if (success) {
      widget.onAuthenticated(true);
    }
  }

  void _onKeyPress(String key) {
    if (_pin.length < 4) {
      setState(() {
        _pin.add(key);
        _error = "";
      });
      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() => _pin.removeLast());
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);
    final res = await _security.verifyPin(_pin.join());
    setState(() => _isLoading = false);

    if (res['status'] == 'success') {
      widget.onAuthenticated(true);
    } else {
      setState(() {
        _pin.clear();
        _error = "Incorrect PIN. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Enter your transaction PIN",
            style: GoogleFonts.outfit(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          
          // PIN Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < _pin.length ? AppColors.primary : Colors.white10,
                  border: Border.all(
                    color: index < _pin.length ? AppColors.primary : Colors.white24,
                  ),
                ),
              );
            }),
          ),
          
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _error,
                style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 13),
              ),
            ),
            
          const SizedBox(height: 32),
          
          // Numpad
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ...["1", "2", "3", "4", "5", "6", "7", "8", "9"].map((key) => _buildKey(key)),
              _canBiometric 
                ? IconButton(icon: const Icon(Icons.fingerprint, color: AppColors.primary, size: 32), onPressed: _authenticateBiometrics)
                : const SizedBox(),
              _buildKey("0"),
              IconButton(icon: const Icon(Icons.backspace_outlined, color: Colors.white, size: 24), onPressed: _onDelete),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildKey(String key) {
    return GestureDetector(
      onTap: () => _onKeyPress(key),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          key,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
