import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  static const String url =
      "https://script.google.com/macros/s/AKfycbx_6czLjzqVvXDyCjfS69XuqPSTtugZhWpF6p1md9Pb-AioWmF9mRcLnkWajeO9UdzumQ/exec?update=true";

  static Future<bool> check(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        return false;
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
        return false;
      }

      if (!context.mounted) return true;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: const Text("Update Available"),
            content: const Text(
              "A new version is available.\nPlease update.",
            ),
            actions: [
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

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}