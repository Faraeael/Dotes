import '../../../player_import/domain/models/recent_match.dart';

enum HeroDetailTag {
  comfortCore('Comfort core'),
  inCurrentPlan('In current plan'),
  outsideCurrentPlan('Outside current plan');

  const HeroDetailTag(this.label);

  final String label;
}

enum HeroTrainingDecision {
  keepInBlock('Keep in block'),
  goodBackupHero('Good backup hero'),
  testLaterNotNow('Test later, not now'),
  tooLittleData('Too little data');

  const HeroTrainingDecision(this.label);

  final String label;
}

enum HeroLastPlanStatus {
  inLastNamedBlock('In last named block'),
  outsideLastNamedBlock('Outside last named block'),
  noNamedHeroBlock('No named hero block');

  const HeroLastPlanStatus(this.label);

  final String label;
}

enum HeroBlockTrendStatus {
  improved('Improved'),
  flat('Flat'),
  worse('Worse'),
  notEnoughHistory('Need more history');

  const HeroBlockTrendStatus(this.label);

  final String label;
}

class HeroBlockContext {
  const HeroBlockContext({
    required this.lastPlanStatus,
    required this.reviewedBlockAppearances,
    required this.reviewedBlockGames,
    required this.trendStatus,
    required this.trendDetail,
  });

  final HeroLastPlanStatus lastPlanStatus;
  final int reviewedBlockAppearances;
  final int reviewedBlockGames;
  final HeroBlockTrendStatus trendStatus;
  final String trendDetail;
}

class HeroDetail {
  const HeroDetail({
    required this.heroId,
    required this.heroName,
    required this.matchesInSample,
    required this.wins,
    required this.losses,
    required this.winRatePercentage,
    required this.averageDeaths,
    required this.averageKda,
    required this.averageMatchDuration,
    required this.tags,
    required this.coachingRead,
    required this.trainingDecision,
    required this.blockContext,
    required this.recentMatches,
  });

  final int heroId;
  final String heroName;
  final int matchesInSample;
  final int wins;
  final int losses;
  final int winRatePercentage;
  final double? averageDeaths;
  final double? averageKda;
  final Duration? averageMatchDuration;
  final List<HeroDetailTag> tags;
  final String coachingRead;
  final HeroTrainingDecision trainingDecision;
  final HeroBlockContext? blockContext;
  final List<RecentMatch> recentMatches;
}
