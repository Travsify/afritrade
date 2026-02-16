import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/services/anchor_service.dart';
import '../../../../core/services/security_service.dart';
import '../../../../core/services/receipt_service.dart';
import '../../../../core/widgets/security_prompt.dart';
import '../../../../core/theme/app_colors.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({super.key});

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  final _amountController = TextEditingController();
  final _anchorService = AnchorService();
  final _securityService = SecurityService();
  final _receiptService = ReceiptService();
  
  String _fromCurrency = 'NGN';
  String _toCurrency = 'USD';
  double _rate = 1600.0;
  double _fee = 0.0;
  bool _isLoading = false;
  bool _isLoadingRate = false;

  Map<String, dynamic> _limits = {
    'tier': 1,
    'remaining_daily': 0.0,
    'daily_limit': 1000.0,
  };

  @override
  void initState() {
    super.initState();
    _updateRate();
    _fetchLimits();
    _amountController.addListener(_updateFee);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchLimits() async {
    final limits = await _anchorService.getUserLimits();
    if (mounted) {
      setState(() => _limits = limits);
    }
  }

  Future<void> _updateRate() async {
    setState(() => _isLoadingRate = true);
    try {
      final rate = await _anchorService.getExchangeRate(_fromCurrency, _toCurrency);
      if (mounted) {
        setState(() {
          _rate = rate;
          _isLoadingRate = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRate = false);
      }
    }
  }

  void _updateFee() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    setState(() {
      _fee = amount * 0.005; // 0.5% fee
    });
  }

  double get _convertedAmount {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    return amount * _rate;
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _updateRate();
    });
  }

  void _handleSwapRequest() async {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0;
    
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    // NEW: Check if PIN is set, otherwise redirect to settings (or just inform)
    final pinStatus = await _securityService.checkPinStatus();
    if (pinStatus['is_pin_set'] == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please set a transaction PIN in Profile > Security first.")),
      );
      return;
    }

    // NEW: Show Security Prompt
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SecurityPrompt(
        onAuthenticated: (success) {
          if (success) {
            Navigator.pop(context);
            _executeSwap(amount);
          }
        },
      ),
    );
  }

  void _executeSwap(double amount) async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _anchorService.swapCurrency(
        amount: amount,
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
      );
      
      if (mounted) {
        setState(() => _isLoading = false);
        if (result['status'] == 'success') {
          _showSuccessDialog({
            ...result,
            'from_currency': _fromCurrency,
            'to_currency': _toCurrency,
            'amount': amount, // for receipt
          });
          _fetchLimits(); // Refresh limits after spend
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Swap failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Swap Currencies",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // NEW: Limits Banner
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tier ${_limits['tier'] ?? 1} Limits",
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Daily Remaining: \$${(_limits['remaining_daily'] ?? 0.0).toStringAsFixed(2)}",
                            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {}, // Navigate to KYC
                      child: Text("Upgrade", style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            _buildSwapCard(),
            const SizedBox(height: 40),
            
            FadeInUp(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Column(
                  children: [
                    _buildRateRow(
                      "Exchange Rate", 
                      _isLoadingRate 
                        ? "Loading..." 
                        : "1 $_fromCurrency = ${_rate.toStringAsFixed(4)} $_toCurrency"
                    ),
                    Divider(color: AppColors.glassBorder, height: 32),
                    _buildRateRow("Service Fee (0.5%)", "₦${_fee.toStringAsFixed(2)}"),
                    Divider(color: AppColors.glassBorder, height: 32),
                    _buildRateRow("Estimated Time", "Instant"),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            FadeInUp(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSwapRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Swap Now", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwapCard() {
    return FadeInDown(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              _buildCurrencyInput("From", _fromCurrency, true),
              const SizedBox(height: 12),
              _buildCurrencyInput("To", _toCurrency, false),
            ],
          ),
          GestureDetector(
            onTap: _swapCurrencies,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 4),
              ),
              child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyInput(String label, String currency, bool isInput) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
              Text("Balance: \$0.00", style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isInput)
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "0.00",
                      hintStyle: GoogleFonts.outfit(color: AppColors.textMuted),
                      border: InputBorder.none,
                    ),
                  ),
                )
              else
                Text(
                  _convertedAmount.toStringAsFixed(2),
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              GestureDetector(
                onTap: () => _showCurrencyPicker(isInput),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    children: [
                      Text(currency, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRateRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: AppColors.textSecondary)),
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showCurrencyPicker(bool isInput) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final currencies = ['NGN', 'USD', 'GBP', 'EUR', 'CNY'];
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Select Currency", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...currencies.map((c) => ListTile(
                title: Text(c, style: GoogleFonts.outfit(color: Colors.white)),
                onTap: () {
                  setState(() {
                    if (isInput) {
                      _fromCurrency = c;
                    } else {
                      _toCurrency = c;
                    }
                    _updateRate();
                  });
                  Navigator.pop(context);
                },
                trailing: (isInput ? _fromCurrency : _toCurrency) == c 
                  ? const Icon(Icons.check, color: AppColors.primary) 
                  : null,
              )),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 72),
            const SizedBox(height: 16),
            Text("Swap Successful!", style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              "Converted ${result['from_amount']} ${result['from_currency']} to ${result['to_amount'].toStringAsFixed(2)} ${result['to_currency']}",
              textAlign: TextAlign.center, 
              style: GoogleFonts.outfit(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            
            // NEW: Share Receipt Button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(c);
                _receiptService.shareReceipt(context, {
                  'id': result['tx_id'],
                  'amount': result['from_amount'],
                  'currency': result['from_currency'],
                  'to_amount': result['to_amount'],
                  'to_currency': result['to_currency'],
                  'type': 'Currency Swap',
                  'date': DateTime.now().toString().split('.')[0],
                  'recipient': 'Self (Swap)',
                });
              },
              icon: const Icon(Icons.ios_share, size: 18),
              label: Text("Share Receipt", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(c),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                child: Text("Awesome", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
