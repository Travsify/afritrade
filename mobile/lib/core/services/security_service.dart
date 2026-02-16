import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final LocalAuthentication auth = LocalAuthentication();
  final String _baseUrl = 'https://admin.afritradepay.com/api/security.php';

  Future<bool> canCheckBiometrics() async {
    try {
      return await auth.canCheckBiometrics || await auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticateBiometrics() async {
    try {
      return await auth.authenticate(
        localizedReason: 'Please authenticate to complete your transaction',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      debugPrint("Biometric Error: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> checkPinStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) return {'is_pin_set': false};

      final response = await http.post(
        Uri.parse('$_baseUrl?action=check_status'),
        body: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Check PIN Status Error: $e");
    }
    return {'is_pin_set': false};
  }

  Future<Map<String, dynamic>> verifyPin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) return {'status': 'error', 'message': 'User not logged in'};

      final response = await http.post(
        Uri.parse('$_baseUrl?action=verify_pin'),
        body: {'user_id': userId, 'pin': pin},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Verify PIN Error: $e");
    }
    return {'status': 'error', 'message': 'Network error'};
  }

  Future<Map<String, dynamic>> setPin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) return {'status': 'error', 'message': 'User not logged in'};

      final response = await http.post(
        Uri.parse('$_baseUrl?action=set_pin'),
        body: {'user_id': userId, 'pin': pin},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Set PIN Error: $e");
    }
    return {'status': 'error', 'message': 'Network error'};
  }
}
