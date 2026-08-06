import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/player_model.dart';
import '../../models/fee_model.dart';
import '../../services/player_service.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/background.dart';
import '../../widgets/month_year_picker.dart';
import '../../widgets/player_search_field.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {

  final PlayerService service = PlayerService();

  bool loading = true;

  List<PlayerModel> players = [];

  List<FeeModel> fees = [];

  DateTime? selectedMonth;

  Map<String,List<FeeModel>> groupedFees = {};

  int totalFees = 0;

  final TextEditingController searchController =
  TextEditingController();

  String search = "";

  @override
  void initState() {
    super.initState();

    loadData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// Saved fees for the picked month, narrowed to the searched player.
  ///
  /// Groups with no matching player are dropped entirely so the coach is
  /// not left tapping through empty sections.
  Map<String, List<FeeModel>> get visibleFees {

    final query = search.trim().toLowerCase();

    if (query.isEmpty) return groupedFees;

    final Map<String, List<FeeModel>> result = {};

    groupedFees.forEach((group, list) {

      final matches = list
          .where((fee) => fee.player.toLowerCase().contains(query))
          .toList();

      if (matches.isNotEmpty) {
        result[group] = matches;
      }

    });

    return result;

  }

  Future<void> loadData({bool refresh = false}) async {

    setState(() {
      loading = true;
    });

    try {
      // Two round trips of two to three seconds each. Awaiting them one by
      // one meant waiting for the sum; Future.wait overlaps them.
      final results = await Future.wait<dynamic>([
        service.getPlayers(refresh: refresh),
        service.getFees(refresh: refresh),
      ]);

      players = (results[0] as List).cast<PlayerModel>();

      fees = (results[1] as List).cast<FeeModel>();

      if (selectedMonth != null) {
        buildMonthData();
      }
    } catch (e) {
      debugPrint("Load fees data error: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Unable to load. Pull down to refresh.",
            ),
          ),
        );
      }
    }

    // Runs even when the load failed, so a network problem cannot leave
    // the spinner turning forever.
    if (mounted) {
      setState(() {
        loading = false;
      });
    }

  }

  String formatMonth(DateTime date){

    const months=[
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];

    return "${months[date.month-1]} ${date.year}";
  }

  Future<void> pickMonth() async{

    final picked =
    await showMonthYearPicker(context);

    if(picked==null) return;

    selectedMonth=DateTime(
      picked.year,
      picked.month,
    );

    // A search from the previous month should not hide the new one.
    searchController.clear();
    search = "";

    buildMonthData();

  }

  void buildMonthData() {

    groupedFees.clear();

    totalFees = 0;

    String month =
        "${selectedMonth!.year}-${selectedMonth!.month.toString().padLeft(2, "0")}";

    for (final player in players) {

      FeeModel? fee;

      try {

        fee = fees.firstWhere(
              (f) =>
          f.player == player.name &&
              f.month.startsWith(month),
        );

      } catch (e) {
        fee = null;
      }

      groupedFees.putIfAbsent(
        player.group,
            () => [],
      );

      groupedFees[player.group]!.add(

        fee ??
            FeeModel(
              id: "",
              player: player.name,
              email: player.email,
              group: player.group,
              month: month,
              monthlyFee: "0",
              amount: "0",
              status: "Pending",
            ),

      );

      if (fee != null) {
        totalFees += int.tryParse(fee.amount) ?? 0;
      }

    }

    setState(() {});
  }

@override
Widget build(BuildContext context) {

    return Scaffold(

      body: Background(

        child: SafeArea(

          child: RefreshIndicator(

            onRefresh: () => loadData(refresh: true),

            child: loading

                ? const Center(
                  child: CircularProgressIndicator(),
                  )

                : ListView(

                    padding: const EdgeInsets.all(20),

                    children: [

                      const AppBackButton(),

                      const Text(
                        "Fees Management",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(

                        onPressed: pickMonth,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize:
                              const Size(double.infinity,55),
                        ),

                        child: const Text(
                          "Search Month",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),

                      ),

                      const SizedBox(height: 15),

                      Builder(
                        builder: (_) {

                          int totalPlayers = players.length;

                          int paidPlayers = 0;

                          int pendingPlayers = 0;

                          for(final group in groupedFees.values){

                            for(final fee in group){

                              if(fee.status=="Paid"){
                                paidPlayers++;
                              }else{
                                pendingPlayers++;
                              }

                            }

                          }

                          return Text(

                            selectedMonth==null
                                ? "No Month Selected"
                                : "${formatMonth(selectedMonth!)}"
                                "\n\nTotal : $totalPlayers"
                                "    Paid : $paidPlayers"
                                "    Pending : $pendingPlayers",

                            style: const TextStyle(

                              fontSize: 18,

                              fontWeight: FontWeight.bold,

                              color: AppColors.primary,

                            ),

                          );

                        },
                      ),

                      const SizedBox(height:20),

                      Container(

                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(

                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(20),

                        ),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            const Text(

                              "Total Fees Collected",

                              style: TextStyle(

                                fontSize:18,

                                fontWeight: FontWeight.bold,

                                color: AppColors.primary,

                              ),

                            ),

                            const SizedBox(height:10),

                            Text(

                              "₹$totalFees",

                              style: const TextStyle(

                                fontSize:34,

                                fontWeight: FontWeight.bold,

                                color: AppColors.primary,

                              ),

                            ),

                          ],

                        ),

                      ),

                      const SizedBox(height:25),

                      if(selectedMonth==null)

                        Container(

                          padding: const EdgeInsets.all(20),

                          decoration: BoxDecoration(

                            color: Colors.white,

                            borderRadius:
                                BorderRadius.circular(20),
                          ),

                          child: const Center(

                            child: Text(

                              "Select Month",

                              style: TextStyle(

                                color: Colors.grey,

                              ),

                            ),

                          ),

                        )

                      else if(groupedFees.isEmpty)

                        Container(

                          padding: const EdgeInsets.all(20),

                          decoration: BoxDecoration(

                            color: Colors.white,

                            borderRadius:
                                BorderRadius.circular(20),

                          ),

                          child: const Center(

                            child: Text(

                              "No Fees Found",

                              style: TextStyle(

                                color: Colors.grey,

                              ),

                            ),

                          ),

                        )

                      else ...[

                        PlayerSearchField(

                          controller: searchController,

                          onChanged: (value){

                            setState(() {
                              search = value;
                            });

                          },

                        ),

                        const SizedBox(height:20),

                        if(visibleFees.isEmpty)

                          NoSearchResults(
                            query: search.trim(),
                          )

                        else

                          ...visibleFees.entries.map(

                                (entry){

                                  return Card(

                                    margin:
                                        const EdgeInsets.only(
                                          bottom:15,
                                        ),

                                    child: ExpansionTile(

                                      // Rebuilds the tile when the search
                                      // starts or ends, so the expanded
                                      // state below takes effect.
                                      key: ValueKey(
                                        "fees-${entry.key}-"
                                        "${search.trim().isNotEmpty}",
                                      ),

                                      // Searching should reveal the match
                                      // without another tap.
                                      initiallyExpanded:
                                          search.trim().isNotEmpty,

                                      title: Text(

                                        entry.key,

                                        style: const TextStyle(

                                          fontWeight:
                                              FontWeight.bold,

                                          color:
                                              AppColors.primary,

                                        ),

                                      ),

                                      children:

                                          entry.value.map(

                                                (fee){

                                                  return buildFeeCard(fee);

                                                  },

                                          ).toList(),

                                    ),

                                  );

                                  },

                          ),

                      ],

                      const SizedBox(height:80),

                    ],

            ),

          ),

        ),

      ),

    );

  }

  Widget buildFeeCard(FeeModel fee){

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

            fee.player,

            style: const TextStyle(

              fontWeight: FontWeight.bold,

              fontSize:16,

            ),

          ),

          const SizedBox(height:8),

          // Blank when a player saved a single month without one.
          if(fee.monthlyFee.trim().isNotEmpty)
            Text("Monthly Fee : ₹${fee.monthlyFee}"),

          Text("Paid Amount : ₹${fee.amount}"),

          Text(

            "Status : ${fee.status}",

            style: TextStyle(

              fontWeight: FontWeight.bold,

              color: fee.status=="Paid"

                  ? Colors.green
                  : Colors.red,

            ),

          ),

          const SizedBox(height: 15),

          if(fee.id.isNotEmpty)

            Row(

              children: [

                Expanded(

                  child: ElevatedButton(

                    onPressed: () async {

                      await showEditDialog(fee);

                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),

                    child: const Text(
                      "Edit",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),

                  ),

                ),

                const SizedBox(width: 10),

                Expanded(

                  child: ElevatedButton(

                    onPressed: () async {

                      await deleteFee(fee);

                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),

                    child: const Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),

                  ),

                ),

              ],

            ),

        ],

      ),

    );

  }

  Future<void> showEditDialog(FeeModel fee) async {

    final amountController =
    TextEditingController(text: fee.amount);

    String selectedStatus = fee.status;

    await showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: const Text("Edit Fees"),

          content: StatefulBuilder(

            builder: (context, setDialogState) {

              return Column(

                mainAxisSize: MainAxisSize.min,

                children: [

                  TextField(

                    controller: amountController,

                    keyboardType: TextInputType.number,

                    decoration: const InputDecoration(

                      labelText: "Amount",

                    ),

                  ),

                  const SizedBox(height: 20),

                  DropdownButton<String>(

                    value: selectedStatus,

                    isExpanded: true,

                    items: const [

                      DropdownMenuItem(

                        value: "Paid",

                        child: Text("Paid"),

                      ),

                      DropdownMenuItem(

                        value: "Pending",

                        child: Text("Pending"),

                      ),

                    ],

                    onChanged: (value){

                      setDialogState((){

                        selectedStatus = value!;

                      });

                    },

                  ),

                ],

              );

            },

          ),

          actions: [

            TextButton(

              onPressed: (){

                Navigator.pop(context);

              },

              child: const Text("Cancel"),

            ),

            ElevatedButton(

              onPressed: () async {

                await service.updateFees(

                  id: fee.id,

                  amount: amountController.text,

                  status: selectedStatus,

                );

                Navigator.pop(context);

                await loadData();

                if(selectedMonth != null){

                  buildMonthData();

                }

                ScaffoldMessenger.of(context).showSnackBar(

                  const SnackBar(

                    content: Text("Fees Updated"),

                  ),

                );

              },

              child: const Text("Save"),

            ),

          ],

        );

      },

    );

  }

  Future<void> deleteFee(FeeModel fee) async {

    bool? confirm = await showDialog<bool>(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: const Text("Delete Fees"),

          content: Text(
            "Delete fees record of ${fee.player} ?",
          ),

          actions: [

            TextButton(

              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text("Cancel"),

            ),

            ElevatedButton(

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),

              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),

            ),

          ],

        );

      },

    );

    if(confirm != true) return;

    await service.deleteFees(fee.id);

    await loadData();

    if(selectedMonth != null){

      buildMonthData();

    }

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text("Fees Deleted"),
      ),

    );

  }

}