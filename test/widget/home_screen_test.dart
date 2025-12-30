import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:movie_picker/ui/screens/home_screen.dart';
import 'package:movie_picker/data/repositories/storage_repository.dart';
import 'package:movie_picker/data/repositories/movie_repository.dart';
import 'package:movie_picker/core/services/haptic_service.dart';
import 'package:movie_picker/core/services/analytics_service.dart';
import 'package:movie_picker/domain/models/app_settings.dart';

@GenerateMocks([
  IStorageRepository,
  IMovieRepository,
  IHapticService,
  IAnalyticsService,
])
import 'home_screen_test.mocks.dart';

void main() {
  testWidgets('HomeScreen renders correctly', (tester) async {
    // Setup mocks
    final mockStorage = MockIStorageRepository();
    final mockMovie = MockIMovieRepository();
    final mockHaptic = MockIHapticService();
    final mockAnalytics = MockIAnalyticsService();

    // Configure mocks
    when(mockStorage.getSettings()).thenReturn(const AppSettings());
    when(mockStorage.getHistory()).thenReturn([]);
    when(mockMovie.getGenres()).thenReturn(['Sci-Fi', 'Action']);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageRepositoryProvider.overrideWithValue(mockStorage),
          movieRepositoryProvider.overrideWithValue(mockMovie),
          hapticServiceProvider.overrideWithValue(mockHaptic),
          analyticsServiceProvider.overrideWithValue(mockAnalytics),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Verify UI elements
    expect(find.text('CINE.PROTOCOL'), findsOneWidget);
    expect(find.text('SELECT GENRE'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNWidgets(2));
    expect(find.text('INITIATE PROTOCOL'), findsOneWidget);
  });
}
