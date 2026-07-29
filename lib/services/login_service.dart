import 'dart:convert';

import 'package:http/http.dart' as http;

class LoginService {

  static const String url =
      "https://script.google.com/macros/s/AKfycbx_6czLjzqVvXDyCjfS69XuqPSTtugZhWpF6p1md9Pb-AioWmF9mRcLnkWajeO9UdzumQ/exec";

  Future<Map<String, dynamic>?> verifyPlayer(String email) async {

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {

      final List data = json.decode(response.body);

      for (var player in data) {

        String sheetEmail =
        player["Email Address"]
            .toString()
            .trim()
            .toLowerCase();

        if (sheetEmail == email.trim().toLowerCase()) {

          return {
            "playerName": player["Players full name"],
            "playerEmail": sheetEmail,
          };
        }
      }
    }

    return null;
  }
}