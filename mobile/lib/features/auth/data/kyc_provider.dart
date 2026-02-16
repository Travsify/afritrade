import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum KYCStatus { none, pending, verified, rejected }
enum KYBStatus { none, pending, verified, rejected }

class KYCProvider with ChangeNotifier {
  KYCStatus _kycStatus = KYCStatus.none;
  KYBStatus _kybStatus = KYBStatus.none;
  bool _isInitialized = false;
  bool _isLoggedIn = false;
  
  // Security settings
  bool _biometricsEnabled = false;
  String _transactionPin = ""; 
  String _appLanguage = "English (Global)"; 
  
  // Account Usage & Limits (Mock data for Elite features)
  double _monthlyLimit = 0.0;
  double _monthlyUsage = 0.0;
  int _referralCount = 0;
  double _referralEarnings = 0.0;
  
  // Profile & Gamification
  String? _profileImagePath;
  int _traderPoints = 1250; // Mock initial points for 'Silver' tier

  // KYB Metadata
  String? _kybRejectionReason;
  Map<String, String> _kybDocStatuses = {
    'CAC': 'awaiting',
    'Address': 'awaiting',
    'Director_ID': 'awaiting',
  };

  KYCStatus get status => _kycStatus; // Alias for backward compatibility
  KYCStatus get kycStatus => _kycStatus;
  KYBStatus get kybStatus => _kybStatus;
  String? get kybRejectionReason => _kybRejectionReason;
  Map<String, String> get kybDocStatuses => _kybDocStatuses;
  
  bool get isInitialized => _isInitialized;
  bool get isVerified => _kycStatus == KYCStatus.verified;
  bool get isKybVerified => _kybStatus == KYBStatus.verified;
  bool get isLoggedIn => _isLoggedIn;
  bool get biometricsEnabled => _biometricsEnabled;
  bool get hasTransactionPin => _transactionPin.isNotEmpty;
  String get appLanguage => _appLanguage;
  
  double get monthlyLimit => _monthlyLimit;
  double get monthlyUsage => _monthlyUsage;
  int get referralCount => _referralCount;
  double get referralEarnings => _referralEarnings;
  String? get profileImagePath => _profileImagePath;
  int get traderPoints => _traderPoints;

  KYCProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    
    _kycStatus = KYCStatus.values[prefs.getInt('kyc_status') ?? 0];
    _kybStatus = KYBStatus.values[prefs.getInt('kyb_status') ?? 0];
    _kybRejectionReason = prefs.getString('kyb_rejection_reason');
    
    final docStatusJson = prefs.getString('kyb_doc_statuses');
    if (docStatusJson != null) {
      _kybDocStatuses = Map<String, String>.from(json.decode(docStatusJson));
    }
    
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    _biometricsEnabled = prefs.getBool('biometrics_enabled') ?? false;
    _transactionPin = prefs.getString('user_pin') ?? "";
    _appLanguage = prefs.getString('app_language') ?? "English (Global)";
    _profileImagePath = prefs.getString('profile_image_path');
    _traderPoints = prefs.getInt('trader_points') ?? 1250;
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLoggedIn(bool value) async {
    _isLoggedIn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', value);
    notifyListeners();
  }

  Future<void> updateKycStatus(KYCStatus newStatus) async {
    _kycStatus = newStatus;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('kyc_status', newStatus.index);
    notifyListeners();
  }

  Future<void> updateKybStatus(KYBStatus newStatus, {String? reason, Map<String, String>? docStatuses}) async {
    _kybStatus = newStatus;
    _kybRejectionReason = reason;
    if (docStatuses != null) _kybDocStatuses = docStatuses;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('kyb_status', newStatus.index);
    if (reason != null) await prefs.setString('kyb_rejection_reason', reason);
    await prefs.setString('kyb_doc_statuses', json.encode(_kybDocStatuses));
    
    notifyListeners();
  }

  Future<void> toggleBiometrics(bool value) async {
    _biometricsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometrics_enabled', value);
    notifyListeners();
  }

  Future<void> setTransactionPin(String pin) async {
    _transactionPin = pin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', pin); // Aligned with SecurityService
    // Also mark as set in SecurityService's expected flag if needed, 
    // but SecurityService checks 'user_pin' existence or 'is_pin_set'.
    await prefs.setBool('is_pin_set', true); 
    notifyListeners();
  }

  Future<void> setAppLanguage(String language) async {
    _appLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', language);
    notifyListeners();
  }

  Future<void> setProfileImage(String path) async {
    _profileImagePath = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
    notifyListeners();
  }

  Future<void> addTraderPoints(int points) async {
    _traderPoints += points;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('trader_points', _traderPoints);
    notifyListeners();
  }

  // Alias for backward compatibility
  Future<void> updateStatus(KYCStatus newStatus) => updateKycStatus(newStatus);

  // Debug methods
  Future<void> debugForceVerify() async {
    await updateKycStatus(KYCStatus.verified);
    await updateKybStatus(KYBStatus.verified);
  }

  Future<void> debugRejectKyb() async {
    await updateKybStatus(
      KYBStatus.rejected,
      reason: "Incomplete Address Proof. The utility bill provided does not clearly show the business address.",
      docStatuses: {
        'CAC': 'verified',
        'Address': 'rejected',
        'Director_ID': 'verified',
      },
    );
  }

  Future<void> debugReset() async {
    await updateKycStatus(KYCStatus.none);
    await updateKybStatus(KYBStatus.none);
    await setLoggedIn(false);
  }
}
