class PlayerModel {
  final String name;
  final String shirtNumber;
  final String profilepicture;
  final String position;
  final String url;
  // final String position;
  // final String imageUrl;

  PlayerModel({
    required this.name,
    required this.shirtNumber,
    required this.profilepicture,
    required this.position,
    required this.url,
    // required this.position,
    // required this.imageUrl,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      name: json['name'] ?? '',
      shirtNumber: json['shirtNumber']?.toString() ?? '',
      profilepicture: json['profileImage']['sizes']['xl']['url'] ?? '',
      position: json['position']['type'] ?? '',
      url: "https://liverpoolfc.com${json['url']}",
      // position: json['position'] ?? '',
      // imageUrl: json['image']['styles']['sm'] ?? '',
    );
  }
}
