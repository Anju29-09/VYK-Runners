class FeeModel {
  final String id;
  final String player;
  final String email;
  final String group;
  final String month;
  final String monthlyFee;
  final String amount;
  final String status;

  FeeModel({
    required this.id,
    required this.player,
    required this.email,
    required this.group,
    required this.month,
    required this.monthlyFee,
    required this.amount,
    required this.status,
  });

  factory FeeModel.fromJson(Map<String,dynamic> json){

    return FeeModel(

      id: json["id"] ?? "",

      player: json["player"] ??
          json["Player Name"] ??
          "",

      email: json["email"] ?? "",

      group: json["group"] ??
          json["Group"] ??
          "",

      month: json["month"] ?? "",

      monthlyFee: json["monthlyFee"] ?? "0",

      amount: json["amount"] ?? "0",

      status: json["status"] ?? "Pending",

    );

  }

}