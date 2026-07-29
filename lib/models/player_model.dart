class PlayerModel {
  final String id;
  final String name;
  final String email;
  final String group;
  final Map<String, dynamic> rawData;

  PlayerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.group,
    required this.rawData,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json["ID"]?.toString() ?? "",
      name: json["Players full name"]?.toString() ?? "",
      email: json["Email Address"]?.toString() ?? "",
      group:
      json["Select which group you represent. "]?.toString().trim() ?? "",
      rawData: json,
    );
  }
}