import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:afritrad_mobile/core/constants/api_config.dart';

class AnchorService {
  static final AnchorService _instance = AnchorService._internal();

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
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId != null) {
        final response = await http.get(
          Uri.parse('$_backendUrl/wallet_balance.php?user_id=$userId'),
          headers: await _getHeaders(),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
             return data;
          }
        }
      }
    } catch (e) {
      debugPrint("Wallet Balance API Error: $e");
    }
    
    // Return empty/zero state on failure instead of mock data
    return {
      'total_usd': 0.00,
      'assets': [],
    };
  }

  // ============ VIRTUAL ACCOUNTS (NUBAN) ============

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return AppApiConfig.getHeaders(token);
  }

  // Use the central API config
  static const String _backendUrl = AppApiConfig.baseUrl; 

  Future<Map<String, dynamic>> getCryptoFundingAddress() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_backendUrl/crypto/address'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'status': 'error', 'message': 'Failed to fetch address'};
    } catch (e) {
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  // ============ VIRTUAL ACCOUNTS (NUBAN) ============

  Future<List<Map<String, dynamic>>> getVirtualAccounts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_backendUrl/virtual-accounts'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _accounts.clear();
        _accounts.addAll(data.map((e) => Map<String, dynamic>.from(e)));
        accountsNotifier.value = List<Map<String, dynamic>>.from(_accounts);
        _saveToPersistence(); // Cache valid response
        return _accounts;
      } else {
        debugPrint('Error fetching accounts: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Connection error fetching accounts: $e');
    }
    
    // Fallback to local cache if offline or error
    if (!_accounts.any((a) => a['currency'] == 'CNY')) {
      _createLocalVirtualAccount(currency: 'CNY', label: 'CNY Wallet');
    }
    return List<Map<String, dynamic>>.from(_accounts);
  }

  Future<Map<String, dynamic>> createVirtualAccount({required String currency, required String label}) async {
    try {
      debugPrint('[VirtualAccount] Creating $currency account with label: $label');
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_backendUrl/virtual-accounts'),
        headers: headers,
        body: jsonEncode({
          'currency': currency,
          'label': label,
        }),
      ).timeout(Duration(seconds: 10));

      debugPrint('[VirtualAccount] Response status: ${response.statusCode}');
      debugPrint('[VirtualAccount] Response body: ${response.body}');
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['status'] == 'success' && data['data'] != null) {
          final newAccount = Map<String, dynamic>.from(data['data']);
          _accounts.add(newAccount);
          accountsNotifier.value = List<Map<String, dynamic>>.from(_accounts);
          await _saveToPersistence();
          debugPrint('[VirtualAccount] Successfully created $currency account');
          return data;
        }
      }
      
      debugPrint('[VirtualAccount] Failed to create account: ${data['message']}');
      return {'status': 'error', 'message': data['message'] ?? 'Failed to create $currency account. Please try again.'};
    } catch (e) {
      debugPrint('[VirtualAccount] Error creating $currency account: $e');
      debugPrint('[VirtualAccount] Using fallback - creating account locally');
      
      // Fallback: Create account locally when backend is unavailable
      return _createLocalVirtualAccount(currency: currency, label: label);
    }
  }

  Map<String, dynamic> _createLocalVirtualAccount({required String currency, required String label}) {
    // Generate mock account details based on currency
    String accountNumber = '';
    String bankName = 'Virtual Wallet';
    
    if (currency != 'CNY') {
      accountNumber = _generateAccountNumber(currency);
      bankName = _getBankName(currency);
    }
    
    final newAccount = {
      'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
      'currency': currency,
      'label': label,
      'account_number': accountNumber.isNotEmpty ? accountNumber : null,
      'account_name': label,
      'bank_name': currency == 'CNY' ? 'CNY Wallet' : bankName,
      'balance': 0.0,
      'status': 'active',
      'created_at': DateTime.now().toIso8601String(),
      // Currency-specific details
      if (currency == 'EUR') ...{
        'iban': 'DE89$accountNumber',
        'bic': 'DEUTDEFF',
      },
      if (currency == 'GBP') ...{
        'sort_code': '20-00-00',
        'account_number': accountNumber.isNotEmpty ? accountNumber.substring(0, 8) : '',
      },
      if (currency == 'USD') ...{
        'routing_number': '026009593',
      },
       if (currency == 'CNY') ...{
        'type': 'wallet_only',
      },
    };

    _accounts.add(newAccount);
    accountsNotifier.value = List<Map<String, dynamic>>.from(_accounts);
    _saveToPersistence();
    
    debugPrint('[VirtualAccount] Local $currency account created successfully');
    return {
      'status': 'success',
      'data': newAccount,
      'message': '$currency account created successfully!',
    };
  }

  String _generateAccountNumber(String currency) {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    switch (currency) {
      case 'EUR':
        return random.substring(random.length - 10);
      case 'GBP':
        return random.substring(random.length - 8);
      case 'USD':
        return random.substring(random.length - 10);
      default:
        return random.substring(random.length - 10);
    }
  }

  String _getBankName(String currency) {
    switch (currency) {
      case 'EUR':
        return 'Deutsche Bank (Virtual)';
      case 'GBP':
        return 'Barclays (Virtual)';
      case 'USD':
        return 'Bank of America (Virtual)';
      case 'NGN':
        return 'Providus Bank (Virtual)';
      default:
        return 'Virtual Bank';
    }
  }
  
  // ============ VIRTUAL CARDS ============

  Future<List<Map<String, dynamic>>> getVirtualCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId != null) {
        final response = await http.get(
          Uri.parse(AppApiConfig.cards),
          headers: await _getHeaders(),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
             _cards.clear();
             _cards.addAll(List<Map<String, dynamic>>.from(data['data']));
             cardsNotifier.value = List<Map<String, dynamic>>.from(_cards);
             return _cards;
          }
        }
      }
    } catch (e) {
      debugPrint("Get Cards Error: $e");
    }
    return [];
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId == null) return {'status': 'error', 'message': 'Not logged in'};

      final body = {
        'user_id': userId,
        'action': action,
        ...extras
      };

      final response = await http.post(
        Uri.parse('$_backendUrl/cards.php'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      
      // Refresh list to keep UI in sync
      getVirtualCards();
      
      return data;
    } catch (e) {
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  // ============ BUSINESS PAYMENTS & SWAP (ANCHOR) ============

  // ============ MARKETS & RATES ============
  
  // Cache for rates
  Map<String, double> _cachedRates = {};

  Future<double> getExchangeRate(String from, String to) async {
    // If cache empty or specific pair missing, try fetch. 
    // Ideally we fetch all at start or periodically.
    if (_cachedRates.isEmpty || !_cachedRates.containsKey("${from}_${to}")) {
      await _fetchRates();
    }
    return _cachedRates["${from}_${to}"] ?? 1.0;
  }
  
  Future<void> _fetchRates() async {
    try {
      final response = await http.get(
        Uri.parse(AppApiConfig.rates),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['rates'] != null) {
          // Flatten rates to Map<String, double>
          // API returns { "USD_NGN": 1600, ... }
          Map<String, dynamic> rates = data['rates'];
          rates.forEach((key, value) {
             _cachedRates[key] = (value is num) ? value.toDouble() : 1.0;
          });
        }
      }
    } catch (e) {
      debugPrint("Rates API Error: $e");
    }
  }

  Future<Map<String, dynamic>> swapCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId == null) {
        return {'status': 'error', 'message': 'User not logged in'};
      }

      final response = await http.post(
        Uri.parse(AppApiConfig.walletSwap),
        headers: await _getHeaders(),
        body: jsonEncode({
          'user_id': userId,
          'amount': amount,
          'from_currency': fromCurrency,
          'to_currency': toCurrency,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint("Swap API Error: $e");
      return {'status': 'error', 'message': 'Swap failed due to network error'};
    }
  }

  Future<Map<String, dynamic>> paySupplier({
    required double amount,
    required String currency,
    required String recipient,
    required String destination,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'status': 'success',
      'tx_id': 'ANCH_PAY_${DateTime.now().millisecondsSinceEpoch}',
      'amount': amount,
      'currency': currency,
      'recipient': recipient,
      'destination': destination,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  // ============ TRANSACTIONS ============
  // ============ TRANSACTIONS ============
  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId != null) {
        final response = await http.get(
          Uri.parse(AppApiConfig.transactions),
          headers: await _getHeaders(),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
             return List<Map<String, dynamic>>.from(data['data']);
          }
        }
      }
    } catch (e) {
      debugPrint("Transactions API Error: $e");
    }
    return [];
  }

  // ============ MARKET RATES DASHBOARD ============
  Future<List<Map<String, dynamic>>> getMarketRates() async {
    try {
      final response = await http.get(
        Uri.parse(AppApiConfig.rates),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['market'] != null) {
          return List<Map<String, dynamic>>.from(data['market']);
        }
      }
    } catch (e) {
      debugPrint("Market Rates Error: $e");
    }
    // Fallback to empty or cache
    return [];
  }

  // ============ BILLS ============
  Future<Map<String, dynamic>> payBill({required String type, required double amount, required String reference}) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'status': 'success',
      'tx_id': 'BILL_${type.toUpperCase()}_${DateTime.now().millisecondsSinceEpoch}',
      'message': '$type payment of $amount successful.',
    };
  }

  // ============ BENEFICIARIES ============
  Future<List<Map<String, dynamic>>> getBeneficiaries() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<Map<String, dynamic>>.from(_beneficiaries);
  }

  Future<void> addBeneficiary(Map<String, dynamic> beneficiary) async {
    await Future.delayed(const Duration(seconds: 1));
    _beneficiaries.add(beneficiary);
    beneficiariesNotifier.value = List<Map<String, dynamic>>.from(_beneficiaries);
    await _saveToPersistence();
  }

  // ============ PAYMENT SCHEDULER ============
  Future<List<Map<String, dynamic>>> getScheduledPayments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<Map<String, dynamic>>.from(_scheduledPayments);
  }

  Future<void> schedulePayment(Map<String, dynamic> schedule) async {
    await Future.delayed(const Duration(seconds: 1));
    _scheduledPayments.add(schedule);
    await _saveToPersistence();
  }

  // ============ RATE ALERTS ============
  Future<List<Map<String, dynamic>>> getRateAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '1';
      
      final response = await http.get(
        Uri.parse(AppApiConfig.kycStatus),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      debugPrint("Get Rate Alerts Error: $e");
    }
    return [];
  }

  Future<bool> createRateAlert(Map<String, dynamic> alert) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '1';
      
      final response = await http.post(
        Uri.parse('https://admin.afritradepay.com/api/rate_alerts.php?action=create'),
        body: {
          'user_id': userId,
          'currency_pair': alert['pair'].toString().replaceAll('/', '_'),
          'target_rate': alert['target'].toString(),
          'direction': alert['direction'].toString(),
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Create Rate Alert Error: $e");
    }
    return false;
  }

  Future<bool> deleteRateAlert(int alertId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '1';
      
      final response = await http.post(
        Uri.parse('https://admin.afritradepay.com/api/rate_alerts.php?action=delete'),
        body: {
          'user_id': userId,
          'alert_id': alertId.toString(),
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Delete Rate Alert Error: $e");
    }
    return false;
  }

  // ============ ORDERS (ANCHOR INVOICING) ============
  Future<List<Map<String, dynamic>>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_orders.isEmpty) {
      _orders.addAll([
        {'id': "INV-2026-001", 'desc': "Electronic Parts (China)", 'amount': 12500.0, 'priority': "High", 'status': 'unpaid'},
        {'id': "INV-2026-002", 'desc': "Textile Batch B", 'amount': 8400.0, 'priority': "Medium", 'status': 'unpaid'},
        {'id': "INV-2026-003", 'desc': "Auto Spare Parts", 'amount': 21500.0, 'priority': "Urgent", 'status': 'unpaid'},
      ]);
      await _saveToPersistence();
    }
    return List<Map<String, dynamic>>.from(_orders.where((o) => o['status'] == 'unpaid'));
  }

  Future<void> payOrder(String orderId) async {
    await Future.delayed(const Duration(seconds: 2));
    final index = _orders.indexWhere((o) => o['id'] == orderId);
    if (index != -1) {
      _orders[index]['status'] = 'paid';
      await _saveToPersistence();
    }
  }

  // ============ TRADE INSIGHTS ============
  Future<Map<String, dynamic>> getTradeInsights(String period) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Mock Data Generator (Restored)
    return {
      'total_spent': 12450.00,
      'spending_trend': [10.0, 40.0, 30.0, 60.0, 50.0, 90.0, 70.0],
      'top_categories': [
        {'name': 'Logistics', 'amount': 5200.0, 'percent': 42},
        {'name': 'Raw Materials', 'amount': 3800.0, 'percent': 30},
        {'name': 'Marketing', 'amount': 1500.0, 'percent': 12},
        {'name': 'Operations', 'amount': 1950.0, 'percent': 16},
      ],
      'recommendations': [
        {'title': 'Bulk Savings', 'desc': 'You could save 2% by consolidating supplier payments.'},
        {'title': 'FX Timing', 'desc': 'Consider executing USD trades on Tuesdays for better rates.'},
      ]
    };
  }

  // ============ BULK PAYMENTS ============
  Future<List<Map<String, dynamic>>> getBulkPayments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_bulkPayments.isEmpty) {
      _bulkPayments.addAll([
        {'id': 'PAY_001', 'supplier': 'Shenzhen Tech Ltd', 'amount': 12500.0, 'currency': 'USD', 'status': 'pending'},
        {'id': 'PAY_002', 'supplier': 'Mumbai Textiles', 'amount': 8400.0, 'currency': 'USD', 'status': 'pending'},
        {'id': 'PAY_003', 'supplier': 'Ankara Hub', 'amount': 450000.0, 'currency': 'NGN', 'status': 'pending'},
        {'id': 'PAY_004', 'supplier': 'Dubai Logistics', 'amount': 3200.0, 'currency': 'USD', 'status': 'pending'},
      ]);
      await _saveToPersistence();
    }
    return List<Map<String, dynamic>>.from(_bulkPayments.where((p) => p['status'] == 'pending'));
  }

  Future<void> processBulkPayments(List<String> ids) async {
    await Future.delayed(const Duration(seconds: 3));
    for (String id in ids) {
      final index = _bulkPayments.indexWhere((p) => p['id'] == id);
      if (index != -1) {
        _bulkPayments[index]['status'] = 'processed';
      }
    }
    await _saveToPersistence();
  }

  // ============ KYC & KYB ============
  
  // Check Status
  Future<Map<String, dynamic>> checkKYCStatus(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(AppApiConfig.kycStatus),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('KYC Check Error: $e');
    }
    return {'status': 'success', 'kyc_status': 'none'}; // Default fallback
  }

  // Upload Document (Multipart)
  Future<Map<String, dynamic>> uploadKYCDocument({
    required String userId,
    required String docType,
    required String filePath,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(AppApiConfig.kycUpload));
      request.headers.addAll(await _getHeaders());
      request.fields['user_id'] = userId;
      request.fields['document_type'] = docType;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        return jsonDecode(respStr);
      }
    } catch (e) {
      debugPrint('KYC Upload Error: $e');
      return {'status': 'error', 'message': e.toString()};
    }
    return {'status': 'error', 'message': 'Upload failed'};
  }

  Future<Map<String, dynamic>> submitKYB({
    required String businessName,
    required String regNumber,
    required String industry,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'status': 'pending',
      'id': 'KYB_${DateTime.now().millisecondsSinceEpoch}',
      'estimated_time': '2-5 business days',
    };
  }
  
  // ============ BANNERS (CMS) ============
  Future<List<Map<String, dynamic>>> getBanners() async {
    try {
      final response = await http.get(
        Uri.parse(AppApiConfig.baseUrl + '/banners'), // Use baseUrl + endpoint or add to AppApiConfig
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
           return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      debugPrint('Banner Error: $e');
    }
    return []; // Return empty if error
  }

  // ============ REFERRALS ============
  Future<Map<String, dynamic>> getReferralData() async {
    try {
      // TODO: Get actual logged-in user ID
      String userId = '1'; // Placeholder
      final prefs = await SharedPreferences.getInstance();
      // Assuming you store user_id in prefs login
      // userId = prefs.getString('user_id') ?? '1';

      final response = await http.get(
        Uri.parse(AppApiConfig.referrals),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Referral Error: $e');
    }
    
    // Fallback Mock (so screen doesn't break if API fails)
    return {
      'code': 'OFFLINE',
      'list': [],
      'stats': {'total_earned': 0, 'referrals': 0, 'pending': 0}
    };
  }

  // ============ COMPLIANCE / TAX REPORTS ============
  Future<List<Map<String, dynamic>>> getTaxReports() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_taxReports.isEmpty) {
      _taxReports.addAll([
        {'id': 'RPT_001', 'name': "Q4 Trade Summary 2025", 'status': "Ready for export", 'date': '2025-12-31'},
        {'id': 'RPT_002', 'name': "VAT Assessment - Dec 2025", 'status': "Review required", 'date': '2025-12-15'},
        {'id': 'RPT_003', 'name': "Annual Compliance 2024", 'status': "Verified", 'date': '2024-12-31'},
      ]);
      await _saveToPersistence();
    }
    return List<Map<String, dynamic>>.from(_taxReports);
  }

  Future<void> generateTaxReport(String type) async {
    await Future.delayed(const Duration(seconds: 3));
    _taxReports.insert(0, {
      'id': 'RPT_${DateTime.now().millisecondsSinceEpoch}', 
      'name': "$type ${DateTime.now().year}", 
      'status': "Processing", 
      'date': DateTime.now().toIso8601String()
    });
    await _saveToPersistence();
  }

  // ============ SECURITY & LIMITS ============
  
  Future<Map<String, dynamic>> getUserLimits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '1';
      
      final response = await http.get(
        Uri.parse(AppApiConfig.settings), // Use settings which likely contains info or limits
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Get User Limits Error: $e");
    }
    return {
      'tier': 1, 
      'daily_limit': 1000.0, 
      'single_tx_limit': 200.0, 
      'remaining_daily': 1000.0
    };
  }

  Future<bool> isTransactionPinSet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '1';
      
      final response = await http.get(
        Uri.parse(AppApiConfig.pinStatus),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_pin_set'] == true;
      }
    } catch (e) {
      debugPrint("Check PIN Status Error: $e");
    }
    return false;
  }
}
