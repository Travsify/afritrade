import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/anchor_service.dart';

class PaymentSchedulerScreen extends StatefulWidget {
  const PaymentSchedulerScreen({super.key});

  @override
  State<PaymentSchedulerScreen> createState() => _PaymentSchedulerScreenState();
}

class _PaymentSchedulerScreenState extends State<PaymentSchedulerScreen> {
  final AnchorService _anchorService = AnchorService();
  final TextEditingController _beneficiaryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment Scheduler',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.featureScheduler, Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              onPressed: () => _showSchedulePaymentSheet(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            FadeInDown(
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Active',
                      '2',
                      AppColors.success,
                      Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Paused',
                      '1',
                      AppColors.warning,
                      Icons.pause_circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'This Month',
                      '\$4.3K',
                      AppColors.featureScheduler,
                      Icons.calendar_month,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Upcoming Payments
            Text(
              'Upcoming Payments',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Calendar Preview
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: _buildCalendarPreview(),
            ),

            const SizedBox(height: 24),

            // Scheduled Payments List
            Text(
              'Scheduled Payments',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: _anchorService.getScheduledPayments(),
              builder: (context, snapshot) {
                 if (snapshot.connectionState == ConnectionState.waiting) {
                   return Center(child: CircularProgressIndicator(color: AppColors.featureScheduler));
                 }
                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
                   return Center(child: Text("No scheduled payments", style: GoogleFonts.outfit(color: AppColors.textMuted)));
                 }

                 return Column(
                   children: snapshot.data!.map((payment) {
                      // Add default flag if missing
                      if (payment['flag'] == null) payment['flag'] = '📅'; 
                      return FadeInUp(
                        child: _buildScheduledPaymentCard(payment),
                      );
                   }).toList(),
                 );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'January 2026',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppColors.textMuted),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((day) => Text(
                      day,
                      style: GoogleFonts.outfit(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          // Sample Week with payment markers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCalendarDay('15', false, false),
              _buildCalendarDay('16', true, false), // Today
              _buildCalendarDay('17', false, false),
              _buildCalendarDay('18', false, true), // Payment due
              _buildCalendarDay('19', false, false),
              _buildCalendarDay('20', false, true), // Payment due
              _buildCalendarDay('21', false, false),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCalendarDay('22', false, false),
              _buildCalendarDay('23', false, false),
              _buildCalendarDay('24', false, false),
              _buildCalendarDay('25', false, true), // Payment due
              _buildCalendarDay('26', false, false),
              _buildCalendarDay('27', false, false),
              _buildCalendarDay('28', false, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(String day, bool isToday, bool hasPayment) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.featureScheduler
            : hasPayment
                ? AppColors.featureScheduler.withOpacity(0.2)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: hasPayment && !isToday
            ? Border.all(color: AppColors.featureScheduler)
            : null,
      ),
      child: Center(
        child: Text(
          day,
          style: GoogleFonts.outfit(
            color: isToday
                ? Colors.white
                : hasPayment
                    ? AppColors.featureScheduler
                    : AppColors.textSecondary,
            fontWeight: isToday || hasPayment ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduledPaymentCard(Map<String, dynamic> payment) {
    final isActive = payment['status'] == 'active';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: AppColors.featureScheduler.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(payment['flag'], style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment['supplier'],
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          payment['frequency'],
                          style: GoogleFonts.outfit(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Paused',
                            style: GoogleFonts.outfit(
                              color: isActive ? AppColors.success : AppColors.warning,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    payment['amount'],
                    style: GoogleFonts.outfit(
                      color: AppColors.featureScheduler,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Next: ${payment['nextDate']}',
                    style: GoogleFonts.outfit(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isActive ? AppColors.warning : AppColors.success,
                    side: BorderSide(
                      color: isActive ? AppColors.warning : AppColors.success,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    isActive ? 'Pause' : 'Resume',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.glassBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Edit', style: GoogleFonts.outfit()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSchedulePaymentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Schedule New Payment',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildInputField('Select Beneficiary', 'Choose from saved', _beneficiaryController),
              const SizedBox(height: 16),
              _buildInputField('Amount', 'e.g. \$1,500', _amountController),
              const SizedBox(height: 16),
              Text(
                'Frequency',
                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildFrequencyChip('Weekly', false),
                  const SizedBox(width: 8),
                  _buildFrequencyChip('Bi-weekly', false),
                  const SizedBox(width: 8),
                  _buildFrequencyChip('Monthly', true),
                ],
              ),
              const SizedBox(height: 16),
              _buildInputField('Start Date', 'Select date', _dateController),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _scheduleNewPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.featureScheduler,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Schedule Payment',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _scheduleNewPayment() {
    if (_beneficiaryController.text.isEmpty || _amountController.text.isEmpty) return;

    final newPayment = {
      'supplier': _beneficiaryController.text,
      'amount': '\$${_amountController.text}',
      'frequency': 'Monthly', // Default for now
      'nextDate': _dateController.text.isNotEmpty ? _dateController.text : 'Next Month',
      'status': 'active',
      'flag': '🌍',
    };

    _anchorService.schedulePayment(newPayment).then((_) {
      setState(() {}); // Refresh future builder
    });
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Scheduled!"), backgroundColor: AppColors.success));
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: GoogleFonts.outfit(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.outfit(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {},
      backgroundColor: AppColors.background,
      selectedColor: AppColors.featureScheduler,
      side: BorderSide(
        color: isSelected ? AppColors.featureScheduler : AppColors.glassBorder,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
