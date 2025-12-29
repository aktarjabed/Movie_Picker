import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../logging/app_logger.dart';

/// Analytics service interface
abstract class IAnalyticsService {
  void init();
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]);
  Future<void> logScreenView(String screenName);
  Future<void> logMoviePick(String genre, String movieId, String movieTitle);
  Future<void> logSettingsChange(String setting, dynamic value);
}

/// Analytics service provider
final analyticsServiceProvider = Provider<IAnalyticsService>((ref) {
  return FirebaseAnalyticsService();
});

/// Firebase Analytics implementation
class FirebaseAnalyticsService implements IAnalyticsService {
  FirebaseAnalytics? _analytics;
  bool _isInitialized = false;

  @override
  void init() {
    try {
      _analytics = FirebaseAnalytics.instance;
      _isInitialized = true;
      AppLogger.i('AnalyticsService initialized');
    } catch (e, stackTrace) {
      AppLogger.w('Firebase Analytics initialization failed', e, stackTrace);
    }
  }

  @override
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _analytics!.logEvent(name: name, parameters: parameters);
    } catch (e, stackTrace) {
      AppLogger.w('Analytics event failed', e, stackTrace);
    }
  }

  @override
  Future<void> logScreenView(String screenName) async {
    await logEvent('screen_view', {'screen_name': screenName});
  }

  @override
  Future<void> logMoviePick(String genre, String movieId, String movieTitle) async {
    await logEvent('movie_pick', {
      'genre': genre,
      'movie_id': movieId,
      'movie_title': movieTitle,
    });
  }

  @override
  Future<void> logSettingsChange(String setting, dynamic value) async {
    await logEvent('settings_change', {
      'setting': setting,
      'value': value.toString(),
    });
  }
}
