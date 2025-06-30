class PlayerModel {
  final String name;
  final String shirtNumber;
  // final String position;
  // final String imageUrl;

  PlayerModel({
    required this.name,
    required this.shirtNumber,

    // required this.position,
    // required this.imageUrl,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      name: json['name'] ?? '',
      shirtNumber: json['shirtNumber'] ?? '',
      // position: json['position'] ?? '',
      // imageUrl: json['image']['styles']['sm'] ?? '',
    );
  }
}
