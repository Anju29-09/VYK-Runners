import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../coach/coach_dashboard.dart';
import '../login/login_screen.dart';
import '../player/player_dashboard.dart';
import '../../services/update_checker.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _start();
  }

  Future<void> _start() async {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    bool updateAvailable =
    await UpdateChecker.check(context);

    if (updateAvailable) {
      return;
    }

    final prefs =
    await SharedPreferences.getInstance();

    bool isLoggedIn =
        prefs.getBool("isLoggedIn") ?? false;

    if (!isLoggedIn) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const LoginScreen(),
        ),
      );

      return;
    }

    String userType =
        prefs.getString("userType") ?? "";

    if (userType == "coach") {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const CoachDashboard(),
        ),
      );

      return;
    }

    if (userType == "player") {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PlayerDashboard(
            playerName:
            prefs.getString(
              "playerName",
            ) ??
                "",
            playerEmail:
            prefs.getString(
              "playerEmail",
            ) ??
                "",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F1EB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Image.asset(
              "assets/images/vyk_logo.png",
              width: 240, // Increase this if you want it bigger
            ),

            const SizedBox(height: 35),

            const CircularProgressIndicator(),

          ],
        ),
      ),
    );
  }
}