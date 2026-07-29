import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VYKRunnersApp());
}

class VYKRunnersApp extends StatelessWidget {
  const VYKRunnersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VYK Runners',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}