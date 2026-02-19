import 'package:flutter/material.dart';
import 'package:afritrad_mobile/features/onboarding/presentation/pages/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:afritrad_mobile/features/auth/data/kyc_provider.dart';
import 'package:afritrad_mobile/core/widgets/biometric_lock_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:afritrad_mobile/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Robust initialization to prevent blank screen hangs
  try {
    await Firebase.initializeApp(); // Requires google-services.json
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint("Notification initialization failed: $e");
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KYCProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
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
      // App went to background — lock if biometric is enabled
      _checkAndLock();
    }
  }

  Future<void> _checkAndLock() async {
    final biometricEnabled = await AppLockManager.isBiometricEnabled();
    if (biometricEnabled) {
      setState(() => _isLocked = true);
    }
  }

  void _unlock() {
    setState(() => _isLocked = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afritrade',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F172A)),
        useMaterial3: true,
      ),
      home: _isLocked
          ? BiometricLockScreen(onUnlocked: _unlock)
          : const SplashScreen(),
    );
  }
}
