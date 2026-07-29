class CompetitionModel {
  final String id;
  final String date;
  final String player;
  final String group;
  final String event;
  final String result;

  CompetitionModel({
    required this.id,
    required this.date,
    required this.player,
    required this.group,
    required this.event,
    required this.result,
  });

  factory CompetitionModel.fromJson(Map<String, dynamic> json) {
    return CompetitionModel(
      id: json["ID"]?.toString() ?? "",
      date: json["Date"]?.toString() ?? "",
      player: json["Player Name"]?.toString() ?? "",
      group: json["Group"]?.toString() ?? "",
      event: json["Event"]?.toString() ?? "",
      result: json["Result"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ID": id,
      "Date": date,
      "Player Name": player,
      "Group": group,
      "Event": event,
      "Result": result,
    };
  }
}