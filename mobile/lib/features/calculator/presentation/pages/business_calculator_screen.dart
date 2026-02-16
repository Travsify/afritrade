import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/anchor_service.dart';

class BusinessCalculatorScreen extends StatefulWidget {
  const BusinessCalculatorScreen({super.key});

  @override
  State<BusinessCalculatorScreen> createState() => _BusinessCalculatorScreenState();
}

class _BusinessCalculatorScreenState extends State<BusinessCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Profit Calculator
  final _costController = TextEditingController();
  final _markupController = TextEditingController();
  double _sellingPrice = 0;
  double _profit = 0;

  // Fee Calculator
  final _amountController = TextEditingController();
  double _feeAmount = 0;
  double _totalAmount = 0;

  String _selectedCurrencyProfit = 'USD';
  String _selectedCurrencyFee = 'USD';
  
  // Currency Converter
  final _convertController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'NGN';
  double _convertedAmount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _costController.dispose();
    _markupController.dispose();
    _amountController.dispose();
    _convertController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Business Calculator',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.featureCalculator,
                  borderRadius: BorderRadius.circular(12),
                ),
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.outfit(fontSize: 13),
                tabs: const [
                  Tab(text: 'Profit'),
                  Tab(text: 'Fees'),
                  Tab(text: 'Convert'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfitCalculator(),
                _buildFeeCalculator(),
                _buildCurrencyConverter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: FadeInUp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profit Margin Calculator',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Calculate your selling price and profit margin',
              style: GoogleFonts.outfit(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildCurrencySelector(_selectedCurrencyProfit, (val) => setState(() => _selectedCurrencyProfit = val!)),
            const SizedBox(height: 16),
            _buildCalculatorInput('Cost Price', _getSymbol(_selectedCurrencyProfit), _costController, () => _calculateProfit()),
            const SizedBox(height: 16),
            _buildCalculatorInput('Markup %', '%', _markupController, () => _calculateProfit()),
            
            const SizedBox(height: 32),
            
            // Results
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.featureCalculator.withOpacity(0.2),
                    AppColors.featureCalculator.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.featureCalculator.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selling Price',
                        style: GoogleFonts.outfit(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${_getSymbol(_selectedCurrencyProfit)}${_sellingPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: AppColors.glassBorder),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profit',
                        style: GoogleFonts.outfit(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${_getSymbol(_selectedCurrencyProfit)}${_profit.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          color: AppColors.success,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: FadeInUp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fee Calculator',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Calculate total cost including Afritrade fees',
              style: GoogleFonts.outfit(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildCurrencySelector(_selectedCurrencyFee, (val) => setState(() => _selectedCurrencyFee = val!)),
            const SizedBox(height: 16),
            _buildCalculatorInput('Amount to Send', _getSymbol(_selectedCurrencyFee), _amountController, () => _calculateFees()),
            
            const SizedBox(height: 32),
            
            // Fee Breakdown
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                children: [
                  _buildFeeRow('Amount', '${_getSymbol(_selectedCurrencyFee)}${_amountController.text.isEmpty ? "0.00" : _amountController.text}'),
                  const SizedBox(height: 12),
                  _buildFeeRow('Service Fee (1.5%)', '${_getSymbol(_selectedCurrencyFee)}${_feeAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  _buildFeeRow('Network Fee', '${_getSymbol(_selectedCurrencyFee)}0.50'),
                  const SizedBox(height: 16),
                  Divider(color: AppColors.glassBorder),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Cost',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_getSymbol(_selectedCurrencyFee)}${_totalAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          color: AppColors.featureCalculator,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No hidden fees! What you see is what you pay.',
                      style: GoogleFonts.outfit(
                        color: AppColors.success,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyConverter() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: FadeInUp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Currency Converter',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Quick currency conversions with live rates',
              style: GoogleFonts.outfit(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            // From Currency
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('From', style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildCurrencyDropdown(_fromCurrency, (val) {
                        setState(() => _fromCurrency = val!);
                        _calculateConversion();
                      }),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _convertController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: GoogleFonts.outfit(color: AppColors.textMuted),
                            border: InputBorder.none,
                          ),
                          textAlign: TextAlign.right,
                          onChanged: (_) => _calculateConversion(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Swap Button
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      final temp = _fromCurrency;
                      _fromCurrency = _toCurrency;
                      _toCurrency = temp;
                    });
                    _calculateConversion();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.featureCalculator,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.featureCalculator.withOpacity(0.4),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.swap_vert, color: Colors.white),
                  ),
                ),
              ),
            ),
            
            // To Currency
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.featureCalculator.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.featureCalculator.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('To', style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildCurrencyDropdown(_toCurrency, (val) {
                        setState(() => _toCurrency = val!);
                        _calculateConversion();
                      }),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _convertedAmount.toStringAsFixed(2),
                          style: GoogleFonts.outfit(
                            color: AppColors.featureCalculator,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Rate Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '1 $_fromCurrency = ',
                    style: GoogleFonts.outfit(color: AppColors.textSecondary),
                  ),
                  Text(
                    '${_getRate(_fromCurrency, _toCurrency).toStringAsFixed(2)} $_toCurrency',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorInput(String label, String prefix, TextEditingController controller, VoidCallback onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Text(
                prefix,
                style: GoogleFonts.outfit(
                  color: AppColors.featureCalculator,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: GoogleFonts.outfit(color: AppColors.textMuted),
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeeRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildCurrencyDropdown(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        items: ['USD', 'EUR', 'GBP', 'NGN', 'GHS', 'KES', 'CNY']
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: onChanged,
        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
        dropdownColor: AppColors.surface,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
      ),
    );
  }

  void _calculateProfit() {
    final cost = double.tryParse(_costController.text) ?? 0;
    final markup = double.tryParse(_markupController.text) ?? 0;
    setState(() {
      _profit = cost * (markup / 100);
      _sellingPrice = cost + _profit;
    });
  }

  void _calculateFees() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _feeAmount = amount * 0.015;
      _totalAmount = amount + _feeAmount + 0.50;
    });
  }

  final AnchorService _anchorService = AnchorService();
  double _currentRate = 1.0;

  void _calculateConversion() async {
    final amount = double.tryParse(_convertController.text) ?? 0;
    
    // Cross-rate calculation
    double rate = 1.0;
    
    if (_fromCurrency == 'USD') {
      rate = await _anchorService.getExchangeRate(_fromCurrency, _toCurrency);
    } else if (_toCurrency == 'USD') {
      // Inverse
      final inverse = await _anchorService.getExchangeRate(_toCurrency, _fromCurrency);
      rate = (inverse == 0) ? 0 : 1 / inverse;
    } else {
      // Cross via USD
      final rateToUsd = await _anchorService.getExchangeRate('USD', _fromCurrency); // e.g. USD->GBP
      final rateFromUsd = await _anchorService.getExchangeRate('USD', _toCurrency); // e.g. USD->CNY
      
      // If from GBP to CNY:
      // 1 GBP = (1/rateToUsd) USD
      // 1 USD = rateFromUsd CNY
      // 1 GBP = (1/rateToUsd) * rateFromUsd CNY
      rate = (rateToUsd == 0) ? 0 : (1 / rateToUsd) * rateFromUsd;
    }

    if (mounted) {
      setState(() {
        _currentRate = rate;
        _convertedAmount = amount * rate;
      });
    }
  }

  String _getSymbol(String currency) {
    switch (currency) {
      case 'USD': return '\$';
      case 'GBP': return '£';
      case 'EUR': return '€';
      case 'NGN': return '₦';
      case 'CNY': return '¥';
      default: return '$currency ';
    }
  }

  Widget _buildCurrencySelector(String currentValue, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          isExpanded: true,
          items: ['USD', 'EUR', 'GBP', 'NGN', 'CNY']
            .map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.outfit(color: Colors.white))))
            .toList(),
          onChanged: onChanged,
          dropdownColor: AppColors.surface,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ),
      ),
    );
  }

  double _getRate(String from, String to) {
    return _currentRate;
  }
}
