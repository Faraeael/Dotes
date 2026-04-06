import 'package:dotes/src/features/hero_compare/domain/models/hero_compare.dart';
import 'package:dotes/src/features/hero_compare/domain/services/hero_compare_service.dart';
import 'package:dotes/src/features/hero_detail/domain/models/hero_detail.dart';
import 'package:dotes/src/features/meta_reference/domain/models/hero_meta_freshness.dart';
import 'package:dotes/src/features/meta_reference/domain/models/hero_meta_reference.dart';
import 'package:dotes/src/features/meta_reference/domain/models/hero_meta_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = HeroCompareService();

  group('HeroCompareService', () {
    test(
      'prefers the better comfort pick when one hero is clearly comfort-backed',
      () {
        final compare = service.build(
          primaryHero: _detail(
            heroName: 'Slardar',
            matches: 5,
            wins: 4,
            losses: 1,
            winRate: 80,
            averageDeaths: 4.0,
            tags: const [HeroDetailTag.comfortCore],
            trainingDecision: HeroTrainingDecision.goodBackupHero,
          ),
          secondaryHero: _detail(
            heroName: 'Sven',
            matches: 5,
            wins: 2,
            losses: 3,
            winRate: 40,
            averageDeaths: 6.0,
          ),
        );

        expect(compare.verdict.type, HeroCompareVerdictType.betterComfortPick);
        expect(
          compare.verdict.message,
          'Slardar is the better comfort pick right now.',
        );
      },
    );

    test('calls the clearly better performer the stronger block pick', () {
      final compare = service.build(
        primaryHero: _detail(
          heroName: 'Mars',
          matches: 6,
          wins: 5,
          losses: 1,
          winRate: 83,
          averageDeaths: 3.5,
          trainingDecision: HeroTrainingDecision.goodBackupHero,
        ),
        secondaryHero: _detail(
          heroName: 'Centaur',
          matches: 6,
          wins: 2,
          losses: 4,
          winRate: 33,
          averageDeaths: 7.0,
        ),
      );

      expect(compare.verdict.type, HeroCompareVerdictType.strongerBlockPick);
      expect(
        compare.verdict.message,
        'Mars is the stronger current block pick.',
      );
    });

    test('stays conservative when one hero has too little data', () {
      final compare = service.build(
        primaryHero: _detail(
          heroName: 'Slardar',
          matches: 2,
          wins: 2,
          losses: 0,
          winRate: 100,
          averageDeaths: 3.0,
          trainingDecision: HeroTrainingDecision.tooLittleData,
        ),
        secondaryHero: _detail(
          heroName: 'Mars',
          matches: 5,
          wins: 4,
          losses: 1,
          winRate: 80,
          averageDeaths: 4.0,
        ),
      );

      expect(compare.verdict.type, HeroCompareVerdictType.tooCloseToCall);
      expect(
        compare.verdict.message,
        'Too close to call from the current sample.',
      );
    });

    test('keeps meta secondary to the coaching score', () {
      final compare = service.build(
        primaryHero: _detail(
          heroName: 'Slardar',
          matches: 5,
          wins: 4,
          losses: 1,
          winRate: 80,
          averageDeaths: 4.0,
          trainingDecision: HeroTrainingDecision.goodBackupHero,
          metaSummary: _metaSummary(HeroMetaTier.neutral),
        ),
        secondaryHero: _detail(
          heroName: 'Mars',
          matches: 5,
          wins: 3,
          losses: 2,
          winRate: 60,
          averageDeaths: 5.0,
          trainingDecision: HeroTrainingDecision.goodBackupHero,
          metaSummary: _metaSummary(HeroMetaTier.top),
        ),
      );

      expect(
        compare.verdict.message,
        'Slardar is the stronger current block pick.',
      );
    });

    test('prefers keeping the current plan hero over an outside-plan hero', () {
      final compare = service.build(
        primaryHero: _detail(
          heroName: 'Mars',
          matches: 5,
          wins: 4,
          losses: 1,
          winRate: 80,
          averageDeaths: 4.0,
          tags: const [HeroDetailTag.inCurrentPlan],
          trainingDecision: HeroTrainingDecision.keepInBlock,
        ),
        secondaryHero: _detail(
          heroName: 'Slardar',
          matches: 5,
          wins: 4,
          losses: 1,
          winRate: 80,
          averageDeaths: 4.0,
          tags: const [HeroDetailTag.outsideCurrentPlan],
          trainingDecision: HeroTrainingDecision.goodBackupHero,
        ),
      );

      expect(compare.verdict.type, HeroCompareVerdictType.keepCurrentBlock);
      expect(compare.verdict.message, 'Keep the current hero block.');
    });
  });
}

HeroDetail _detail({
  required String heroName,
  required int matches,
  required int wins,
  required int losses,
  required int winRate,
  required double averageDeaths,
  List<HeroDetailTag> tags = const [],
  HeroTrainingDecision trainingDecision = HeroTrainingDecision.testLaterNotNow,
  HeroMetaSummary? metaSummary,
}) {
  return HeroDetail(
    heroId: heroName.hashCode,
    heroName: heroName,
    matchesInSample: matches,
    wins: wins,
    losses: losses,
    winRatePercentage: winRate,
    averageDeaths: averageDeaths,
    averageKda: 3.0,
    averageMatchDuration: const Duration(minutes: 35),
    tags: tags,
    coachingRead: 'Read',
    rationaleLines: const ['Reason'],
    trainingDecision: trainingDecision,
    blockContext: null,
    metaSummary:
        metaSummary ??
        const HeroMetaSummary(
          reference: null,
          freshness: null,
          interpretation: 'No meta',
          fallbackMessage: 'No meta',
        ),
    recentMatches: const [],
  );
}

HeroMetaSummary _metaSummary(HeroMetaTier tier) {
  return HeroMetaSummary(
    reference: HeroMetaReference(
      heroId: 1,
      patchLabel: '7.41a',
      tier: tier,
      roleLabel: 'Role',
      coreItemDirection: 'Items',
    ),
    freshness: const HeroMetaFreshness(
      metaPatchLabel: '7.41a',
      currentSupportedPatchLabel: '7.41a',
      status: HeroMetaFreshnessStatus.current,
    ),
    interpretation: 'Meta',
    fallbackMessage: '',
  );
}
