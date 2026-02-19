import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/api_config.dart';

class WithdrawalHistoryScreen extends StatefulWidget {
  const WithdrawalHistoryScreen({super.key});

  @override
  State<WithdrawalHistoryScreen> createState() => _WithdrawalHistoryScreenState();
}

class _WithdrawalHistoryScreenState extends State<WithdrawalHistoryScreen> {
  List<Map<String, dynamic>> _withdrawals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWithdrawals();
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> _loadWithdrawals() async {
    setState(() => _isLoading = true);
    
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(AppApiConfig.withdrawals),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          setState(() {
            _withdrawals = List<Map<String, dynamic>>.from(data['data']);
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading withdrawals: $e');
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'successful':
      case 'completed':
        return AppColors.success;
      case 'pending':
      case 'processing':
        return Colors.amber;
      case 'failed':
        return Colors.red;
      default:
        return AppColors.textMuted;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'successful':
      case 'completed':
        return Icons.check_circle;
      case 'pending':
      case 'processing':
        return Icons.hourglass_empty;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help_outline;
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
        title: Text(
          "Withdrawal History",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadWithdrawals,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _withdrawals.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadWithdrawals,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _withdrawals.length,
                    itemBuilder: (context, index) {
                      final wd = _withdrawals[index];
                      return _buildWithdrawalItem(wd, index);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            "No withdrawals yet",
            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            "Your withdrawal history will appear here",
            style: GoogleFonts.outfit(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalItem(Map<String, dynamic> wd, int index) {
    final status = wd['status']?.toString() ?? 'pending';
    final amount = wd['amount'] ?? 0;
    final reference = wd['reference'] ?? 'N/A';
    final accountName = wd['account_name'] ?? wd['beneficiary_name'] ?? 'Unknown';
    final accountNumber = wd['account_number'] ?? wd['beneficiary_account'] ?? '';
    final createdAt = wd['created_at'] ?? wd['createdAt'] ?? '';

    return FadeInUp(
      delay: Duration(milliseconds: index * 50),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getStatusIcon(status), color: _getStatusColor(status)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accountName,
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  if (accountNumber.isNotEmpty)
                    Text(
                      accountNumber,
                      style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  Text(
                    reference,
                    style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₦${(amount is num ? amount : double.tryParse(amount.toString()) ?? 0).toStringAsFixed(2)}",
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.outfit(color: _getStatusColor(status), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
