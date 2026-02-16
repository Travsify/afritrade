import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/anchor_service.dart';

class RateAlertsScreen extends StatefulWidget {
  const RateAlertsScreen({super.key});

  @override
  State<RateAlertsScreen> createState() => _RateAlertsScreenState();
}

class _RateAlertsScreenState extends State<RateAlertsScreen> {
  final AnchorService _anchorService = AnchorService();
  final TextEditingController _targetController = TextEditingController();
  List<Map<String, dynamic>> _alerts = [];
  bool _isLoadingAlerts = true;
  
  Map<String, double> _liveRates = {
    'USD/NGN': 0.0,
    'GBP/NGN': 0.0,
    'EUR/NGN': 0.0,
    'CNY/NGN': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _fetchLiveRates();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoadingAlerts = true);
    final alerts = await _anchorService.getRateAlerts();
    if (mounted) {
      setState(() {
        _alerts = alerts;
        _isLoadingAlerts = false;
      });
    }
  }

  void _fetchLiveRates() async {
    final usd = await _anchorService.getExchangeRate('USD', 'NGN');
    final gbp = await _anchorService.getExchangeRate('GBP', 'NGN');
    final eur = await _anchorService.getExchangeRate('EUR', 'NGN');
    final cny = await _anchorService.getExchangeRate('CNY', 'NGN');
    
    if (mounted) {
      setState(() {
        _liveRates['USD/NGN'] = usd;
        _liveRates['GBP/NGN'] = gbp;
        _liveRates['EUR/NGN'] = eur;
        _liveRates['CNY/NGN'] = cny;
      });
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
          'Rate Alerts',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.featureAlerts, Color(0xFFF97316)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              onPressed: () => _showAddAlertSheet(),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchLiveRates();
          await _loadAlerts();
        },
        color: AppColors.featureAlerts,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: _buildLiveRatesCard(),
              ),
              const SizedBox(height: 28),
              _buildAlertListHeader(),
              const SizedBox(height: 16),
              _isLoadingAlerts
                  ? Center(child: CircularProgressIndicator(color: AppColors.featureAlerts))
                  : _alerts.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: List.generate(_alerts.length, (index) {
                            return FadeInUp(
                              delay: Duration(milliseconds: 100 * index),
                              child: _buildAlertCard(_alerts[index]),
                            );
                          }),
                        ),
              const SizedBox(height: 24),
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveRatesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.featureAlerts, Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.featureAlerts.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Live Rates', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
              _buildLiveBadge(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLiveRate('USD/NGN', _liveRates['USD/NGN']!.toStringAsFixed(2), true),
              _buildLiveRate('GBP/NGN', _liveRates['GBP/NGN']!.toStringAsFixed(2), true),
              _buildLiveRate('EUR/NGN', _liveRates['EUR/NGN']!.toStringAsFixed(2), false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('Live', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLiveRate(String pair, String rate, bool isUp) {
    return Column(
      children: [
        Text(pair, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text('₦$rate', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Icon(isUp ? Icons.trending_up : Icons.trending_down, color: isUp ? AppColors.success : AppColors.error, size: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildAlertListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Your Alerts', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(
          '${_alerts.where((a) => a['status'] == 'active').length} active',
          style: GoogleFonts.outfit(color: AppColors.success, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          "No active alerts\nTap + to create your first rate alert",
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(color: AppColors.textMuted),
        ),
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final status = alert['status'] ?? 'active';
    final isActive = status == 'active';
    final pair = alert['currency_pair'].toString().replaceAll('_', '/');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? AppColors.featureAlerts.withOpacity(0.3) : AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 50, width: 50,
                decoration: BoxDecoration(color: AppColors.featureAlerts.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.notifications, color: AppColors.featureAlerts, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pair, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 13),
                        children: [
                          TextSpan(text: 'When rate ${alert['direction']} '),
                          TextSpan(
                            text: '₦${alert['target_rate']}',
                            style: const TextStyle(color: AppColors.featureAlerts, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 20),
                onPressed: () async {
                   final ok = await _anchorService.deleteRateAlert(int.parse(alert['id']));
                   if (ok) _loadAlerts();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status', style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 13)),
                Text(
                  status.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: status == 'active' ? AppColors.success : (status == 'triggered' ? Colors.orange : Colors.grey),
                    fontSize: 12, fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.notifications_active, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Push Notifications', style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'You\'ll receive instant notifications when your target rates are hit.',
                  style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAlertSheet() {
    String selectedPair = 'USD/NGN';
    String selectedDirection = 'below';
    _targetController.clear();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Rate Alert', style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                Text('Currency Pair', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                  child: DropdownButton<String>(
                    value: selectedPair,
                    isExpanded: true,
                    items: ['USD/NGN', 'GBP/NGN', 'EUR/NGN', 'CNY/NGN'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (val) => setModalState(() => selectedPair = val!),
                    style: GoogleFonts.outfit(color: Colors.white),
                    dropdownColor: AppColors.surface,
                    underline: const SizedBox(),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text('Direction', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => selectedDirection = 'below'),
                        child: _buildDirectionTab('Drops Below', selectedDirection == 'below', AppColors.featureAlerts),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => selectedDirection = 'above'),
                        child: _buildDirectionTab('Rises Above', selectedDirection == 'above', AppColors.success),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Text('Target Rate', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'e.g. 1400.00',
                    hintStyle: GoogleFonts.outfit(color: AppColors.textMuted),
                    prefixText: '₦ ',
                    prefixStyle: GoogleFonts.outfit(color: AppColors.featureAlerts, fontWeight: FontWeight.bold),
                    filled: true, fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_targetController.text.isEmpty) return;
                      final ok = await _anchorService.createRateAlert({
                        'pair': selectedPair,
                        'target': _targetController.text,
                        'direction': selectedDirection,
                      });
                      if (ok) {
                        _loadAlerts();
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.featureAlerts,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Create Alert', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionTab(String label, bool isSelected, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? color : AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
        ),
      ),
    );
  }
}
