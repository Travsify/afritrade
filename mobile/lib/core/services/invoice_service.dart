import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_config.dart';

class InvoiceService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return AppApiConfig.getHeaders(token);
  }

  static const String _backendUrl = AppApiConfig.baseUrl;

  /// Get all invoices (sent + received)
  Future<List<Map<String, dynamic>>> getInvoices({String type = 'all'}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_backendUrl/invoices?type=$type'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['data'] ?? []);
        }
      }
    } catch (e) {
      debugPrint('Invoice Fetch Error: $e');
    }
    return [];
  }

  /// Create a new invoice (bill a user)
  Future<Map<String, dynamic>> createInvoice({
    required String recipientEmail,
    required double amount,
    required String currency,
    String? description,
    String? dueDate,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_backendUrl/invoices'),
        headers: headers,
        body: jsonEncode({
          'recipient_email': recipientEmail,
          'amount': amount,
          'currency': currency,
          'description': description,
          'due_date': dueDate,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  /// Pay an invoice
  Future<Map<String, dynamic>> payInvoice(int invoiceId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_backendUrl/invoices/$invoiceId/pay'),
        headers: headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }
}
