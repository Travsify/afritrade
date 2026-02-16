import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/services/anchor_service.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final AnchorService _anchorService = AnchorService();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Order Integration", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(child: _buildSearchArea()),
            const SizedBox(height: 32),
            _buildSectionTitle("Unpaid Commercial Invoices"),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _anchorService.getOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No unpaid invoices", style: GoogleFonts.outfit(color: AppColors.textMuted)));
                }
                return Column(
                  children: snapshot.data!.map((order) => _buildOrderItem(order)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: AppColors.textMuted),
          hintText: "Search Invoice ID...",
          hintStyle: GoogleFonts.outfit(color: AppColors.textMuted),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    String id = order['id'];
    String description = order['desc'];
    double amount = order['amount'];
    String priority = order['priority'];
    Color priorityColor = priority == "Urgent" ? AppColors.error : (priority == "High" ? AppColors.amber : AppColors.success);

    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(id, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(description, style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: priorityColor.withOpacity(0.3)),
                  ),
                  child: Text(priority, style: TextStyle(color: priorityColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("\$${amount.toStringAsFixed(0)}", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ElevatedButton(
                  child: Text("Pay Now", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700)),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Processing Payment..."), backgroundColor: AppColors.primary));
                    await _anchorService.payOrder(id);
                    setState(() {}); // Refresh list
                    if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Successful!"), backgroundColor: AppColors.success));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
