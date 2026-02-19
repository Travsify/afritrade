import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_config.dart';

class SettlementService {
  // Use the central API config
  static const String _backendUrl = AppApiConfig.baseUrl; 

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return AppApiConfig.getHeaders(token);
  }

  Future<Map<String, dynamic>> paySupplier({
    required double amount,
    required String currency, // e.g. 'CNY', 'GBP'
    required String recipient,
    required String destination,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_backendUrl/payment/supplier'),
        headers: headers,
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'recipient_name': recipient,
          'bank_details': destination,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data; // Expected {status: success, message: ..., reference: ...}
      } else {
        return {
          'status': 'error', 
          'message': data['message'] ?? 'Payment failed'
        };
      }
    } catch (e) {
      debugPrint('Settlement Error: $e');
      return {'status': 'error', 'message': 'Network error occurred'};
    }
  }
}
