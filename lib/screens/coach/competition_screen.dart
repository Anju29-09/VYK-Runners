import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/competition_model.dart';
import '../../models/player_model.dart';
import '../../services/player_service.dart';
import '../../widgets/background.dart';

class PlayerCompetitionEntry {

  final PlayerModel player;

  List<EventEntry> events = [];

  PlayerCompetitionEntry(this.player);

}

class EventEntry {

  String? event;

  TextEditingController resultController =
  TextEditingController();

}

class CompetitionScreen extends StatefulWidget {
  const CompetitionScreen({super.key});

  @override
  State<CompetitionScreen> createState() =>
      _CompetitionScreenState();
}

class _CompetitionScreenState
    extends State<CompetitionScreen> {

  final PlayerService service = PlayerService();

  bool loading = true;

  List<CompetitionModel> competitions = [];
  List<String> events = [];

  DateTime? savedCompetitionDate;

  Map<String, List<CompetitionModel>> groupedSavedCompetitions = {};

  List<PlayerModel> players = [];

  DateTime? selectedCompetitionDate;

  DateTime? selectedSavedDate;

  final Map<String, List<PlayerCompetitionEntry>>
  groupedPlayers = {};

  final Map<String, List<CompetitionModel>>
  groupedCompetitions = {};

  final Map<String, bool> groupExpanded = {};

  final Map<String, bool> savedGroupExpanded = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }


  Future<void> loadData() async {
    setState(() {
      loading = true;
    });

    players = await service.getPlayers();

    competitions = await service.getCompetitions();

    events = await service.getEvents();

    print(events);

    groupPlayers();

    setState(() {
      loading = false;
    });
  }

  void groupPlayers() {

    groupedPlayers.clear();

    for(final player in players){

      groupedPlayers.putIfAbsent(
        player.group,
            ()=>[],
      );

      groupedPlayers[player.group]!.add(

        PlayerCompetitionEntry(player),

      );

    }

  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, "0")}-"
        "${date.month.toString().padLeft(2, "0")}-"
        "${date.year}";
  }

  Future<void> pickCompetitionDate() async {
    final picked =
    await showDatePicker(
      context: context,
      initialDate:
      DateTime.now(),
      firstDate:
      DateTime(2020),
      lastDate:
      DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      selectedCompetitionDate = picked;
    });
  }

  Future<void> pickSavedDate() async {
    final picked =
    await showDatePicker(
      context: context,
      initialDate:
      DateTime.now(),
      firstDate:
      DateTime(2020),
      lastDate:
      DateTime(2100),
    );

    if (picked == null) return;

    selectedSavedDate = picked;

    buildSavedCompetition();

    setState(() {});
  }

  void buildSavedCompetition() {
    groupedCompetitions.clear();

    final date =
    formatDate(selectedSavedDate!);

    for (final item in competitions) {
      if (item.date != date) continue;

      groupedCompetitions.putIfAbsent(
        item.group,
            () => [],
      );

      groupedCompetitions[item.group]!
          .add(item);
    }
  }

  Widget buildPlayerGroups() {

    return Column(

      children: groupedPlayers.entries.map((group){

        groupExpanded.putIfAbsent(
          group.key,
              ()=>false,
        );

        return Card(

          margin: const EdgeInsets.only(bottom:15),

          child: ExpansionTile(

            initiallyExpanded:
            groupExpanded[group.key]!,

            onExpansionChanged: (value){

              groupExpanded[group.key]=value;

            },

            title: Text(

              group.key,

              style: const TextStyle(

                fontWeight: FontWeight.bold,

                color: AppColors.primary,

              ),

            ),

            children:

            group.value.map((entry){

              return buildPlayerCard(entry);

            }).toList(),

          ),

        );

      }).toList(),

    );

  }

  Widget buildPlayerCard(
      PlayerCompetitionEntry entry){

    return Container(

      margin: const EdgeInsets.fromLTRB(
        12,
        6,
        12,
        6,
      ),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(16),

      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(

            entry.player.name,

            style: const TextStyle(

              fontWeight: FontWeight.bold,

              fontSize:16,

            ),

          ),

          const SizedBox(height:12),

          ...entry.events.map(

                (event){

              return buildEventRow(
                event,
                entry,
              );

            },

          ),

          ElevatedButton(

            onPressed: () {

              setState(() {

                entry.events.add(
                  EventEntry(),
                );

              });

            },

            style: ElevatedButton.styleFrom(

              backgroundColor:
              AppColors.primary,

            ),

            child: const Text(

              "Add Event",

              style: TextStyle(

                color: Colors.white,

              ),

            ),

          ),

        ],

      ),

    );

  }

  Widget buildEventRow(

      EventEntry event,

      PlayerCompetitionEntry player){

    return Container(

      margin: const EdgeInsets.only(
        top:12,
      ),

      child: Row(

        children: [

          Expanded(

            child: DropdownButtonFormField<String>(

              value: event.event,

              decoration:
              const InputDecoration(

                border:
                OutlineInputBorder(),

              ),

              items: events.map((e){

                return DropdownMenuItem<String>(
                  value: e,
                  child: Text(e),
                );

              }).toList(),

              onChanged: (value){

                setState(() {

                  event.event=value;

                });

              },

            ),

          ),

          const SizedBox(width:10),

          Expanded(

            child: TextField(

              controller:
              event.resultController,

              decoration:
              const InputDecoration(

                hintText: "Result",

                border:
                OutlineInputBorder(),

              ),

            ),

          ),

          IconButton(

            icon: const Icon(

              Icons.delete,

              color: Colors.red,

            ),

            onPressed: (){

              setState(() {

                player.events.remove(event);

              });

            },

          )

        ],

      ),

    );

  }

  Future<void> saveCompetitions() async {

    if (selectedCompetitionDate == null) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Select competition date first"),
        ),

      );

      return;

    }

    bool hasCompetition = false;

    for (final group in groupedPlayers.values) {

      for (final playerEntry in group) {

        for (final event in playerEntry.events) {

          if (event.event == null) continue;

          if (event.resultController.text.trim().isEmpty) continue;

          hasCompetition = true;

          await service.saveCompetition(

            CompetitionModel(

              id: "",

              date: formatDate(selectedCompetitionDate!),

              player: playerEntry.player.name,

              group: playerEntry.player.group,

              event: event.event!,

              result: event.resultController.text.trim(),

            ),

          );

        }

      }

    }

    if (!hasCompetition) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("No competition entered"),
        ),

      );

      return;

    }

    await refreshCompetitions();

    clearCompetitionEntries();

    selectedCompetitionDate = null;

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text("Competition Saved"),
      ),

    );

  }

  void clearCompetitionEntries() {

    for (final group in groupedPlayers.values) {

      for (final player in group) {

        player.events.clear();

      }

    }

  }

  Widget buildSavedCompetitionWidget(){

    if(selectedSavedDate==null){

      return Container(

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
          BorderRadius.circular(20),

        ),

        child: const Center(

          child: Text(

            "Select Date",

            style: TextStyle(

              color: Colors.grey,

            ),

          ),

        ),

      );

    }

    if(groupedCompetitions.isEmpty){

      return Container(

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
          BorderRadius.circular(20),

        ),

        child: const Center(

          child: Text(

            "No Competition Found",

            style: TextStyle(

              color: Colors.grey,

            ),

          ),

        ),

      );

    }

    return Column(

      children:

      groupedCompetitions.entries.map((group){

        return Card(

          margin:
          const EdgeInsets.only(bottom:15),

          child: ExpansionTile(

            title: Text(

              group.key,

              style: const TextStyle(

                fontWeight: FontWeight.bold,

                color: AppColors.primary,

              ),

            ),

            children:

            group.value.map((competition){

              return buildCompetitionCard(
                  competition);

            }).toList(),

          ),

        );

      }).toList(),

    );

  }

  Widget buildCompetitionCard(
      CompetitionModel competition){

    return Container(

      margin: const EdgeInsets.fromLTRB(
        12,
        6,
        12,
        6,
      ),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(16),

      ),

      child: Row(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Expanded(

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  "Player : ${competition.player}",
                ),

                Text(
                  "Event : ${competition.event}",
                ),

                Text(
                  "Result : ${competition.result}",
                ),

              ],

            ),

          ),

          IconButton(

            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),

            onPressed: () async {

              final delete = await showDialog<bool>(

                context: context,

                builder: (_) {

                  return AlertDialog(

                    title: const Text("Delete Competition"),

                    content: const Text(
                      "Delete this competition?",
                    ),

                    actions: [

                      TextButton(

                        onPressed: () {

                          Navigator.pop(context, false);

                        },

                        child: const Text("Cancel"),

                      ),

                      ElevatedButton(

                        onPressed: () {

                          Navigator.pop(context, true);

                        },

                        child: const Text("Delete"),

                      ),

                    ],

                  );

                },

              );

              if (delete != true) return;

              await service.deleteCompetition(
                competition.id,
              );

              await refreshCompetitions();

              ScaffoldMessenger.of(context).showSnackBar(

                const SnackBar(

                  content: Text(
                    "Competition Deleted",
                  ),

                ),

              );

            },

          )

        ],

      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Background(

        child: SafeArea(

          child: RefreshIndicator(

            onRefresh: loadData,

            child: loading

                ? const Center(
              child: CircularProgressIndicator(),
            )

                : ListView(

              padding: const EdgeInsets.all(20),

              children: [

                const Text(
                  "Competition Management",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(

                  onPressed: pickCompetitionDate,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize:
                    const Size(double.infinity,55),
                  ),

                  child: const Text(
                    "Select Competition Date",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),

                ),

                const SizedBox(height:15),

                Text(

                  selectedCompetitionDate==null
                      ? "No Date Selected"
                      : formatDate(selectedCompetitionDate!),

                  style: const TextStyle(
                    fontSize:18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),

                ),

                const SizedBox(height:25),

                buildPlayerGroups(),

                const SizedBox(height:20),

                ElevatedButton(

                  onPressed: saveCompetitions,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize:
                    const Size(double.infinity,55),
                  ),

                  child: const Text(
                    "Save Competition Data",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),

                ),

                const SizedBox(height:40),

                const Text(
                  "Saved Competitions",
                  style: TextStyle(
                    fontSize:30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height:15),

                ElevatedButton(

                  onPressed: pickSavedDate,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize:
                    const Size(double.infinity,55),
                  ),

                  child: const Text(
                    "Select Date",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),

                ),

                const SizedBox(height:15),

                Text(

                  selectedSavedDate==null
                      ? "No Date Selected"
                      : formatDate(selectedSavedDate!),

                  style: const TextStyle(
                    fontSize:18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),

                ),

                const SizedBox(height:20),

                buildSavedCompetitionWidget(),

                const SizedBox(height:80),

              ],

            ),

          ),

        ),

      ),

    );

  }

  Future<void> refreshCompetitions() async {

    competitions = await service.getCompetitions();

    if (selectedSavedDate != null) {
      buildSavedCompetition();
    }

    setState(() {});

  }

}