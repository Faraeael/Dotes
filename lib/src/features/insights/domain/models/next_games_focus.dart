import 'coaching_insight.dart';

class NextGamesFocus {
  const NextGamesFocus({
    required this.title,
    required this.action,
    required this.sourceLabel,
    this.sourceType,
  });

  final String title;
  final String action;
  final String sourceLabel;
  final CoachingInsightType? sourceType;
}
