import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/services/anchor_service.dart';
import '../../../../core/theme/app_colors.dart';
import 'fund_wallet_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _anchorService = AnchorService();
  
  Map<String, dynamic>? _walletData;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoading = true);
    try {
      final wallet = await _anchorService.getWalletBalance();
      final rawTx = await _anchorService.getTransactions();
      
      final transactions = List<Map<String, dynamic>>.from(rawTx.map((tx) {
        final isCredit = tx['type'] == 'credit';
        final amount = tx['amount'] as num;
        return {
          'title': tx['title'],
          'status': (tx['type'] as String).toUpperCase(),
          'amount': isCredit ? '+ \$${amount.toStringAsFixed(2)}' : '- \$${amount.toStringAsFixed(2)}',
          'time': tx['date'],
        };
      }));

      if (mounted) {
        setState(() {
          _walletData = wallet;
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadWalletData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Your Wallet",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: _loadWalletData,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.refresh_rounded, color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Total Balance Card
                    FadeInUp(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Balance (USD)",
                              style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "\$${(_walletData?['total_usd'] ?? 0.0).toStringAsFixed(2)}",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                _buildMiniAction(Icons.add, "Fund"),
                                const SizedBox(width: 12),
                                _buildMiniAction(Icons.send_rounded, "Pay"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Asset Breakdown
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        "Assets",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Dynamic assets from API
                    ...(_walletData?['assets'] as List<dynamic>? ?? []).map((asset) {
                      return _buildAssetItem(
                        asset['name'] ?? 'Unknown',
                        asset['currency'] ?? '',
                        (asset['balance'] ?? 0.0).toStringAsFixed(2),
                        "\$${(asset['usd_value'] ?? 0.0).toStringAsFixed(2)}",
                        _getAssetColor(asset['currency']),
                      );
                    }).toList(),
                    
                    const SizedBox(height: 40),
                    
                    // Recent Transactions
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recent Activity",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "See all",
                            style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    if (_transactions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.history_rounded, color: AppColors.textMuted, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              "No transactions yet",
                              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Your transaction history will appear here",
                              style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ..._transactions.map((tx) => _buildTransactionItem(
                        tx['title'] ?? 'Transaction',
                        tx['status'] ?? 'Pending',
                        tx['amount'] ?? '',
                        tx['time'] ?? '',
                        Icons.swap_horiz_rounded,
                        AppColors.primary,
                      )).toList(),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Color _getAssetColor(String? currency) {
    switch (currency) {
      case 'USDT': return const Color(0xFF26A17B);
      case 'USDC': return const Color(0xFF2775CA);
      case 'NGN': return const Color(0xFF008751);
      case 'USD': return const Color(0xFF3B82F6);
      default: return AppColors.primary;
    }
  }

  Widget _buildMiniAction(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == "Fund") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FundWalletScreen()),
          );
        } else if (label == "Pay") {
          // TODO: Navigate to Pay Screen
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetItem(String name, String symbol, String amount, String value, Color color) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  symbol == 'USDT' || symbol == 'USDC' ? Icons.monetization_on : Icons.account_balance_wallet,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(symbol, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(value, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String title, String status, String amount, String time, IconData icon, Color color) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(time, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount, style: GoogleFonts.outfit(
                  color: amount.startsWith('+') ? AppColors.success : Colors.white,
                  fontWeight: FontWeight.bold,
                )),
                Text(status, style: GoogleFonts.outfit(color: AppColors.success, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
