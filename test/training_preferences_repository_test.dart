import 'package:dotes/src/features/training_preferences/data/local/training_preferences_local_store.dart';
import 'package:dotes/src/features/training_preferences/data/repositories/local_training_preferences_repository.dart';
import 'package:dotes/src/features/training_preferences/domain/models/training_preferences.dart';
import 'package:dotes/src/features/training_preferences/domain/repositories/training_preferences_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalTrainingPreferencesRepository', () {
    late InMemoryTrainingPreferencesLocalStore store;
    late TrainingPreferencesRepository repository;

    setUp(() {
      store = InMemoryTrainingPreferencesLocalStore();
      repository = LocalTrainingPreferencesRepository(store);
    });

    test('stores preferences per account locally', () async {
      const preferences = TrainingPreferences(
        coachingMode: TrainingCoachingMode.preferManualSetup,
        preferredRole: TrainingRolePreference.mid,
        lockedHeroIds: [28, 129],
      );

      await repository.saveForAccount(86745912, preferences);
      final loaded = await repository.loadForAccount(86745912);

      expect(loaded.coachingMode, TrainingCoachingMode.preferManualSetup);
      expect(loaded.preferredRole, TrainingRolePreference.mid);
      expect(loaded.normalizedLockedHeroIds, [28, 129]);
    });

    test('different accounts do not share preferences', () async {
      await repository.saveForAccount(
        86745912,
        const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          preferredRole: TrainingRolePreference.carry,
          lockedHeroIds: [28],
        ),
      );
      await repository.saveForAccount(
        2222,
        const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          preferredRole: TrainingRolePreference.hardSupport,
          lockedHeroIds: [30, 31],
        ),
      );

      final firstLoaded = await repository.loadForAccount(86745912);
      final secondLoaded = await repository.loadForAccount(2222);

      expect(firstLoaded.preferredRole, TrainingRolePreference.carry);
      expect(firstLoaded.normalizedLockedHeroIds, [28]);
      expect(secondLoaded.preferredRole, TrainingRolePreference.hardSupport);
      expect(secondLoaded.normalizedLockedHeroIds, [30, 31]);
    });

    test('returns defaults when no preferences are saved', () async {
      final loaded = await repository.loadForAccount(86745912);

      expect(loaded.coachingMode, TrainingCoachingMode.followAppRead);
      expect(loaded.preferredRole, TrainingRolePreference.auto);
      expect(loaded.activeLockedHeroIds, isEmpty);
    });
  });
}

class InMemoryTrainingPreferencesLocalStore
    implements TrainingPreferencesLocalStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> getString(String key) async {
    return _values[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }
}
