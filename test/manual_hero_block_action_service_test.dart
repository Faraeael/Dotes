import 'package:dotes/src/features/training_preferences/domain/models/manual_hero_block_action.dart';
import 'package:dotes/src/features/training_preferences/domain/models/training_preferences.dart';
import 'package:dotes/src/features/training_preferences/domain/services/manual_hero_block_action_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = ManualHeroBlockActionService();

  group('ManualHeroBlockActionService', () {
    test(
      'adding first hero to the block creates a manual single-hero block',
      () {
        final updated = service.addHeroToBlock(
          heroId: 28,
          preferences: const TrainingPreferences(),
        );

        expect(updated.coachingMode, TrainingCoachingMode.preferManualSetup);
        expect(updated.normalizedLockedHeroIds, [28]);
      },
    );

    test('adding second hero to the block appends the second slot', () {
      final updated = service.addHeroToBlock(
        heroId: 129,
        preferences: const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          lockedHeroIds: [28],
        ),
      );

      expect(updated.coachingMode, TrainingCoachingMode.preferManualSetup);
      expect(updated.normalizedLockedHeroIds, [28, 129]);
    });

    test('replacing a hero in a full block preserves the other slot', () {
      final updated = service.replaceHeroInBlock(
        heroId: 53,
        replaceHeroId: 28,
        preferences: const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          lockedHeroIds: [28, 129],
        ),
      );

      expect(updated.normalizedLockedHeroIds, [53, 129]);
    });

    test('removing a hero already in the block leaves the other hero', () {
      final updated = service.removeHeroFromBlock(
        heroId: 28,
        preferences: const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          lockedHeroIds: [28, 129],
        ),
      );

      expect(updated.normalizedLockedHeroIds, [129]);
    });

    test(
      'block action control flags when the action will switch to manual mode',
      () {
        final control = service.buildControl(
          heroId: 28,
          preferences: const TrainingPreferences(
            coachingMode: TrainingCoachingMode.followAppRead,
            lockedHeroIds: [],
          ),
          heroLabelFor: _heroLabelFor,
        );

        expect(control.primaryAction, HeroTrainingBlockActionType.add);
        expect(control.willSwitchToManualSetup, isTrue);
        expect(control.lockedBlockLabel, 'None');
      },
    );
  });
}

String _heroLabelFor(int heroId) {
  return switch (heroId) {
    28 => 'Slardar',
    53 => 'Nature\'s Prophet',
    129 => 'Mars',
    _ => 'Hero $heroId',
  };
}
