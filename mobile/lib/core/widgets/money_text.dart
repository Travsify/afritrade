import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

enum MoneyVisibility {
  visible,
  hidden,
}

class MoneyText extends StatelessWidget {
  final double amount;
  final String currency;
  final double size;
  final FontWeight fontWeight;
  final Color? color;
  final bool useColorSign;
  final MoneyVisibility visibility;
  final bool isCompact;

  const MoneyText({
    super.key,
    required this.amount,
    this.currency = 'USD',
    this.size = 16,
    this.fontWeight = FontWeight.w500,
    this.color,
    this.useColorSign = false,
    this.visibility = MoneyVisibility.visible,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (visibility == MoneyVisibility.hidden) {
      return Text(
        '****',
        style: GoogleFonts.jetBrainsMono(
          color: color ?? AppColors.textPrimary,
          fontSize: size,
          fontWeight: fontWeight,
          letterSpacing: -0.5,
        ),
      );
    }

    final format = NumberFormat.currency(
      symbol: _getSymbol(currency),
      decimalDigits: isCompact ? 0 : 2,
    );

    // If compact, specific logic might be needed, but for now we stick to standard formatting
    // or we could use NumberFormat.compactSimpleCurrency() but with our custom symbol logic.
    String formatted = format.format(amount);
    
    // Remove the currency code if format adds it, we handle symbol manually if needed
    // But NumberFormat.currency usually does a good job with standard codes.
    // For bespoke behavior (like just the amount), we might parse it. 
    // Let's stick to standard behavior for "GlobalLine" correctness and locale safety.

    Color displayColor = color ?? AppColors.textPrimary;
    if (useColorSign) {
        if (amount > 0) displayColor = AppColors.success;
        if (amount < 0) displayColor = AppColors.error;
    }

    return Text(
      formatted,
      style: GoogleFonts.jetBrainsMono(
        color: displayColor,
        fontSize: size,
        fontWeight: fontWeight,
        letterSpacing: -1.0, // Tighter tracking for numbers is more modern
      ),
    );
  }

  String _getSymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'NGN': return '₦';
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'CNY': return '¥';
      case 'ZAR': return 'R';
      case 'GHS': return '₵';
      case 'AED': return 'dh';
      default: return currencyCode;
    }
  }
}
