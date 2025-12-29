import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/logging/app_logger.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/haptic_service.dart';
import '../../data/repositories/storage_repository.dart';
import '../../domain/models/app_settings.dart';

part 'settings_view_model.g.dart';

/// Settings ViewModel with state management
@riverpod
class SettingsViewModel extends _$SettingsViewModel {
  @override
  AppSettings build() {
    final storage = ref.read(storageRepositoryProvider);
    final settings = storage.getSettings();
    AppLogger.d('Settings loaded: ${settings.toJson()}');
    return settings;
  }

  /// Toggle haptic feedback setting
  Future<void> toggleHaptics(bool enabled) async {
    try {
      final newSettings = state.copyWith(hapticsEnabled: enabled);
      state = newSettings;

      final storage = ref.read(storageRepositoryProvider);
      await storage.saveSettings(newSettings);

      // Update haptic service
      ref.read(hapticServiceProvider).setEnabled(enabled);

      // Log analytics
      ref.read(analyticsServiceProvider).logSettingsChange('haptics', enabled);

      AppLogger.i('Haptics setting changed: $enabled');
    } catch (e, stackTrace) {
      AppLogger.e('Failed to toggle haptics', e, stackTrace);
      throw Exception('Settings update failed: $e');
    }
  }

  /// Toggle auto-play setting
  Future<void> toggleAutoPlay(bool enabled) async {
    try {
      final newSettings = state.copyWith(autoPlayEnabled: enabled);
      state = newSettings;

      final storage = ref.read(storageRepositoryProvider);
      await storage.saveSettings(newSettings);

      // Log analytics
      ref.read(analyticsServiceProvider).logSettingsChange('auto_play', enabled);

      AppLogger.i('Auto-play setting changed: $enabled');
    } catch (e, stackTrace) {
      AppLogger.e('Failed to toggle auto-play', e, stackTrace);
      throw Exception('Settings update failed: $e');
    }
  }

  /// Get haptic service state
  bool get isHapticEnabled => state.hapticsEnabled;
  bool get isAutoPlayEnabled => state.autoPlayEnabled;
}
