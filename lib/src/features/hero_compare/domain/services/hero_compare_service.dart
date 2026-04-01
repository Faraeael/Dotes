import '../../../hero_detail/domain/models/hero_detail.dart';
import '../models/hero_compare.dart';

class HeroCompareService {
  const HeroCompareService();

  static const double _strongEnoughMargin = 0.75;
  static const int _minimumStrongSample = 3;

  HeroCompare build({
    required HeroDetail primaryHero,
    required HeroDetail secondaryHero,
  }) {
    final primaryScore = _score(primaryHero);
    final secondaryScore = _score(secondaryHero);
    final difference = (primaryScore - secondaryScore).abs();

    return HeroCompare(
      primaryHero: primaryHero,
      secondaryHero: secondaryHero,
      verdict: _verdictFor(
        primaryHero: primaryHero,
        secondaryHero: secondaryHero,
        primaryScore: primaryScore,
        secondaryScore: secondaryScore,
        difference: difference,
      ),
    );
  }

  HeroCompareVerdict _verdictFor({
    required HeroDetail primaryHero,
    required HeroDetail secondaryHero,
    required double primaryScore,
    required double secondaryScore,
    required double difference,
  }) {
    final primaryHasStrongSample = _hasStrongSample(primaryHero);
    final secondaryHasStrongSample = _hasStrongSample(secondaryHero);

    if (!primaryHasStrongSample || !secondaryHasStrongSample) {
      return const HeroCompareVerdict(
        type: HeroCompareVerdictType.tooCloseToCall,
        message: 'Too close to call from the current sample.',
      );
    }

    final winner = primaryScore >= secondaryScore ? primaryHero : secondaryHero;
    final loser = identical(winner, primaryHero) ? secondaryHero : primaryHero;

    if (difference < _strongEnoughMargin) {
      return const HeroCompareVerdict(
        type: HeroCompareVerdictType.tooCloseToCall,
        message: 'Too close to call from the current sample.',
      );
    }

    final winnerInPlan = winner.tags.contains(HeroDetailTag.inCurrentPlan);
    final loserInPlan = loser.tags.contains(HeroDetailTag.inCurrentPlan);
    if (winnerInPlan && !loserInPlan) {
      return const HeroCompareVerdict(
        type: HeroCompareVerdictType.keepCurrentBlock,
        message: 'Keep the current hero block.',
      );
    }

    final winnerComfort = winner.tags.contains(HeroDetailTag.comfortCore);
    final loserComfort = loser.tags.contains(HeroDetailTag.comfortCore);
    if (winnerComfort && !loserComfort) {
      return HeroCompareVerdict(
        type: HeroCompareVerdictType.betterComfortPick,
        message: '${winner.heroName} is the better comfort pick right now.',
      );
    }

    return HeroCompareVerdict(
      type: HeroCompareVerdictType.strongerBlockPick,
      message: '${winner.heroName} is the stronger current block pick.',
    );
  }

  double _score(HeroDetail detail) {
    var score = 0.0;
    score += detail.matchesInSample >= _minimumStrongSample ? 1.0 : 0.0;
    score += detail.winRatePercentage / 20;
    score += detail.tags.contains(HeroDetailTag.inCurrentPlan) ? 1.4 : 0.0;
    score += detail.tags.contains(HeroDetailTag.comfortCore) ? 1.0 : 0.0;
    score += switch (detail.trainingDecision) {
      HeroTrainingDecision.keepInBlock => 1.2,
      HeroTrainingDecision.goodBackupHero => 0.7,
      HeroTrainingDecision.testLaterNotNow => 0.1,
      HeroTrainingDecision.tooLittleData => -1.0,
    };

    if (detail.averageDeaths != null) {
      score -= detail.averageDeaths! / 10;
    }

    if (detail.metaSummary.isFresh && detail.metaSummary.reference != null) {
      final tier = detail.metaSummary.reference!.tier;
      score += switch (tier) {
        _ when tier.isHighMeta => 0.25,
        _ when tier.isLowMeta => -0.1,
        _ => 0.0,
      };
    }

    return score;
  }

  bool _hasStrongSample(HeroDetail detail) {
    return detail.matchesInSample >= _minimumStrongSample &&
        detail.trainingDecision != HeroTrainingDecision.tooLittleData;
  }
}
