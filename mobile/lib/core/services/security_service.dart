import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api_config.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final LocalAuthentication auth = LocalAuthentication();

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

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return AppApiConfig.getHeaders(token);
  }

  Future<Map<String, dynamic>> checkPinStatus() async {
    try {
      final response = await http.get(
        Uri.parse(AppApiConfig.pinStatus),
        headers: await _getHeaders(),
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
      final response = await http.post(
        Uri.parse(AppApiConfig.pinVerify),
        headers: await _getHeaders(),
        body: jsonEncode({'pin': pin}),
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
      final response = await http.post(
        Uri.parse(AppApiConfig.pinSet),
        headers: await _getHeaders(),
        body: jsonEncode({'pin': pin}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Set PIN Error: $e");
    }
    return {'status' : 'error', 'message': 'Network error'};
  }
}
