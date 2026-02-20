import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/anchor_service.dart';

class BulkPaymentScreen extends StatefulWidget {
  const BulkPaymentScreen({super.key});

  @override
  State<BulkPaymentScreen> createState() => _BulkPaymentScreenState();
}

class _BulkPaymentScreenState extends State<BulkPaymentScreen> {
  final AnchorService _anchorService = AnchorService();
  List<Map<String, dynamic>> _pendingPayments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  void _fetchPayments() async {
    final payments = await _anchorService.getBulkPayments();
    if(mounted) {
      setState(() {
        _pendingPayments = payments;
        _isLoading = false;
      });
    }
  }

  bool _isProcessing = false;
  final Set<String> _selectedIds = {};

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _processBatch() async {
    if (_selectedIds.isEmpty) return;

    setState(() => _isProcessing = true);
    
    // Processing via service
    await _anchorService.processBulkPayments(_selectedIds.toList());
    
    // Refresh list
    final updatedList = await _anchorService.getBulkPayments();

    if (mounted) {
      setState(() {
        _pendingPayments = updatedList;
        _selectedIds.clear();
        _isProcessing = false;
      });

      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 64),
            const SizedBox(height: 24),
            Text(
              "Batch Processed!",
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "All selected payments have been queued for settlement.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> currencyTotals = {};
    for (var p in _pendingPayments) {
      if (_selectedIds.contains(p['id'])) {
        String curr = p['currency'] ?? 'USD';
        currencyTotals[curr] = (currencyTotals[curr] ?? 0.0) + (p['amount'] ?? 0.0);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Bulk Payment Hub", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSummaryCard(currencyTotals),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _pendingPayments.isEmpty 
                  ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _pendingPayments.length,
                  itemBuilder: (context, index) {
                    final payment = _pendingPayments[index];
                    final isSelected = _selectedIds.contains(payment['id']);
                    return FadeInUp(
                      delay: Duration(milliseconds: index * 50),
                      child: _buildPaymentItem(payment, isSelected),
                    );
                  },
                ),
          ),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, double> totals) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.glowShadow(AppColors.primary),
      ),
      child: Column(
        children: [
          Text("Batch Totals (Selected)", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          if (totals.isEmpty)
             Text(
              "\$0.00",
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            )
          else
            Column(
              children: totals.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "${e.key} ${e.value.toStringAsFixed(2)}",
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: e.key == 'USD' ? 32 : 24, fontWeight: FontWeight.bold),
                ),
              )).toList(),
            ),
          const SizedBox(height: 12),
          Text(
            "${_selectedIds.length} payments selected",
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> payment, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleSelection(payment['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => _toggleSelection(payment['id']),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment['supplier'],
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Order Ref: ${payment['id']}",
                    style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              "${payment['currency']} ${payment['amount'].toStringAsFixed(2)}",
              style: GoogleFonts.outfit(
                color: isSelected ? AppColors.primary : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: (_isProcessing || _selectedIds.isEmpty) ? null : _processBatch,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: _isProcessing 
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                "Approve Batch Settlement", 
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
              ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.playlist_add_check_rounded, color: AppColors.textMuted, size: 64),
          const SizedBox(height: 16),
          Text(
            "No Pending Batches",
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            "All settlements are up to date.",
            style: GoogleFonts.outfit(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
