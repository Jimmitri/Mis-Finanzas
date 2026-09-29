import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MisFinanzasApp());
}

class MisFinanzasApp extends StatelessWidget {
  const MisFinanzasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mis Finanzas',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}