import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/player_model.dart';
import '../../services/player_service.dart';
import '../../widgets/background.dart';

class PlayerAttendance {
  final PlayerModel player;

  String? status;

  PlayerAttendance({
    required this.player,
    this.status,
  });
}

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() =>
      _AttendanceScreenState();
}

class _AttendanceScreenState
    extends State<AttendanceScreen> {

  final PlayerService service = PlayerService();

  bool loading = true;

  List<PlayerModel> players = [];

  Map<String,List<PlayerAttendance>> groupedPlayers = {};

  DateTime? attendanceDate;

  DateTime? historyDate;

  List<dynamic> attendanceHistory = [];

  bool saving = false;
  bool loadingAttendance = false;

  @override
  void initState() {
    super.initState();

    loadPlayers();
  }

  Future<void> loadPlayers() async {

    setState(() {
      loading = true;
    });

    players = await service.getPlayers();

    groupedPlayers.clear();

    for(final player in players){

      groupedPlayers.putIfAbsent(
        player.group,
            ()=>[],
      );

      groupedPlayers[player.group]!.add(

        PlayerAttendance(player: player),

      );

    }

    setState(() {
      loading = false;
    });

  }

  Future<void> pickAttendanceDate() async {

    final picked =
    await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2024),

      lastDate: DateTime(2100),

    );

    if(picked!=null){

      attendanceDate= picked;

      for(final group in groupedPlayers.values){

        for(final player in group){

          player.status=null;

        }

      }

      setState(() {});

    }

  }

  Future<void> pickHistoryDate() async {

    final picked =
    await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2024),

      lastDate: DateTime(2100),

    );

    if (picked != null) {

      historyDate = picked;

      await loadAttendanceHistory();

      setState(() {});

    }

  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, "0")}-"
        "${date.month.toString().padLeft(2, "0")}-"
        "${date.year}";
  }

  Future<void> deleteAttendance() async {
    if (historyDate == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Attendance"),
        content: Text(
            "Delete attendance of ${formatDate(historyDate!)} ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await service.deleteAttendance(
      formatDate(historyDate!),
    );

    attendanceHistory.clear();

    historyDate = null;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Attendance Deleted")),
    );
  }

  Future<void> saveAttendance() async {

    if (attendanceDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select attendance date first"),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    String date =
        "${attendanceDate!.day.toString().padLeft(2, '0')}-"
        "${attendanceDate!.month.toString().padLeft(2, '0')}-"
        "${attendanceDate!.year}";

    bool hasAttendance = false;

    for (final group in groupedPlayers.values) {

      for (final item in group) {

        if (item.status == null) continue;

        hasAttendance = true;

        await service.saveAttendance(
          date: date,
          player: item.player.name,
          group: item.player.group,
          status: item.status!,
        );

      }
    }

    setState(() {
      saving = false;
    });

    if (!hasAttendance) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No attendance selected"),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Attendance Saved"),
      ),
    );

    for (final group in groupedPlayers.values) {
      for (final item in group) {
        item.status = null;
      }
    }

    attendanceDate = null;

    setState(() {});
  }

  Future<void> loadAttendanceHistory() async {

    if (historyDate == null) return;

    setState(() {
      loadingAttendance = true;
    });

    String date =
        "${historyDate!.day.toString().padLeft(2, '0')}-"
        "${historyDate!.month.toString().padLeft(2, '0')}-"
        "${historyDate!.year}";

    attendanceHistory =
    await service.getAttendance(date);

    setState(() {
      loadingAttendance = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: loadPlayers,
            child: loading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : ListView(
              padding: const EdgeInsets.all(20),
              children: [

                const Text(
                  "Attendance",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Color(0xff312C51),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: pickAttendanceDate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 55),
                  ),
                  child: const Text(
                    "Select Attendance Date",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  attendanceDate == null
                      ? "No Date Selected"
                      : "${attendanceDate!.day.toString().padLeft(2, '0')}-"
                      "${attendanceDate!.month.toString().padLeft(2, '0')}-"
                      "${attendanceDate!.year}",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 20),

                ...groupedPlayers.entries.map((entry) {
                  return Card(
                    elevation: 6,
                    margin: const EdgeInsets.only(bottom: 15),
                    child: ExpansionTile(
                      title: Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),

                      children: entry.value.map((attendance) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [

                              Text(
                                attendance.player.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              Row(
                                children: [

                                  Radio<String>(
                                    value: "Present",
                                    groupValue: attendance.status,
                                    onChanged: (v) {
                                      setState(() {
                                        attendance.status = v;
                                      });
                                    },
                                  ),

                                  const Text(
                                    "Present",
                                    style: TextStyle(fontSize: 15),
                                  ),

                                  const SizedBox(width: 15),

                                  Radio<String>(
                                    value: "Absent",
                                    groupValue: attendance.status,
                                    onChanged: (v) {
                                      setState(() {
                                        attendance.status = v;
                                      });
                                    },
                                  ),

                                  const Text(
                                    "Absent",
                                    style: TextStyle(fontSize: 15),
                                  ),

                                ],
                              )

                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),

                const SizedBox(height: 15),

                ElevatedButton(
                  onPressed:
                  saving ? null : saveAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize:
                    const Size(double.infinity, 55),
                  ),
                  child: saving
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    "Save Attendance",
                    style:
                    TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 35),

                const Text(
                  "View Saved Attendance",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 15),

                ElevatedButton(
                  onPressed: pickHistoryDate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize:
                    const Size(double.infinity, 55),
                  ),
                  child: const Text(
                    "Select Date",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 10),

                Builder(
                  builder: (_) {

                    int total = attendanceHistory.length;

                    int present = attendanceHistory.where((e) =>
                    e["Status"].toString().toLowerCase() == "present").length;

                    int absent = attendanceHistory.where((e) =>
                    e["Status"].toString().toLowerCase() == "absent").length;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Expanded(
                          child: Text(
                            historyDate == null
                                ? "No Date Selected"
                                : "${historyDate!.day}-${historyDate!.month}-${historyDate!.year}"
                                "\nTotal : $total    Present : $present    Absent : $absent",

                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        if (historyDate != null)
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: deleteAttendance,
                          ),

                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                if (loadingAttendance)

                  Container(
                    padding: const EdgeInsets.all(30),
                    child: const Center(
                      child: Column(
                        children: [

                          CircularProgressIndicator(),

                          SizedBox(height: 15),

                          Text(
                            "Loading attendance...",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                        ],
                      ),
                    ),
                  )

                else if (attendanceHistory.isEmpty)

                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        "No Attendance Found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )

                else

                  Builder(
                    builder: (context) {

                      Map<String, List<dynamic>> groupedAttendance = {};

                      for (var item in attendanceHistory) {

                        String group = item["Group"];

                        groupedAttendance.putIfAbsent(
                          group,
                              () => [],
                        );

                        groupedAttendance[group]!.add(item);

                      }

                      return Column(

                        children: groupedAttendance.entries.map((entry) {

                          return Card(

                            elevation: 6,

                            margin: const EdgeInsets.only(bottom: 15),

                            child: ExpansionTile(

                              title: Text(

                                entry.key,

                                style: const TextStyle(

                                  fontWeight: FontWeight.bold,

                                  color: AppColors.primary,

                                ),

                              ),

                              children: entry.value.map((player) {

                                return ListTile(

                                  title: Text(
                                    player["Player Name"],
                                  ),

                                  trailing: Text(

                                    player["Status"],

                                    style: TextStyle(

                                      color: player["Status"] == "Present"
                                          ? Colors.green
                                          : Colors.red,

                                      fontWeight: FontWeight.bold,

                                    ),

                                  ),

                                );

                              }).toList(),

                            ),

                          );

                        }).toList(),

                      );

                    },
                  ),

                const SizedBox(height: 80),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAttendanceCard(PlayerAttendance playerAttendance) {

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(

        title: Text(
          playerAttendance.player.name,
          style: const TextStyle(
            color: Color(0xff312C51),
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Row(
          children: [

            Expanded(
              child: RadioListTile<String>(
                dense: true,
                value: "Present",
                groupValue: playerAttendance.status,
                title: const Text("Present"),
                onChanged: (value) {

                  setState(() {
                    playerAttendance.status = value;
                  });

                },
              ),
            ),

            Expanded(
              child: RadioListTile<String>(
                dense: true,
                value: "Absent",
                groupValue: playerAttendance.status,
                title: const Text("Absent"),
                onChanged: (value) {

                  setState(() {
                    playerAttendance.status = value;
                  });

                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
