import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/services/invoice_service.dart';
import '../../../../core/theme/app_colors.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _invoiceService = InvoiceService();

  List<Map<String, dynamic>> _sentInvoices = [];
  List<Map<String, dynamic>> _receivedInvoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);
    final sent = await _invoiceService.getInvoices(type: 'sent');
    final received = await _invoiceService.getInvoices(type: 'received');
    if (mounted) {
      setState(() {
        _sentInvoices = sent;
        _receivedInvoices = received;
        _isLoading = false;
      });
    }
  }

  void _showCreateInvoiceModal() {
    final emailController = TextEditingController();
    final amountController = TextEditingController();
    final descController = TextEditingController();
    String selectedCurrency = 'USD';

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
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Create Invoice", style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildModalField(emailController, "Recipient Email", Icons.email),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildModalField(amountController, "Amount", Icons.attach_money, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCurrency,
                        dropdownColor: AppColors.surface,
                        items: ['USD', 'NGN', 'GBP', 'EUR', 'CNY'].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white)))).toList(),
                        onChanged: (val) => setModalState(() => selectedCurrency = val!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildModalField(descController, "Description (Optional)", Icons.description),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (emailController.text.isEmpty || amountController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fill all required fields")));
                      return;
                    }
                    Navigator.pop(context);
                    final result = await _invoiceService.createInvoice(
                      recipientEmail: emailController.text.trim(),
                      amount: double.tryParse(amountController.text) ?? 0,
                      currency: selectedCurrency,
                      description: descController.text.isNotEmpty ? descController.text : null,
                    );
                    if (result['status'] == 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Invoice sent!')));
                      _loadInvoices();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Failed')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text("Send Invoice", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: Colors.white54),
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white38),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text("Invoices", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: "Sent"), Tab(text: "Received")],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        onPressed: _showCreateInvoiceModal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInvoiceList(_sentInvoices, isSent: true),
                _buildInvoiceList(_receivedInvoices, isSent: false),
              ],
            ),
    );
  }

  Widget _buildInvoiceList(List<Map<String, dynamic>> invoices, {required bool isSent}) {
    if (invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(isSent ? "No invoices sent yet" : "No invoices received", style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadInvoices,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final inv = invoices[index];
          final isPending = inv['status'] == 'pending';
          return FadeInUp(
            delay: Duration(milliseconds: index * 50),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  Container(
                    height: 48, width: 48,
                    decoration: BoxDecoration(
                      color: (isPending ? Colors.amber : AppColors.success).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(isPending ? Icons.pending_actions : Icons.check_circle, color: isPending ? Colors.amber : AppColors.success),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(inv['description'] ?? 'Invoice #${inv['reference']}', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(isSent ? 'To: ${inv['recipient_email']}' : 'Ref: ${inv['reference']}', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("${inv['currency']} ${inv['amount']}", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(inv['status'].toString().toUpperCase(), style: GoogleFonts.outfit(color: isPending ? Colors.amber : AppColors.success, fontSize: 11)),
                    ],
                  ),
                  if (!isSent && isPending) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.payment, color: AppColors.primary),
                      onPressed: () async {
                        final result = await _invoiceService.payInvoice(inv['id']);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Done')));
                        _loadInvoices();
                      },
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
