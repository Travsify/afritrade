import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:afritrad_mobile/features/onboarding/presentation/pages/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:afritrad_mobile/features/auth/data/kyc_provider.dart';
import 'package:afritrad_mobile/core/widgets/biometric_lock_screen.dart';
import 'package:afritrad_mobile/core/widgets/error_boundary.dart';
import 'package:afritrad_mobile/core/widgets/connectivity_indicator.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:afritrad_mobile/core/services/notification_service.dart';
import 'package:afritrad_mobile/core/theme/app_theme.dart';
// AppLockManager is available via biometric_lock_screen.dart


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Robust initialization to prevent blank screen hangs
  try {
    // Global Error Boundary - Catch rendering crashes
    GlobalErrorBoundary.init();

    // Initialize Firebase with a longer timeout
    try {
      await Firebase.initializeApp().timeout(const Duration(seconds: 15));
      debugPrint("Firebase initialized successfully");
    } catch (e) {
      debugPrint("Firebase initialization failed/timed out: $e");
    }

    // Initialize Crashlytics only if Firebase is ready
    try {
      if (Firebase.apps.isNotEmpty) {
        FlutterError.onError = (errorDetails) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        };
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      }
    } catch (e) {
      debugPrint("Crashlytics initialization failed: $e");
    }

    // Initialize NotificationService
    try {
      await NotificationService().init().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint("Notification service initialization failed: $e");
    }

  } catch (e) {
    debugPrint("Critical initialization error: $e");
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
      title: 'Afritrad Mobile',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      builder: (context, child) => OfflineIndicator(child: child!),
      home: _isLocked
          ? BiometricLockScreen(onUnlocked: _unlock)
          : const SplashScreen(),
    );
  }
}
