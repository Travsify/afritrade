import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PinPad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspace;
  final bool showBiometrics;
  final VoidCallback? onBiometricsPressed;

  const PinPad({
    super.key, 
    required this.onDigitPressed, 
    required this.onBackspace,
    this.showBiometrics = false,
    this.onBiometricsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        children: [
          _buildRow(['1', '2', '3']),
          const SizedBox(height: 24),
          _buildRow(['4', '5', '6']),
          const SizedBox(height: 24),
          _buildRow(['7', '8', '9']),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showBiometrics 
                ? IconButton(
                    icon: const Icon(Icons.fingerprint, color: Colors.white, size: 32),
                    onPressed: onBiometricsPressed,
                  )
                : const SizedBox(width: 60),
              _buildDigit('0'),
              SizedBox(
                width: 60,
                child: IconButton(
                  icon: const Icon(Icons.backspace_outlined, color: Colors.white70),
                  onPressed: onBackspace,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: digits.map((d) => _buildDigit(d)).toList(),
    );
  }

  Widget _buildDigit(String digit) {
    return GestureDetector(
      onTap: () => onDigitPressed(digit),
      behavior: HitTestBehavior.translucent, // Improves touch response
      child: Container(
        height: 60,
        width: 60,
        alignment: Alignment.center,
        child: Text(
          digit,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
