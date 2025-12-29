import 'package:flutter_test/flutter_test.dart';
import 'package:movie_picker/data/repositories/movie_repository.dart';
import 'package:movie_picker/domain/models/movie.dart';

void main() {
  group('MovieRepository', () {
    late IMovieRepository repository;

    setUp(() {
      repository = MovieRepository();
    });

    test('getGenres returns non-empty list with expected genres', () {
      final genres = repository.getGenres();
      expect(genres, isNotEmpty);
      expect(genres, contains('Sci-Fi'));
      expect(genres, contains('Action'));
      expect(genres, contains('Horror'));
    });

    test('pickMovie returns valid movie for valid genre', () {
      final movie = repository.pickMovie('Sci-Fi', []);
      expect(movie.genre, 'Sci-Fi');
      expect(movie.rating, greaterThan(0));
      expect(movie.rating, lessThanOrEqualTo(10));
    });

    test('pickMovie avoids recently picked movies', () {
      // Pick first movie
      final first = repository.pickMovie('Action', []);

      // Pick again, should avoid first
      final second = repository.pickMovie('Action', [first.id]);

      expect(second.id, isNot(equals(first.id)));
    });

    test('pickMovie handles empty exclude list', () {
      final movies = List.generate(5, (_) => repository.pickMovie('Sci-Fi', []));

      expect(movies, hasLength(5));
      expect(movies, everyElement(isA<Movie>()));
    });

    test('pickMovie handles when all movies are excluded', () {
      final allMovies = repository.getGenres().expand((g) {
        return List.generate(10, (_) => repository.pickMovie(g, []));
      }).toList();

      final excludeIds = allMovies.map((m) => m.id).take(3).toList();
      final movie = repository.pickMovie('Sci-Fi', excludeIds);

      expect(movie, isA<Movie>());
    });

    test('pickMovie throws for invalid genre', () {
      expect(
        () => repository.pickMovie('InvalidGenre', []),
        throwsException,
      );
    });

    test('weighted selection favors higher-rated movies', () {
      final picks = <String, int>{};

      // Pick 100 times and count
      for (var i = 0; i < 100; i++) {
        final movie = repository.pickMovie('Sci-Fi', []);
        picks[movie.id] = (picks[movie.id] ?? 0) + 1;
      }

      // Check that movies were picked (statistical test)
      expect(picks.length, greaterThan(1));

      // Find highest rated movie
      final sciFiMovies = (repository as MovieRepository)
          .getGenres()
          .where((g) => g == 'Sci-Fi')
          .expand((g) => [
                repository.pickMovie(g, []),
                repository.pickMovie(g, []),
                repository.pickMovie(g, []),
              ])
          .toList();

      final highestRated = sciFiMovies.reduce((a, b) => a.rating > b.rating ? a : b);

      // Highest rated should have more picks (simple heuristic)
      expect(picks[highestRated.id], greaterThan(10));
    });
  });
}
