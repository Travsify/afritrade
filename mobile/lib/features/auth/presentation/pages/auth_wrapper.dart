import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';
import '../../data/kyc_provider.dart';
import 'kyc_required_screen.dart';
import '../../../home/presentation/pages/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final kycProvider = context.watch<KYCProvider>();

    if (!kycProvider.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!kycProvider.isLoggedIn) {
      return const LoginScreen();
    }
    
    // Allow navigation to HomeScreen for all logged-in users.
    // KYC status is now handled via feature gating and banners on the dashboard.
    return const HomeScreen();
  }
}
