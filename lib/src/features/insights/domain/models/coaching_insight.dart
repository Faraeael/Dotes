enum CoachingInsightType {
  earlyDeathRisk,
  specializationRecommendation,
  heroPoolSpread,
  comfortHeroDependence,
  weakRecentTrend,
  limitedConfidence,
}

enum CoachingInsightSeverity {
  low,
  medium,
  high;

  String get label => switch (this) {
    CoachingInsightSeverity.low => 'Low',
    CoachingInsightSeverity.medium => 'Medium',
    CoachingInsightSeverity.high => 'High',
  };

  int get sortWeight => switch (this) {
    CoachingInsightSeverity.low => 0,
    CoachingInsightSeverity.medium => 1,
    CoachingInsightSeverity.high => 2,
  };
}

enum CoachingInsightConfidence {
  low,
  medium,
  high;

  String get label => switch (this) {
    CoachingInsightConfidence.low => 'Low',
    CoachingInsightConfidence.medium => 'Medium',
    CoachingInsightConfidence.high => 'High',
  };

  int get sortWeight => switch (this) {
    CoachingInsightConfidence.low => 0,
    CoachingInsightConfidence.medium => 1,
    CoachingInsightConfidence.high => 2,
  };
}

class CoachingInsight {
  const CoachingInsight({
    required this.type,
    required this.title,
    required this.explanation,
    required this.severity,
    required this.confidence,
  });

  final CoachingInsightType type;
  final String title;
  final String explanation;
  final CoachingInsightSeverity severity;
  final CoachingInsightConfidence confidence;
}
