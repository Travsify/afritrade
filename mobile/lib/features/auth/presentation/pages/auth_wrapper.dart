import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';
import '../../data/kyc_provider.dart';
import 'kyc_required_screen.dart';
import '../../../home/presentation/pages/home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<void> _initializationTimeout;

  @override
  void initState() {
    super.initState();
    _initializationTimeout = Future.delayed(const Duration(seconds: 5));
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
        
        return const HomeScreen();
      },
    );
  }
}
