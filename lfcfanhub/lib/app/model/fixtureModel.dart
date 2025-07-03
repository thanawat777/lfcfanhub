class FixtureModel {
  final int id;
  final String title;
  final String homeTeam;
  final String awayTeam;
  final String premier;
  // final DateTime date;
  final String stadium;
  // final String homeTeam;
  // final String awayTeam;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final DateTime date;
  bool favorite;
  // final String competitionName;
  // final String competitionLogo;

  FixtureModel({
    required this.id,
    required this.title,
    required this.homeTeam,
    required this.awayTeam,
    required this.premier,
    required this.date,
    required this.stadium,
    required this.homeTeamLogo,
    required this.awayTeamLogo,
    required this.favorite,
    // required this.competitionName,
    // required this.competitionLogo,
  });

  factory FixtureModel.fromJson(Map<String, dynamic> json) {
    final match = json['matchData'] ?? {};

    return FixtureModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      homeTeam: match['homeTeam'] ?? '',
      awayTeam: match['awayTeam'] ?? '',
      premier: match['competition']['shortName'] ?? '',
      homeTeamLogo: match['homeTeamLogo']?['sizes']?['sm']?['url'] ?? '',
      awayTeamLogo: match['awayTeamLogo']?['sizes']?['sm']?['url'] ?? '',
      date: DateTime.parse(match['date'] ?? DateTime.now().toString()),
      stadium: match['stadium'] ?? '',
      favorite: false,
    );
  }
}

    // final match = json['matchData'] ?? {};

    // String extractLogo(Map? data) {
    //   return data?['sizes']?['sm']?['url'] ?? '';
    // }

    // return FixtureModel(
    //   id: match['id'] ?? 0,
    //   title: match['title'] ?? '',
  

