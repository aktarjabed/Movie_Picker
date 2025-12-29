import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_picker/data/repositories/storage_repository.dart';
import 'package:movie_picker/domain/models/app_settings.dart';

@GenerateMocks([SharedPreferences])
import 'storage_repository_test.mocks.dart';

void main() {
  group('StorageRepository', () {
    late MockSharedPreferences mockPrefs;
    late StorageRepository repository;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      repository = StorageRepository(mockPrefs);
    });

    test('getSettings returns default when no data', () {
      when(mockPrefs.getString('app_settings')).thenReturn(null);

      final settings = repository.getSettings();

      expect(settings.hapticsEnabled, true);
      expect(settings.autoPlayEnabled, false);
    });

    test('saveSettings stores data correctly', () async {
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

      const settings = AppSettings(hapticsEnabled: false, autoPlayEnabled: true);
      await repository.saveSettings(settings);

      verify(mockPrefs.setString('app_settings', any)).called(1);
    });

    test('getHistory returns empty list when no data', () {
      when(mockPrefs.getString('movie_history')).thenReturn(null);

      final history = repository.getHistory();

      expect(history, isEmpty);
    });
  });
}
