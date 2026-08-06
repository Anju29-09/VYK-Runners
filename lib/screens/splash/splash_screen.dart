import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../coach/coach_dashboard.dart';
import '../login/login_screen.dart';
import '../player/player_dashboard.dart';
import '../../services/player_service.dart';
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
    // Fired and left to run. Waiting on it here cost every launch the four
    // to twelve seconds the Apps Script takes to answer.
    unawaited(UpdateChecker.checkInBackground());

    // Pulls every list down in one request while the logo is still up, so
    // the dashboard cards open against a warm cache instead of each one
    // starting its own two second wait. Failure is fine; the screens fall
    // back to fetching for themselves.
    unawaited(
      PlayerService().prefetchAll().catchError((Object e) {
        debugPrint("Prefetch failed: $e");
      }),
    );

    final prefsFuture = SharedPreferences.getInstance();

    // Long enough to read the logo, rather than a fixed two second wait.
    await Future.delayed(
      const Duration(milliseconds: 900),
    );

    final prefs = await prefsFuture;

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