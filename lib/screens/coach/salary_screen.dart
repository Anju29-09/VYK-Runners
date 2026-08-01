import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/salary_model.dart';
import '../../services/player_service.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/background.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {

  final PlayerService service = PlayerService();

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController amountController =
  TextEditingController();

  bool loading = true;

  List<SalaryModel> salaries = [];

  DateTime? selectedMonth;

  DateTime? selectedViewMonth;

  List<SalaryModel> filteredSalary = [];

  @override
  void initState() {
    super.initState();
    loadSalary();
  }

  Future<void> loadSalary() async {

    salaries = await service.getSalary();

    if (selectedViewMonth != null) {
      filterSalary();
    }

    setState(() {
      loading = false;
    });

  }

  String monthKey(DateTime date) {

    return "${date.year}-${date.month.toString().padLeft(2, "0")}";

  }

  String monthText(DateTime date) {

    const months = [

      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",

    ];

    return "${months[date.month - 1]} ${date.year}";

  }

  Future<void> pickMonth(bool isView) async {

    int year = DateTime.now().year;
    int month = DateTime.now().month;

    await showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text("Select Month"),

          content: StatefulBuilder(

            builder: (context, setDialogState) {

              return Column(

                mainAxisSize: MainAxisSize.min,

                children: [

                  DropdownButton<int>(

                    value: month,

                    isExpanded: true,

                    items: List.generate(

                      12,

                          (index) => DropdownMenuItem(

                        value: index + 1,

                        child: Text(

                          monthText(
                            DateTime(2024, index + 1),
                          ).split(" ")[0],
                        ),

                      ),

                    ),

                    onChanged: (value) {

                      setDialogState(() {

                        month = value!;

                      });

                    },

                  ),

                  const SizedBox(height: 15),

                  TextField(

                    keyboardType: TextInputType.number,

                    decoration: const InputDecoration(
                      labelText: "Year",
                    ),

                    controller: TextEditingController(
                      text: year.toString(),
                    ),

                    onChanged: (value) {

                      if (value.isNotEmpty) {

                        year = int.parse(value);

                      }

                    },

                  ),

                ],

              );

            },

          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);

              },

              child: const Text("Cancel"),

            ),

            ElevatedButton(

              onPressed: () {

                final date = DateTime(year, month);

                if (isView) {

                  selectedViewMonth = date;

                  filterSalary();

                } else {

                  selectedMonth = date;

                }

                Navigator.pop(context);

                setState(() {});

              },

              child: const Text("OK"),

            ),

          ],

        );

      },

    );

  }

  void filterSalary() {

    filteredSalary = salaries.where((salary) {

      return salary.month ==
          monthKey(selectedViewMonth!);

    }).toList();

  }

  Future<void> saveSalary() async {

    if (nameController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Enter Coach Name"),
        ),

      );

      return;

    }

    if (selectedMonth == null) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Select Month"),
        ),

      );

      return;

    }

    if (amountController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Enter Salary Amount"),
        ),

      );

      return;

    }

    await service.saveSalary(

      month: monthKey(selectedMonth!),

      name: nameController.text.trim(),

      amount: amountController.text.trim(),

    );

    nameController.clear();

    amountController.clear();

    selectedMonth = null;

    await loadSalary();

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text("Salary Saved"),
      ),

    );

  }

  Future<void> deleteSalary(String id) async {

    final delete = await showDialog<bool>(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: const Text("Delete Salary"),

          content: const Text(
            "Delete this salary record?",
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

    await service.deleteSalary(id);

    await loadSalary();

    filterSalary();

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text("Salary Deleted"),
      ),

    );

  }

  Widget buildSalaryCard(SalaryModel salary) {

    return Container(

      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(15),

      ),

      child: Row(

        children: [

          Expanded(

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  "Coach : ${salary.name}",
                ),

                const SizedBox(height: 8),

                Text(
                  "Amount : ₹${salary.amount}",
                ),

              ],

            ),

          ),

          IconButton(

            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),

            onPressed: () {

              deleteSalary(salary.id);

            },

          )

        ],

      ),

    );

  }

  Widget buildSavedSalaryWidget() {

    if (selectedViewMonth == null) {

      return Container(

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
          BorderRadius.circular(20),

        ),

        child: const Center(

          child: Text(
            "Select Month",
          ),

        ),

      );

    }

    if (filteredSalary.isEmpty) {

      return Container(

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
          BorderRadius.circular(20),

        ),

        child: const Center(

          child: Text(
            "No Salary Found",
          ),

        ),

      );

    }

    return Column(

      children:

      filteredSalary.map((salary) {

        return buildSalaryCard(salary);

      }).toList(),

    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Background(

        child: SafeArea(

          child: RefreshIndicator(

            onRefresh: loadSalary,

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

                  "Salary",

                  style: TextStyle(

                    fontSize: 34,

                    fontWeight:
                    FontWeight.w900,

                    color:
                    AppColors.primary,

                  ),

                ),

                const SizedBox(height: 20),

                TextField(

                  controller:
                  nameController,

                  decoration:
                  const InputDecoration(

                    labelText:
                    "Coach Name",

                    border:
                    OutlineInputBorder(),

                  ),

                ),

                const SizedBox(height: 20),

                ElevatedButton(

                  onPressed: () {

                    pickMonth(false);

                  },

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    AppColors.primary,

                    minimumSize:
                    const Size(
                        double.infinity,
                        55),

                  ),

                  child: const Text(

                    "Select Month",

                    style: TextStyle(
                      color: Colors.white,
                    ),

                  ),

                ),

                const SizedBox(height: 15),

                Text(

                  selectedMonth == null

                      ? "No Month Selected"

                      : monthText(
                    selectedMonth!,
                  ),

                  style: const TextStyle(

                    fontWeight:
                    FontWeight.bold,

                    color:
                    AppColors.primary,

                    fontSize: 18,

                  ),

                ),

                const SizedBox(height: 20),

                TextField(

                  controller:
                  amountController,

                  keyboardType:
                  TextInputType.number,

                  decoration:
                  const InputDecoration(

                    labelText:
                    "Salary Amount",

                    border:
                    OutlineInputBorder(),

                  ),

                ),

                const SizedBox(height: 25),

                ElevatedButton(

                  onPressed:
                  saveSalary,

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    AppColors.primary,

                    minimumSize:
                    const Size(
                        double.infinity,
                        55),

                  ),

                  child: const Text(

                    "Save Salary",

                    style: TextStyle(
                      color: Colors.white,
                    ),

                  ),

                ),

                const SizedBox(height: 45),

                const Text(

                  "Saved Salary",

                  style: TextStyle(

                    fontSize: 30,

                    fontWeight:
                    FontWeight.bold,

                    color:
                    AppColors.primary,

                  ),

                ),

                const SizedBox(height: 15),

                ElevatedButton(

                  onPressed: () {

                    pickMonth(true);

                  },

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    AppColors.primary,

                    minimumSize:
                    const Size(
                        double.infinity,
                        55),

                  ),

                  child: const Text(

                    "Select Month",

                    style: TextStyle(
                      color: Colors.white,
                    ),

                  ),

                ),

                const SizedBox(height: 15),

                Text(

                  selectedViewMonth == null

                      ? "No Month Selected"

                      : monthText(
                    selectedViewMonth!,
                  ),

                  style: const TextStyle(

                    fontWeight:
                    FontWeight.bold,

                    color:
                    AppColors.primary,

                    fontSize: 18,

                  ),

                ),

                const SizedBox(height: 20),

                buildSavedSalaryWidget(),

                const SizedBox(height: 80),

              ],

            ),

          ),

        ),

      ),

    );

  }
}