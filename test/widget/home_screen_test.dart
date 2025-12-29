import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:movie_picker/ui/screens/home_screen.dart';
import 'package:movie_picker/data/repositories/storage_repository.dart';
import 'package:movie_picker/data/repositories/movie_repository.dart';
import 'package:movie_picker/core/services/haptic_service.dart';
import 'package:movie_picker/core/services/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_picker/domain/models/app_settings.dart';

class MockStorageRepository extends Mock implements IStorageRepository {}
class MockMovieRepository extends Mock implements IMovieRepository {}
class MockHapticService extends Mock implements IHapticService {}
class MockAnalyticsService extends Mock implements IAnalyticsService {}

void main() {
  testWidgets('HomeScreen renders correctly', (tester) async {
    // Setup mocks
    final mockStorage = MockStorageRepository();
    final mockMovie = MockMovieRepository();
    final mockHaptic = MockHapticService();
    final mockAnalytics = MockAnalyticsService();

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
