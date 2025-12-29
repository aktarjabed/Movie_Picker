import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/models/movie.dart';

abstract class IMovieRepository {
  List<String> getGenres();
  Movie pickMovie(String genre, List<String> excludeIds);
}

final movieRepositoryProvider = Provider<IMovieRepository>((ref) {
  return MovieRepository();
});

class MovieRepository implements IMovieRepository {
  static final _movieDatabase = <String, List<Movie>>{
    'Sci-Fi': [
      const Movie(
        id: 'scifi_001',
        title: 'Blade Runner 2049',
        year: '2017',
        description: 'A replicant uncovers a dangerous truth.',
        genre: 'Sci-Fi',
        rating: 8.0,
        iconName: 'android',
      ),
      const Movie(
        id: 'scifi_002',
        title: 'The Matrix',
        year: '1999',
        description: 'Reality is a simulation.',
        genre: 'Sci-Fi',
        rating: 8.7,
        iconName: 'terminal',
      ),
      const Movie(
        id: 'scifi_003',
        title: 'Interstellar',
        year: '2014',
        description: 'Journey beyond the stars.',
        genre: 'Sci-Fi',
        rating: 8.6,
        iconName: 'explore',
      ),
      const Movie(
        id: 'scifi_004',
        title: 'Arrival',
        year: '2016',
        description: 'Language bridges worlds.',
        genre: 'Sci-Fi',
        rating: 7.9,
        iconName: 'theater',
      ),
      const Movie(
        id: 'scifi_005',
        title: 'Dune',
        year: '2021',
        description: 'Desert planet destiny.',
        genre: 'Sci-Fi',
        rating: 8.0,
        iconName: 'explore',
      ),
    ],
    'Action': [
      const Movie(
        id: 'action_001',
        title: 'John Wick',
        year: '2014',
        description: 'Precision revenge.',
        genre: 'Action',
        rating: 7.4,
        iconName: 'pets',
      ),
      const Movie(
        id: 'action_002',
        title: 'Mad Max: Fury Road',
        year: '2015',
        description: 'Desert warfare unleashed.',
        genre: 'Action',
        rating: 8.1,
        iconName: 'explore',
      ),
      const Movie(
        id: 'action_003',
        title: 'The Dark Knight',
        year: '2008',
        description: 'Gotham\'s reckoning.',
        genre: 'Action',
        rating: 9.0,
        iconName: 'theater',
      ),
      const Movie(
        id: 'action_004',
        title: 'Die Hard',
        year: '1988',
        description: 'Tower siege.',
        genre: 'Action',
        rating: 8.2,
        iconName: 'movie',
      ),
    ],
    'Horror': [
      const Movie(
        id: 'horror_001',
        title: 'The Shining',
        year: '1980',
        description: 'Isolation drives madness.',
        genre: 'Horror',
        rating: 8.4,
        iconName: 'theater',
      ),
      const Movie(
        id: 'horror_002',
        title: 'Hereditary',
        year: '2018',
        description: 'Family trauma unleashed.',
        genre: 'Horror',
        rating: 7.3,
        iconName: 'movie',
      ),
    ],
  };

  @override
  List<String> getGenres() {
    final genres = _movieDatabase.keys.toList();
    AppLogger.d('Available genres: $genres');
    return genres;
  }

  @override
  Movie pickMovie(String genre, List<String> excludeIds) {
    try {
      final movies = _movieDatabase[genre];
      if (movies == null || movies.isEmpty) {
        throw Exception('No movies found for genre: $genre');
      }

      // Filter out excluded movies
      var available = movies.where((m) => !excludeIds.contains(m.id)).toList();

      // If all movies are excluded, reset the pool
      if (available.isEmpty) {
        AppLogger.w('All movies excluded, resetting pool for $genre');
        available = movies;
      }

      // Weighted random selection based on rating
      final weights = available.map((m) => (m.rating * 10).round()).toList();
      final totalWeight = weights.reduce((a, b) => a + b);

      var random = Random.secure().nextInt(totalWeight);
      Movie selected = available.last; // Default fallback

      for (var i = 0; i < available.length; i++) {
        random -= weights[i];
        if (random < 0) {
          selected = available[i];
          break;
        }
      }

      AppLogger.d('Picked movie: ${selected.title} (rating: ${selected.rating})');
      return selected;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to pick movie', e, stackTrace);
      rethrow;
    }
  }
}
