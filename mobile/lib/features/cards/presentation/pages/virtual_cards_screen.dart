import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/services/anchor_service.dart';
import '../../../../core/theme/app_colors.dart';

class VirtualCardsScreen extends StatefulWidget {
  const VirtualCardsScreen({super.key});

  @override
  State<VirtualCardsScreen> createState() => _VirtualCardsScreenState();
}

class _VirtualCardsScreenState extends State<VirtualCardsScreen> {
  final _anchorService = AnchorService();
  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    final cards = await _anchorService.getVirtualCards();
    if (mounted) {
      setState(() {
        _cards = cards;
        _isLoading = false;
      });
    }
  }

  void _showCreateCardModal() {
    final labelController = TextEditingController();
    final amountController = TextEditingController();
    String selectedBrand = 'Visa';

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
              Text("Create Virtual Card", style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildModalField(labelController, "Card Label (e.g. Shopping)", Icons.label),
              const SizedBox(height: 12),
              _buildModalField(amountController, "Initial Funding (USD)", Icons.attach_money, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text("Card Brand: ", style: GoogleFonts.outfit(color: Colors.white70)),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text("Visa"),
                    selected: selectedBrand == 'Visa',
                    onSelected: (_) => setModalState(() => selectedBrand = 'Visa'),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: selectedBrand == 'Visa' ? Colors.white : Colors.white70),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text("Mastercard"),
                    selected: selectedBrand == 'Mastercard',
                    onSelected: (_) => setModalState(() => selectedBrand = 'Mastercard'),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: selectedBrand == 'Mastercard' ? Colors.white : Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (labelController.text.isEmpty || amountController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fill all fields")));
                      return;
                    }
                    Navigator.pop(context);
                    final result = await _anchorService.issueCard(
                      label: labelController.text,
                      amount: double.tryParse(amountController.text) ?? 0,
                      brand: selectedBrand.toLowerCase(),
                    );
                    if (result['status'] == 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Card created!")));
                      _loadCards();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text("Create Card", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
        title: Text("Virtual Cards", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        onPressed: _showCreateCardModal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _cards.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadCards,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) => _buildCardItem(_cards[index], index),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card_off, size: 80, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text("No virtual cards yet", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 18)),
          const SizedBox(height: 8),
          Text("Tap + to create your first card", style: GoogleFonts.outfit(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildCardItem(Map<String, dynamic> card, int index) {
    return FadeInUp(
      delay: Duration(milliseconds: index * 100),
      child: HolographicCard(
        card: card,
        onTap: () => _showCardDetails(card),
      ),
    );
  }

  void _showCardDetails(Map<String, dynamic> card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Card Details", style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _detailRow("Card Number", "**** **** **** ${card['last4']}", canCopy: true),
            _detailRow("CVV", card['cvv']?.toString() ?? '***', canCopy: true),
            _detailRow("Expiry", card['expiry'] ?? '12/28'),
            _detailRow("Balance", "\$${(card['balance'] ?? 0.0).toStringAsFixed(2)}"),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final result = card['status'] == 'Active'
                          ? await _anchorService.freezeCard(card['id'])
                          : await _anchorService.unfreezeCard(card['id']);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Done')));
                      _loadCards();
                    },
                    icon: Icon(card['status'] == 'Active' ? Icons.ac_unit : Icons.play_arrow, color: Colors.white),
                    label: Text(card['status'] == 'Active' ? "Freeze" : "Unfreeze", style: const TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showFundCardModal(card);
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Fund", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool canCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white54)),
          Row(
            children: [
              Text(value, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              if (canCopy) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied!")));
                  },
                  child: const Icon(Icons.copy, size: 16, color: AppColors.primary),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  void _showFundCardModal(Map<String, dynamic> card) {
    final amountController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Fund Card", style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildModalField(amountController, "Amount (USD)", Icons.attach_money, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _anchorService.fundCard(cardId: card['id'], amount: double.tryParse(amountController.text) ?? 0);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Card funded!")));
                  _loadCards();
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text("Fund Card", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HolographicCard extends StatefulWidget {
  final Map<String, dynamic> card;
  final VoidCallback onTap;

  const HolographicCard({super.key, required this.card, required this.onTap});

  @override
  State<HolographicCard> createState() => _HolographicCardState();
}

class _HolographicCardState extends State<HolographicCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _holoAnimation;
  late Animation<double> _tiltAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _holoAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    
    _tiltAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.card['status'] == 'Active';
    final brand = widget.card['brand'] ?? 'Visa';
    final isVisa = brand == 'Visa';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Simulated 3D Tilt
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_tiltAnimation.value)
          ..rotateY(_tiltAnimation.value * 0.5);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isVisa
                      ? [const Color(0xFF1A1F71), const Color(0xFF2B3187)]
                      : [const Color(0xFFEB001B), const Color(0xFFF79E1B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isVisa ? const Color(0xFF1A1F71) : const Color(0xFFEB001B))
                        .withOpacity(0.4 + (_tiltAnimation.value.abs())), // Pulsing shadow
                    blurRadius: 15 + (_tiltAnimation.value.abs() * 50),
                    offset: Offset(0, 8 + (_tiltAnimation.value * 20)),
                  ),
                ],
              ),
              child: Stack(
                children: [
                   // Content Layer
                   Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.card['label'] ?? 'Virtual Card', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.card['status'] ?? 'Active',
                                style: GoogleFonts.outfit(color: isActive ? Colors.greenAccent : Colors.redAccent, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "**** **** **** ${widget.card['last4'] ?? '0000'}",
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 2),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Balance", style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11)),
                                Text("\$${(widget.card['balance'] ?? 0.0).toStringAsFixed(2)}", style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("VALID THRU", style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10)),
                                Text(widget.card['expiry'] ?? '12/28', style: GoogleFonts.outfit(color: Colors.white, fontSize: 14)),
                              ],
                            ),
                            Text(brand.toUpperCase(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Holographic Overlay Layer
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment(_holoAnimation.value - 1, -1),
                          end: Alignment(_holoAnimation.value, 1),
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.3), // Shine peak
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                  
                  // Noise/Grain Overlay (Optional, simple circular one for now)
                  Positioned(
                    right: -30, top: -30,
                    child: Container(
                      height: 150, width: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
