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

class _SwapScreenState extends State<SwapScreen> with SingleTickerProviderStateMixin {
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

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  double get _convertedAmount {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount * _rate;
  }

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 800),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
    
    _updateRate();
    _fetchLimits();
    _amountController.addListener(_updateFee);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _fetchLimits() async {
    try {
      final limits = await _anchorService.getUserLimits();
      if (mounted) {
        setState(() {
          _limits = limits;
        });
      }
    } catch (e) {
      debugPrint('Error fetching limits: $e');
    }
  }

  Future<void> _updateRate() async {
    setState(() => _isLoadingRate = true);
    try {
      final rates = await _anchorService.getMarketRates();
      final pair = '${_fromCurrency}_$_toCurrency';
      if (mounted) {
        setState(() {
          _rate = (rates[pair] as num?)?.toDouble() ?? 1.0;
          _isLoadingRate = false;
          _updateFee();
        });
      }
    } catch (e) {
      debugPrint('Error fetching rate: $e');
      if (mounted) setState(() => _isLoadingRate = false);
    }
  }

  void _updateFee() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _fee = amount * 0.005; // 0.5% fee
    });
  }

  void _swapCurrencies() {
    if (_flipController.isAnimating) return;
    
    if (_flipController.status == AnimationStatus.dismissed) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          final temp = _fromCurrency;
          _fromCurrency = _toCurrency;
          _toCurrency = temp;
          _updateRate();
        });
      }
    });
  }

  Future<void> _handleSwapRequest() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final pin = await SecurityPrompt.show(
      context,
      title: 'Confirm Swap',
    );

    if (pin != null) {
      _executeSwap(amount, pin);
    }
  }

  Future<void> _executeSwap(double amount, String? pin) async {
    setState(() => _isLoading = true);
    try {
      final result = await _anchorService.swapCurrency(
        from: _fromCurrency,
        to: _toCurrency,
        amount: amount,
        transactionPin: pin,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        if (result['status'] == 'error') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Swap failed')),
          );
        } else {
          _showSuccessDialog(result);
          _amountController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Swap failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Currency Swap', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 3D Flip Swap Card
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
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * 3.14159;
        
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(angle);

        final isBack = angle > 1.57;

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform(
                transform: Matrix4.identity()..rotateX(isBack ? -3.14159 : 0),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    _buildCurrencyInput("From", _fromCurrency, true, isTop: true),
                    const SizedBox(height: 12),
                    _buildCurrencyInput("To", _toCurrency, false, isTop: false),
                  ],
                ),
              ),

              GestureDetector(
                onTap: _swapCurrencies,
                child: Transform.rotate(
                  angle: -angle,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ]
                    ),
                    child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencyInput(String label, String currency, bool isInput, {required bool isTop}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: isTop ? [] : [
           BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
        ]
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
              "Converted ${result['from_amount']} ${result['from_currency']} to ${result['to_amount']?.toStringAsFixed(2) ?? '0.00'} ${result['to_currency']}",
              textAlign: TextAlign.center, 
              style: GoogleFonts.outfit(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            
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
