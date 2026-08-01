import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../widgets/app_back_button.dart';

class PlayerFeesScreen extends StatefulWidget {
  final String playerName;
  final String playerEmail;
  final String group;

  const PlayerFeesScreen({
    super.key,
    this.playerName = "",
    this.playerEmail = "",
    this.group = "",
  });

  @override
  State<PlayerFeesScreen> createState() => _PlayerFeesScreenState();
}

class _PlayerFeesScreenState extends State<PlayerFeesScreen> {
  final TextEditingController monthlyFeeController =
  TextEditingController();

  final TextEditingController amountController =
  TextEditingController();

  final List<String> selectedMonths = [];

  final List<String> allMonths = [
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

  bool isLoading = false;

  // Empty initially.
  // Saved data will only be displayed after selecting a month.
  String selectedViewMonth = "";

  List<Map<String, dynamic>> feeRecords = [];

  final String url =
      "https://script.google.com/macros/s/AKfycbx_6czLjzqVvXDyCjfS69XuqPSTtugZhWpF6p1md9Pb-AioWmF9mRcLnkWajeO9UdzumQ/exec";

  @override
  void initState() {
    super.initState();

    // IMPORTANT:
    // Do NOT load fees when the page opens.
    // User must select a month first.
  }

  @override
  void dispose() {
    monthlyFeeController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F1EB),

      // No AppBar, to keep the decorative background unbroken.
      // The back arrow is the AppBackButton at the top of the content.

      body: Stack(
        children: [
          // ---------------------------------------------------------
          // TOP RIGHT PURPLE CIRCLE
          // ---------------------------------------------------------

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

          // ---------------------------------------------------------
          // BOTTOM LEFT PEACH CIRCLE
          // ---------------------------------------------------------

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

          SafeArea(
            child: RefreshIndicator(
              onRefresh: selectedViewMonth.isEmpty
                  ? () async {}
                  : _loadFees,

              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppBackButton(),

                    // ------------------------------------------------
                    // TITLE
                    // ------------------------------------------------

                    const Text(
                      "Fees",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff312C51),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Manage your fee records",
                      style: TextStyle(
                        color: Color(0xff48426D),
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ------------------------------------------------
                    // MONTHLY FEE
                    // ------------------------------------------------

                    TextField(
                      controller: monthlyFeeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Monthly Fee",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ------------------------------------------------
                    // ENTER AMOUNT
                    // ------------------------------------------------

                    TextField(
                      controller: amountController,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter Amount",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ------------------------------------------------
                    // SELECT MONTHS TO SAVE
                    // ------------------------------------------------

                    _button(
                      text: "Select Months",
                      onPressed: _selectMonth,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      selectedMonths.isEmpty
                          ? "No Months Selected"
                          : selectedMonths.join(", "),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff48426D),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ------------------------------------------------
                    // SAVE FEES
                    // ------------------------------------------------

                    _button(
                      text: "Save Fees",
                      onPressed: _saveFees,
                    ),

                    const SizedBox(height: 35),

                    // ------------------------------------------------
                    // VIEW SAVED FEES
                    // ------------------------------------------------

                    const Text(
                      "View Saved Fees",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff312C51),
                      ),
                    ),

                    const SizedBox(height: 15),

                    _button(
                      text: "Select Month",
                      onPressed: _selectViewMonth,
                    ),

                    // ------------------------------------------------
                    // IMPORTANT:
                    // Nothing below this point is displayed until
                    // the user selects a month.
                    // ------------------------------------------------

                    if (selectedViewMonth.isNotEmpty) ...[
                      const SizedBox(height: 12),

                      Text(
                        selectedViewMonth,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff48426D),
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 25),

                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        ),

                      if (!isLoading && feeRecords.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              "No Data Found",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                      if (!isLoading)
                        ...feeRecords.map(
                              (record) => _feeCard(record),
                        ),
                    ],

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

  // ---------------------------------------------------------
  // COMMON BUTTON
  // ---------------------------------------------------------

  Widget _button({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff48426D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // SELECT MONTHS TO SAVE
  // ---------------------------------------------------------

  Future<void> _selectMonth() async {
    final yearController = TextEditingController(
      text: DateTime.now().year.toString(),
    );

    String selectedMonth = allMonths.first;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Month"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Year",
                    ),
                  ),

                  const SizedBox(height: 15),

                  DropdownButton<String>(
                    value: selectedMonth,
                    isExpanded: true,
                    items: allMonths.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(month),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedMonth = value;
                        });
                      }
                    },
                  ),
                ],
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
                    final year =
                    yearController.text.trim();

                    if (year.isEmpty) {
                      return;
                    }

                    final value =
                        "$selectedMonth $year";

                    if (!selectedMonths.contains(value)) {
                      setState(() {
                        selectedMonths.add(value);
                      });
                    }

                    Navigator.pop(context);
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );

    yearController.dispose();
  }

  // ---------------------------------------------------------
  // SELECT MONTH TO VIEW
  // ---------------------------------------------------------

  Future<void> _selectViewMonth() async {
    final yearController = TextEditingController(
      text: DateTime.now().year.toString(),
    );

    String selectedMonth = allMonths.first;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Month"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Year",
                    ),
                  ),

                  const SizedBox(height: 15),

                  DropdownButton<String>(
                    value: selectedMonth,
                    isExpanded: true,
                    items: allMonths.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(month),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedMonth = value;
                        });
                      }
                    },
                  ),
                ],
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
                    final year =
                    yearController.text.trim();

                    if (year.isEmpty) {
                      return;
                    }

                    setState(() {
                      selectedViewMonth =
                      "$selectedMonth $year";

                      // Clear old results before loading
                      // the newly selected month.
                      feeRecords.clear();
                    });

                    Navigator.pop(context);

                    _loadFees();
                  },
                  child: const Text("Search"),
                ),
              ],
            );
          },
        );
      },
    );

    yearController.dispose();
  }

  // ---------------------------------------------------------
  // CONVERT "July 2026" → "2026-07"
  // ---------------------------------------------------------

  String _convertMonthToDatabase(
      String monthText,
      ) {
    final parts = monthText.split(" ");

    final monthName = parts[0];
    final year = parts[1];

    String monthNumber = "01";

    switch (monthName) {
      case "January":
        monthNumber = "01";
        break;
      case "February":
        monthNumber = "02";
        break;
      case "March":
        monthNumber = "03";
        break;
      case "April":
        monthNumber = "04";
        break;
      case "May":
        monthNumber = "05";
        break;
      case "June":
        monthNumber = "06";
        break;
      case "July":
        monthNumber = "07";
        break;
      case "August":
        monthNumber = "08";
        break;
      case "September":
        monthNumber = "09";
        break;
      case "October":
        monthNumber = "10";
        break;
      case "November":
        monthNumber = "11";
        break;
      case "December":
        monthNumber = "12";
        break;
    }

    return "$year-$monthNumber";
  }

  // ---------------------------------------------------------
  // SAVE FEES TO GOOGLE SHEETS
  // ---------------------------------------------------------

  Future<void> _saveFees() async {
    if (monthlyFeeController.text.trim().isEmpty) {
      _showMessage("Enter Monthly Fee");
      return;
    }

    if (amountController.text.trim().isEmpty) {
      _showMessage("Enter Amount");
      return;
    }

    if (selectedMonths.isEmpty) {
      _showMessage("Select Month");
      return;
    }

    final double? monthlyFee =
    double.tryParse(
      monthlyFeeController.text.trim(),
    );

    final double? totalAmount =
    double.tryParse(
      amountController.text.trim(),
    );

    if (monthlyFee == null || monthlyFee <= 0) {
      _showMessage("Enter a valid Monthly Fee");
      return;
    }

    if (totalAmount == null || totalAmount <= 0) {
      _showMessage("Enter a valid Amount");
      return;
    }

    // ---------------------------------------------------------
    // CALCULATE AMOUNT FOR EACH MONTH
    // ---------------------------------------------------------
    //
    // Example:
    //
    // Monthly Fee = ₹1000
    // Enter Amount = ₹2000
    // Selected Months = 2
    //
    // 2000 / 2 = ₹1000 per month
    //
    // Each month's database record gets ₹1000.
    //
    // ---------------------------------------------------------

    final double paidAmountPerMonth =
        totalAmount / selectedMonths.length;

    setState(() {
      isLoading = true;
    });

    try {
      for (final month in selectedMonths) {
        final dbMonth =
        _convertMonthToDatabase(month);

        final response = await http.post(
          Uri.parse(url),
          body: {
            "type": "saveFees",
            "month": dbMonth,

            "monthlyFee":
            monthlyFee.toStringAsFixed(2),

            // IMPORTANT:
            // Save per-month amount, not total amount.
            "amount":
            paidAmountPerMonth.toStringAsFixed(2),

            "status": "Paid",

            "player": widget.playerName,

            "email":
            widget.playerEmail
                .trim()
                .toLowerCase(),

            "group": widget.group,
          },
        );

        debugPrint(
          "Save fees response: ${response.statusCode}",
        );

        debugPrint(response.body);
      }

      monthlyFeeController.clear();
      amountController.clear();

      setState(() {
        selectedMonths.clear();

        // Do not automatically show saved data.
        feeRecords.clear();
        selectedViewMonth = "";
      });

      if (mounted) {
        _showMessage(
          "Fees Saved Successfully",
        );
      }
    } catch (e) {
      debugPrint(
        "Save fees error: $e",
      );

      if (mounted) {
        _showMessage(
          "Network error. Please try again.",
        );
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ---------------------------------------------------------
  // LOAD FEES FROM GOOGLE SHEETS
  // ---------------------------------------------------------

  Future<void> _loadFees() async {
    // Don't load anything until a month is selected.
    if (selectedViewMonth.isEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        isLoading = true;
        feeRecords.clear();
      });
    }

    try {
      final response = await http.get(
        Uri.parse("$url?fees=true"),
      );

      if (response.statusCode != 200) {
        throw Exception("HTTP ${response.statusCode}");
      }

      final List<dynamic> data = jsonDecode(response.body);

      final List<Map<String, dynamic>> records = [];

      final selectedDbMonth =
      _convertMonthToDatabase(selectedViewMonth);

      final playerEmail =
      widget.playerEmail.trim().toLowerCase();

      final playerName =
      widget.playerName.trim().toLowerCase();

      for (final item in data) {
        final record = Map<String, dynamic>.from(item);

        final email =
        (record["email"] ?? "")
            .toString()
            .trim()
            .toLowerCase();

        final name =
        (record["player"] ?? "")
            .toString()
            .trim()
            .toLowerCase();

        final dbMonth =
        (record["month"] ?? "")
            .toString()
            .trim();

        // ---------------------------------------------------------
        // CHECK PLAYER
        // ---------------------------------------------------------

        final bool isThisPlayer =
            (playerEmail.isNotEmpty && email == playerEmail) ||
                (playerName.isNotEmpty && name == playerName);

        if (!isThisPlayer) {
          continue;
        }

        // ---------------------------------------------------------
        // CHECK SELECTED MONTH
        // ---------------------------------------------------------

        if (dbMonth != selectedDbMonth) {
          continue;
        }

        records.add(record);
      }

      // ---------------------------------------------------------
      // PLAYER HAS NO RECORD FOR THIS MONTH
      // ---------------------------------------------------------

      if (records.isEmpty) {
        records.add({
          "month": selectedDbMonth,
          "status": "Pending",
        });
      }

      if (mounted) {
        setState(() {
          feeRecords = records;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Load fees error: $e");

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        _showMessage("Unable to load fees");
      }
    }
  }

  // ---------------------------------------------------------
  // FEE CARD
  // ---------------------------------------------------------

  Widget _feeCard(
      Map<String, dynamic> record,
      ) {
    final String dbMonth =
    (record["month"] ?? "").toString();

    final String displayMonth =
    _databaseMonthToDisplay(dbMonth);

    final String monthlyFee =
    (record["monthlyFee"] ?? "").toString();

    final String paidAmount =
    (record["amount"] ?? "").toString();

    final String status =
    (record["status"] ?? "").toString();

    final bool isPaid =
        status.trim().toLowerCase() == "paid";

    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(
        bottom: 15,
      ),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // -------------------------------------------------------
          // MONTH + YEAR
          // -------------------------------------------------------

          Text(
            displayMonth,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xff312C51),
            ),
          ),

          const SizedBox(height: 10),

          // -------------------------------------------------------
          // ONLY SHOW AMOUNTS IF PAID
          // -------------------------------------------------------

          if (isPaid) ...[
            Text(
              "Monthly Fee : ₹$monthlyFee",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Paid Amount : ₹$paidAmount",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 6),
          ],

          // -------------------------------------------------------
          // STATUS
          // -------------------------------------------------------

          Text(
            "Status : ${isPaid ? "Paid" : "Pending"}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPaid
                  ? Colors.green
                  : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // DATABASE MONTH → DISPLAY MONTH
  // ---------------------------------------------------------

  String _databaseMonthToDisplay(
      String dbMonth,
      ) {
    final parts =
    dbMonth.split("-");

    if (parts.length != 2) {
      return dbMonth;
    }

    final year = parts[0];

    final monthNumber =
        int.tryParse(parts[1]) ?? 0;

    if (monthNumber < 1 ||
        monthNumber > 12) {
      return dbMonth;
    }

    return "${allMonths[monthNumber - 1]} $year";
  }

  // ---------------------------------------------------------
  // MESSAGE
  // ---------------------------------------------------------

  void _showMessage(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}