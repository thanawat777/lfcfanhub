import 'package:flutter/material.dart';

class NewsModel {
  final String title;
  final String url;
  final String image;
  // final String publishDate;

  NewsModel({
    required this.title,
    required this.url,
    required this.image,
    // required this.publishDate,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? '',
      url: "http://liverpoolfc.com${json['url']}",
      image: json['coverImage']['sizes']['xs']['url'] ?? '',
      // thumbnail: json['thumbnail'] ?? '',
      // publishDate: json['publishDate'] ?? '',
    );
  }
}
