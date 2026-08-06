import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/player_model.dart';
import '../models/fee_model.dart';
import '../models/competition_model.dart';
import '../models/salary_model.dart';

/// One cached response plus the time it arrived.
class _CacheEntry {
  final List<dynamic> data;

  final DateTime fetchedAt;

  _CacheEntry(this.data, this.fetchedAt);

  bool get isFresh =>
      DateTime.now().difference(fetchedAt) <
          PlayerService.cacheLifetime;
}

class PlayerService {
  static const String url =
      "https://script.google.com/macros/s/AKfycbx_6czLjzqVvXDyCjfS69XuqPSTtugZhWpF6p1md9Pb-AioWmF9mRcLnkWajeO9UdzumQ/exec";

  /// Every request to the Apps Script costs roughly two to three seconds no
  /// matter how little data comes back, so the same list is not fetched
  /// twice in quick succession. Short enough that another device's changes
  /// still show up soon, and any write below clears the affected key
  /// immediately.
  static const Duration cacheLifetime = Duration(minutes: 3);

  static final Map<String, _CacheEntry> _cache = {};

  /// Requests already on the wire, so two screens asking for the same list
  /// at the same moment share one round trip instead of making two.
  static final Map<String, Future<List<dynamic>>> _pending = {};

  /// The combined request, while it is running.
  static Future<void>? _bootstrap;

  static const String _playersKey = "players";
  static const String _attendanceKey = "attendance";
  static const String _feesKey = "fees";
  static const String _competitionKey = "competition";
  static const String _eventsKey = "events";
  static const String _salaryKey = "salary";

  /// Drops everything, so the next screen reloads from the sheet.
  static void clearCache() {
    _cache.clear();
    _pending.clear();
    _bootstrap = null;
  }

  //---------------- LOAD EVERYTHING AT ONCE ----------------//

  /// Fills every cache from a single request to `?all=true`.
  ///
  /// The Apps Script costs about two seconds to start up whatever it is
  /// asked for, so six separate calls cost six startups and one combined
  /// call costs one. Fired at launch, so by the time a card on the
  /// dashboard is tapped the screen has nothing left to wait for.
  ///
  /// Safe to fail. Anything it did not fill is fetched the old way.
  Future<void> prefetchAll({bool refresh = false}) {
    final running = _bootstrap;

    if (!refresh && running != null) {
      return running;
    }

    final future = _downloadAll();

    _bootstrap = future;

    void release(Object? _) {
      if (identical(_bootstrap, future)) {
        _bootstrap = null;
      }
    }

    future.then(release, onError: release);

    return future;
  }

  Future<void> _downloadAll() async {
    final response = await http.get(Uri.parse("$url?all=true"));

    if (response.statusCode != 200) {
      throw Exception("Unable to load data");
    }

    final decoded = jsonDecode(response.body);

    // An older deployment without the combined endpoint answers with the
    // player list instead. Leave the caches alone and let each screen
    // fetch for itself.
    if (decoded is! Map) {
      throw Exception("Combined endpoint not deployed");
    }

    final now = DateTime.now();

    void store(String key, String field) {
      final value = decoded[field];

      if (value is List) {
        _cache[key] = _CacheEntry(value, now);
      }
    }

    store(_playersKey, "players");
    store(_attendanceKey, "attendance");
    store(_feesKey, "fees");
    store(_competitionKey, "competitions");
    store(_eventsKey, "events");
    store(_salaryKey, "salary");
  }

  Future<List<dynamic>> _download(
      String key,
      String query,
      ) async {
    final response = await http.get(Uri.parse("$url$query"));

    if (response.statusCode != 200) {
      throw Exception("Unable to load $key");
    }

    final List data = jsonDecode(response.body);

    _cache[key] = _CacheEntry(data, DateTime.now());

    return data;
  }

  Future<List<dynamic>> _fetch(
      String key,
      String query, {
        required bool refresh,
      }) async {
    if (refresh) {
      _cache.remove(key);
    } else {
      final cached = _cache[key];

      if (cached != null && cached.isFresh) {
        return cached.data;
      }

      // The combined request already on the wire is about to fill this
      // key, so wait for it rather than asking for the same rows again.
      final bootstrap = _bootstrap;

      if (bootstrap != null) {
        try {
          await bootstrap;
        } catch (e) {
          // Fall through and fetch this one list on its own.
        }

        final filled = _cache[key];

        if (filled != null && filled.isFresh) {
          return filled.data;
        }
      }

      final inFlight = _pending[key];

      if (inFlight != null) {
        return inFlight;
      }
    }

    final future = _download(key, query);

    _pending[key] = future;

    // Clear the slot either way, but only if a newer request has not
    // already taken it.
    void release(Object? _) {
      if (identical(_pending[key], future)) {
        _pending.remove(key);
      }
    }

    future.then(release, onError: release);

    return future;
  }

  //---------------- LOAD PLAYERS ----------------//

  Future<List<PlayerModel>> getPlayers({
    bool refresh = false,
  }) async {
    final data = await _fetch(
      _playersKey,
      "",
      refresh: refresh,
    );

    return data
        .map((e) => PlayerModel.fromJson(e))
        .toList();
  }

  /// Same cached response as [getPlayers], left as raw JSON for screens
  /// that read the sheet columns directly instead of through a model.
  Future<List<dynamic>> getPlayersRaw({
    bool refresh = false,
  }) {
    return _fetch(_playersKey, "", refresh: refresh);
  }

  /// Every attendance row, uncached filtering left to the caller.
  Future<List<dynamic>> getAllAttendance({
    bool refresh = false,
  }) {
    return _fetch(
      _attendanceKey,
      "?attendance=true",
      refresh: refresh,
    );
  }

  /// Every competition row, as raw JSON.
  Future<List<dynamic>> getCompetitionsRaw({
    bool refresh = false,
  }) {
    return _fetch(
      _competitionKey,
      "?competition=true",
      refresh: refresh,
    );
  }

  /// Every fee row, as raw JSON.
  Future<List<dynamic>> getFeesRaw({
    bool refresh = false,
  }) {
    return _fetch(
      _feesKey,
      "?fees=true",
      refresh: refresh,
    );
  }

  /// For screens that post fees without going through [updateFees], so the
  /// next read does not serve the list from before the write.
  static void invalidateFees() {
    _cache.remove(_feesKey);
  }

  Future<bool> deletePlayer(String id) async {
    final response = await http.post(
      Uri.parse(url),
      body: {
        "type": "deletePlayer",
        "id": id,
      },
    );

    _cache.remove(_playersKey);

    return response.statusCode == 200;
  }

  //---------------- SAVE ATTENDANCE ----------------//

  Future<bool> saveAttendance({
    required String date,
    required String player,
    required String group,
    required String status,
  }) async {

    final response = await http.post(

      Uri.parse(url),

      body: {
        "type": "attendance",
        "date": date,
        "player": player,
        "group": group,
        "status": status,
      },

    );

    _cache.remove(_attendanceKey);

    return response.statusCode == 200;
  }

//---------------- LOAD ATTENDANCE ----------------//

  Future<List<dynamic>> getAttendance(
      String date, {
        bool refresh = false,
      }) async {

    // The sheet has no per-date endpoint, so the whole list is fetched and
    // filtered here. Cached, so picking a second date costs nothing.
    final data = await _fetch(
      _attendanceKey,
      "?attendance=true",
      refresh: refresh,
    );

    return data.where((item) {
      return item["Date"] == date;
    }).toList();

  }

//---------------- DELETE ATTENDANCE ----------------//

  Future<bool> deleteAttendance(String date) async {

    final response = await http.post(

      Uri.parse(url),

      body: {
        "type": "deleteAttendance",
        "date": date,
      },

    );

    _cache.remove(_attendanceKey);

    return response.statusCode == 200;

  }

  //---------------- LOAD FEES ----------------//

  Future<List<FeeModel>> getFees({
    bool refresh = false,
  }) async {

    final data = await _fetch(
      _feesKey,
      "?fees=true",
      refresh: refresh,
    );

    return data
        .map((e) => FeeModel.fromJson(e))
        .toList();

  }

  //---------------- UPDATE FEES ----------------//
  Future<bool> updateFees({

    required String id,

    required String amount,

    required String status,

  }) async{

    final response =
    await http.post(

      Uri.parse(url),

      body:{

        "type":"updateFees",

        "id":id,

        "amount":amount,

        "status":status,

      },

    );

    _cache.remove(_feesKey);

    return response.statusCode==200;

  }

  //---------------- DELETE FEES ----------------//
  Future<bool> deleteFees(
      String id,
      ) async{

    final response =
    await http.post(

      Uri.parse(url),

      body:{

        "type":"deleteFees",

        "id":id,

      },

    );

    _cache.remove(_feesKey);

    return response.statusCode==200;

  }

  //---------------- LOAD COMPETITION ----------------//

  Future<List<CompetitionModel>> getCompetitions({
    bool refresh = false,
  }) async {

    final List data;

    try {
      data = await _fetch(
        _competitionKey,
        "?competition=true",
        refresh: refresh,
      );
    } catch (e) {
      return [];
    }

    return data.map((e) {

      return CompetitionModel(

        id: e["ID"]?.toString() ?? "",

        date: e["Date"]?.toString() ?? "",

        player: e["Player Name"]?.toString() ?? "",

        group: e["Group"]?.toString() ?? "",

        event: e["Event"]?.toString() ?? "",

        result: e["Result"]?.toString() ?? "",

      );

    }).toList();

  }

  //---------------- SAVE COMPETITION ----------------//

  Future<void> saveCompetition(
      CompetitionModel competition) async {

    await http.post(

      Uri.parse(url),

      body: {

        "type": "competition",

        "date": competition.date,

        "player": competition.player,

        "group": competition.group,

        "event": competition.event,

        "result": competition.result,

      },

    );

    _cache.remove(_competitionKey);

  }

  //---------------- DELETE COMPETITION ----------------//

  Future<void> deleteCompetition(
      String id) async {

    await http.post(

      Uri.parse(url),

      body: {

        "type": "deleteCompetition",

        "id": id,

      },

    );

    _cache.remove(_competitionKey);

  }

  //---------------- LOAD EVENTS ----------------//

  Future<List<String>> getEvents({
    bool refresh = false,
  }) async {

    try {
      final data = await _fetch(
        _eventsKey,
        "?events=true",
        refresh: refresh,
      );

      return data.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }

  }

//---------------- LOAD SALARY ----------------//

  Future<List<SalaryModel>> getSalary({
    bool refresh = false,
  }) async {

    try {
      final data = await _fetch(
        _salaryKey,
        "?salary=true",
        refresh: refresh,
      );

      return data.map((e) => SalaryModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  //---------------- SAVE SALARY ----------------//

  Future<void> saveSalary({
    required String month,
    required String name,
    required String amount,
  }) async {

    await http.post(

      Uri.parse(url),

      body: {

        "type": "salary",

        "month": month,

        "name": name,

        "amount": amount,

      },

    );

    _cache.remove(_salaryKey);

  }

  //---------------- DELETE SALARY ----------------//

  Future<void> deleteSalary(String id) async {

    await http.post(

      Uri.parse(url),

      body: {

        "type": "deleteSalary",

        "id": id,

      },

    );

    _cache.remove(_salaryKey);
  }
}
