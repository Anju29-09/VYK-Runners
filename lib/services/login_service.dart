import 'player_service.dart';

class LoginService {

  final PlayerService _players = PlayerService();

  Future<Map<String, dynamic>?> verifyPlayer(String email) async {

    // The same player list the rest of the app uses. Launch pulls it down
    // in the background, so by the time anyone finishes typing an email
    // this is usually already in hand and the login is instant.
    final List data;

    try {
      data = await _players.getPlayersRaw();
    } catch (e) {
      return null;
    }

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

    return null;
  }
}
