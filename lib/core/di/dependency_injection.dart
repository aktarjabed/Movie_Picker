import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/haptic_service.dart';
import '../services/analytics_service.dart';
import '../../data/repositories/storage_repository.dart';
import '../../data/repositories/movie_repository.dart';

/// Configures the dependency injection container
Future<ProviderContainer> configureDI() async {
  final container = ProviderContainer();

  // Initialize external dependencies
  final prefs = await SharedPreferences.getInstance();

  // Register services
  container.read(hapticServiceProvider).init();
  container.read(analyticsServiceProvider).init();

  // Override repository implementations
  container.updateOverrides([
    storageRepositoryProvider.overrideWithValue(StorageRepository(prefs)),
    movieRepositoryProvider.overrideWithValue(MovieRepository()),
  ]);

  return container;
}
