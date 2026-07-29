class SalaryModel {
  final String id;
  final String month;
  final String name;
  final String amount;

  SalaryModel({
    required this.id,
    required this.month,
    required this.name,
    required this.amount,
  });

  factory SalaryModel.fromJson(Map<String, dynamic> json) {
    return SalaryModel(
      id: json["ID"]?.toString() ?? "",
      month: json["Month"]?.toString() ?? "",
      name: json["Name"]?.toString() ?? "",
      amount: json["Amount"]?.toString() ?? "",
    );
  }
}