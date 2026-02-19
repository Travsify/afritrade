import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';

import 'package:afritrad_mobile/core/theme/app_colors.dart';
import 'package:afritrad_mobile/core/theme/app_theme.dart';
import 'package:afritrad_mobile/core/services/anchor_service.dart';
import 'package:afritrad_mobile/features/payments/presentation/pages/pay_supplier_screen.dart';
import 'package:afritrad_mobile/features/payments/presentation/pages/fund_wallet_screen.dart';
import 'package:afritrad_mobile/features/accounts/presentation/pages/virtual_accounts_screen.dart';
import 'package:afritrad_mobile/features/cards/presentation/pages/virtual_cards_screen.dart';
import 'package:afritrad_mobile/features/accounts/presentation/pages/accounts_screen.dart';
import 'package:afritrad_mobile/features/swap/presentation/pages/swap_screen.dart';
import 'package:afritrad_mobile/features/profile/presentation/pages/profile_screen.dart';
import 'package:afritrad_mobile/features/referral/presentation/pages/referral_screen.dart';
// Productivity Tools
import 'package:afritrad_mobile/features/tools/presentation/pages/bulk_payment_screen.dart';
import 'package:afritrad_mobile/features/tools/presentation/pages/tax_report_screen.dart';
import 'package:afritrad_mobile/features/tools/presentation/pages/order_management_screen.dart';
// Other Features
import 'package:afritrad_mobile/features/calculator/presentation/pages/business_calculator_screen.dart';
import 'package:afritrad_mobile/features/beneficiaries/presentation/pages/saved_beneficiaries_screen.dart';
import 'package:afritrad_mobile/features/insights/presentation/pages/trade_insights_screen.dart';
import 'package:afritrad_mobile/features/alerts/presentation/pages/rate_alerts_screen.dart';
import 'package:afritrad_mobile/features/scheduler/presentation/pages/payment_scheduler_screen.dart';
import 'package:afritrad_mobile/features/invoices/presentation/pages/invoices_screen.dart';
import 'package:afritrad_mobile/features/wallet/presentation/pages/withdrawal_screen.dart';
import 'package:provider/provider.dart';
import 'package:afritrad_mobile/features/auth/data/kyc_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _balanceVisible = true;
  late AnimationController _glowController;
  
  // Dashboard Account Selection
  final _anchorService = AnchorService();
  Map<String, dynamic>? _selectedAccount;
  bool _isLoadingAccounts = true;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    _fetchAccounts();
  }

  void _fetchAccounts() async {
    final accounts = await _anchorService.getVirtualAccounts();
    if (mounted) {
      setState(() {
        if (accounts.isNotEmpty) {
          // Default to USD if available, else first one
          _selectedAccount = accounts.firstWhere(
            (a) => a['currency'] == 'USD',
            orElse: () => accounts.first,
          );
        } else {
          _selectedAccount = null;
        }
        _isLoadingAccounts = false;
      });
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: _buildFloatingBottomNav(),
      extendBody: true,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return AccountsScreen();
      case 2:
        return _buildQuickActionsMenu();
      case 3:
        return VirtualCardsScreen();
      case 4:
        return ProfileScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildFloatingBottomNav() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(0, Iconsax.home, "Home"),
          _buildNavItem(1, Iconsax.wallet_2, "Accounts"),
          _buildCenterNavItem(),
          _buildNavItem(3, Iconsax.card, "Cards"),
          _buildNavItem(4, Iconsax.user, "Profile"),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textMuted,
            size: 24,
          ),
          if (isSelected)
            Container(
              margin: EdgeInsets.only(top: 4),
              height: 4,
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCenterNavItem() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, Color(0xFF00FFCC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Iconsax.add, color: Colors.black, size: 28),
      ),
    );
  }
  
  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: () async {
        _fetchAccounts();
        await Future.delayed(Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildHeader(),
                   SizedBox(height: 16),
                   _buildVerificationBanner(),
                   SizedBox(height: 24),
                  _buildBannerCarousel(),
                  SizedBox(height: 24),
                  ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: _anchorService.accountsNotifier,
                    builder: (context, accounts, child) {
                      if (accounts.isEmpty && !_isLoadingAccounts) {
                         return _buildEmptyAccountState();
                      }
                      
                      if (_selectedAccount != null && !accounts.contains(_selectedAccount)) {
                         if (accounts.isNotEmpty) _selectedAccount = accounts.first;
                      }
                      if (_selectedAccount == null && accounts.isNotEmpty) {
                        _selectedAccount = accounts.first;
                      }

                      return _buildAccountCard();
                    },
                  ),
                  SizedBox(height: 32),
                   _buildBusinessHealthCard(),
                  SizedBox(height: 32),
                  _buildNewsTicker(),
                  SizedBox(height: 32),
                  _buildQuickActionsGrid(),
                  SizedBox(height: 32),
                  _buildFeatureGrid(),
                  SizedBox(height: 32),
                  _buildRecentTransactions(),
                  SizedBox(height: 32),
                  _buildMarketRates(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBanner() {
    final kycProvider = Provider.of<KYCProvider>(context);
    if (kycProvider.isVerified) return SizedBox.shrink();

    return FadeInDown(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.amber.withOpacity(0.2), AppColors.accent.withOpacity(0.2)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.amber.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.info_outline_rounded, color: AppColors.amber, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Verification Required",
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    "Complete your KYB to unlock all features.",
                    style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to KYC/KYB flow
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Redirecting to verification flow..."))
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(horizontal: 16),
                elevation: 0,
              ),
              child: Text("Verify", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Afritrad User",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => _showNotifications(),
              icon: Icon(Iconsax.notification, color: Colors.white),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen()),
                );
              },
              child: Container(
                height: 40, width: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: ClipOval(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBannerCarousel() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _anchorService.getBanners(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return SizedBox.shrink();
        
        final banners = snapshot.data!;
        return Container(
          height: 160,
          width: double.infinity,
          child: PageView.builder(
            itemCount: banners.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(banners[index]['image_url']),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                  ]
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyAccountState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
           Icon(Icons.account_balance_wallet, size: 48, color: AppColors.textMuted),
           SizedBox(height: 16),
           Text(
             "No Accounts Active",
             style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
           ),
           SizedBox(height: 16),
           ElevatedButton(
             onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AccountsScreen()));
             },
             style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
             child: Text("Create Account"),
           ),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    if (_selectedAccount == null) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF0F3D2E),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0F3D2E).withOpacity(0.5),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: _anchorService.accountsNotifier,
                  builder: (context, accounts, _) {
                    return DropdownButtonHideUnderline(
                      child: DropdownButton<Map<String, dynamic>>(
                        value: _selectedAccount,
                        dropdownColor: AppColors.surface,
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedAccount = newValue;
                            });
                          }
                        },
                        items: accounts.map((account) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: account,
                            child: Row(
                              children: [
                                Text(account['currency'] ?? 'NGN'),
                                SizedBox(width: 8),
                                Text(
                                  account['label'] ?? '', 
                                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.white70)
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                ),
              ),
              SvgPicture.asset(
                'assets/icons/mastercard.svg',
                height: 24,
                placeholderBuilder: (_) => Icon(Icons.credit_card, color: Colors.white54),
              )
            ],
          ),
          SizedBox(height: 24),
          Text(
            "Total Balance",
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                _balanceVisible 
                  ? "${_selectedAccount!['currency']} ${(_selectedAccount!['balance'] ?? 0).toStringAsFixed(2)}" 
                  : "****",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 12),
              IconButton(
                onPressed: () => setState(() => _balanceVisible = !_balanceVisible),
                icon: Icon(
                  _balanceVisible ? Iconsax.eye : Iconsax.eye_slash,
                  color: Colors.white54,
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Account Number", style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _selectedAccount!['account_number'] ?? 'Wallet Only',
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.copy, color: Colors.white54, size: 14),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Bank Name", style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                    SizedBox(height: 4),
                    Text(
                      _selectedAccount!['bank_name'] ?? 'Anchor',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      {'icon': Iconsax.convert_card, 'label': 'Swap', 'color': Colors.orange, 'page': SwapScreen()},
      {'icon': Iconsax.export_1, 'label': 'Send', 'color': Colors.blue, 'page': PaySupplierScreen()},
      {'icon': Iconsax.import, 'label': 'Receive', 'color': Colors.green, 'page': FundWalletScreen()},
      {'icon': Iconsax.bill, 'label': 'Bills', 'color': Colors.purple, 'page': null, 'action': () => _showBillsDialog()},
    ];

    final kycProvider = Provider.of<KYCProvider>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        bool isRestricted = !kycProvider.isVerified && (action['label'] == 'Swap' || action['label'] == 'Send');
        
        return GestureDetector(
          onTap: isRestricted ? () {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text("Please complete verification to use ${action['label']}"),
                 backgroundColor: AppColors.amber,
               )
             );
          } : () {
            if (action['action'] != null) {
              (action['action'] as VoidCallback)();
            } else if (action['page'] != null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => action['page'] as Widget));
            }
          },
          child: Opacity(
            opacity: isRestricted ? 0.5 : 1.0,
            child: Column(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: (action['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: (action['color'] as Color).withOpacity(0.2)),
                  ),
                  child: Icon(action['icon'] as IconData, color: action['color'] as Color),
                ),
                SizedBox(height: 8),
                Text(
                  action['label'] as String,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Trader Tools",
          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
          children: [
            _buildFeatureCard(Icons.people_rounded, "Beneficiaries", AppColors.featureBeneficiaries, () => Navigator.push(context, MaterialPageRoute(builder: (c) => SavedBeneficiariesScreen()))),
            _buildFeatureCard(Icons.insights_rounded, "Insights", AppColors.featureInsights, () => Navigator.push(context, MaterialPageRoute(builder: (c) => TradeInsightsScreen()))),
            _buildFeatureCard(Icons.payments_rounded, "Bulk Pay", AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (c) => BulkPaymentScreen()))),
            _buildFeatureCard(Icons.assignment_turned_in_rounded, "Compliance", AppColors.success, () => Navigator.push(context, MaterialPageRoute(builder: (c) => TaxReportScreen()))),
            _buildFeatureCard(Icons.inventory_2_rounded, "Orders", AppColors.amber, () => Navigator.push(context, MaterialPageRoute(builder: (c) => OrderManagementScreen()))),
            _buildFeatureCard(Icons.schedule_rounded, "Schedule", AppColors.featureScheduler, () => Navigator.push(context, MaterialPageRoute(builder: (c) => PaymentSchedulerScreen()))),
            _buildFeatureCard(Icons.calculate_rounded, "Calculator", AppColors.featureCalculator, () => Navigator.push(context, MaterialPageRoute(builder: (c) => BusinessCalculatorScreen()))),
            _buildFeatureCard(Icons.notifications_active_rounded, "Rate Alerts", AppColors.featureAlerts, () => Navigator.push(context, MaterialPageRoute(builder: (c) => RateAlertsScreen()))),
            _buildFeatureCard(Icons.card_giftcard_rounded, "Refer", AppColors.featureReferral, () => Navigator.push(context, MaterialPageRoute(builder: (c) => ReferralScreen()))),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            SizedBox(height: 12),
            Text(label, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsMenu() {
    final quickActions = [
      {'icon': Iconsax.convert_card, 'label': 'Swap Currency', 'color': Colors.orange, 'page': SwapScreen()},
      {'icon': Iconsax.export_1, 'label': 'Send Money', 'color': Colors.blue, 'page': PaySupplierScreen()},
      {'icon': Iconsax.import, 'label': 'Receive Money', 'color': Colors.green, 'page': FundWalletScreen()},
      {'icon': Iconsax.card_add, 'label': 'Virtual Cards', 'color': Colors.purple, 'page': VirtualCardsScreen()},
      {'icon': Iconsax.bank, 'label': 'Virtual Accounts', 'color': Colors.teal, 'page': VirtualAccountsScreen()},
      {'icon': Iconsax.receipt_item, 'label': 'Invoices', 'color': Colors.indigo, 'page': InvoicesScreen()},
      {'icon': Iconsax.money_send, 'label': 'Withdraw', 'color': Colors.red, 'page': WithdrawalScreen()},
      {'icon': Iconsax.calculator, 'label': 'Calculator', 'color': Colors.amber, 'page': BusinessCalculatorScreen()},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Quick Actions',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => setState(() => _currentIndex = 0),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: quickActions.length,
          itemBuilder: (context, index) {
            final action = quickActions[index];
            return GestureDetector(
              onTap: () {
                if (action['page'] != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => action['page'] as Widget));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: (action['color'] as Color).withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (action['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(action['icon'] as IconData, color: action['color'] as Color, size: 32),
                    ),
                    SizedBox(height: 12),
                    Text(
                      action['label'] as String,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Transactions",
              style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AccountsScreen())),
              child: Text("See All", style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _anchorService.getTransactions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                 return Center(child: Text("No transactions yet", style: GoogleFonts.outfit(color: AppColors.textMuted)));
              }
              
              return Column(
                children: snapshot.data!.map((tx) {
                   return Column(
                     children: [
                       _buildTransactionItem(
                          icon: _getIconForType(tx['type']),
                          iconColor: _getColorForType(tx['type']),
                          title: tx['title'],
                          subtitle: tx['date'],
                          amount: "${tx['type'] == 'debit' ? '-' : '+'}${tx['currency']} ${tx['amount']}",
                          amountColor: _getColorForType(tx['type']),
                       ),
                       if (tx != snapshot.data!.last) Divider(color: AppColors.glassBorder),
                     ],
                   );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'debit': return Iconsax.arrow_up_2;
      case 'credit': return Iconsax.arrow_down_2;
      case 'swap': return Iconsax.convert_card;
      default: return Iconsax.transaction_minus;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'debit': return Colors.red;
      case 'credit': return Colors.green;
      case 'swap': return Colors.orange;
      default: return AppColors.textPrimary;
    }
  }

  void _showBillsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text("Pay Bill", style: GoogleFonts.outfit(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.phone_android, color: Colors.blue),
              title: Text("Airtime & Data", style: GoogleFonts.outfit(color: Colors.white)),
              onTap: () { Navigator.pop(context); _processBill("Airtime"); },
            ),
            ListTile(
              leading: Icon(Icons.lightbulb, color: Colors.amber),
              title: Text("Electricity", style: GoogleFonts.outfit(color: Colors.white)),
              onTap: () { Navigator.pop(context); _processBill("Electricity"); },
            ),
             ListTile(
              leading: Icon(Icons.tv, color: Colors.red),
              title: Text("Cable TV", style: GoogleFonts.outfit(color: Colors.white)),
              onTap: () { Navigator.pop(context); _processBill("Cable TV"); },
            ),
          ],
        ),
      ),
    );
  }

  void _processBill(String type) async {
    // Show loading
    showDialog(context: context, barrierDismissible: false, builder: (c) => Center(child: CircularProgressIndicator(color: AppColors.primary)));
    
    await _anchorService.payBill(type: type, amount: 5000, reference: "REF123"); 
    
    Navigator.pop(context); // Close loading
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.success,
      content: Text("$type Payment Successful!", style: GoogleFonts.outfit(color: Colors.white)),
    ));
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.outfit(color: amountColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketRates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Market Rates", style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RateAlertsScreen())),
                child: Text("See All", style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _anchorService.getMarketRates(),
            builder: (context, snapshot) {
               if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: AppColors.primary));
               
               return ListView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: snapshot.data!.map((rate) {
                   return _buildRateCard(
                     rate['from'], 
                     rate['to'], 
                     rate['rate'].toString(), 
                     (rate['change'] as double) >= 0, 
                     (rate['change'] as double) >= 0 ? AppColors.success : AppColors.error // Simplified color logic
                   );
                }).toList(),
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _buildRateCard(String from, String to, String rate, bool isUp, Color color) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$from/$to", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
              Icon(isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: isUp ? AppColors.success : AppColors.error, size: 18),
            ],
          ),
          Row(
            children: [
              Text("₦", style: GoogleFonts.outfit(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(rate, style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildBusinessHealthCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 60, width: 60,
                child: CircularProgressIndicator(
                  value: 0.85,
                  strokeWidth: 8,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  color: AppColors.primary,
                ),
              ),
              Text("85", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Business Health", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13)),
                SizedBox(height: 4),
                Text(
                  "Market Standard",
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "High trade volume this month.",
                  style: GoogleFonts.outfit(color: AppColors.success, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
        ],
      ),
    );
  }

  Widget _buildNewsTicker() {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Marquee(
          text: " USD/NGN ₦1,600.00 (-1.2%) • GBP/NGN ₦2,025.30 (+0.2%) • EUR/NGN ₦1,739.13 (-0.5%) • CNY/NGN ₦222.22 (+0.4%) • Global Logistics: All systems operational. ",
          style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
          scrollAxis: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.center,
          blankSpace: 20.0,
          velocity: 30.0,
          pauseAfterRound: Duration(seconds: 1),
          startPadding: 10.0,
          accelerationDuration: Duration(seconds: 1),
          accelerationCurve: Curves.linear,
          decelerationDuration: Duration(milliseconds: 500),
          decelerationCurve: Curves.easeOut,
        ),
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('All notifications marked as read', style: GoogleFonts.outfit(color: Colors.white)),
                          backgroundColor: AppColors.success,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text(
                      'Mark all read',
                      style: GoogleFonts.outfit(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildNotificationItem(
                    icon: Icons.notifications_active,
                    color: AppColors.primary,
                    title: 'Welcome to Afritrad!',
                    message: 'Start trading with secure cross-border payments.',
                    time: '2 hours ago',
                  ),
                  _buildNotificationItem(
                    icon: Icons.info_outline,
                    color: AppColors.featureAlerts,
                    title: 'Rate Alert',
                    message: 'USD/NGN reached your target rate of ₦1,550',
                    time: '5 hours ago',
                  ),
                  _buildNotificationItem(
                    icon: Icons.check_circle_outline,
                    color: AppColors.success,
                    title: 'Transaction Completed',
                    message: 'Payment of \$500.00 was successful',
                    time: 'Yesterday',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.outfit(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple Marquee-like implementation to avoid dependency if not available
class Marquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double velocity;
  final double blankSpace;
  final Axis scrollAxis;
  final CrossAxisAlignment crossAxisAlignment;
  final Duration pauseAfterRound;
  final double startPadding;
  final Duration accelerationDuration;
  final Curve accelerationCurve;
  final Duration decelerationDuration;
  final Curve decelerationCurve;

  Marquee({
    super.key,
    required this.text,
    this.style = const TextStyle(),
    this.velocity = 50.0,
    this.blankSpace = 20.0,
    this.scrollAxis = Axis.horizontal,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.pauseAfterRound = Duration.zero,
    this.startPadding = 0.0,
    this.accelerationDuration = Duration.zero,
    this.accelerationCurve = Curves.decelerate,
    this.decelerationDuration = Duration.zero,
    this.decelerationCurve = Curves.decelerate,
  });

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() async {
    while (_scrollController.hasClients) {
      await Future.delayed(widget.pauseAfterRound);
      if (_scrollController.hasClients) {
        final maxExtent = _scrollController.position.maxScrollExtent;
        final duration = Duration(milliseconds: (maxExtent / widget.velocity * 1000).toInt());
        await _scrollController.animateTo(
          maxExtent,
          duration: duration,
          curve: Curves.linear,
        );
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: widget.scrollAxis,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: widget.startPadding),
            child: Text(widget.text, style: widget.style),
          ),
          SizedBox(width: widget.blankSpace),
          Text(widget.text, style: widget.style),
        ],
      ),
    );
  }
}
