class PlayerModel {
  final String name;
  final String shirtNumber;
  final String profilepicture;
  final String position;

  // final String position;
  // final String imageUrl;

  PlayerModel({
    required this.name,
    required this.shirtNumber,
    required this.profilepicture,
    required this.position,

    // required this.position,
    // required this.imageUrl,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      name: json['name'] ?? '',
      shirtNumber: json['shirtNumber']?.toString() ?? '',
      profilepicture: json['profileImage']['sizes']['xl']['url'] ?? '',
      position: json['position']['type'] ?? '',
      // position: json['position'] ?? '',
      // imageUrl: json['image']['styles']['sm'] ?? '',
    );
  }
}
