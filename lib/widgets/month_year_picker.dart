import 'package:flutter/material.dart';

Future<DateTime?> showMonthYearPicker(BuildContext context) async {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  return await showDialog<DateTime>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Select Month"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                DropdownButton<int>(
                  value: selectedMonth,
                  isExpanded: true,
                  items: List.generate(
                    12,
                        (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text(
                        [
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
                          "December"
                        ][index],
                      ),
                    ),
                  ),
                  onChanged: (v) {
                    setState(() {
                      selectedMonth = v!;
                    });
                  },
                ),

                const SizedBox(height: 20),

                DropdownButton<int>(
                  value: selectedYear,
                  isExpanded: true,
                  items: List.generate(
                    10,
                        (index) {
                      int year = 2024 + index;

                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    },
                  ),
                  onChanged: (v) {
                    setState(() {
                      selectedYear = v!;
                    });
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
              Navigator.pop(
                context,
                DateTime(selectedYear, selectedMonth),
              );
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}