import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/app_logger.dart';

abstract class IHapticService {
  void init();
  void setEnabled(bool enabled);
  void light();
  void medium();
  void heavy();
  void selection();
  void success();
  void warning();
  void error();
}

final hapticServiceProvider = Provider<IHapticService>((ref) {
  return HapticService();
});

class HapticService implements IHapticService {
  bool _isInitialized = false;
  bool _isEnabled = true;

  @override
  void init() {
    _isInitialized = true;
    AppLogger.i('HapticService initialized');
  }

  @override
  void setEnabled(bool enabled) => _isEnabled = enabled;

  @override
  void light() => _trigger(HapticFeedback.lightImpact);

  @override
  void medium() => _trigger(HapticFeedback.mediumImpact);

  @override
  void heavy() => _trigger(HapticFeedback.heavyImpact);

  @override
  void selection() => _trigger(HapticFeedback.selectionClick);

  @override
  void success() => _trigger(HapticFeedback.lightImpact);

  @override
  void warning() => _trigger(HapticFeedback.mediumImpact);

  @override
  void error() => _trigger(HapticFeedback.heavyImpact);

  void _trigger(Function() feedback) {
    if (!_isInitialized || !_isEnabled) return;
    try {
      feedback();
    } catch (e, stackTrace) {
      AppLogger.w('Haptic feedback failed', e, stackTrace);
    }
  }
}
