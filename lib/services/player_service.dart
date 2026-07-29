import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/player_model.dart';
import '../models/fee_model.dart';
import '../models/competition_model.dart';
import '../models/salary_model.dart';

class PlayerService {
  static const String url =
      "https://script.google.com/macros/s/AKfycbx_6czLjzqVvXDyCjfS69XuqPSTtugZhWpF6p1md9Pb-AioWmF9mRcLnkWajeO9UdzumQ/exec";

  Future<List<PlayerModel>> getPlayers() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Unable to load players");
    }

    final List jsonData = jsonDecode(response.body);

    return jsonData
        .map((e) => PlayerModel.fromJson(e))
        .toList();
  }

  Future<bool> deletePlayer(String id) async {
    final response = await http.post(
      Uri.parse(url),
      body: {
        "type": "deletePlayer",
        "id": id,
      },
    );

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

    return response.statusCode == 200;
  }

//---------------- LOAD ATTENDANCE ----------------//

  Future<List<dynamic>> getAttendance(String date) async {

    final response = await http.get(
      Uri.parse("$url?attendance=true"),
    );

    if (response.statusCode != 200) {
      throw Exception("Unable to load attendance");
    }

    final List data = jsonDecode(response.body);

    print(data);

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

    return response.statusCode == 200;

  }

  //---------------- LOAD FEES ----------------//

  Future<List<FeeModel>> getFees() async {

    final response =
    await http.get(
      Uri.parse("$url?fees=true"),
    );

    if(response.statusCode!=200){

      throw Exception("Unable to load fees");

    }

    final List data =
    jsonDecode(response.body);

    return data
        .map((e)=>FeeModel.fromJson(e))
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

    return response.statusCode==200;

  }

  //---------------- LOAD COMPETITION ----------------//

  Future<List<CompetitionModel>> getCompetitions() async {

    final response = await http.get(

      Uri.parse("$url?competition=true"),

    );

    if (response.statusCode != 200) {

      return [];

    }

    final List data = jsonDecode(response.body);

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

  }

  //---------------- LOAD EVENTS ----------------//

  Future<List<String>> getEvents() async {

    final response = await http.get(
      Uri.parse("$url?events=true"),
    );

    if (response.statusCode != 200) return [];

    final List data = jsonDecode(response.body);

    return data.map((e) => e.toString()).toList();

  }

//---------------- LOAD SALARY ----------------//

  Future<List<SalaryModel>> getSalary() async {

    final response = await http.get(
      Uri.parse("$url?salary=true"),
    );

    if (response.statusCode != 200) {
      return [];
    }

    final List data = jsonDecode(response.body);

    return data.map((e) => SalaryModel.fromJson(e)).toList();
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
  }
}