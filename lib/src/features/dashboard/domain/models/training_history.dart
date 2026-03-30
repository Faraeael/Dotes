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
  });

  final List<TrainingHistoryEntry> entries;
  final String? fallbackMessage;

  bool get hasEntries => entries.isNotEmpty;
}

class TrainingHistoryEntry {
  const TrainingHistoryEntry({
    required this.savedAt,
    required this.focusLabel,
    required this.outcome,
    required this.resultSummary,
  });

  final DateTime savedAt;
  final String focusLabel;
  final TrainingCycleOutcome outcome;
  final String resultSummary;
}
