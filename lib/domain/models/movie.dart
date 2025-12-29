import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie.freezed.dart';
part 'movie.g.dart';

/// Movie model with immutable properties
@freezed
class Movie with _$Movie {
  const factory Movie({
    required String id,
    required String title,
    required String year,
    required String description,
    required String genre,
    required double rating,
    @Default('movie') String iconName,
  }) = _Movie;

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
}

/// Gets the icon data for a movie based on icon name
IconData getIconForMovie(String iconName) {
  switch (iconName) {
    case 'android':
      return Icons.android;
    case 'terminal':
      return Icons.terminal;
    case 'pets':
      return Icons.pets;
    case 'explore':
      return Icons.explore;
    case 'theater':
      return Icons.theater_comedy;
    case 'movie':
    default:
      return Icons.movie;
  }
}

/// Movie history entry with timestamp
@freezed
class MovieHistory with _$MovieHistory {
  const factory MovieHistory({
    required Movie movie,
    required DateTime timestamp,
  }) = _MovieHistory;

   factory MovieHistory.fromJson(Map<String, dynamic> json) => _$MovieHistoryFromJson(json);
}
