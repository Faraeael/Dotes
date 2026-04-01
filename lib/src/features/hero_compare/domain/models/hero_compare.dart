import '../../../hero_detail/domain/models/hero_detail.dart';

enum HeroCompareVerdictType {
  strongerBlockPick,
  betterComfortPick,
  keepCurrentBlock,
  tooCloseToCall;
}

class HeroCompareVerdict {
  const HeroCompareVerdict({
    required this.type,
    required this.message,
  });

  final HeroCompareVerdictType type;
  final String message;
}

class HeroCompareOption {
  const HeroCompareOption({
    required this.heroId,
    required this.heroName,
  });

  final int heroId;
  final String heroName;
}

class HeroCompare {
  const HeroCompare({
    required this.primaryHero,
    required this.secondaryHero,
    required this.verdict,
  });

  final HeroDetail primaryHero;
  final HeroDetail secondaryHero;
  final HeroCompareVerdict verdict;
}

class HeroCompareRequest {
  const HeroCompareRequest({
    required this.primaryHeroId,
    required this.secondaryHeroId,
  });

  final int primaryHeroId;
  final int secondaryHeroId;
}
