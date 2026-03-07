import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';
import '../../data/kyc_provider.dart';
import 'kyc_required_screen.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../../../core/widgets/biometric_lock_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  late Future<void> _initializationTimeout;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _initializationTimeout = Future.delayed(const Duration(seconds: 5));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App going to background — mark as locked if biometrics are enabled
      final kycProvider = context.read<KYCProvider>();
      if (kycProvider.isLoggedIn && kycProvider.biometricsEnabled) {
        setState(() => _isLocked = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kycProvider = context.watch<KYCProvider>();

    // Fail-safe: If initialization takes too long (e.g., 5s), force show login
    // to prevent infinite "blank" loading screens.
    return FutureBuilder(
      future: _initializationTimeout,
      builder: (context, snapshot) {
        if (!kycProvider.isInitialized && snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!kycProvider.isLoggedIn) {
          return const LoginScreen();
        }

        // Show biometric lock screen when returning from background
        if (_isLocked) {
          return BiometricLockScreen(
            onUnlocked: () => setState(() => _isLocked = false),
          );
        }
        
        return const HomeScreen();
      },
    );
  }
}

