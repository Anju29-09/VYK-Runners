import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/player_model.dart';
import '../../models/fee_model.dart';
import '../../services/player_service.dart';
import '../../widgets/background.dart';
import '../../widgets/month_year_picker.dart';

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

    fees = await service.getFees();

    setState(() {
      loading = false;
    });

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

            onRefresh: loadData,

            child: loading

                ? const Center(
                  child: CircularProgressIndicator(),
                  )

                : ListView(

                    padding: const EdgeInsets.all(20),

                    children: [

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

                      else

                        ...groupedFees.entries.map(

                              (entry){

                                return Card(

                                  margin:
                                      const EdgeInsets.only(
                                        bottom:15,
                                      ),

                                  child: ExpansionTile(

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