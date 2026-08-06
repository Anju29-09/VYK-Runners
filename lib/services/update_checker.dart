import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/navigation.dart';

class UpdateChecker {
  static const String url =
      "https://script.google.com/macros/s/AKfycbx_6czLjzqVvXDyCjfS69XuqPSTtugZhWpF6p1md9Pb-AioWmF9mRcLnkWajeO9UdzumQ/exec?update=true";

  /// Looks for a newer APK without holding up the first screen.
  ///
  /// This request takes four to twelve seconds to come back, and the splash
  /// screen used to sit and wait for all of it before showing the
  /// dashboard. Now it runs alongside startup and raises its dialog over
  /// whatever screen is showing once it has an answer.
  static Future<void> checkInBackground() async {
    // The update flow serves an APK link, which only Android can install.
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        return;
      }

      final data = jsonDecode(response.body);

      final int latest =
      int.parse(data["versionCode"].toString());

      final String link =
      data["apkLink"].toString();

      final packageInfo =
      await PackageInfo.fromPlatform();

      final int current =
      int.parse(packageInfo.buildNumber);

      if (latest <= current) {
        return;
      }

      final context = navigatorKey.currentContext;

      if (context == null || !context.mounted) return;

      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("Update Available"),
            content: const Text(
              "A new version is available.\nPlease update.",
            ),
            actions: [
              // The dialog no longer sits on the splash screen blocking
              // entry, so it needs a way out for anyone who cannot update
              // right now. It reappears on the next launch.
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text("Later"),
              ),

              ElevatedButton(
                onPressed: () async {
                  final uri = Uri.parse(link);

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(
                      uri,
                      mode:
                      LaunchMode.externalApplication,
                    );
                  }
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
