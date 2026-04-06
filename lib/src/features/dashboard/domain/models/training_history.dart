enum TrainingCycleOutcome {
  onTrack('On track'),
  mixed('Mixed'),
  offTrack('Off track');

  const TrainingCycleOutcome(this.label);

  final String label;
}

class TrainingHistory {
  const TrainingHistory({
    required this.entries,
    required this.fallbackMessage,
    required this.trend,
  });

  final List<TrainingHistoryEntry> entries;
  final String? fallbackMessage;
  final TrainingHistoryTrend trend;

  bool get hasEntries => entries.isNotEmpty;
}

class TrainingHistoryTrend {
  const TrainingHistoryTrend({
    required this.headline,
    required this.detail,
    required this.completedCycles,
    required this.onTrackCount,
    required this.mixedCount,
    required this.offTrackCount,
    required this.currentStreakCount,
    required this.currentStreakOutcome,
  });

  final String headline;
  final String detail;
  final int completedCycles;
  final int onTrackCount;
  final int mixedCount;
  final int offTrackCount;
  final int currentStreakCount;
  final TrainingCycleOutcome? currentStreakOutcome;
}

class TrainingHistoryEntry {
  const TrainingHistoryEntry({
    required this.savedAt,
    required this.focusLabel,
    required this.outcome,
    required this.resultSummary,
    this.deathsAverage,
    this.winRatePercent,
  });

  final DateTime savedAt;
  final String focusLabel;
  final TrainingCycleOutcome outcome;
  final String resultSummary;
  final double? deathsAverage;
  final double? winRatePercent;
}
