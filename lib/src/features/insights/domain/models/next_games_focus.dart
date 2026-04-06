import 'coaching_insight.dart';

class NextGamesFocus {
  const NextGamesFocus({
    required this.title,
    required this.action,
    required this.sourceLabel,
    this.confidenceLabel = 'Conservative read',
    this.reasonLabel,
    this.sourceType,
    this.heroBlock,
  });

  final String title;
  final String action;
  final String sourceLabel;
  final String confidenceLabel;
  final String? reasonLabel;
  final CoachingInsightType? sourceType;
  final NextGamesFocusHeroBlock? heroBlock;
}

class NextGamesFocusHeroBlock {
  const NextGamesFocusHeroBlock({
    required this.heroIds,
    required this.heroLabels,
    required this.wins,
    required this.losses,
  });

  final List<int> heroIds;
  final List<String> heroLabels;
  final int wins;
  final int losses;

  int get matches => wins + losses;

  double get winRate => matches == 0 ? 0 : wins / matches;

  String get actionLabel {
    if (heroLabels.isEmpty) {
      return 'your top heroes';
    }

    if (heroLabels.length == 1) {
      return heroLabels.first;
    }

    return '${heroLabels.first} and ${heroLabels.last}';
  }
}
