import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/api_config.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  Map<String, dynamic>? _kycStatus;
  bool _isLoading = true;
  bool _isSubmitting = false;

  final _documentNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKycStatus();
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> _loadKycStatus() async {
    setState(() => _isLoading = true);
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(AppApiConfig.kycStatus),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _kycStatus = data['data'];
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('KYC Status Error: $e');
    }
    setState(() => _isLoading = false);
  }

  void _showSubmitDocumentModal(String documentType, String title) {
    _documentNumberController.clear();
    File? selectedFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Verify $title", style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              if (documentType != 'utility_bill') ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _documentNumberController,
                    style: GoogleFonts.outfit(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: _getHint(documentType),
                      hintStyle: const TextStyle(color: Colors.white38),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (documentType == 'utility_bill') ...[
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setModalState(() => selectedFile = File(image.path));
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          selectedFile != null ? Icons.check_circle : Icons.cloud_upload,
                          color: selectedFile != null ? AppColors.success : Colors.white54,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedFile != null ? "File Selected" : "Tap to upload document",
                          style: GoogleFonts.outfit(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () async {
                    setModalState(() => _isSubmitting = true);
                    Navigator.pop(context);
                    await _submitDocument(documentType, selectedFile);
                    setState(() => _isSubmitting = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _isSubmitting ? "Verifying..." : "Submit for Verification",
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getHint(String type) {
    switch (type) {
      case 'bvn': return 'Enter 11-digit BVN';
      case 'nin': return 'Enter 11-digit NIN';
      case 'drivers_license': return 'Enter License Number';
      case 'passport': return 'Enter Passport Number';
      default: return 'Enter Document Number';
    }
  }

  Future<void> _submitDocument(String type, File? file) async {
    try {
      final headers = await _getHeaders();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppApiConfig.kycVerify), // Using kycVerify for submission
      );
      
      request.headers.addAll(headers);
      request.fields['document_type'] = type;
      
      if (_documentNumberController.text.isNotEmpty) {
        request.fields['document_number'] = _documentNumberController.text;
      }
      
      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('document_file', file.path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Submitted')),
        );
        _loadKycStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("KYC Verification", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadKycStatus,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTierCard(),
                    const SizedBox(height: 24),
                    _buildDocumentsList(),
                    const SizedBox(height: 24),
                    _buildRequirements(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTierCard() {
    final tier = _kycStatus?['kyc_tier'] ?? 0;
    final tierInfo = _kycStatus?['tier_info'] ?? {};

    return FadeInDown(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getTierGradient(tier),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(_getTierIcon(tier), color: Colors.white, size: 48),
            const SizedBox(height: 12),
            Text("Tier $tier", style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(tierInfo['description'] ?? '', style: GoogleFonts.outfit(color: Colors.white70)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _limitBadge("Daily", "₦${_formatNumber(tierInfo['daily'] ?? 0)}"),
                _limitBadge("Monthly", "₦${_formatNumber(tierInfo['monthly'] ?? 0)}"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _limitBadge(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  List<Color> _getTierGradient(int tier) {
    switch (tier) {
      case 1: return [Colors.blue[700]!, Colors.blue[400]!];
      case 2: return [Colors.purple[700]!, Colors.purple[400]!];
      case 3: return [Colors.amber[700]!, Colors.amber[400]!];
      default: return [Colors.grey[700]!, Colors.grey[500]!];
    }
  }

  IconData _getTierIcon(int tier) {
    switch (tier) {
      case 1: return Icons.verified_user;
      case 2: return Icons.shield;
      case 3: return Icons.workspace_premium;
      default: return Icons.person_outline;
    }
  }

  String _formatNumber(dynamic num) {
    final n = num is int ? num : (num as double).toInt();
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toString();
  }

  Widget _buildDocumentsList() {
    final docs = _kycStatus?['documents'] as List? ?? [];
    if (docs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Submitted Documents", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...docs.map((doc) => _docItem(doc)).toList(),
      ],
    );
  }

  Widget _docItem(Map<String, dynamic> doc) {
    final status = doc['status'] ?? 'pending';
    final statusColor = status == 'approved' ? AppColors.success : (status == 'rejected' ? Colors.red : Colors.amber);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.description, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDocType(doc['document_type']), style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                if (doc['document_number'] != null)
                  Text(doc['document_number'], style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status.toUpperCase(), style: GoogleFonts.outfit(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatDocType(String type) {
    return type.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }

  Widget _buildRequirements() {
    final required = _kycStatus?['required_for_next_tier'] as Map<String, dynamic>? ?? {};
    if (required.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 12),
            Expanded(child: Text("Maximum verification level reached!", style: GoogleFonts.outfit(color: Colors.white))),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Upgrade to Next Tier", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...required.entries.map((e) => _requirementItem(e.key, e.value)).toList(),
      ],
    );
  }

  Widget _requirementItem(String type, String label) {
    return GestureDetector(
      onTap: () => _showSubmitDocumentModal(type, label),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500))),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
