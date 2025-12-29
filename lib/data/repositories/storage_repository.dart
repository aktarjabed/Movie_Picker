import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/movie.dart';

abstract class IStorageRepository {
  AppSettings getSettings();
  Future<void> saveSettings(AppSettings settings);
  List<MovieHistory> getHistory();
  Future<void> addToHistory(MovieHistory entry);
  Future<void> clearHistory();
}

final storageRepositoryProvider = Provider<IStorageRepository>((ref) {
  throw UnimplementedError('StorageRepository must be overridden in main.dart');
});

class StorageRepository implements IStorageRepository {
  StorageRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _keySettings = 'app_settings';
  static const _keyHistory = 'movie_history';
  static const _maxHistorySize = 50;

  @override
  AppSettings getSettings() {
    try {
      final json = _prefs.getString(_keySettings);
      if (json == null) return const AppSettings();

      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return AppSettings.fromJson(decoded);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to load settings', e, stackTrace);
      return const AppSettings();
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    try {
      final encoded = jsonEncode(settings.toJson());
      await _prefs.setString(_keySettings, encoded);
      AppLogger.d('Settings saved: ${settings.toJson()}');
    } catch (e, stackTrace) {
      AppLogger.e('Failed to save settings', e, stackTrace);
      throw Exception('Storage error: $e');
    }
  }

  @override
  List<MovieHistory> getHistory() {
    try {
      final json = _prefs.getString(_keyHistory);
      if (json == null) return [];

      final list = jsonDecode(json) as List;
      return list
          .map((e) => MovieHistory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e('Failed to load history', e, stackTrace);
      return [];
    }
  }

  @override
  Future<void> addToHistory(MovieHistory entry) async {
    try {
      final history = getHistory();
      history.insert(0, entry);

      final trimmed = history.take(_maxHistorySize).toList();
      final encoded = jsonEncode(trimmed.map((e) => e.toJson()).toList());

      await _prefs.setString(_keyHistory, encoded);
      AppLogger.d('History updated: ${entry.movie.title}');
    } catch (e, stackTrace) {
      AppLogger.e('Failed to add to history', e, stackTrace);
      throw Exception('Storage error: $e');
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await _prefs.remove(_keyHistory);
      AppLogger.i('History cleared');
    } catch (e, stackTrace) {
      AppLogger.e('Failed to clear history', e, stackTrace);
      throw Exception('Storage error: $e');
    }
  }
}
