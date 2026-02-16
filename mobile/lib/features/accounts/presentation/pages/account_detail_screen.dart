import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../payments/presentation/pages/fund_wallet_screen.dart';
import '../../../payments/presentation/pages/pay_supplier_screen.dart';
import '../../../swap/presentation/pages/swap_screen.dart';

class AccountDetailScreen extends StatelessWidget {
  final Map<String, dynamic> account;

  const AccountDetailScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final currency = account['currency'] ?? 'USD';
    final balance = (account['balance'] ?? 0.0).toStringAsFixed(2);
    final bankName = account['bank_name'] ?? 'Virtual Bank';
    final accountName = account['account_name'] ?? 'User Account';
    
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
          "$currency Account",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Balance Card
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getCurrencyColor(currency),
                      _getCurrencyColor(currency).withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: _getCurrencyColor(currency).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Available Balance",
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${_getSymbol(currency)}$balance",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Action Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(context, Icons.add_circle_outline, "Fund", () {
                          Navigator.push(context, MaterialPageRoute(builder: (c) => const FundWalletScreen()));
                        }),
                        const SizedBox(width: 24),
                        _buildActionButton(context, Icons.send_outlined, "Send", () {
                           Navigator.push(context, MaterialPageRoute(builder: (c) => const PaySupplierScreen()));
                        }),
                        const SizedBox(width: 24),
                        _buildActionButton(context, Icons.swap_horiz, "Swap", () {
                           Navigator.push(context, MaterialPageRoute(builder: (c) => const SwapScreen()));
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Account Details Section
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account Details",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow(context, "Bank Name", bankName),
                    _buildDetailRow(context, "Account Name", accountName),
                    if (account['account_number'] != null)
                      _buildDetailRow(context, "Account Number", account['account_number'], isCopyable: true),
                    if (account['routing_number'] != null)
                      _buildDetailRow(context, "Routing Number", account['routing_number'], isCopyable: true),
                    if (account['iban'] != null)
                      _buildDetailRow(context, "IBAN", account['iban'], isCopyable: true),
                    if (account['bic'] != null)
                      _buildDetailRow(context, "BIC / SWIFT", account['bic'], isCopyable: true),
                    if (account['sort_code'] != null)
                      _buildDetailRow(context, "Sort Code", account['sort_code'], isCopyable: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isCopyable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
          ),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              if (isCopyable) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("$label copied!"), backgroundColor: AppColors.success),
                    );
                  },
                  child: Icon(Icons.copy, size: 16, color: AppColors.primary),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getCurrencyColor(String? currency) {
    switch (currency) {
      case 'USD': return AppColors.primary;
      case 'EUR': return AppColors.accent;
      case 'GBP': return AppColors.secondary;
      case 'NGN': return AppColors.success;
      default: return AppColors.primary;
    }
  }

  String _getSymbol(String? currency) {
    switch (currency) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'NGN': return '₦';
      default: return '';
    }
  }
}
