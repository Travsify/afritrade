import 'package:flutter/material.dart';
import 'package:afritrad_mobile/features/onboarding/presentation/pages/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:afritrad_mobile/features/auth/data/kyc_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:afritrad_mobile/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Requires google-services.json
  await NotificationService().init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KYCProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afritrade',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F172A)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
