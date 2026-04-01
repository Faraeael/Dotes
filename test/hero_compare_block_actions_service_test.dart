import 'package:dotes/src/features/hero_compare/domain/models/hero_compare.dart';
import 'package:dotes/src/features/hero_compare/domain/services/hero_compare_block_actions_service.dart';
import 'package:dotes/src/features/hero_detail/domain/models/hero_detail.dart';
import 'package:dotes/src/features/meta_reference/domain/models/hero_meta_summary.dart';
import 'package:dotes/src/features/training_preferences/domain/models/manual_hero_block_action.dart';
import 'package:dotes/src/features/training_preferences/domain/models/training_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = HeroCompareBlockActionsService();

  test('renders current block state and already-in-block hero state correctly', () {
    final actions = service.build(
      compare: HeroCompare(
        primaryHero: _detail('Mars', 129),
        secondaryHero: _detail('Slardar', 28),
        verdict: const HeroCompareVerdict(
          type: HeroCompareVerdictType.keepCurrentBlock,
          message: 'Keep the current hero block.',
        ),
      ),
      leftControl: const HeroTrainingBlockControl(
        coachingMode: TrainingCoachingMode.preferManualSetup,
        lockedHeroIds: [129, 135],
        lockedBlockLabel: 'Mars + Dawnbreaker',
        primaryAction: HeroTrainingBlockActionType.remove,
        willSwitchToManualSetup: false,
        replaceOptions: [],
      ),
      rightControl: const HeroTrainingBlockControl(
        coachingMode: TrainingCoachingMode.preferManualSetup,
        lockedHeroIds: [129, 135],
        lockedBlockLabel: 'Mars + Dawnbreaker',
        primaryAction: HeroTrainingBlockActionType.replace,
        willSwitchToManualSetup: false,
        replaceOptions: [
          HeroTrainingBlockReplaceOption(heroId: 129, heroLabel: 'Mars'),
          HeroTrainingBlockReplaceOption(heroId: 135, heroLabel: 'Dawnbreaker'),
        ],
      ),
    );

    expect(actions.currentBlockLabel, 'Mars + Dawnbreaker');
    expect(actions.leftHero.isAlreadyInBlock, isTrue);
    expect(actions.leftHero.actionLabel, 'Mars already in block');
    expect(actions.rightHero.actionLabel, 'Replace current block hero with Slardar');
  });
}

HeroDetail _detail(String name, int heroId) {
  return HeroDetail(
    heroId: heroId,
    heroName: name,
    matchesInSample: 4,
    wins: 3,
    losses: 1,
    winRatePercentage: 75,
    averageDeaths: 4,
    averageKda: 3,
    averageMatchDuration: const Duration(minutes: 34),
    tags: const [],
    coachingRead: 'Read',
    trainingDecision: HeroTrainingDecision.goodBackupHero,
    blockContext: null,
    metaSummary: const HeroMetaSummary(
      reference: null,
      freshness: null,
      interpretation: 'No meta',
      fallbackMessage: 'No meta',
    ),
    recentMatches: const [],
  );
}
