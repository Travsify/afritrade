import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:afritrad_mobile/core/constants/api_config.dart';
import 'package:afritrad_mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/kyc_provider.dart';
import '../../../auth/presentation/pages/kyb_registration_screen.dart';
import 'transaction_pin_screen.dart';
import '../../../support/presentation/pages/support_assistant_screen.dart';
import '../../../settings/presentation/pages/about_afritrade_screen.dart';
import '../../../settings/presentation/pages/legal_document_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  String _userName = 'Afritrade Merchant';
  String _userEmail = 'merchant@afritrade.com';
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Afritrade User';
        _userEmail = prefs.getString('user_email') ?? 'user@afritrade.com';
      });
      // Fetch fresh data from backend
      Provider.of<KYCProvider>(context, listen: false).fetchProfile().then((_) {
        // Update local UI name/email if they changed
        if (mounted) {
          setState(() {
            _userName = prefs.getString('user_name') ?? _userName;
            _userEmail = prefs.getString('user_email') ?? _userEmail;
          });
        }
      });
    }
  }

  Future<void> _pickImage(KYCProvider provider) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await provider.setProfileImage(image.path);
    }
  }
  Widget build(BuildContext context) {
    final kycProvider = context.watch<KYCProvider>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(kycProvider),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVerificationStatus(kycProvider),
                  const SizedBox(height: 24),
                  _buildTraderTier(kycProvider),
                  const SizedBox(height: 24),
                  _buildTradeAnalytics(),
                  const SizedBox(height: 24),
                  _buildBusinessIDCard(kycProvider),
                  const SizedBox(height: 32),
                  _buildAccountLimits(kycProvider),
                  const SizedBox(height: 24),
                  _buildReferralCard(kycProvider),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Security & Privacy"),
                  const SizedBox(height: 16),
                  _buildSecuritySettings(kycProvider),
                  const SizedBox(height: 32),
                  _buildSectionTitle("General Settings"),
                  const SizedBox(height: 16),
                  _buildGeneralSettings(kycProvider),
                  const SizedBox(height: 48),
                  _buildLogoutButton(kycProvider),
                  const SizedBox(height: 40),
                  _buildVersionInfo(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(KYCProvider kyc) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative background
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                FadeInDown(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        height: 110,
                        width: 110,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: GestureDetector(
                          onTap: () => _pickImage(kyc),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: kyc.profileImagePath != null
                                ? DecorationImage(
                                    image: FileImage(File(kyc.profileImagePath!)),
                                    fit: BoxFit.cover,
                                  )
                                : const DecorationImage(
                                    image: NetworkImage("https://ui-avatars.com/api/?name=Afritrade+Merchant&background=6366F1&color=fff&size=200"),
                                    fit: BoxFit.cover,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _pickImage(kyc),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.background, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  child: Text(
                    _userName,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    _userEmail,
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStatus(KYCProvider kyc) {
    bool isVerified = kyc.isVerified;
    bool isKybVerified = kyc.isKybVerified;
    bool isKybRejected = kyc.kybStatus == KYBStatus.rejected;

    return GestureDetector(
      onTap: () => _showVerificationCenter(kyc),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildStatusIndicator("Identity (KYC)", isVerified, kyc.kycStatus == KYCStatus.pending),
                const SizedBox(width: 4),
                _buildStatusIndicator("Business (KYB)", isKybVerified, kyc.kybStatus == KYBStatus.pending),
              ],
            ),
            if (!isVerified || !isKybVerified) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isKybRejected ? AppColors.error.withOpacity(0.1) : AppColors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isKybRejected ? Icons.error_outline : Icons.info_outline, 
                      color: isKybRejected ? AppColors.error : AppColors.amber, 
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isKybRejected 
                            ? "Action Required: KYB Rejected"
                            : isVerified ? "Complete KYB to unlock higher limits." : "Finish verification to start trading.",
                        style: GoogleFonts.outfit(
                          color: isKybRejected ? AppColors.error : AppColors.amber, 
                          fontSize: 13,
                          fontWeight: isKybRejected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios, 
                      color: isKybRejected ? AppColors.error : AppColors.amber, 
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showVerificationCenter(KYCProvider kyc) {
    bool isKybRejected = kyc.kybStatus == KYBStatus.rejected;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: AppColors.glassBorder),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            Row(
              children: [
                Text("Verification Center", style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text("Tier 2", style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            if (isKybRejected) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Text("Rejection Reason", style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      kyc.kybRejectionReason ?? "Unknown error. Please contact support.",
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            _buildDocStatusSection("Business Documents", kyc.kybDocStatuses),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const KYBRegistrationScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isKybRejected ? AppColors.error : AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  isKybRejected ? "Update Rejected Documents" : "Start KYB Verification",
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocStatusSection(String title, Map<String, String> statuses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...statuses.entries.map((e) => _buildDocStatusRow(e.key, e.value)),
      ],
    );
  }

  Widget _buildDocStatusRow(String doc, String status) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'verified':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        statusText = "Verified";
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        statusText = "Rejected";
        break;
      case 'pending':
        statusColor = AppColors.amber;
        statusIcon = Icons.hourglass_empty;
        statusText = "Pending";
        break;
      default:
        statusColor = AppColors.textMuted;
        statusIcon = Icons.radio_button_unchecked;
        statusText = "Awaiting";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.file_copy_outlined, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              doc.replaceAll('_', ' '), 
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 14),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: GoogleFonts.outfit(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, bool isVerified, bool isPending) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isVerified 
                  ? AppColors.success.withOpacity(0.1) 
                  : isPending ? AppColors.amber.withOpacity(0.1) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVerified ? Icons.check_circle : isPending ? Icons.hourglass_empty : Icons.cancel,
                  color: isVerified ? AppColors.success : isPending ? AppColors.amber : AppColors.textMuted,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    isVerified ? "Verified" : isPending ? "Pending" : "Unverified",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: isVerified ? AppColors.success : isPending ? AppColors.amber : AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountLimits(KYCProvider kyc) {
    double progress = kyc.monthlyLimit > 0 ? kyc.monthlyUsage / kyc.monthlyLimit : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Monthly Trade Limit",
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Tier 2",
                style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8 ? AppColors.error : AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$${kyc.monthlyUsage.toStringAsFixed(0)} used",
                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                "\$${kyc.monthlyLimit.toStringAsFixed(0)} limit",
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard(KYCProvider kyc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.purple.withOpacity(0.2), AppColors.pink.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.purple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.card_giftcard, color: AppColors.purple, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Referral Rewards",
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${kyc.referralCount} friends joined via your link",
                  style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${kyc.referralEarnings.toStringAsFixed(2)}",
                style: GoogleFonts.outfit(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                "Earned",
                style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildSecuritySettings(KYCProvider kyc) {
    return Column(
      children: [
        _buildToggleItem(
          Icons.fingerprint, 
          "Biometric Authentication", 
          kyc.biometricsEnabled,
          (val) => kyc.toggleBiometrics(val),
        ),
        _buildActionItem(
          Icons.lock_outline, 
          "Change Transaction PIN", 
          kyc.hasTransactionPin ? "Secure your executions" : "Setup your security PIN", 
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TransactionPinScreen(isChange: kyc.hasTransactionPin)),
            );
          },
        ),
        _buildActionItem(
          Icons.history_toggle_off, 
          "Security Audit Log", 
          "Recent activity and devices", 
          () => _showSecurityAuditLog(kyc),
        ),
      ],
    );
  }

  void _showSecurityAuditLog(KYCProvider kyc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 450,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text("Security Audit Log", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: kyc.securityLogs.isEmpty
                  ? Center(child: Text("No recent security activity", style: GoogleFonts.outfit(color: AppColors.textMuted)))
                  : ListView.builder(
                      itemCount: kyc.securityLogs.length,
                      itemBuilder: (context, index) {
                        final log = kyc.securityLogs[index];
                        return _buildAuditItem(
                          log['title'] ?? 'Security Alert',
                          log['message'] ?? '',
                          log['created_at'] != null 
                            ? log['created_at'].toString().split('T').first 
                            : 'Recently',
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditItem(String title, String details, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: const Icon(Icons.security, color: AppColors.success, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text(details, style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings(KYCProvider kyc) {
    return Column(
      children: [
        _buildActionItem(
          Icons.language, 
          "App Language", 
          kyc.appLanguage, 
          () => _showLanguageSelection(kyc),
        ),
        _buildActionItem(
          Icons.help_center_outlined, 
          "Support HQ", 
          "Live chat and knowledge base", 
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SupportAssistantScreen()),
            );
          },
        ),
        _buildActionItem(
          Icons.info_outline, 
          "About Afritrade", 
          "Legal, Privacy and Version", 
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutAfritradeScreen()),
            );
          },
        ),
        _buildActionItem(
          Icons.privacy_tip_outlined, 
          "Privacy Policy", 
          "How we handle your data", 
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LegalDocumentScreen(
                  title: "Privacy Policy",
                  content: "Afritrade is committed to protecting your privacy. We collect and process your personal information only to provide and improve our cross-border trading services. We use industry-standard encryption to protect your data and never share your details with unauthorized third parties. For a detailed breakdown of data usage, please review our full policy...",
                ),
              ),
            );
          },
        ),
        _buildActionItem(
          Icons.gavel_rounded, 
          "Terms & Conditions", 
          "Your agreement with Afritrade", 
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LegalDocumentScreen(
                  title: "Terms & Conditions",
                  content: "By using Afritrade, you agree to comply with our trading guidelines and local financial regulations. Users are responsible for maintaining the security of their accounts and transaction PINs. Afritrade reserves the right to suspend accounts found to be in violation of our anti-money laundering (AML) protocols. Trades are final once executed...",
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showLanguageSelection(KYCProvider kyc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 350,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text("Select App Language", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildLanguageOption("English (Global)", kyc),
            _buildLanguageOption("French (Français)", kyc),
            _buildLanguageOption("Spanish (Español)", kyc),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String lang, KYCProvider kyc) {
    bool isSelected = kyc.appLanguage == lang;
    return InkWell(
      onTap: () {
        kyc.setAppLanguage(lang);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Text(lang, style: GoogleFonts.outfit(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showStatementExport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 350,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text("Export Trade Statements", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Select format and time period", style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 14)),
            const SizedBox(height: 32),
            _buildExportOption("PDF Statement", "Professional report for accounting", Icons.picture_as_pdf, Colors.redAccent),
            const SizedBox(height: 16),
            _buildExportOption("CSV Spreadsheet", "Raw data for Excel/reconciliation", Icons.table_chart, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(subtitle, style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.download, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }

  Widget _buildToggleItem(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          Switch.adaptive(
            value: value, 
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text(subtitle, style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(KYCProvider kyc) {
    return Center(
      child: _isLoggingOut
          ? const CircularProgressIndicator(color: AppColors.error)
          : TextButton(
              onPressed: () => _performLogout(kyc),
              child: Text(
                "Sign Out Safely",
                style: GoogleFonts.outfit(
                  color: AppColors.error,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  Future<void> _performLogout(KYCProvider kyc) async {
    setState(() => _isLoggingOut = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        await http.post(
          Uri.parse(AppApiConfig.logout),
          headers: AppApiConfig.getHeaders(token),
        ).timeout(const Duration(seconds: 5));
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_pin');

    kyc.setLoggedIn(false);

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Column(
        children: [
          Text(
            "Afritrade v1.4.2 (Elite Build)",
            style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            "Secured by 256-bit Encryption",
            style: GoogleFonts.outfit(color: AppColors.primary.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  Widget _buildTraderTier(KYCProvider kyc) {
    int points = kyc.traderPoints;
    String tier = points >= 2000 ? "Gold" : (points >= 1000 ? "Silver" : "Bronze");
    Color tierColor = tier == "Gold" ? AppColors.amber : (tier == "Silver" ? AppColors.secondary : Colors.brown);
    double progress = (points % 1000) / 1000;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(color: tierColor.withOpacity(0.1), shape: BoxShape.circle),
                     child: Icon(Icons.stars_rounded, color: tierColor, size: 20),
                   ),
                   const SizedBox(width: 12),
                   Text("$tier Merchant", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Text("$points pts", style: GoogleFonts.outfit(color: tierColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.background,
              color: tierColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${(1000 - (points % 1000)).toInt()} more points to reach next tier",
            style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeAnalytics() {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
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
              Text("Trade Volume", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              Text("+12.5%", style: GoogleFonts.outfit(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 3),
                      const FlSpot(1, 1),
                      const FlSpot(2, 4),
                      const FlSpot(3, 2),
                      const FlSpot(4, 5),
                      const FlSpot(5, 3.5),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessIDCard(KYCProvider kyc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("BUSINESS ID", style: GoogleFonts.outfit(color: Colors.white38, letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.bold)),
              const Icon(Icons.qr_code_2_rounded, color: Colors.white54, size: 24),
            ],
          ),
          const SizedBox(height: 24),
          Text("AFRITRAD MERCHANT", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(kyc.kybStatus == KYBStatus.verified ? "Verified Enterprise" : "Standard Account", style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("MEMBER SINCE", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 8)),
                  Text("ACTIVE MERCHANT", style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share_rounded, size: 14),
                label: const Text("Share ID"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


