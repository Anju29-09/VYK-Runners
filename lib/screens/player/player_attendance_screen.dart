import 'package:flutter/material.dart';

import '../../services/player_service.dart';
import '../../widgets/app_back_button.dart';

class PlayerAttendanceScreen extends StatefulWidget {
  final String playerName;

  const PlayerAttendanceScreen({
    super.key,
    required this.playerName,
  });

  @override
  State<PlayerAttendanceScreen> createState() =>
      _PlayerAttendanceScreenState();
}

class _PlayerAttendanceScreenState
    extends State<PlayerAttendanceScreen> {

  final PlayerService service = PlayerService();

  List attendanceList = [];

  bool loading = true;

  String selectedDate = "";

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance({bool refresh = false}) async {
    setState(() {
      loading = true;
    });

    try {
      // Shared cache, so re-opening this screen within a few minutes
      // costs nothing.
      attendanceList =
      await service.getAllAttendance(refresh: refresh);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Network issue. Pull down to refresh.",
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      selectedDate =
      "${picked.day.toString().padLeft(2, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-"
          "${picked.year}";

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    final filteredList = attendanceList.where((item) {

      final player = item["Player Name"] ?? "";
      final date = item["Date"] ?? "";

      if (player.toString().toLowerCase() !=
          widget.playerName.toLowerCase()) {
        return false;
      }

      if (selectedDate.isNotEmpty &&
          date != selectedDate) {
        return false;
      }

      return true;

    }).toList();

    return Scaffold(

      backgroundColor: const Color(0xffF7F1EB),

      body: Stack(
        children: [

          // ------------------------------------------------
          // TOP RIGHT PURPLE CIRCLE
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

              onRefresh: () => loadAttendance(refresh: true),

              child: SingleChildScrollView(

                physics:
                const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.all(20),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const AppBackButton(),

                    const Text(
                      "My Attendance",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff312C51),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "View your attendance history",
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

                        onPressed: pickDate,

                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xff48426D),

                          foregroundColor:
                          Colors.white,

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                        ),

                        child: const Text(
                          "Search By Date",
                          style: TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            fontSize: 16,
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
                        fontWeight:
                        FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (loading)

                      const Center(
                        child: Padding(
                          padding:
                          EdgeInsets.all(20),

                          child:
                          CircularProgressIndicator(),
                        ),
                      ),

                    if (!loading)

                      ...filteredList.map(
                            (item) =>
                            attendanceCard(item),
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

  Widget attendanceCard(Map item) {

    final String date =
        item["Date"] ?? "";

    final String status =
        item["Status"] ?? "";

    final bool present =
        status.toLowerCase() == "present";

    return Container(

      width: double.infinity,

      margin:
      const EdgeInsets.only(bottom: 15),

      padding:
      const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(18),

        boxShadow: const [

          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),

        ],
      ),

      child: Text(

        "$date    •    $status",

        style: TextStyle(

          fontSize: 18,

          fontWeight:
          FontWeight.bold,

          color: present
              ? const Color(0xff2E7D32)
              : const Color(0xffC62828),
        ),
      ),
    );
  }
}