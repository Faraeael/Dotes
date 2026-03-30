enum ComfortCoreConclusionType {
  successInsideCore,
  outsideWeaker,
  noClearCore,
  tinySample,
}

class ComfortCoreHeroUsage {
  const ComfortCoreHeroUsage({
    required this.heroId,
    required this.matches,
  });

  final int heroId;
  final int matches;
}

class ComfortCoreSummary {
  const ComfortCoreSummary({
    required this.conclusionType,
    required this.conclusion,
    required this.totalMatches,
    required this.minimumMatches,
    required this.topHeroes,
    required this.topHeroWins,
    required this.topHeroLosses,
    required this.otherHeroWins,
    required this.otherHeroLosses,
  });

  final ComfortCoreConclusionType conclusionType;
  final String conclusion;
  final int totalMatches;
  final int minimumMatches;
  final List<ComfortCoreHeroUsage> topHeroes;
  final int topHeroWins;
  final int topHeroLosses;
  final int otherHeroWins;
  final int otherHeroLosses;

  bool get isReady => conclusionType != ComfortCoreConclusionType.tinySample;

  int get topHeroMatches => topHeroWins + topHeroLosses;

  int get otherHeroMatches => otherHeroWins + otherHeroLosses;
}
