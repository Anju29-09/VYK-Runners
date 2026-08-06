import 'package:flutter/material.dart';

import '../../services/player_service.dart';
import '../../widgets/app_back_button.dart';
import 'player_profile_screen.dart';

class PlayerDetailsScreen extends StatefulWidget {
  const PlayerDetailsScreen({super.key});

  @override
  State<PlayerDetailsScreen> createState() =>
      _PlayerDetailsScreenState();
}

class _PlayerDetailsScreenState
    extends State<PlayerDetailsScreen> {

  // ============================================================
  // DATA
  // ============================================================

  final PlayerService service = PlayerService();

  List<dynamic> players = [];

  bool loading = true;

  String searchText = "";

  // ============================================================
  // LOAD PLAYERS
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadPlayers();
  }

  Future<void> loadPlayers({bool refresh = false}) async {

    setState(() {
      loading = true;
    });

    try {

      // Shared with the attendance, fees and competition screens, so
      // whichever one is opened first pays for the request and the rest
      // read it straight from the cache.
      final data = await service
          .getPlayersRaw(refresh: refresh)
          .timeout(
        const Duration(seconds: 20),
      );

      if (!mounted) return;

      setState(() {

        players = data;

        loading = false;

      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unable to load players\n$e",
          ),
        ),
      );

    }

  }

  // ============================================================
  // DELETE PLAYER
  // ============================================================

  Future<void> deletePlayer(
      String id,
      String playerName,
      ) async {

    final confirm =
    await showDialog<bool>(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Delete Player",
          ),

          content: Text(
            "Delete $playerName permanently?",
          ),

          actions: [

            TextButton(

              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child: const Text(
                "Cancel",
              ),

            ),

            ElevatedButton(

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),

              onPressed: () {

                Navigator.pop(
                  context,
                  true,
                );

              },

              child: const Text(
                "Delete",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

            ),

          ],

        );

      },

    );

    if (confirm != true) return;

    try {

      // Through the service so the shared player cache is dropped and the
      // other screens do not keep showing the deleted player.
      final deleted = await service
          .deletePlayer(id)
          .timeout(
        const Duration(seconds: 20),
      );

      if (deleted) {

        if (!mounted) return;

        setState(() {

          players.removeWhere(
                (player) =>
            player["ID"].toString() == id,
          );

        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Player Deleted",
            ),
          ),
        );

      } else {

        throw Exception(
          "Delete failed",
        );

      }

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Delete failed\n$e",
          ),
        ),
      );

    }

  }

  // ============================================================
  // GET PLAYER NAME
  // ============================================================

  String playerName(dynamic player) {

    return player["Players full name"]
        ?.toString()
        .trim() ??
        "";

  }

  // ============================================================
  // GET PLAYER GROUP
  // ============================================================

  String playerGroup(dynamic player) {

    return player[
    "Select which group you represent. "
    ]
        ?.toString()
        .trim() ??
        "Unknown";

  }

  // ============================================================
  // GET PLAYER ID
  // ============================================================

  String playerId(dynamic player) {

    return player["ID"]
        ?.toString()
        .trim() ??
        "";

  }

  // ============================================================
  // FILTER PLAYERS
  // ============================================================

  List<dynamic> get filteredPlayers {

    if (searchText.trim().isEmpty) {

      return players;

    }

    return players.where((player) {

      final name =
      playerName(player).toLowerCase();

      return name.contains(
        searchText.toLowerCase().trim(),
      );

    }).toList();

  }

  // ============================================================
  // GROUP PLAYERS
  // ============================================================

  Map<String, List<dynamic>> get groupedPlayers {

    final Map<String, List<dynamic>> groups = {};

    for (final player in filteredPlayers) {

      final group =
      playerGroup(player);

      groups.putIfAbsent(
        group,
            () => [],
      );

      groups[group]!.add(player);

    }

    return groups;

  }

  // ============================================================
  // BUILD STATISTICS
  // ============================================================

  Widget buildStatistics() {

    final Map<String, int> counts = {};

    for (final player in players) {

      final group =
      playerGroup(player);

      counts[group] =
          (counts[group] ?? 0) + 1;

    }

    final List<Color> colors = [

      const Color(0xff312C51),
      const Color(0xff48426D),
      const Color(0xffF0C38E),
      const Color(0xffF1AA9B),
      const Color(0xff8B7AA8),
      const Color(0xffD8C3A5),
      const Color(0xffA68DAD),

    ];

    final List<Widget> cards = [];

    // Total Players

    cards.add(
      buildStatCard(
        "Total Players",
        players.length,
        colors[0],
      ),
    );

    int colorIndex = 1;

    counts.forEach((group, count) {

      cards.add(
        buildStatCard(
          group,
          count,
          colors[
          colorIndex %
              colors.length
          ],
        ),
      );

      colorIndex++;

    });

    return GridView.count(

      crossAxisCount:
      MediaQuery.of(context).size.width > 600
          ? 3
          : 2,

      shrinkWrap: true,

      physics:
      const NeverScrollableScrollPhysics(),

      crossAxisSpacing: 10,

      mainAxisSpacing: 10,

      childAspectRatio: 1.6,

      children: cards,

    );

  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget buildStatCard(
      String title,
      int count,
      Color color,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PLAYER ROW
  // ============================================================

  Widget buildPlayerRow(
      dynamic player,
      ) {

    final name =
    playerName(player);

    final id =
    playerId(player);

    return Container(

      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(15),

        boxShadow: const [

          BoxShadow(
            blurRadius: 5,
            offset: Offset(0, 2),
            color: Colors.black12,
          ),

        ],

      ),

      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xff312C51),
          ),
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlayerProfileScreen(
                player: Map<String, dynamic>.from(player),
              ),
            ),
          );
        },

        trailing: IconButton(
          icon: const Text(
            "🗑",
            style: TextStyle(fontSize: 22),
          ),
          onPressed: () {
            deletePlayer(
              id,
              name,
            );
          },
        ),
      ),

    );

  }

  // ============================================================
  // GROUP CARD
  // ============================================================

  Widget buildGroup(
      String group,
      List<dynamic> groupPlayers,
      ) {

    return Card(

      elevation: 5,

      margin:
      const EdgeInsets.only(
        bottom: 15,
      ),

      shape: RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(0),

      ),

      child: ExpansionTile(

        initiallyExpanded:
        searchText.isNotEmpty,

        backgroundColor:
        Colors.transparent,

        collapsedBackgroundColor:
        const Color(0xff48426D),

        title: Text(

          group,

          style: const TextStyle(

            fontWeight:
            FontWeight.bold,

            fontSize: 17,

            color: Colors.white,

          ),

        ),

        trailing: Row(

          mainAxisSize:
          MainAxisSize.min,

          children: [

            CircleAvatar(

              radius: 17,

              backgroundColor:
              Colors.white24,

              child: Text(

                groupPlayers.length
                    .toString(),

                style: const TextStyle(

                  color: Colors.white,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),

            ),

            const SizedBox(width: 10),

            const Icon(

              Icons.keyboard_arrow_down,

              color: Colors.white,

            ),

          ],

        ),

        children: groupPlayers.map(

              (player) {

            return Padding(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 2,
              ),

              child:
              buildPlayerRow(player),

            );

          },

        ).toList(),

      ),

    );

  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {

    final groups =
        groupedPlayers;

    return Scaffold(

      backgroundColor:
      const Color(0xffF8F1E9),

      body: SafeArea(

        child: RefreshIndicator(

          onRefresh: () => loadPlayers(refresh: true),

          child: loading

              ? const Center(
            child:
            CircularProgressIndicator(),
          )

              : ListView(

            padding:
            const EdgeInsets.all(20),

            children: [

              const AppBackButton(),

              const Text(

                "Player Details",

                style: TextStyle(

                  fontSize: 34,

                  fontWeight:
                  FontWeight.w900,

                  color:
                  Color(0xff312C51),

                ),

              ),

              const SizedBox(
                height: 20,
              ),

              // SEARCH

              TextField(

                onChanged: (value) {

                  setState(() {

                    searchText =
                        value;

                  });

                },

                decoration:
                InputDecoration(

                  hintText:
                  "Search Player",

                  prefixIcon:
                  const Icon(
                    Icons.search,
                  ),

                  filled: true,

                  fillColor:
                  Colors.white,

                  border:
                  OutlineInputBorder(

                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),

                    borderSide:
                    BorderSide.none,

                  ),

                ),

              ),

              const SizedBox(
                height: 25,
              ),

              // STATISTICS

              buildStatistics(),

              const SizedBox(
                height: 30,
              ),

              const Text(

                "Player Groups",

                style: TextStyle(

                  fontSize: 28,

                  fontWeight:
                  FontWeight.bold,

                  color:
                  Color(0xff312C51),

                ),

              ),

              const SizedBox(
                height: 15,
              ),

              if (groups.isEmpty)

                Container(

                  padding:
                  const EdgeInsets.all(
                    25,
                  ),

                  decoration:
                  BoxDecoration(

                    color:
                    Colors.white,

                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),

                  ),

                  child:
                  const Center(

                    child: Text(
                      "No Players Found",
                    ),

                  ),

                )

              else

                ...groups.entries.map(

                      (entry) {

                    return buildGroup(

                      entry.key,

                      entry.value,

                    );

                  },

                ),

              const SizedBox(
                height: 80,
              ),

            ],

          ),

        ),

      ),

    );

  }

}