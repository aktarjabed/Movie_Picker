import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/movie.dart';
import '../view_models/movie_view_model.dart';
import '../view_models/settings_view_model.dart';
import '../widgets/movie_card.dart';
import '../widgets/settings_drawer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieState = ref.watch(movieViewModelProvider);
    final genres = ref.read(movieRepositoryProvider).getGenres();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CINE.PROTOCOL'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      drawer: const SettingsDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.read(movieViewModelProvider.notifier).reset();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildGenreSelector(context, ref, genres, movieState),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildActionButton(context, ref, movieState),
                  if (movieState.error != null) _buildErrorBanner(context, movieState),
                  const SizedBox(height: AppSpacing.xxl),
                  if (movieState.currentMovie != null)
                    _buildMovieResult(context, movieState.currentMovie!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT GENRE',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: AppAnimation.normal),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Choose your cinematic adventure',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textDim,
          ),
        ).animate().fadeIn(delay: 100.ms, duration: AppAnimation.normal),
      ],
    );
  }

  Widget _buildGenreSelector(
    BuildContext context,
    WidgetRef ref,
    List<String> genres,
    MovieState movieState,
  ) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: genres.map((genre) {
        final isSelected = movieState.selectedGenre == genre;
        return ChoiceChip(
          label: Text(genre),
          selected: isSelected,
          onSelected: (_) {
            ref.read(movieViewModelProvider.notifier).selectGenre(genre);
          },
          avatar: isSelected
              ? const Icon(Icons.check, size: 18)
              : Icon(Icons.movie, size: 18, color: AppColors.textDim),
        ).animate().scale(
          duration: AppAnimation.fast,
          curve: Curves.easeOut,
        );
      }).toList(),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, MovieState state) {
    return ElevatedButton.icon(
      onPressed: state.isLoading || state.selectedGenre == null
          ? null
          : () => ref.read(movieViewModelProvider.notifier).pickMovie(),
      icon: state.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
              ),
            )
          : const Icon(Icons.play_arrow),
      label: Text(
        state.isLoading ? 'PROCESSING...' : 'INITIATE PROTOCOL',
        style: const TextStyle(
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slide(
      begin: const Offset(0, 0.2),
      curve: Curves.easeOut,
    );
  }

  Widget _buildErrorBanner(BuildContext context, MovieState state) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          border: Border.all(color: AppColors.error),
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                state.error!,
                style: TextStyle(color: AppColors.error),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: AppColors.error),
              onPressed: () {
                // Clear error state
              },
            ),
          ],
        ),
      ).animate().fadeIn(duration: AppAnimation.fast),
    );
  }

  Widget _buildMovieResult(BuildContext context, Movie movie) {
    return MovieCard(movie: movie)
        .animate()
        .fadeIn(duration: AppAnimation.slow)
        .scale(
          delay: 100.ms,
          curve: Curves.easeOut,
        )
        .move(
          begin: const Offset(0, 20),
          curve: Curves.easeOut,
        );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('CINE.PROTOCOL'),
        content: const Text(
          'A production-ready movie picker demonstrating modern Flutter architecture.\n\n'
          'Features:\n'
          '• Weighted random selection\n'
          '• Smart history management\n'
          '• Haptic feedback\n'
          '• Auto-play mode\n'
          '• Firebase Analytics\n'
          '• Clean architecture',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('DISMISS'),
          ),
        ],
      ),
    );
  }
}
