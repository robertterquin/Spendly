import 'package:flutter/material.dart';
import 'package:spendly/features/auth/presentation/screens/splash_screen.dart';
import 'package:spendly/shared/theme/app_theme.dart';

class SpendlyApp extends StatelessWidget {
  const SpendlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spendly',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const SplashScreen(),
    );
  }
}
