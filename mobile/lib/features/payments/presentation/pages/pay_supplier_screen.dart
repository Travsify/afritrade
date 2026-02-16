import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/settlement_service.dart';
import '../../../auth/presentation/widgets/pin_verification_modal.dart';

class PaySupplierScreen extends StatefulWidget {
  const PaySupplierScreen({super.key});

  @override
  State<PaySupplierScreen> createState() => _PaySupplierScreenState();
}

class _PaySupplierScreenState extends State<PaySupplierScreen> {
  final _amountController = TextEditingController();
  final _recipientController = TextEditingController();
  final _bankController = TextEditingController();
  final _settlementService = SettlementService();
  String _selectedCurrency = 'USD';
  bool isProcessingPayment = false;
  double _exchangeRate = 1.0; // Default pending dynamic rates

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  void _updateExchangeRate() {
    // Mock rates for now based on current market trends
    switch (_selectedCurrency) {
      case 'CNY':
        _exchangeRate = 215.0;
        break;
      case 'EUR':
        _exchangeRate = 1650.0;
        break;
      case 'GBP':
        _exchangeRate = 1950.0;
        break;
      default:
        _exchangeRate = 1550.0; // USD
    }
    setState(() {});
  }

  void _processPayment() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    if (_recipientController.text.isEmpty || _bankController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in beneficiary details")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PinVerificationModal(
        onVerified: (pin) {
          _executeTransaction(amount);
        },
      ),
    );
  }

  void _executeTransaction(double amount) async {
    setState(() {
      isProcessingPayment = true;
    });

    try {
      final result = await _settlementService.paySupplier(
        amount: amount,
        currency: _selectedCurrency,
        recipient: _recipientController.text,
        destination: _bankController.text,
      );


      if (mounted) {
        setState(() {
          isProcessingPayment = false;
        });
        if (result['status'] == 'success') {
          _showSuccessDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isProcessingPayment = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment failed: $e")),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ZoomIn(
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Payment Successful",
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Your payment of $_selectedCurrency ${_amountController.text} has been sent to ${_recipientController.text}.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to Home
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Done", style: GoogleFonts.outfit(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Send Money",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Currency & Amount",
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              "Amount",
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCurrency,
                      dropdownColor: const Color(0xFF1E293B),
                      items: ["USD", "CNY", "EUR", "GBP"]
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCurrency = val!;
                          _updateExchangeRate();
                        });
                      },
                    ),
                  ),
                  const VerticalDivider(color: Colors.white24, thickness: 1),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "0.00",
                        hintStyle: TextStyle(color: Colors.white24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Rate: 1 $_selectedCurrency = ₦${_exchangeRate.toStringAsFixed(2)}",
                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
                ),
                if (_amountController.text.isNotEmpty)
                  Text(
                    "You Pay: ₦${((double.tryParse(_amountController.text) ?? 0) * _exchangeRate).toStringAsFixed(2)}",
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFF59E0B),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FadeInUp(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Beneficiary Details", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildTextField(controller: _recipientController, label: "Beneficiary Name"),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _bankController, label: "Account / WeChat ID"),
                ],
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isProcessingPayment ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: isProcessingPayment
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("Continue to Payment",
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
