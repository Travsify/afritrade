import 'package:flutter/material.dart';
import 'package:afritrad_mobile/core/services/security_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Full-screen biometric/PIN lock screen shown when app resumes from background.
class BiometricLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const BiometricLockScreen({super.key, required this.onUnlocked});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  final SecurityService _securityService = SecurityService();
  bool _isAuthenticating = false;
  String? _errorMessage;
  final List<TextEditingController> _pinControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _pinFocusNodes = List.generate(4, (_) => FocusNode());
  bool _showPinFallback = false;

  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }

  @override
  void dispose() {
    for (var c in _pinControllers) { c.dispose(); }
    for (var f in _pinFocusNodes) { f.dispose(); }
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    if (_isAuthenticating) return;
    setState(() { _isAuthenticating = true; _errorMessage = null; });

    try {
      final canCheck = await _securityService.canCheckBiometrics();
      if (!canCheck) {
        setState(() { _showPinFallback = true; _isAuthenticating = false; });
        return;
      }

      final authenticated = await _securityService.authenticateBiometrics();
      if (authenticated) {
        widget.onUnlocked();
      } else {
        setState(() {
          _errorMessage = 'Authentication failed. Try again or use PIN.';
          _showPinFallback = true;
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Biometric error. Please use PIN.';
        _showPinFallback = true;
        _isAuthenticating = false;
      });
    }
  }

  String get _pin => _pinControllers.map((c) => c.text).join();

  Future<void> _verifyPinFallback() async {
    if (_pin.length != 4) return;
    setState(() { _isAuthenticating = true; _errorMessage = null; });

    final result = await _securityService.verifyPin(_pin);
    if (result['status'] == 'success') {
      widget.onUnlocked();
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Incorrect PIN';
        _isAuthenticating = false;
      });
      for (var c in _pinControllers) { c.clear(); }
      _pinFocusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo / Lock Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF00D4AA).withOpacity(0.2), const Color(0xFF0066FF).withOpacity(0.2)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_rounded, color: Color(0xFF00D4AA), size: 48),
                ),
                const SizedBox(height: 24),

                const Text('App Locked', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  _showPinFallback ? 'Enter your PIN to unlock' : 'Authenticate to continue',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                ),
                const SizedBox(height: 32),

                if (_showPinFallback) ...[
                  // PIN Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => Container(
                      width: 50, height: 56,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: TextField(
                        controller: _pinControllers[i],
                        focusNode: _pinFocusNodes[i],
                        obscureText: true,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFF16213E),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF00D4AA), width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && i < 3) _pinFocusNodes[i + 1].requestFocus();
                          if (value.isEmpty && i > 0) _pinFocusNodes[i - 1].requestFocus();
                          if (_pin.length == 4) _verifyPinFallback();
                        },
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),

                  // Try biometric again
                  TextButton.icon(
                    onPressed: _tryBiometric,
                    icon: const Icon(Icons.fingerprint, color: Color(0xFF00D4AA)),
                    label: const Text('Use Biometrics', style: TextStyle(color: Color(0xFF00D4AA))),
                  ),
                ] else ...[
                  // Biometric prompt
                  if (_isAuthenticating)
                    const CircularProgressIndicator(color: Color(0xFF00D4AA))
                  else
                    Column(
                      children: [
                        IconButton(
                          onPressed: _tryBiometric,
                          iconSize: 64,
                          icon: const Icon(Icons.fingerprint, color: Color(0xFF00D4AA)),
                        ),
                        const SizedBox(height: 8),
                        const Text('Tap to authenticate', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() => _showPinFallback = true),
                          child: const Text('Use PIN instead', style: TextStyle(color: Color(0xFF00D4AA))),
                        ),
                      ],
                    ),
                ],

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13), textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Manages app lock state via SharedPreferences.
class AppLockManager {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _appLockedKey = 'app_locked';

  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  static Future<bool> isAppLocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_appLockedKey) ?? false;
  }

  static Future<void> setAppLocked(bool locked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_appLockedKey, locked);
  }
}
