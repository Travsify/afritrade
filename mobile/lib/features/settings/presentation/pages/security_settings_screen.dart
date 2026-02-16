import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/services/security_service.dart';
import '../../../../core/theme/app_colors.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final _securityService = SecurityService();
  bool _isPinSet = false;
  bool _canBiometric = false;
  bool _biometricEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSecurityStatus();
  }

  Future<void> _loadSecurityStatus() async {
    final pinStatus = await _securityService.checkPinStatus();
    final canBio = await _securityService.canCheckBiometrics();
    
    if (mounted) {
      setState(() {
        _isPinSet = pinStatus['is_pin_set'] ?? false;
        _canBiometric = canBio;
        _isLoading = false;
      });
    }
  }

  void _setupPin() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PinSetupSheet(
        isChange: _isPinSet,
        onComplete: (success) {
          if (success) {
            _loadSecurityStatus();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("PIN updated successfully"), backgroundColor: AppColors.success),
            );
          }
        },
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
        title: Text("Security", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: _buildSectionHeader("Transaction Protection"),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  child: _buildSecurityTile(
                    icon: Icons.lock_outline,
                    title: "Transaction PIN",
                    subtitle: _isPinSet ? "PIN is active" : "Protect your transactions",
                    trailing: Text(_isPinSet ? "Change" : "Set Up", 
                      style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    onTap: _setupPin,
                  ),
                ),
                const SizedBox(height: 12),
                if (_canBiometric)
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _buildSecurityTile(
                      icon: Icons.fingerprint,
                      title: "Biometric Auth",
                      subtitle: "Use FaceID or Fingerprint",
                      trailing: Switch(
                        value: _biometricEnabled,
                        onChanged: (v) => setState(() => _biometricEnabled = v),
                        activeColor: AppColors.primary,
                      ),
                      onTap: () {},
                    ),
                  ),
                const SizedBox(height: 32),
                _buildSectionHeader("Device & Access"),
                const SizedBox(height: 16),
                _buildSecurityTile(
                  icon: Icons.devices,
                  title: "Active Sessions",
                  subtitle: "Manage logged in devices",
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildSecurityTile(
                  icon: Icons.history,
                  title: "Security Logs",
                  subtitle: "Recent security activities",
                  onTap: () {},
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildSecurityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        title: Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 13)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}

class _PinSetupSheet extends StatefulWidget {
  final bool isChange;
  final Function(bool) onComplete;

  const _PinSetupSheet({required this.isChange, required this.onComplete});

  @override
  State<_PinSetupSheet> createState() => _PinSetupSheetState();
}

class _PinSetupSheetState extends State<_PinSetupSheet> {
  final List<String> _pin = [];
  final List<String> _confirmPin = [];
  bool _isConfirming = false;
  bool _isLoading = false;
  String _error = "";

  void _onKeyPress(String key) {
    if (_pin.length < 4 && !_isConfirming) {
      setState(() => _pin.add(key));
      if (_pin.length == 4) {
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            _isConfirming = true;
          });
        });
      }
    } else if (_confirmPin.length < 4 && _isConfirming) {
      setState(() => _confirmPin.add(key));
      if (_confirmPin.length == 4) {
        _submit();
      }
    }
  }

  Future<void> _submit() async {
    if (_pin.join() != _confirmPin.join()) {
      setState(() {
        _confirmPin.clear();
        _error = "PINs do not match. Try again.";
      });
      return;
    }

    setState(() => _isLoading = true);
    final res = await SecurityService().setPin(_pin.join());
    setState(() => _isLoading = false);
    widget.onComplete(res['status'] == 'success');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isConfirming ? "Confirm PIN" : "Setup Transaction PIN",
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _isConfirming ? "Enter your PIN again to confirm" : "Choose a 4-digit security PIN",
            style: GoogleFonts.outfit(color: AppColors.textMuted),
          ),
          const SizedBox(height: 32),
          
          // PIN Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final active = _isConfirming ? (index < _confirmPin.length) : (index < _pin.length);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppColors.primary : Colors.white10,
                ),
              );
            }),
          ),
          
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(_error, style: GoogleFonts.outfit(color: Colors.redAccent)),
            ),
            
          const SizedBox(height: 32),
          
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ...["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "DEL"].map((key) {
                if (key == "") return const SizedBox();
                if (key == "DEL") {
                  return IconButton(
                    icon: const Icon(Icons.backspace_outlined, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        if (_isConfirming && _confirmPin.isNotEmpty) {
                          _confirmPin.removeLast();
                        } else if (!_isConfirming && _pin.isNotEmpty) {
                          _pin.removeLast();
                        }
                      });
                    },
                  );
                }
                return GestureDetector(
                  onTap: () => _onKeyPress(key),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(key, style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
