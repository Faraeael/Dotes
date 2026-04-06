import 'package:dotes/src/features/training_preferences/domain/models/training_preferences.dart';
import 'package:dotes/src/features/training_preferences/domain/services/coaching_source_summary_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = CoachingSourceSummaryService();

  group('CoachingSourceSummaryService', () {
    test('auto mode label uses app read wording', () {
      final summary = service.build(const TrainingPreferences());

      expect(summary.headline, 'Coaching source: App read');
      expect(summary.detail, 'Using the app read for role and hero block.');
    });

    test('manual role-only label shows the role override', () {
      final summary = service.build(
        const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          preferredRole: TrainingRolePreference.mid,
        ),
      );

      expect(summary.headline, 'Coaching source: Manual setup');
      expect(summary.detail, 'Role: Mid');
    });

    test('manual hero-block label shows the locked hero block', () {
      final summary = service.build(
        const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          lockedHeroIds: [28, 129],
        ),
        heroLabelFor: _heroLabelFor,
      );

      expect(summary.headline, 'Coaching source: Manual setup');
      expect(summary.detail, 'Hero block: Slardar + Mars');
    });

    test('manual role and hero-block label shows both constraints', () {
      final summary = service.build(
        const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          preferredRole: TrainingRolePreference.offlane,
          lockedHeroIds: [28],
        ),
        heroLabelFor: _heroLabelFor,
      );

      expect(summary.headline, 'Coaching source: Manual setup');
      expect(summary.detail, 'Role: Offlane | Hero block: Slardar');
    });

    test('manual note is included in the setup summary', () {
      final summary = service.build(
        const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          coachingNote: 'Practice calmer lane exits.',
        ),
      );

      expect(summary.headline, 'Coaching source: Manual setup');
      expect(summary.detail, 'Goal: Practice calmer lane exits.');
    });

    test('manual focus priority is included in the setup summary', () {
      final summary = service.build(
        const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          focusPriority: TrainingFocusPriority.reduceDeaths,
        ),
      );

      expect(summary.headline, 'Coaching source: Manual setup');
      expect(summary.detail, 'Priority: Reduce deaths');
    });

    test('manual coaching style is included in the setup summary', () {
      final summary = service.build(
        const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          coachingStyle: TrainingCoachingStyle.direct,
        ),
      );

      expect(summary.headline, 'Coaching source: Manual setup');
      expect(summary.detail, 'Style: Direct');
    });

    test('manual queue preference is included in the setup summary', () {
      final summary = service.build(
        const TrainingPreferences(
          coachingMode: TrainingCoachingMode.preferManualSetup,
          queuePreference: TrainingQueuePreference.soloOnly,
        ),
      );

      expect(summary.headline, 'Coaching source: Manual setup');
      expect(summary.detail, 'Queue: Solo only');
    });
  });
}

String _heroLabelFor(int heroId) {
  return switch (heroId) {
    28 => 'Slardar',
    129 => 'Mars',
    _ => 'Hero $heroId',
  };
}
