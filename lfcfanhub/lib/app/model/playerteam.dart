class PlayerModel {
  final String name;
  final String shirtNumber;
  final String profilepicture;
  final String position;

  final String dateOfBirth;
  final String bio;
  final String placeOfBirth;
  final String nationality;
  final List<String> honors;
  // final String position;
  // final String imageUrl;

  PlayerModel({
    required this.name,
    required this.shirtNumber,
    required this.profilepicture,
    required this.position,

    required this.dateOfBirth,
    required this.bio,
    required this.placeOfBirth,
    required this.nationality,
    required this.honors,
    // required this.position,
    // required this.imageUrl,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      name: json['name'] ?? '',
      shirtNumber: json['shirtNumber']?.toString() ?? '',
      profilepicture: json['profileImage']['sizes']['xl']['url'] ?? '',
      position: json['position']['type'] ?? '',

      dateOfBirth: json['dateOfBirth'] ?? "",
      bio: json['bio'] ?? "",
      placeOfBirth: json['placeOfBirth'] ?? "",
      nationality: json['nationality'] ?? "",
      honors: List<String>.from(json['honors'] ?? []),
      // position: json['position'] ?? '',
      // imageUrl: json['image']['styles']['sm'] ?? '',
    );
  }
}
