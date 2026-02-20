import 'dart:convert';
import 'package:afritrad_mobile/core/constants/api_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:afritrad_mobile/core/services/anchor_service.dart';
import '../../../auth/presentation/widgets/pin_verification_modal.dart';
import 'withdrawal_history_screen.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();
  final _accountNameController = TextEditingController();
  
  final _anchorService = AnchorService();
  
  String _selectedBank = 'GTBank';
  bool _isLoading = false;
  
  List<Map<String, dynamic>> _accounts = [];
  Map<String, dynamic>? _selectedAccount;
  double _exchangeRate = 0.0;
  double _receiveAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _amountController.addListener(_calculateReceiveAmount);
  }
  
  void _loadAccounts() async {
    final accounts = await _anchorService.getVirtualAccounts();
    if (mounted) {
      setState(() {
        _accounts = accounts;
        // Default to USD or first available
        _selectedAccount = accounts.firstWhere(
          (a) => a['currency'] == 'USD', 
          orElse: () => accounts.isNotEmpty ? accounts.first : {}
        );
        if (_selectedAccount != null && _selectedAccount!.isEmpty) _selectedAccount = null;
      });
      _updateExchangeRate();
    }
  }

  void _updateExchangeRate() async {
    if (_selectedAccount == null) return;
    final rate = await _anchorService.getExchangeRate(_selectedAccount!['currency'], 'NGN');
    if (mounted) {
      setState(() {
        _exchangeRate = rate;
      });
      _calculateReceiveAmount();
    }
  }

  void _calculateReceiveAmount() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _receiveAmount = amount * _exchangeRate;
    });
  }

  final List<Map<String, String>> _banks = [
    {'name': 'GTBank', 'code': '058'},
    {'name': 'Access Bank', 'code': '044'},
    {'name': 'Zenith Bank', 'code': '057'},
    {'name': 'First Bank', 'code': '011'},
    {'name': 'UBA', 'code': '033'},
    {'name': 'Kuda Bank', 'code': '090267'},
    {'name': 'Opay', 'code': '100004'},
    {'name': 'PalmPay', 'code': '100033'},
  ];

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  void _processWithdrawal() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0 || _accountController.text.length != 10 || _accountNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields correctly")));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PinVerificationModal(
        onVerified: (pin) => _executeWithdrawal(amount),
      ),
    );
  }

  void _executeWithdrawal(double amount) async {
    setState(() => _isLoading = true);
    
    final bankCode = _banks.firstWhere((b) => b['name'] == _selectedBank)['code'] ?? '058';

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(AppApiConfig.withdraw),
        headers: headers,
        body: jsonEncode({
          'amount': amount,
          'currency': _selectedAccount?['currency'] ?? 'USD',
          'bank_code': bankCode,
          'account_number': _accountController.text,
          'account_name': _accountNameController.text,
        }),
      );

      final data = jsonDecode(response.body);
      if (mounted) {
        setState(() => _isLoading = false);
        if (data['status'] == 'success') {
          _showSuccessDialog(data['message']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Failed')));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 64),
            const SizedBox(height: 16),
            Text("Withdrawal Initiated", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, style: GoogleFonts.outfit(color: Colors.white70), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Done", style: TextStyle(color: AppColors.primary)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text("Withdraw to Bank", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawalHistoryScreen())),
            tooltip: 'History',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_accounts.isNotEmpty) ...[
              Text("Source Wallet", style: GoogleFonts.outfit(color: Colors.white70)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: _selectedAccount,
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    hint: Text("Select Wallet", style: TextStyle(color: Colors.white70)),
                    items: _accounts.map((acc) => DropdownMenuItem(
                      value: acc, 
                      child: Text("${acc['currency']} Wallet (Bal: ${acc['balance']})", style: const TextStyle(color: Colors.white))
                    )).toList(),
                    onChanged: (val) {
                      setState(() => _selectedAccount = val);
                      _updateExchangeRate();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            Text("Amount (${_selectedAccount?['currency'] ?? 'USD'})", style: GoogleFonts.outfit(color: Colors.white70)),
            const SizedBox(height: 8),
            _buildField(_amountController, "0.00", keyboardType: TextInputType.number, prefix: null),
            if (_exchangeRate > 0) ...[
              const SizedBox(height: 8),
              Text(
                "You will receive: ₦${_receiveAmount.toStringAsFixed(2)}",
                style: GoogleFonts.outfit(color: AppColors.success, fontWeight: FontWeight.bold),
              ),
              Text(
                "Rate: 1 ${_selectedAccount?['currency']} = ₦${_exchangeRate.toStringAsFixed(2)}",
                style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
              ),
            ],
            const SizedBox(height: 20),

            Text("Select Bank", style: GoogleFonts.outfit(color: Colors.white70)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBank,
                  isExpanded: true,
                  dropdownColor: AppColors.surface,
                  items: _banks.map((b) => DropdownMenuItem(value: b['name'], child: Text(b['name']!, style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (val) => setState(() => _selectedBank = val!),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text("Account Number", style: GoogleFonts.outfit(color: Colors.white70)),
            const SizedBox(height: 8),
            _buildField(_accountController, "0123456789", keyboardType: TextInputType.number),
            const SizedBox(height: 20),

            Text("Account Name", style: GoogleFonts.outfit(color: Colors.white70)),
            const SizedBox(height: 8),
            _buildField(_accountNameController, "John Doe"),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processWithdrawal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Withdraw", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, {TextInputType? keyboardType, String? prefix}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          if (prefix != null) Text(prefix, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.outfit(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
