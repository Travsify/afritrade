import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/services/anchor_service.dart'; // UPDATED IMPORT
import '../../../../core/theme/app_colors.dart';
import 'account_detail_screen.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  // Use Singleton Use new Anchor service
  final _anchorService = AnchorService();
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  void _fetchAccounts() async {
    await _anchorService.getVirtualAccounts();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCreateAccountModal() {
    String selectedCurrency = 'NGN';
    String accountLabel = '';
    bool isCreating = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: AppColors.glassBorder),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Create Virtual Account",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Get a dedicated NUBAN or foreign account for your business.",
                style: GoogleFonts.outfit(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              Text("Select Currency", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 12),
              Row(
                children: ['NGN', 'USD', 'EUR', 'GBP', 'CNY'].map((currency) {
                  final isSelected = selectedCurrency == currency;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedCurrency = currency),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.glassBorder,
                        ),
                      ),
                      child: Text(
                        currency,
                        style: GoogleFonts.outfit(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text("Account Label (Optional)", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: TextField(
                  onChanged: (val) => accountLabel = val,
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "e.g., Main Business Account",
                    hintStyle: GoogleFonts.outfit(color: AppColors.textMuted),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isCreating ? null : () async {
                    setModalState(() => isCreating = true);
                    final result = await _anchorService.createVirtualAccount(
                      currency: selectedCurrency,
                      label: accountLabel.isEmpty ? '$selectedCurrency Account' : accountLabel,
                    );
                    
                    if (mounted) {
                      Navigator.pop(context); // Close modal
                      if (result['status'] == 'success') {
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Account created successfully!"),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        // No need to manually refresh, ValueListenableBuilder handles it
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: isCreating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Create Account",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Your Accounts",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: _showCreateAccountModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _anchorService.accountsNotifier,
              builder: (context, accounts, child) {
                if (accounts.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return FadeInUp(
                      delay: Duration(milliseconds: index * 100),
                      child: _buildAccountListItem(account),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance, size: 80, color: AppColors.textMuted.withOpacity(0.3)),
          const SizedBox(height: 24),
          Text(
            "No Accounts Yet",
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Create your first virtual account to get started.",
            style: GoogleFonts.outfit(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _showCreateAccountModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text("Create Account", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountListItem(Map<String, dynamic> account) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountDetailScreen(account: account),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              height: 48, width: 48,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  account['currency'] ?? 'NGN',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    account['label'] ?? 'Business Account',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "${account['bank_name']} • ${account['account_number'] ?? 'Wallet Only'}",
                    style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              "${account['currency']} ${(account['balance'] ?? 0).toStringAsFixed(2)}",
              style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
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

  String _formatBalance(dynamic balance, String? currency) {
    final amount = (balance ?? 0.0).toStringAsFixed(2);
    String symbol = '';
    switch (currency) {
      case 'USD': symbol = '\$'; break;
      case 'EUR': symbol = '€'; break;
      case 'GBP': symbol = '£'; break;
      case 'NGN': symbol = '₦'; break;
      default: symbol = '';
    }
    return "$symbol$amount";
  }
}
