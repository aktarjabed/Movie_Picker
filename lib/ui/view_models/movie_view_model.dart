import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/logging/app_logger.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/analytics_service.dart';
import '../../data/repositories/movie_repository.dart';
import '../../data/repositories/storage_repository.dart';
import '../../domain/models/movie.dart';
import 'settings_view_model.dart';

part 'movie_view_model.g.dart';

/// Movie state with proper immutability
@immutable
class MovieState {
  final String? selectedGenre;
  final Movie? currentMovie;
  final List<MovieHistory> history;
  final bool isLoading;
  final String? error;

  const MovieState({
    this.selectedGenre,
    this.currentMovie,
    this.history = const [],
    this.isLoading = false,
    this.error,
  });

  MovieState copyWith({
    String? selectedGenre,
    Movie? currentMovie,
    List<MovieHistory>? history,
    bool? isLoading,
    String? error,
  }) {
    return MovieState(
      selectedGenre: selectedGenre ?? this.selectedGenre,
      currentMovie: currentMovie ?? this.currentMovie,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'MovieState(genre: $selectedGenre, movie: ${currentMovie?.title}, history: ${history.length}, loading: $isLoading)';
  }
}

/// Movie ViewModel with AsyncNotifier (Riverpod 3.0)
@riverpod
class MovieViewModel extends _$MovieViewModel {
  @override
  MovieState build() {
    final storage = ref.read(storageRepositoryProvider);
    final history = storage.getHistory();
    AppLogger.d('MovieViewModel initialized with ${history.length} history items');
    return MovieState(history: history);
  }

  /// Select a genre and trigger auto-pick if enabled
  void selectGenre(String genre) {
    AppLogger.d('Genre selected: $genre');

    state = state.copyWith(
      selectedGenre: genre,
      currentMovie: null,
      error: null,
    );

    final settings = ref.read(settingsViewModelProvider);
    if (settings.autoPlayEnabled) {
      AppLogger.d('Auto-play triggered for $genre');
      pickMovie();
    }
  }

  /// Pick a movie based on selected genre with error handling
  Future<void> pickMovie() async {
    final genre = state.selectedGenre;
    if (genre == null) {
      AppLogger.w('Pick attempted without genre selection');
      state = state.copyWith(error: 'Please select a genre first');
      return;
    }

    // Trigger haptic feedback
    ref.read(hapticServiceProvider).medium();

    // Set loading state
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Add slight delay for better UX
      await Future.delayed(const Duration(milliseconds: 300));

      // Get recent movie IDs to avoid repeats
      final recentIds = state.history.take(3).map((h) => h.movie.id).toList();
      AppLogger.d('Excluding recent IDs: $recentIds');

      // Pick movie from repository
      final movieRepo = ref.read(movieRepositoryProvider);
      final movie = movieRepo.pickMovie(genre, recentIds);

      // Create history entry
      final entry = MovieHistory(
        movie: movie,
        timestamp: DateTime.now(),
      );

      // Save to storage
      final storage = ref.read(storageRepositoryProvider);
      await storage.addToHistory(entry);

      // Log analytics
      ref.read(analyticsServiceProvider).logMoviePick(genre, movie.id, movie.title);

      // Update state
      state = state.copyWith(
        currentMovie: movie,
        history: storage.getHistory(),
        isLoading: false,
      );

      AppLogger.i('Movie picked: ${movie.title}');
    } catch (e, stackTrace) {
      AppLogger.e('Movie pick failed', e, stackTrace);

      // Log analytics for error
      ref.read(analyticsServiceProvider).logEvent('movie_pick_error', {
        'error': e.toString(),
        'genre': genre,
      });

      // Update error state
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to pick movie: ${e.toString()}',
      );
    }
  }

  /// Clear movie history
  Future<void> clearHistory() async {
    try {
      final storage = ref.read(storageRepositoryProvider);
      await storage.clearHistory();

      state = state.copyWith(history: []);
      AppLogger.i('History cleared');

      // Log analytics
      ref.read(analyticsServiceProvider).logEvent('history_cleared');
    } catch (e, stackTrace) {
      AppLogger.e('Failed to clear history', e, stackTrace);
      state = state.copyWith(error: 'Failed to clear history: $e');
    }
  }

  /// Reset current selection
  void reset() {
    state = MovieState(history: state.history);
    AppLogger.d('Movie selection reset');
  }
}
