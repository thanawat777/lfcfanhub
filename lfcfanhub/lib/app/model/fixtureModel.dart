import 'package:flutter/material.dart';

class FixtureModel {
  final int id;
  final String title;
  final DateTime date;
  final String stadium;
  final String homeTeam;
  final String awayTeam;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final String competitionName;
  final String competitionLogo;

  FixtureModel({
    required this.id,
    required this.title,
    required this.date,
    required this.stadium,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeTeamLogo,
    required this.awayTeamLogo,
    required this.competitionName,
    required this.competitionLogo,
  });

  factory FixtureModel.fromJson(Map<String, dynamic> json) {
    final match = json['matchData'];
    return FixtureModel(
      id: json['id'] ?? '',
      title: match['title'] ?? '',
      date: DateTime.parse(match['date']),
      stadium: match['stadium'] ?? '',
      homeTeam: match['homeTeam'] ?? '',
      awayTeam: match['awayTeam'] ?? '',
      homeTeamLogo: match['homeTeamLogo']['sizes']['sm']['url'] ?? '',
      awayTeamLogo: match['awayTeamLogo']['sizes']['sm']['url'] ?? '',
      competitionName: match['competition']['displayName'] ?? '',
      competitionLogo: match['competition']['logo']['sizes']['sm']['url'] ?? '',
    );
  }
}
