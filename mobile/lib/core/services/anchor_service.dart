import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afritrad_mobile/core/constants/api_config.dart';
import 'package:afritrad_mobile/core/services/api_client.dart';
import 'package:http/http.dart' as http;

class AnchorService {
  static final AnchorService _instance = AnchorService._internal();
  final ApiClient _apiClient = ApiClient();

  factory AnchorService() {
    return _instance;
  }

  AnchorService._internal() {
    _loadFromPersistence();
  }

  // In-memory clones of persisted data
  final List<Map<String, dynamic>> _accounts = [];
  final List<Map<String, dynamic>> _cards = [];

  final ValueNotifier<List<Map<String, dynamic>>> accountsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
  final ValueNotifier<List<Map<String, dynamic>>> cardsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);

  // Feature Data
  final List<Map<String, dynamic>> _beneficiaries = [];
  final List<Map<String, dynamic>> _scheduledPayments = [];
  final List<Map<String, dynamic>> _rateAlerts = [];
  final List<Map<String, dynamic>> _orders = [];
  final List<Map<String, dynamic>> _referrals = [];
  final List<Map<String, dynamic>> _bulkPayments = [];
  final List<Map<String, dynamic>> _taxReports = [];
  
  final ValueNotifier<List<Map<String, dynamic>>> beneficiariesNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);

  Future<List<Map<String, dynamic>>> getBeneficiaries() async {
    final response = await _apiClient.get('${AppApiConfig.baseUrl}/beneficiaries');
    if (response.success && response.data != null) {
      final dynamic rawData = response.data!['data'] ?? response.data!;
      if (rawData is List) {
        _beneficiaries.clear();
        _beneficiaries.addAll(rawData.map((e) => Map<String, dynamic>.from(e)));
        beneficiariesNotifier.value = List<Map<String, dynamic>>.from(_beneficiaries);
        await _saveToPersistence();
        return _beneficiaries;
      }
    }
    return List<Map<String, dynamic>>.from(_beneficiaries);
  }

  Future<Map<String, dynamic>> addBeneficiary(Map<String, dynamic> beneficiary) async {
    final response = await _apiClient.post(
      '${AppApiConfig.baseUrl}/beneficiaries',
      body: beneficiary,
    );
    if (response.success && response.data != null) {
      final newBeneficiary = Map<String, dynamic>.from(response.data!['data'] ?? response.data!);
      _beneficiaries.add(newBeneficiary);
      beneficiariesNotifier.value = List<Map<String, dynamic>>.from(_beneficiaries);
      await _saveToPersistence();
      return response.data!;
    }
    return {'status': 'error', 'message': response.message};
  }

  static const String _baseUrl = 'https://api.getanchor.co/api/v1';

  // Persistence Keys
  static const String _accountsKey = 'anchor_accounts';
  static const String _cardsKey = 'anchor_cards';
  static const String _beneficiariesKey = 'anchor_beneficiaries';
  static const String _scheduleKey = 'anchor_schedule';
  static const String _alertsKey = 'anchor_alerts';
  static const String _ordersKey = 'anchor_orders';
  static const String _referralsKey = 'anchor_referrals';
  static const String _bulkKey = 'anchor_bulk';
  static const String _reportsKey = 'anchor_reports';

  Future<void> _saveToPersistence() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountsKey, jsonEncode(_accounts));
    await prefs.setString(_cardsKey, jsonEncode(_cards));
    await prefs.setString(_beneficiariesKey, jsonEncode(_beneficiaries));
    await prefs.setString(_scheduleKey, jsonEncode(_scheduledPayments));
    await prefs.setString(_alertsKey, jsonEncode(_rateAlerts));
    await prefs.setString(_ordersKey, jsonEncode(_orders));
    await prefs.setString(_referralsKey, jsonEncode(_referrals));
    await prefs.setString(_bulkKey, jsonEncode(_bulkPayments));
    await prefs.setString(_reportsKey, jsonEncode(_taxReports));
  }

  Future<void> _loadFromPersistence() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsStr = prefs.getString(_accountsKey);
      final cardsStr = prefs.getString(_cardsKey);

      if (accountsStr != null) {
        final List<dynamic> decoded = jsonDecode(accountsStr);
        _accounts.clear();
        _accounts.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
        accountsNotifier.value = List<Map<String, dynamic>>.from(_accounts);
      }

      if (cardsStr != null) {
        final List<dynamic> decoded = jsonDecode(cardsStr);
        _cards.clear();
        _cards.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
        _cards.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
        cardsNotifier.value = List<Map<String, dynamic>>.from(_cards);
      }

      final benefStr = prefs.getString(_beneficiariesKey);
      if (benefStr != null) {
        final List<dynamic> decoded = jsonDecode(benefStr);
        _beneficiaries.clear();
        _beneficiaries.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
        beneficiariesNotifier.value = List<Map<String, dynamic>>.from(_beneficiaries);
      }

      final schedStr = prefs.getString(_scheduleKey);
      if (schedStr != null) {
         final List<dynamic> decoded = jsonDecode(schedStr);
        _scheduledPayments.clear();
        _scheduledPayments.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
      }

      final alertsStr = prefs.getString(_alertsKey);
      if (alertsStr != null) {
         final List<dynamic> decoded = jsonDecode(alertsStr);
        _rateAlerts.clear();
        _rateAlerts.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
      }

      final ordersStr = prefs.getString(_ordersKey);
      if (ordersStr != null) {
        final List<dynamic> decoded = jsonDecode(ordersStr);
        _orders.clear();
        _orders.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
      }

      final referralsStr = prefs.getString(_referralsKey);
      if (referralsStr != null) {
        final List<dynamic> decoded = jsonDecode(referralsStr);
        _referrals.clear();
        _referrals.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
      }

      final bulkStr = prefs.getString(_bulkKey);
      if (bulkStr != null) {
        final List<dynamic> decoded = jsonDecode(bulkStr);
        _bulkPayments.clear();
        _bulkPayments.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
      }

      final reportsStr = prefs.getString(_reportsKey);
      if (reportsStr != null) {
        final List<dynamic> decoded = jsonDecode(reportsStr);
        _taxReports.clear();
        _taxReports.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
      }
    } catch (e) {
      debugPrint('Error loading persistence: $e');
    }
  }

  // ============ WALLET ============
  // ============ WALLET ============
  Future<Map<String, dynamic>> getWalletBalance() async {
    final response = await _apiClient.get('${AppApiConfig.baseUrl}/wallet_balance.php');
    if (response.success && response.data != null) {
      return response.data!;
    }
    
    return {
      'total_usd': 0.00,
      'assets': [],
    };
  }

  // ============ VIRTUAL ACCOUNTS (NUBAN) ============

  Future<Map<String, dynamic>> getCryptoFundingAddress() async {
    final response = await _apiClient.get('${AppApiConfig.baseUrl}/crypto/address');
    if (response.success && response.data != null) {
      return response.data!;
    }
    return {'status': 'error', 'message': response.message};
  }

  Future<Map<String, dynamic>> paySupplier({
    required double amount,
    required String currency,
    required String recipient,
    required String destination,
    String? transactionPin,
  }) async {
    final response = await _apiClient.post(
      AppApiConfig.paySupplier,
      body: {
        'amount': amount,
        'currency': currency,
        'recipient': recipient,
        'destination': destination,
      },
      transactionPin: transactionPin,
    );
    return response.success ? response.data! : {'status': 'error', 'message': response.message};
  }

  Future<Map<String, dynamic>> schedulePayment(Map<String, dynamic> payment) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    payment['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    payment['status'] = 'Pending';
    _scheduledPayments.add(payment);
    await _saveToPersistence();
    return {'status': 'success', 'data': payment};
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final response = await _apiClient.get(AppApiConfig.transactions);
    if (response.success && response.data != null) {
      final dynamic rawData = response.data!['data'] ?? response.data!;
      if (rawData is List) {
        return List<Map<String, dynamic>>.from(rawData);
      }
    }
    return [];
  }

  Future<Map<String, dynamic>> getMarketRates() async {
    final response = await _apiClient.get(AppApiConfig.rates);
    if (response.success && response.data != null) {
      return response.data!;
    }
    return {'USD_NGN': 1550.0, 'EUR_USD': 1.08, 'CNY_USD': 0.14};
  }

  Future<double> getExchangeRate(String from, String to) async {
    final rates = await getMarketRates();
    final pair = '${from}_$to';
    if (rates.containsKey(pair)) {
      return (rates[pair] as num).toDouble();
    }
    // Try inverse
    final inversePair = '${to}_$from';
    if (rates.containsKey(inversePair)) {
      final inverseRate = (rates[inversePair] as num).toDouble();
      return inverseRate > 0 ? 1.0 / inverseRate : 1.0;
    }
    return 1.0;
  }

  Future<List<Map<String, dynamic>>> getScheduledPayments() async {
    return List<Map<String, dynamic>>.from(_scheduledPayments);
  }

  Future<Map<String, dynamic>> swapCurrency({
    required String from,
    required String to,
    required double amount,
    String? transactionPin,
  }) async {
    final response = await _apiClient.post(
      AppApiConfig.walletSwap,
      body: {
        'from_currency': from,
        'to_currency': to,
        'amount': amount,
      },
      transactionPin: transactionPin,
    );
    return response.success ? response.data! : {'status': 'error', 'message': response.message};
  }

  // ============ VIRTUAL ACCOUNTS (NUBAN) ============

  Future<List<Map<String, dynamic>>> getVirtualAccounts() async {
    final response = await _apiClient.get(AppApiConfig.virtualAccounts);
    
    if (response.success && response.data != null) {
      // Assuming response body is a List or has a 'data' field that is a list
      final dynamic rawData = response.data!['data'] ?? response.data!;
      if (rawData is List) {
        _accounts.clear();
        _accounts.addAll(rawData.map((e) => Map<String, dynamic>.from(e)));
        accountsNotifier.value = List<Map<String, dynamic>>.from(_accounts);
        await _saveToPersistence();
        return _accounts;
      }
    }

    return List<Map<String, dynamic>>.from(_accounts);
  }

  Future<Map<String, dynamic>> createVirtualAccount({required String currency, required String label}) async {
    final response = await _apiClient.post(
      AppApiConfig.virtualAccounts,
      body: {
        'currency': currency,
        'label': label,
      },
    );

    if (response.success && response.data != null) {
      final newAccount = Map<String, dynamic>.from(response.data!['data'] ?? response.data!);
      _accounts.add(newAccount);
      accountsNotifier.value = List<Map<String, dynamic>>.from(_accounts);
      await _saveToPersistence();
      return response.data!;
    }
    
    return {'status': 'error', 'message': response.message};
  }
  
  // ============ VIRTUAL CARDS ============

  Future<List<Map<String, dynamic>>> getVirtualCards() async {
    final response = await _apiClient.get(AppApiConfig.cards);
    
    if (response.success && response.data != null) {
      final List<dynamic> rawData = response.data!['data'] ?? response.data!;
      if (rawData is List) {
        _cards.clear();
        _cards.addAll(rawData.map((e) => Map<String, dynamic>.from(e)));
        cardsNotifier.value = List<Map<String, dynamic>>.from(_cards);
        await _saveToPersistence();
        return _cards;
      }
    }
    return List<Map<String, dynamic>>.from(_cards);
  }

  Future<Map<String, dynamic>> issueCard({required String label, required double amount, required String brand}) async {
    return _cardAction('issue', {
      'label': label,
      'amount': amount,
      'brand': brand
    });
  }

  Future<Map<String, dynamic>> fundCard({required String cardId, required double amount}) async {
    return _cardAction('fund', {
      'card_id': cardId,
      'amount': amount
    });
  }

  Future<Map<String, dynamic>> withdrawFromCard({required String cardId, required double amount}) async {
    return _cardAction('withdraw', {
      'card_id': cardId,
      'amount': amount
    });
  }

  Future<Map<String, dynamic>> freezeCard(String cardId) async {
    return _cardAction('freeze', {'card_id': cardId});
  }

  Future<Map<String, dynamic>> unfreezeCard(String cardId) async {
    return _cardAction('unfreeze', {'card_id': cardId});
  }

  Future<Map<String, dynamic>> _cardAction(String action, Map<String, dynamic> extras) async {
    final response = await _apiClient.post(
      '${AppApiConfig.baseUrl}/cards.php',
      body: {
        'action': action,
        ...extras
      },
    );

    if (response.success && response.data != null) {
      // Refresh list to keep UI in sync
      getVirtualCards();
      return response.data!;
    }
    
    return {'status': 'error', 'message': response.message};
  }

  // ============ BUSINESS PAYMENTS & SWAP (ANCHOR) ============

  // ============ MARKETS & RATES ============
  
  Future<List<Map<String, dynamic>>> getRateAlerts() async {
    final response = await _apiClient.get(AppApiConfig.alerts);
    if (response.success && response.data != null) {
      final dynamic rawData = response.data!['data'] ?? response.data!;
      if (rawData is List) {
        return List<Map<String, dynamic>>.from(rawData);
      }
    }
    return [];
  }

  Future<bool> createRateAlert(Map<String, dynamic> alert) async {
    final response = await _apiClient.post(
      AppApiConfig.alerts,
      body: {
        'currency_pair': alert['pair'].toString().replaceAll('/', '_'),
        'target_rate': alert['target'].toString(),
        'direction': alert['direction'].toString(),
      },
    );
    return response.success;
  }

  Future<bool> deleteRateAlert(int alertId) async {
    final response = await _apiClient.delete('${AppApiConfig.alerts}/$alertId');
    return response.success;
  }

  // ============ ORDERS (ANCHOR INVOICING) ============
  Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await _apiClient.get(AppApiConfig.invoices);
    if (response.success && response.data != null) {
      final dynamic rawData = response.data!['data'] ?? response.data!;
      if (rawData is List) {
        return List<Map<String, dynamic>>.from(rawData);
      }
    }
    return [];
  }

  Future<void> payOrder(String orderId) async {
    await _apiClient.post('${AppApiConfig.invoices}/$orderId/pay');
  }

  // ============ TRADE INSIGHTS ============
  Future<Map<String, dynamic>> getTradeInsights(String period) async {
    final response = await _apiClient.get('${AppApiConfig.tradeInsights}?period=$period');
    if (response.success && response.data != null) {
      return response.data!;
    }
    // Fallback if endpoint not yet fully implemented in backend
    return {
      'total_spent': 0.00,
      'spending_trend': [],
      'top_categories': [],
      'recommendations': []
    };
  }

  // ============ BULK PAYMENTS ============
  Future<List<Map<String, dynamic>>> getBulkPayments() async {
    final response = await _apiClient.get(AppApiConfig.bulkPayments);
    if (response.success && response.data != null) {
      final dynamic rawData = response.data!['data'] ?? response.data!;
      if (rawData is List) {
        return List<Map<String, dynamic>>.from(rawData);
      }
    }
    return [];
  }

  Future<void> processBulkPayments(List<String> ids, {String? transactionPin}) async {
    await _apiClient.post(
      '${AppApiConfig.bulkPayments}/process',
      body: {'ids': ids},
      transactionPin: transactionPin,
    );
  }

  Future<Map<String, dynamic>> payBill({Map<String, dynamic>? billData, String? type, double? amount, String? reference}) async {
    final response = await _apiClient.post(
      '${AppApiConfig.baseUrl}/bills/pay',
      body: billData ?? {
        'type': type,
        'amount': amount,
        'reference': reference,
      },
    );
    return response.success ? response.data! : {'status': 'error', 'message': response.message};
  }

  // ============ KYC & KYB ============
  
  // Check Status
  Future<Map<String, dynamic>> checkKYCStatus(String userId) async {
    final response = await _apiClient.get(AppApiConfig.kycStatus);
    return response.success ? response.data! : {'status': 'error', 'message': response.message};
  }

  // Upload Document (Multipart)
  Future<Map<String, dynamic>> uploadKYCDocument({
    required String userId,
    required String docType,
    required String filePath,
  }) async {
    try {
      // Use ApiClient's base logic for headers but handle Multipart manually as ApiClient doesn't support it yet
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      var request = http.MultipartRequest('POST', Uri.parse(AppApiConfig.kycUpload));
      request.headers.addAll(AppApiConfig.getHeaders(token));
      request.fields['user_id'] = userId;
      request.fields['document_type'] = docType;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        return jsonDecode(respStr);
      }
      return {'status': 'error', 'message': 'Upload failed with status ${response.statusCode}'};
    } catch (e) {
      debugPrint('KYC Upload Error: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> submitKYB({
    required String businessName,
    required String regNumber,
    required String industry,
  }) async {
    final response = await _apiClient.post(
      AppApiConfig.kycVerifyBusiness,
      body: {
        'business_name': businessName,
        'registration_number': regNumber,
        'industry': industry,
      },
    );
    return response.success ? response.data! : {'status': 'error', 'message': response.message};
  }
  
  // ============ BANNERS (CMS) ============
  Future<List<Map<String, dynamic>>> getBanners() async {
    final response = await _apiClient.get('${AppApiConfig.baseUrl}/banners');
    if (response.success && response.data != null) {
      final dynamic rawData = response.data!['data'] ?? response.data!;
      if (rawData is List) {
        return List<Map<String, dynamic>>.from(rawData);
      }
    }
    return [];
  }

  // ============ REFERRALS ============
  Future<Map<String, dynamic>> getReferralData() async {
    final response = await _apiClient.get(AppApiConfig.referrals);
    if (response.success && response.data != null) {
      return response.data!;
    }
    
    return {
      'code': 'OFFLINE',
      'list': [],
      'stats': {'total_earned': 0, 'referrals': 0, 'pending': 0}
    };
  }

  // ============ SECURITY & LIMITS ============
  
  Future<Map<String, dynamic>> getUserLimits() async {
    final response = await _apiClient.get(AppApiConfig.settings);
    if (response.success && response.data != null) {
      return response.data!;
    }
    return {
      'tier': 1, 
      'daily_limit': 1000.0, 
      'single_tx_limit': 200.0, 
      'remaining_daily': 1000.0
    };
  }

  Future<bool> isTransactionPinSet() async {
    final response = await _apiClient.get(AppApiConfig.pinStatus);
    if (response.success && response.data != null) {
      return response.data!['is_pin_set'] == true;
    }
    return false;
  }

  // ============ COMPLIANCE / TAX REPORTS ============
  Future<List<Map<String, dynamic>>> getTaxReports() async {
    final response = await _apiClient.get('${AppApiConfig.baseUrl}/tax_reports');
    if (response.success && response.data != null) {
      final dynamic rawData = response.data!['data'] ?? response.data!;
      if (rawData is List) {
        return List<Map<String, dynamic>>.from(rawData);
      }
    }
    return [];
  }

  Future<void> generateTaxReport(String type) async {
    await _apiClient.post(
      '${AppApiConfig.baseUrl}/tax_reports/generate',
      body: {'type': type},
    );
  }

  // ============ GENERIC WRAPPERS ============
  Future<Map<String, dynamic>?> sendGetRequest({
    required String endpoint,
    String? token, // Token is handled by ApiClient but kept for compat
  }) async {
    final response = await _apiClient.get('${AppApiConfig.baseUrl}$endpoint');
    return response.success ? response.data : null;
  }
}
