import 'dart:async';
import 'package:flutter/foundation.dart';

class MapleradService {
  // Singleton Pattern
  static final MapleradService _instance = MapleradService._internal();
  factory MapleradService() => _instance;
  MapleradService._internal();

  // State
  final List<Map<String, dynamic>> _accounts = [];
  final List<Map<String, dynamic>> _cards = [];
  
  // Notifiers for UI updates
  final ValueNotifier<List<Map<String, dynamic>>> accountsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
  final ValueNotifier<List<Map<String, dynamic>>> cardsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);

  static const String _baseUrl = 'https://api.maplerad.com/v1';
  static const String apiKey = 'MAPLERAD_API_KEY';

  // ============ VIRTUAL ACCOUNTS ============

  Future<List<Map<String, dynamic>>> getVirtualAccounts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Update notifier to ensure listeners have latest data
    accountsNotifier.value = List<Map<String, dynamic>>.from(_accounts); 
    return _accounts;
  }

  Future<Map<String, dynamic>> createVirtualAccount({
    required String currency,
    required String accountName,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    final accountId = 'acc_${DateTime.now().millisecondsSinceEpoch}';
    
    Map<String, dynamic> accountDetails = {
      'id': accountId,
      'currency': currency,
      'account_name': accountName,
      'balance': 0.0,
      'status': 'active',
      'created_at': DateTime.now().toIso8601String(),
    };

    switch (currency) {
      case 'USD':
        accountDetails.addAll({
          'bank_name': 'Silvergate Bank',
          'account_number': _generateAccountNumber(),
          'routing_number': '121140399',
          'account_type': 'checking',
        });
        break;
      case 'EUR':
        accountDetails.addAll({
          'bank_name': 'Clear Junction',
          'iban': 'GB${_generateAccountNumber()}',
          'bic': 'CLRJR21XXX',
        });
        break;
      case 'GBP':
        accountDetails.addAll({
          'bank_name': 'Modulr',
          'account_number': _generateAccountNumber().substring(0, 8),
          'sort_code': '04-00-04',
        });
        break;
      case 'NGN':
        accountDetails.addAll({
          'bank_name': 'Providus Bank',
          'account_number': _generateAccountNumber(),
        });
        break;
    }

    _accounts.add(accountDetails);
    accountsNotifier.value = List<Map<String, dynamic>>.from(_accounts); // Notify listeners

    return {
      'status': 'success',
      'account': accountDetails,
    };
  }

  // ============ VIRTUAL CARDS ============

  Future<List<Map<String, dynamic>>> getVirtualCards() async {
    await Future.delayed(const Duration(milliseconds: 500));
    cardsNotifier.value = List<Map<String, dynamic>>.from(_cards);
    return _cards;
  }

  Future<Map<String, dynamic>> issueCard({
    required String label,
    required double amount,
    String brand = 'Visa',
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    final cardId = 'card_${DateTime.now().millisecondsSinceEpoch}';
    final card = {
      'id': cardId,
      'type': 'Virtual',
      'brand': brand,
      'last4': _generateLast4(),
      'expiry': _generateExpiry(),
      'cvv': '***',
      'status': 'Active',
      'balance': amount,
      'label': label,
      'currency': 'USD',
      'created_at': DateTime.now().toIso8601String(),
    };

    _cards.add(card);
    cardsNotifier.value = List<Map<String, dynamic>>.from(_cards);

    return {'status': 'success', 'card': card};
  }

  Future<Map<String, dynamic>> fundCard({required String cardId, required double amount}) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _cards.indexWhere((c) => c['id'] == cardId);
    if (index != -1) {
      _cards[index]['balance'] = (_cards[index]['balance'] ?? 0.0) + amount;
      cardsNotifier.value = List<Map<String, dynamic>>.from(_cards);
    }
    return {'status': 'success'};
  }

  Future<Map<String, dynamic>> withdrawFromCard({required String cardId, required double amount}) async {
    await Future.delayed(const Duration(seconds: 1));
     final index = _cards.indexWhere((c) => c['id'] == cardId);
    if (index != -1) {
       _cards[index]['balance'] = (_cards[index]['balance'] ?? 0.0) - amount;
      cardsNotifier.value = List<Map<String, dynamic>>.from(_cards);
    }
    return {'status': 'success'};
  }

  Future<Map<String, dynamic>> freezeCard(String cardId) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _cards.indexWhere((c) => c['id'] == cardId);
    if (index != -1) {
      _cards[index]['status'] = 'Frozen';
      cardsNotifier.value = List<Map<String, dynamic>>.from(_cards);
    }
    return {'status': 'success', 'card_status': 'Frozen', 'message': 'Card frozen successfully'};
  }

  Future<Map<String, dynamic>> unfreezeCard(String cardId) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _cards.indexWhere((c) => c['id'] == cardId);
    if (index != -1) {
      _cards[index]['status'] = 'Active';
      cardsNotifier.value = List<Map<String, dynamic>>.from(_cards);
    }
    return {'status': 'success', 'card_status': 'Active', 'message': 'Card unfrozen successfully'};
  }
  
  // Helpers
  String _generateAccountNumber() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (random % 10000000000).toString().padLeft(10, '0');
  }

  String _generateLast4() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (random % 10000).toString().padLeft(4, '0');
  }

  String _generateExpiry() {
    final now = DateTime.now();
    final expiryYear = (now.year + 3) % 100;
    return '${now.month.toString().padLeft(2, '0')}/$expiryYear';
  }
}
