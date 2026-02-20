import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/anchor_service.dart';
import '../../../../core/theme/app_colors.dart';

class TradeInsightsScreen extends StatefulWidget {
  const TradeInsightsScreen({super.key});

  @override
  State<TradeInsightsScreen> createState() => _TradeInsightsScreenState();
}

class _TradeInsightsScreenState extends State<TradeInsightsScreen> {
  final AnchorService _anchorService = AnchorService();
  String _selectedPeriod = 'This Month';
  Map<String, dynamic>? _insightsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInsights();
  }

  void _fetchInsights() async {
    setState(() => _isLoading = true);
    final data = await _anchorService.getTradeInsights(_selectedPeriod);
    if(mounted) {
      setState(() {
        _insightsData = data;
        _isLoading = false;
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
          'Trade Insights',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _buildPeriodTab('This Week'),
                    _buildPeriodTab('This Month'),
                    _buildPeriodTab('This Year'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (_isLoading) 
              const Center(child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ))
            else if (_insightsData == null || (_insightsData!['total_spent'] ?? 0) == 0)
              _buildNoDataState()
            else ...[
              // Total Spending Card
              FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.featureInsights, Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.featureInsights.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Spent',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${(_insightsData?['total_spent'] ?? 0.0).toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_insightsData?['trend'] != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  (_insightsData?['trend_up'] ?? true) ? Icons.trending_up : Icons.trending_down,
                                  color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  _insightsData?['trend'] ?? '',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Spending by Category/Country (Luminous Ring)
            if (_insightsData?['top_categories'] != null && (_insightsData?['top_categories'] as List).isNotEmpty)
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _buildSection(
                  'Spending Break-down',
                  Column(
                    children: [
                      // Luminous Ring Chart
                      SizedBox(
                        height: 250,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glowing Background for "Luminous" effect
                            Container(
                              height: 180,
                              width: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.2),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            PieChart(
                              PieChartData(
                                sectionsSpace: 4,
                                centerSpaceRadius: 60,
                                sections: (_insightsData!['top_categories'] as List).map((cat) {
                                  final isHigh = (cat['percent'] ?? 0) > 30;
                                  return PieChartSectionData(
                                    color: _getCategoryColor(cat['name'] ?? ''),
                                    value: (cat['percent'] ?? 0).toDouble(),
                                    title: '${(cat['percent'] ?? 0)}%',
                                    radius: isHigh ? 35 : 30, // Make larger segments pop
                                    titleStyle: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            // Center Text
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Total", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                                Text(
                                  "\$${(_insightsData?['total_spent'] ?? 0).toStringAsFixed(0)}", 
                                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Legend / List
                      Column(
                        children: (_insightsData!['top_categories'] as List).map((cat) {
                          return _buildCountryBar(
                            cat['name'] ?? 'Unknown', 
                            (cat['amount'] ?? 0.0).toDouble(), 
                            (cat['percent'] ?? 0.0) / 100.0, 
                            _getCategoryColor(cat['name'] ?? '')
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Top Suppliers
            if (_insightsData?['top_suppliers'] != null && (_insightsData?['top_suppliers'] as List).isNotEmpty)
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: _buildSection(
                  'Key Partners',
                  Column(
                    children: (_insightsData!['top_suppliers'] as List).map((sup) {
                      return _buildSupplierRow(
                        sup['name'] ?? 'Supplier', 
                        '\$${(sup['amount'] ?? 0).toStringAsFixed(0)}', 
                        sup['flag'] ?? '🌐'
                      );
                    }).toList(),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Pro Tips
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lightbulb,
                        color: AppColors.amber,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pro Tip',
                            style: GoogleFonts.outfit(
                              color: AppColors.amber,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Payments made on Tuesdays have 8% lower fees on average.',
                            style: GoogleFonts.outfit(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTab(String label) {
    final isSelected = _selectedPeriod == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.featureInsights : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildCountryBar(String country, double amount, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                country,
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                '\$${amount.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierRow(String name, String amount, String flag) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.outfit(
              color: AppColors.featureInsights,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String name) {
    switch (name.toLowerCase()) {
      case 'china': case 'logistics': return const Color(0xFFEF4444);
      case 'india': case 'raw materials': return const Color(0xFFF59E0B);
      case 'uae': case 'marketing': return const Color(0xFF3B82F6);
      case 'turkey': case 'operations': return const Color(0xFF8B5CF6);
      default: return AppColors.primary;
    }
  }

  Widget _buildNoDataState() {
    return FadeInUp(
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(Icons.bar_chart_rounded, color: AppColors.featureInsights, size: 80),
            ),
            const SizedBox(height: 32),
            Text(
              "Gathering Insights...",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Once you start trading and making payments, we'll provide deep insights into your supply chain performance and savings.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
