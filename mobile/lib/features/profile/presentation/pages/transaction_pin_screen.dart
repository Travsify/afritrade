import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/kyc_provider.dart';

class TransactionPinScreen extends StatefulWidget {
  final bool isChange;
  const TransactionPinScreen({super.key, this.isChange = false});

  @override
  State<TransactionPinScreen> createState() => _TransactionPinScreenState();
}

class _TransactionPinScreenState extends State<TransactionPinScreen> {
  String _pin = "";
  String _confirmPin = "";
  bool _isConfirming = false;

  void _onKeyTap(String value) {
    if (_pin.length < 4) {
      setState(() => _pin += value);
      if (_pin.length == 4) {
        if (!widget.isChange || _isConfirming) {
          _handleSubmit();
        } else {
          // In real app, we'd check against old pin or just move to "new pin"
          _confirmPin = _pin;
          _pin = "";
          _isConfirming = true;
          setState(() {});
        }
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _handleSubmit() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      context.read<KYCProvider>().setTransactionPin(_pin);
      _showSuccess();
    }
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isChange ? "PIN updated successfully!" : "PIN setup complete!"),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
          const SizedBox(height: 40),
          FadeInDown(
            child: Icon(
              widget.isChange ? Icons.lock_reset : Icons.shield_outlined,
              color: AppColors.primary,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              _isConfirming ? "Confirm New PIN" : (widget.isChange ? "Enter New PIN" : "Setup Transaction PIN"),
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            child: Text(
              "Used to authorize trades and withdrawals",
              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
          const SizedBox(height: 60),
          _buildPinDots(),
          const Spacer(),
          _buildKeypad(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        bool isFilled = index < _pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          height: 16,
          width: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? AppColors.primary : Colors.white.withOpacity(0.05),
            border: Border.all(color: isFilled ? AppColors.primary : AppColors.glassBorder),
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _buildKeypadRow(["1", "2", "3"]),
          const SizedBox(height: 20),
          _buildKeypadRow(["4", "5", "6"]),
          const SizedBox(height: 20),
          _buildKeypadRow(["7", "8", "9"]),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 60),
              _buildKey("0"),
              _buildBackspaceKey(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map((k) => _buildKey(k)).toList(),
    );
  }

  Widget _buildKey(String value) {
    return InkWell(
      onTap: () => _onKeyTap(value),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        height: 60,
        width: 60,
        alignment: Alignment.center,
        child: Text(
          value,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return InkWell(
      onTap: _onBackspace,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        height: 60,
        width: 60,
        alignment: Alignment.center,
        child: const Icon(Icons.backspace_outlined, color: Colors.white, size: 24),
      ),
    );
  }
}
