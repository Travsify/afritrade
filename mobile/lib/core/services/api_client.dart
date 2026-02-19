import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afritrad_mobile/core/constants/api_config.dart';

/// Centralized HTTP client with retry logic, token management, and error handling.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(milliseconds: 500);
  static const Duration _timeout = Duration(seconds: 30);

  /// Get auth headers from stored token.
  Future<Map<String, String>> _getHeaders({String? transactionPin}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final headers = AppApiConfig.getHeaders(token);
    if (transactionPin != null) {
      headers['X-Transaction-Pin'] = transactionPin;
    }
    return headers;
  }

  /// GET request with retry.
  Future<ApiResponse> get(String url, {String? transactionPin}) async {
    return _executeWithRetry(() async {
      final headers = await _getHeaders(transactionPin: transactionPin);
      return http.get(Uri.parse(url), headers: headers).timeout(_timeout);
    });
  }

  /// POST request with retry.
  Future<ApiResponse> post(String url, {Map<String, dynamic>? body, String? transactionPin}) async {
    return _executeWithRetry(() async {
      final headers = await _getHeaders(transactionPin: transactionPin);
      return http.post(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_timeout);
    });
  }

  /// PUT request with retry.
  Future<ApiResponse> put(String url, {Map<String, dynamic>? body}) async {
    return _executeWithRetry(() async {
      final headers = await _getHeaders();
      return http.put(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_timeout);
    });
  }

  /// DELETE request with retry.
  Future<ApiResponse> delete(String url) async {
    return _executeWithRetry(() async {
      final headers = await _getHeaders();
      return http.delete(Uri.parse(url), headers: headers).timeout(_timeout);
    });
  }

  /// Execute HTTP call with exponential backoff retry.
  Future<ApiResponse> _executeWithRetry(Future<http.Response> Function() request) async {
    int attempt = 0;
    Exception? lastError;

    while (attempt < _maxRetries) {
      try {
        final response = await request();
        return _handleResponse(response);
      } on TimeoutException {
        lastError = TimeoutException('Request timed out');
      } on SocketException catch (e) {
        lastError = e;
      } on http.ClientException catch (e) {
        lastError = e;
      } catch (e) {
        // Non-retryable error
        return ApiResponse(
          success: false,
          statusCode: 0,
          message: _friendlyError(e),
          data: null,
        );
      }

      attempt++;
      if (attempt < _maxRetries) {
        final delay = _baseDelay * (1 << attempt); // Exponential backoff
        debugPrint('API retry $attempt after ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      }
    }

    return ApiResponse(
      success: false,
      statusCode: 0,
      message: _friendlyError(lastError),
      data: null,
    );
  }

  /// Parse HTTP response into ApiResponse.
  ApiResponse _handleResponse(http.Response response) {
    Map<String, dynamic>? data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = {'raw': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(
        success: true,
        statusCode: response.statusCode,
        message: data?['message'] ?? 'Success',
        data: data,
      );
    }

    // Handle specific error codes
    String message;
    switch (response.statusCode) {
      case 401:
        message = 'Session expired. Please log in again.';
        break;
      case 403:
        message = data?['message'] ?? 'Access denied.';
        break;
      case 422:
        message = data?['message'] ?? 'Please check your input.';
        break;
      case 429:
        message = 'Too many requests. Please wait a moment.';
        break;
      case 500:
        message = 'Server error. Please try again later.';
        break;
      default:
        message = data?['message'] ?? 'Something went wrong (${response.statusCode}).';
    }

    return ApiResponse(
      success: false,
      statusCode: response.statusCode,
      message: message,
      data: data,
    );
  }

  /// Convert exception to user-friendly message.
  String _friendlyError(dynamic error) {
    if (error is TimeoutException) {
      return 'Connection timed out. Please check your internet connection.';
    }
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    }
    if (error is http.ClientException) {
      return 'Network error. Please try again.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}

/// Standardized API response wrapper.
class ApiResponse {
  final bool success;
  final int statusCode;
  final String message;
  final Map<String, dynamic>? data;

  ApiResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  /// Check if requires PIN setup
  bool get requiresPinSetup => data?['requires_pin_setup'] == true;

  @override
  String toString() => 'ApiResponse(success: $success, code: $statusCode, message: $message)';
}
