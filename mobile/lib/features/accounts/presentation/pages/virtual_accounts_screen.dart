import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/services/anchor_service.dart';
import '../../../../core/theme/app_colors.dart';

class VirtualAccountsScreen extends StatefulWidget {
  const VirtualAccountsScreen({super.key});

  @override
  State<VirtualAccountsScreen> createState() => _VirtualAccountsScreenState();
}

class _VirtualAccountsScreenState extends State<VirtualAccountsScreen> {
  final _anchorService = AnchorService();
  List<Map<String, dynamic>> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  void _fetchAccounts() async {
    final accounts = await _anchorService.getVirtualAccounts();
    if (mounted) {
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    }
  }

  void _showCreateAccountModal() {
    String selectedCurrency = 'USD';
    final nameController = TextEditingController(text: 'Afritrade Business');
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
                "Choose a currency to create a new virtual account",
                style: GoogleFonts.outfit(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              Text("Account Name", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: TextField(
                  controller: nameController,
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter account name",
                    hintStyle: GoogleFonts.outfit(color: AppColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text("Select Currency", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: ['USD', 'EUR', 'GBP', 'NGN'].map((currency) {
                  final isSelected = selectedCurrency == currency;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedCurrency = currency),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.glassBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        currency,
                        style: GoogleFonts.outfit(
                          color: isSelected ? AppColors.primary : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
                      label: nameController.text,
                    );
                    setModalState(() => isCreating = false);
                    if (mounted) {
                      Navigator.pop(context);
                      if (result['status'] == 'success') {
                        setState(() {
                          _accounts.add(result['data']);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("$selectedCurrency account created successfully!"),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } else {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message'] ?? "Failed to create account"),
                            backgroundColor: AppColors.error,
                            duration: Duration(seconds: 4),
                          ),
                        );
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
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountDetails(Map<String, dynamic> account) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
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
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    account['currency'],
                    style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account['bank_name'] ?? 'Virtual Account',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        account['account_name'] ?? '',
                        style: GoogleFonts.outfit(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (account['account_number'] != null)
                      _buildCopyableDetail("Account Number", account['account_number']),
                    if (account['routing_number'] != null)
                      _buildCopyableDetail("Routing Number", account['routing_number']),
                    if (account['iban'] != null)
                      _buildCopyableDetail("IBAN", account['iban']),
                    if (account['bic'] != null)
                      _buildCopyableDetail("BIC/SWIFT", account['bic']),
                    if (account['sort_code'] != null)
                      _buildCopyableDetail("Sort Code", account['sort_code']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final details = StringBuffer();
                  details.writeln("Bank: ${account['bank_name']}");
                  details.writeln("Name: ${account['account_name']}");
                  if (account['account_number'] != null) details.writeln("Account: ${account['account_number']}");
                  if (account['routing_number'] != null) details.writeln("Routing: ${account['routing_number']}");
                  if (account['iban'] != null) details.writeln("IBAN: ${account['iban']}");
                  if (account['bic'] != null) details.writeln("BIC: ${account['bic']}");
                  
                  Clipboard.setData(ClipboardData(text: details.toString()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Account details copied!")),
                  );
                },
                icon: const Icon(Icons.copy),
                label: Text("Copy All Details", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyableDetail(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: AppColors.primary, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$label copied!")),
              );
            },
          ),
        ],
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
          "Virtual Accounts",
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
          : _accounts.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async => _fetchAccounts(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _accounts.length,
                    itemBuilder: (context, index) {
                      final account = _accounts[index];
                      return FadeInUp(
                        delay: Duration(milliseconds: index * 100),
                        child: _buildAccountCard(account),
                      );
                    },
                  ),
                ),
      floatingActionButton: _accounts.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _showCreateAccountModal,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text("New Account", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_balance_outlined, size: 64, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            Text(
              "No Virtual Accounts Yet",
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Create your first virtual account to receive payments in USD, EUR, GBP, or NGN",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showCreateAccountModal,
              icon: const Icon(Icons.add),
              label: Text("Create Account", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(Map<String, dynamic> account) {
    return GestureDetector(
      onTap: () => _showAccountDetails(account),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        account['currency'] ?? 'USD',
                        style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      account['bank_name'] ?? 'Virtual Account',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  account['account_name'] ?? '',
                  style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
                ),
                Text(
                  "${account['currency']} ${(account['balance'] ?? 0.0).toStringAsFixed(2)}",
                  style: GoogleFonts.outfit(color: AppColors.success, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
