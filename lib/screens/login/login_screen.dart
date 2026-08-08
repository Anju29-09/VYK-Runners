import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';

import '../coach/coach_dashboard.dart';
import '../player/player_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final coachController = TextEditingController();

  final emailController = TextEditingController();

  bool isLoading = false;

  // Darker colors specifically for Login page
  static const Color darkPurple = Color(0xff312C51);
  static const Color darkButtonPurple = Color(0xff3B365F);

  @override
  void dispose() {
    coachController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F1EB),

      body: Stack(
        children: [

          // =========================================================
          // BACKGROUND
          // =========================================================

          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xffF7F1EB),
          ),

          // =========================================================
          // TOP LEFT CIRCLE
          // =========================================================

          Positioned(
            top: -70,
            left: -70,
            child: Container(
              width: 170,
              height: 170,
              decoration: const BoxDecoration(
                color: Color(0xffF0C38E),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // =========================================================
          // TOP RIGHT CIRCLE
          // =========================================================

          Positioned(
            top: -70,
            right: -70,
            child: Container(
              width: 170,
              height: 170,
              decoration: const BoxDecoration(
                color: Color(0xff8B7AA8),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // =========================================================
          // BOTTOM LEFT CIRCLE
          // =========================================================

          Positioned(
            bottom: -70,
            left: -70,
            child: Container(
              width: 170,
              height: 170,
              decoration: const BoxDecoration(
                color: Color(0xffF0C38E),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // =========================================================
          // BOTTOM RIGHT CIRCLE
          // =========================================================

          Positioned(
            bottom: -70,
            right: -70,
            child: Container(
              width: 170,
              height: 170,
              decoration: const BoxDecoration(
                color: Color(0xff8B7AA8),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // =========================================================
          // LOGIN CONTENT
          // =========================================================

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: Column(
                  children: [

                    // LOGO
                    Image.asset(
                      "assets/images/vyk_logo.png",
                      width: 220,
                      height: 220,
                    ),

                    const SizedBox(height: 5),

                    // TAGLINE
                    const Text(
                      "Train • Compete • Achieve",
                      style: TextStyle(
                        color: darkPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // COACH CODE
                    Container(
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: coachController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            color: darkPurple,
                          ),
                          suffixIcon: Icon(
                            Icons.person,
                            color: Colors.grey,
                          ),
                          hintText: "Coach Access Code",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // EMAIL
                    Container(
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.email,
                            color: darkPurple,
                          ),
                          suffixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.grey,
                          ),
                          hintText: "Player Email Address",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // =================================================
                    // LOGIN BUTTON
                    // =================================================

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkButtonPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),

                        // ORIGINAL WORKING LOGIN FUNCTION
                        onPressed: () async {
                          final prefs =
                          await SharedPreferences.getInstance();

                          String coachCode =
                          coachController.text.trim();

                          String email =
                          emailController.text.trim();

                          // -------------------------------
                          // COACH LOGIN
                          // -------------------------------

                          // The code is no longer compared here. It is sent
                          // to the Apps Script, which holds the real one in
                          // Script Properties and answers with a signed
                          // token. Nothing secret ships inside the app, so
                          // reading the source no longer reveals it.
                          if (coachCode.isNotEmpty) {
                            setState(() {
                              isLoading = true;
                            });

                            final result =
                            await AuthService.loginCoach(coachCode);

                            if (!mounted) return;

                            setState(() {
                              isLoading = false;
                            });

                            if (!result.ok) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(result.message),
                                ),
                              );

                              return;
                            }

                            await prefs.setBool(
                              "isLoggedIn",
                              true,
                            );

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

                          // -------------------------------
                          // PLAYER EMAIL VALIDATION
                          // -------------------------------

                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Enter Email Address",
                                ),
                              ),
                            );

                            return;
                          }

                          // -------------------------------
                          // VERIFY PLAYER
                          // -------------------------------

                          setState(() {
                            isLoading = true;
                          });

                          // The sheet is searched on the server now. The
                          // whole player list is no longer downloaded to
                          // the phone just to check one email against it.
                          final result =
                          await AuthService.loginPlayer(email);

                          if (!mounted) return;

                          setState(() {
                            isLoading = false;
                          });

                          // -------------------------------
                          // PLAYER FOUND
                          // -------------------------------

                          if (result.ok) {
                            final String playerName =
                                result.playerName;

                            final String playerEmail =
                                result.playerEmail.isNotEmpty
                                    ? result.playerEmail
                                    : email;

                            await prefs.setBool(
                              "isLoggedIn",
                              true,
                            );

                            await prefs.setString(
                              "playerName",
                              playerName,
                            );

                            await prefs.setString(
                              "playerEmail",
                              playerEmail,
                            );

                            if (!mounted) return;

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PlayerDashboard(
                                      playerName: playerName,
                                      playerEmail: playerEmail,
                                    ),
                              ),
                            );
                          }

                          // -------------------------------
                          // PLAYER NOT FOUND
                          // -------------------------------

                          else {
                            if (!mounted) return;

                            // The server says why - unknown email, or the
                            // script not being reachable. Reporting its
                            // message beats always blaming the email.
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  result.message.isNotEmpty
                                      ? result.message
                                      : "Email Not Registered",
                                ),
                              ),
                            );
                          }
                        },

                        child: isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text(
                          "LOGIN",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // VERSION
                    const Text(
                      "Version 1.0",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}