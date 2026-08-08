import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/navigation.dart';
import '../screens/login/login_screen.dart';
import 'player_service.dart';

/// Thrown when the server rejects the token, so a screen can send the
/// user back to the login page instead of showing an empty list.
class AuthExpired implements Exception {
  const AuthExpired();

  @override
  String toString() => "Please sign in again.";
}

/// The outcome of a sign in attempt.
class AuthResult {
  final bool ok;

  final String message;

  final String role;

  final String playerName;

  final String playerEmail;

  const AuthResult({
    required this.ok,
    this.message = "",
    this.role = "",
    this.playerName = "",
    this.playerEmail = "",
  });
}

/// Signing in happens on the server, not here.
///
/// The coach code used to be compared inside the app, which meant it had to
/// ship inside the app, which meant anyone reading the source had it. Now
/// the code is only ever sent to the Apps Script, which holds the real one
/// in Script Properties and answers with a signed token.
///
/// The token says who you are and cannot be edited, because the signature
/// is made with a secret the app never receives. Every request carries it,
/// and the server trims the reply to what that person may see.
class AuthService {
  /// Held in memory so requests do not wait on disk, and mirrored into
  /// preferences so a restart does not force a new sign in.
  static String? token;

  static String role = "";

  static const String _tokenKey = "authToken";

  static const String _roleKey = "userType";

  /// Restores the saved session. Call before the first request.
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString(_tokenKey);

    role = prefs.getString(_roleKey) ?? "";
  }

  static Future<void> _store(
      String newToken,
      String newRole,
      ) async {
    token = newToken;

    role = newRole;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, newToken);

    await prefs.setString(_roleKey, newRole);
  }

  /// Forgets the session. Cached rows go too, because they belong to
  /// whoever was signed in and must not leak into the next account.
  static Future<void> signOut() async {
    token = null;

    role = "";

    PlayerService.clearCache();

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);

    await prefs.setBool("isLoggedIn", false);

    await prefs.remove(_roleKey);

    await prefs.remove("playerName");

    await prefs.remove("playerEmail");
  }

  /// Tokens last thirty days, and the coach can invalidate every one of
  /// them by changing the secret. Either way the app has to cope with a
  /// token that used to work and no longer does, so it signs out and shows
  /// the login screen instead of leaving dead screens behind.
  ///
  /// Guarded so that several screens failing at once still only produces a
  /// single trip back to login.
  static bool _returningToLogin = false;

  static Future<void> handleExpired() async {
    if (_returningToLogin) return;

    _returningToLogin = true;

    await signOut();

    final context = navigatorKey.currentContext;

    if (context == null || !context.mounted) {
      _returningToLogin = false;

      return;
    }

    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );

    _returningToLogin = false;
  }

  static Future<AuthResult> _login(Map<String, String> body) async {
    final http.Response response;

    try {
      response = await http
          .post(Uri.parse(PlayerService.url), body: body)
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      return const AuthResult(
        ok: false,
        message: "Could not reach the server. Check your connection.",
      );
    }

    if (response.statusCode != 200) {
      return const AuthResult(
        ok: false,
        message: "Server error. Please try again.",
      );
    }

    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (e) {
      return const AuthResult(
        ok: false,
        message: "Unexpected reply from the server.",
      );
    }

    // An Apps Script that has not been updated yet does not know what a
    // login is, so it answers with its generic error. Say so plainly
    // rather than reporting a wrong password.
    if (decoded is! Map || decoded["token"] == null) {
      final String message =
          decoded is Map && decoded["message"] != null
              ? decoded["message"].toString()
              : "Sign in is not available yet.";

      return AuthResult(ok: false, message: message);
    }

    final String issued = decoded["token"].toString();

    final String issuedRole =
        decoded["role"]?.toString() ?? "";

    await _store(issued, issuedRole);

    return AuthResult(
      ok: true,
      role: issuedRole,
      playerName: decoded["playerName"]?.toString() ?? "",
      playerEmail: decoded["playerEmail"]?.toString() ?? "",
    );
  }

  static Future<AuthResult> loginCoach(String code) {
    return _login({
      "type": "login",
      "role": "coach",
      "code": code,
    });
  }

  static Future<AuthResult> loginPlayer(String email) {
    return _login({
      "type": "login",
      "role": "player",
      "email": email.trim(),
    });
  }
}
