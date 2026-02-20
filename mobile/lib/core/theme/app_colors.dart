import 'package:flutter/material.dart';

/// Premium color palette for Afritrade app
/// Modern fintech aesthetic with vibrant gradients and glassmorphism support
class AppColors {
  AppColors._();

  // ============ BASE COLORS (DEEP SPACE) ============
  
  /// Void - True black for modals and depth
  static const Color voidColor = Color(0xFF080816);

  /// Deep space - Main background color
  static const Color background = Color(0xFF0F0F23);
  
  /// Nebula - Elevated background for cards
  static const Color surface = Color(0xFF141432);
  
  /// Atmosphere - Lighter interactive surface
  static const Color surfaceLight = Color(0xFF1E1E3F);

  // ============ PRIMARY GRADIENT (GLOBAL LINE) ============
  
  /// Indigo - Primary gradient start
  static const Color primary = Color(0xFF4F46E5);
  
  /// Violet - Middle gradient
  static const Color primaryMid = Color(0xFF7C3AED);
  
  /// Cyan - Primary gradient end
  static const Color secondary = Color(0xFF06B6D4);

  // ============ ACCENT COLORS ============
  
  /// Coral - Accent highlights
  static const Color accent = Color(0xFFF97316);
  
  /// Electric pink - Secondary accent
  static const Color pink = Color(0xFFEC4899);
  
  /// Purple - For special elements
  static const Color purple = Color(0xFF8B5CF6);
  
  /// Amber/Gold - Warning and fund actions
  static const Color amber = Color(0xFFF59E0B);

  // ============ CURRENCY IDENTITIES ============
  
  /// Naira Green (NGN)
  static const Color currencyNGN = Color(0xFF00D09C);
  
  /// Dollar Blue (USD)
  static const Color currencyUSD = Color(0xFF3B82F6);
  
  /// Renminbi Gold (CNY)
  static const Color currencyCNY = Color(0xFFF59E0B);
  
  /// Rand Red (ZAR)
  static const Color currencyZAR = Color(0xFFEF4444);
  
  /// Euro Violet (EUR)
  static const Color currencyEUR = Color(0xFF8B5CF6);
  
  /// Pound Cyan (GBP)
  static const Color currencyGBP = Color(0xFF06B6D4);
  
  /// Cedi Orange (GHS)
  static const Color currencyGHS = Color(0xFFF97316);
  
  /// Dirham Rose (AED)
  static const Color currencyAED = Color(0xFFEC4899);

  // ============ SEMANTIC COLORS ============
  
  /// Success green - Positive amounts
  static const Color success = Color(0xFF22C55E);
  
  /// Error red - Negative amounts and errors
  static const Color error = Color(0xFFEF4444);
  
  /// Warning yellow
  static const Color warning = Color(0xFFFBBF24);

  // ============ TEXT COLORS ============
  
  /// Primary text color
  static const Color textPrimary = Colors.white;
  
  /// Secondary text color
  static const Color textSecondary = Color(0xFFB0B0C0);
  
  /// Muted text color
  static const Color textMuted = Color(0xFF6B7280);

  // ============ GRADIENTS ============
  
  /// Signature "GlobalLine" Gradient - Indigo to Cyan
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryMid, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Balance card gradient - More vibrant
  static const LinearGradient balanceCardGradient = LinearGradient(
    colors: [
      Color(0xFF4F46E5),
      Color(0xFF7C3AED),
      Color(0xFF06B6D4),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Coral to Pink gradient
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, pink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark gradient for overlays
  static const LinearGradient darkGradient = LinearGradient(
    colors: [
      Color(0xFF080816),
      Color(0xFF0F0F23),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ============ GLASSMORPHISM ============
  
  /// Glass background color
  static Color glassBackground = Colors.white.withOpacity(0.08);
  
  /// Glass border color
  static Color glassBorder = Colors.white.withOpacity(0.12);

  // ============ QUICK ACTION COLORS ============
  
  /// Send/Pay action color
  static const Color actionSend = Color(0xFF6366F1);
  
  /// Fund/Add action color
  static const Color actionFund = Color(0xFF06B6D4);
  
  /// Accounts action color
  static const Color actionAccounts = Color(0xFFF97316);
  
  /// Cards action color
  static const Color actionCards = Color(0xFFEC4899);

  // ============ FEATURE GRID COLORS ============
  
  /// Beneficiaries - Blue
  static const Color featureBeneficiaries = Color(0xFF3B82F6);
  
  /// Trade Insights - Green
  static const Color featureInsights = Color(0xFF10B981);
  
  /// Payment Scheduler - Purple
  static const Color featureScheduler = Color(0xFF8B5CF6);
  
  /// Business Calculator - Orange
  static const Color featureCalculator = Color(0xFFF59E0B);
  
  /// Rate Alerts - Red
  static const Color featureAlerts = Color(0xFFEF4444);
  
  /// Referral - Pink
  static const Color featureReferral = Color(0xFFEC4899);

  // ============ HELPER METHODS ============
  
  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Create a glow box shadow
  static List<BoxShadow> glowShadow(Color color, {double blur = 20, double spread = 0}) {
    return [
      BoxShadow(
        color: color.withOpacity(0.4),
        blurRadius: blur,
        spreadRadius: spread,
      ),
    ];
  }
}
