import 'package:flutter/material.dart';

import '../../services/player_service.dart';
import '../../widgets/app_back_button.dart';

class PlayerCompetitionScreen extends StatefulWidget {

  final String playerName;

  const PlayerCompetitionScreen({
    super.key,
    required this.playerName,
  });

  @override
  State<PlayerCompetitionScreen> createState() =>
      _PlayerCompetitionScreenState();

}

class _PlayerCompetitionScreenState
    extends State<PlayerCompetitionScreen> {

  // -------------------------------------------------------
  // GOOGLE APPS SCRIPT URL
  // -------------------------------------------------------

  final PlayerService service = PlayerService();

  // -------------------------------------------------------
  // VARIABLES
  // -------------------------------------------------------

  List<dynamic> competitionArray = [];

  bool isLoading = false;

  String selectedDate = "";

  // -------------------------------------------------------
  // INIT
  // -------------------------------------------------------

  @override
  void initState() {

    super.initState();

    _loadCompetitions();

  }

  // -------------------------------------------------------
  // LOAD COMPETITIONS
  // -------------------------------------------------------

  Future<void> _loadCompetitions({bool refresh = false}) async {

    if (mounted) {

      setState(() {
        isLoading = true;
      });

    }

    try {

      // Shared cache, so re-opening this screen within a few minutes
      // costs nothing.
      final data =
      await service.getCompetitionsRaw(refresh: refresh);

      if (mounted) {

        setState(() {

          competitionArray = data;

        });

      }

    } catch (e) {

      debugPrint(e.toString());

      _showMessage(
        "Network issue. Pull down to refresh.",
      );

    }

    if (mounted) {

      setState(() {
        isLoading = false;
      });

    }

  }

  // -------------------------------------------------------
  // DATE PICKER
  // -------------------------------------------------------

  Future<void> _selectDate() async {

    final DateTime? pickedDate =
    await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2020),

      lastDate: DateTime(2100),

    );

    if (pickedDate == null) {

      return;

    }

    final formattedDate =
    _formatDate(pickedDate);

    setState(() {

      selectedDate =
          formattedDate;

    });

  }

  // -------------------------------------------------------
  // FORMAT DATE
  // dd-MM-yyyy
  // -------------------------------------------------------

  String _formatDate(DateTime date) {

    final day =
    date.day.toString().padLeft(2, "0");

    final month =
    date.month.toString().padLeft(2, "0");

    final year =
    date.year.toString();

    return "$day-$month-$year";

  }

  // -------------------------------------------------------
  // CONVERT GOOGLE SHEET DATE
  // -------------------------------------------------------

  String _convertDate(String date) {

    try {

      date = date.trim();

      // Example:
      // 2026-07-25T00:00:00.000Z

      if (date.contains("T")) {

        final parsed =
        DateTime.parse(date).toUtc();

        return _formatDate(parsed);

      }

      // Example:
      // 2026-07-25

      if (RegExp(
        r'^\d{4}-\d{2}-\d{2}$',
      ).hasMatch(date)) {

        final parts =
        date.split("-");

        return "${parts[2]}-${parts[1]}-${parts[0]}";

      }

      // Example:
      // Sat Jul 25 2026 00:00:00 GMT...

      if (date.contains("GMT")) {

        final match =
        RegExp(
          r'^[A-Za-z]{3} ([A-Za-z]{3}) (\d{1,2}) (\d{4})',
        ).firstMatch(date);

        if (match != null) {

          final monthName =
          match.group(1)!;

          final day =
          int.parse(match.group(2)!);

          final year =
          int.parse(match.group(3)!);

          final month =
          _monthNumber(monthName);

          return
            "${day.toString().padLeft(2, "0")}-"
                "${month.toString().padLeft(2, "0")}-"
                "$year";

        }

      }

    } catch (e) {

      debugPrint(
        "Date conversion error: $e",
      );

    }

    return date;

  }

  // -------------------------------------------------------
  // MONTH NUMBER
  // -------------------------------------------------------

  int _monthNumber(String month) {

    const months = {

      "Jan": 1,
      "Feb": 2,
      "Mar": 3,
      "Apr": 4,
      "May": 5,
      "Jun": 6,
      "Jul": 7,
      "Aug": 8,
      "Sep": 9,
      "Oct": 10,
      "Nov": 11,
      "Dec": 12,

    };

    return months[month] ?? 1;

  }

  // -------------------------------------------------------
  // GET PLAYER COMPETITIONS
  // -------------------------------------------------------

  Map<String, List<Map<String, String>>>
  _getPlayerCompetitions() {

    final Map<String, List<Map<String, String>>>
    groupedData = {};

    for (final item in competitionArray) {

      if (item is! Map) {

        continue;

      }

      final player =
          item["Player Name"]?.toString() ?? "";

      if (player.toLowerCase() !=
          widget.playerName.toLowerCase()) {

        continue;

      }

      String date =
          item["Date"]?.toString() ?? "";

      date = _convertDate(date);

      if (selectedDate.isNotEmpty &&
          date != selectedDate) {

        continue;

      }

      final event =
          item["Event"]?.toString() ?? "";

      final result =
          item["Result"]?.toString() ?? "";

      if (!groupedData.containsKey(date)) {

        groupedData[date] = [];

      }

      groupedData[date]!.add({

        "event": event,

        "result": result,

      });

    }

    return groupedData;

  }

  // -------------------------------------------------------
  // MESSAGE
  // -------------------------------------------------------

  void _showMessage(String message) {

    if (!mounted) {

      return;

    }

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content: Text(message),
      ),

    );

  }

  // -------------------------------------------------------
  // BUILD
  // -------------------------------------------------------

  @override
  Widget build(BuildContext context) {

    final groupedData =
    _getPlayerCompetitions();

    final dates =
    groupedData.keys.toList();

    return Scaffold(

      backgroundColor:
      const Color(0xffF7F1EB),

      body: Stack(

        children: [

          // ------------------------------------------------
          // TOP RIGHT PURPLE CIRCLE
          // SAME AS FEES PAGE
          // ------------------------------------------------

          Positioned(
            top: -90,
            right: -90,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                color: Color(0xff8B7AA8),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ------------------------------------------------
          // BOTTOM LEFT PEACH CIRCLE
          // SAME AS FEES PAGE
          // ------------------------------------------------

          Positioned(
            bottom: -90,
            left: -90,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                color: Color(0xffF0C38E),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ------------------------------------------------
          // CONTENT
          // ------------------------------------------------

          SafeArea(

            child: RefreshIndicator(

              onRefresh: () => _loadCompetitions(refresh: true),

              child: SingleChildScrollView(

                physics:
                const AlwaysScrollableScrollPhysics(),

                padding:
                const EdgeInsets.all(20),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const AppBackButton(),

                    // TITLE

                    const Text(
                      "My Competitions",
                      style: TextStyle(
                        color: Color(0xff312C51),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // SUBTITLE

                    const Text(
                      "View your competition history",
                      style: TextStyle(
                        color: Color(0xff48426D),
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // SEARCH BY DATE

                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(

                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xff48426D),

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                        ),

                        onPressed: _selectDate,

                        child: const Text(
                          "Search By Date",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      selectedDate.isEmpty
                          ? "Showing All Dates"
                          : selectedDate,

                      style: const TextStyle(
                        color: Color(0xff48426D),
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // LOADING

                    if (isLoading)

                      const Center(
                        child: Padding(
                          padding:
                          EdgeInsets.all(20),

                          child:
                          CircularProgressIndicator(),
                        ),
                      ),

                    // NO DATA

                    if (!isLoading &&
                        dates.isEmpty)

                      Container(

                        width: double.infinity,

                        padding:
                        const EdgeInsets.all(20),

                        decoration:
                        BoxDecoration(

                          color: Colors.white,

                          borderRadius:
                          BorderRadius.circular(18),

                          boxShadow: const [

                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset:
                              Offset(0, 4),
                            ),

                          ],
                        ),

                        child: const Text(
                          "No Data Found",
                          style: TextStyle(
                            color:
                            Color(0xff312C51),
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),

                    // DATES + RECORDS

                    ...dates.map(

                          (date) {

                        final records =
                        groupedData[date]!;

                        return Column(

                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Padding(
                              padding:
                              const EdgeInsets.only(
                                top: 20,
                                bottom: 5,
                              ),

                              child: Text(
                                "Date : $date",

                                style:
                                const TextStyle(
                                  color:
                                  Color(0xff312C51),
                                  fontSize: 22,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),

                            ...records.map(

                                  (record) {

                                return Container(

                                  width:
                                  double.infinity,

                                  margin:
                                  const EdgeInsets
                                      .symmetric(
                                    vertical: 10,
                                  ),

                                  padding:
                                  const EdgeInsets
                                      .all(25),

                                  decoration:
                                  BoxDecoration(

                                    color:
                                    Colors.white,

                                    borderRadius:
                                    BorderRadius
                                        .circular(18),

                                    boxShadow: const [

                                      BoxShadow(
                                        color:
                                        Colors.black12,
                                        blurRadius: 8,
                                        offset:
                                        Offset(0, 4),
                                      ),

                                    ],
                                  ),

                                  child: Text(

                                    "Event : ${record["event"]}"
                                        "\n\n"
                                        "Result : ${record["result"]}",

                                    style:
                                    const TextStyle(
                                      color:
                                      Color(0xff312C51),
                                      fontSize: 18,
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {

    super.dispose();

  }

}