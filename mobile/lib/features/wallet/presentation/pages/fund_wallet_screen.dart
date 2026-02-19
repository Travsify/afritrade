import 'package:afritrad_mobile/core/constants/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/anchor_service.dart';
import '../../../../core/theme/app_colors.dart';

class FundWalletScreen extends StatefulWidget {
  const FundWalletScreen({super.key});

  @override
  State<FundWalletScreen> createState() => _FundWalletScreenState();
}

class _FundWalletScreenState extends State<FundWalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _anchorService = AnchorService();
  
  bool _isLoading = true;
  Map<String, dynamic>? _account;
  String? _cryptoAddress;
  Map<String, dynamic> _limits = {
    'tier': 1,
    'remaining_daily': 0.0,
    'daily_limit': 1000.0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // 1. Get Accounts (Bank Transfer)
    final accounts = await _anchorService.getVirtualAccounts();
    // 2. Get Crypto Address
    final cryptoData = await _anchorService.getCryptoFundingAddress();
    // 3. Get Limits
    final limits = await _anchorService.getUserLimits();

    if (mounted) {
      setState(() {
        if (accounts.isNotEmpty) _account = accounts.first;
        if (cryptoData['status'] == 'success') _cryptoAddress = cryptoData['address'];
        _limits = limits;
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
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        title: Text("Fund Wallet",
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: "Bank Transfer"),
            Tab(text: "Stablecoin (USDT)"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // NEW: Limits Banner
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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

                  _buildAccountSelector(),
                  SizedBox(
                    height: 500, // Fixed height for TabBarView in ScrollView
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBankTab(),
                        _buildCryptoTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAccountSelector() {
    if (_account == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: _anchorService.accountsNotifier,
          builder: (context, accounts, _) {
            return DropdownButtonHideUnderline(
              child: DropdownButton<Map<String, dynamic>>(
                value: _account,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                style: GoogleFonts.outfit(color: Colors.white),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _account = newValue;
                    });
                  }
                },
                items: accounts.map((account) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: account,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Text(account['currency'] ?? '',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                        ),
                        const SizedBox(width: 12),
                        Text(account['label'] ?? 'Account'),
                        const Spacer(),
                        Text(
                          "${account['currency']} ${(account['balance'] ?? 0).toStringAsFixed(2)}",
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          }),
    );
  }

  Widget _buildBankTab() {
    if (_account == null) {
      return Center(
          child: Text("No Virtual Account Found",
              style: GoogleFonts.outfit(color: Colors.white)));
    }

    // CNY Handling
    if (_account!['currency'] == 'CNY') {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 64, color: AppColors.warning),
            const SizedBox(height: 24),
            Text(
              "Direct Funding Unavailable",
              style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "CNY wallets cannot be funded directly via bank transfer. Please fund your NGN/USD wallet and Swap to CNY.",
              style: GoogleFonts.outfit(
                  color: AppColors.textSecondary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailCard([
            _row("Bank Name", _account!['bank_name'] ?? 'Virtual Bank'),
            const Divider(color: Colors.white10),
            _row("Account Name", _account!['account_name'] ?? 'User'),
            const Divider(color: Colors.white10),
            _row("Account Number", _account!['account_number'] ?? 'N/A',
                isCopyable: true),
          ]),
          const SizedBox(height: 24),
          Text(
            "Transfer to this account number to fund your wallet automatically.",
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoTab() {
    if (_cryptoAddress == null) {
      return Center(
          child: Text("Crypto Service Unavailable",
              style: GoogleFonts.outfit(color: Colors.white)));
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            // Placeholder for QR
            child: const Icon(Icons.qr_code_2, size: 200, color: Colors.black),
          ),
          const SizedBox(height: 32),
          Text(
            "USDT (TRC20) Deposit Address",
            style: GoogleFonts.outfit(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _cryptoAddress!,
                    style: GoogleFonts.outfit(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: AppColors.primary),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _cryptoAddress!));
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Address copied!")));
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Only send USDT (TRC20) to this address. Sending any other asset may result in permanent loss.",
            style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _row(String label, String value, {bool isCopyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white54)),
          Row(
            children: [
              Text(value,
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              if (isCopyable) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Copied!")));
                  },
                  child: const Icon(Icons.copy,
                      size: 16, color: AppColors.primary),
                )
              ]
            ],
          ),
        ],
      ),
    );
  }
}
