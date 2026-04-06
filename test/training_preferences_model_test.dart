import 'package:dotes/src/features/training_preferences/domain/models/training_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrainingPreferences', () {
    test('trims coaching note in the exposed helper and json payload', () {
      const preferences = TrainingPreferences(
        coachingMode: TrainingCoachingMode.preferManualSetup,
        coachingNote: '  Practice cleaner lane exits.  ',
      );

      expect(preferences.trimmedCoachingNote, 'Practice cleaner lane exits.');
      expect(
        preferences.toJson()['coachingNote'],
        'Practice cleaner lane exits.',
      );
    });

    test('reads a persisted coaching note from json', () {
      final preferences = TrainingPreferences.fromJson({
        'coachingMode': TrainingCoachingMode.preferManualSetup.name,
        'coachingNote': 'Avoid solo smoke feeds.',
      });

      expect(preferences.coachingMode, TrainingCoachingMode.preferManualSetup);
      expect(preferences.trimmedCoachingNote, 'Avoid solo smoke feeds.');
    });

    test('reads a persisted focus priority from json', () {
      final preferences = TrainingPreferences.fromJson({
        'focusPriority': TrainingFocusPriority.tightenHeroPool.name,
      });

      expect(preferences.focusPriority, TrainingFocusPriority.tightenHeroPool);
    });

    test('reads a persisted coaching style from json', () {
      final preferences = TrainingPreferences.fromJson({
        'coachingStyle': TrainingCoachingStyle.direct.name,
      });

      expect(preferences.coachingStyle, TrainingCoachingStyle.direct);
    });

    test('reads a persisted queue preference from json', () {
      final preferences = TrainingPreferences.fromJson({
        'queuePreference': TrainingQueuePreference.soloOnly.name,
      });

      expect(preferences.queuePreference, TrainingQueuePreference.soloOnly);
    });
  });
}
