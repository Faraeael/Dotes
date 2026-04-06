class SavedBlockSummary {
  const SavedBlockSummary({
    required this.playerLabel,
    required this.completionDateLabel,
    required this.outcome,
    required this.mainTargetResult,
    required this.adherenceResult,
    required this.takeaway,
    required this.nextStep,
    required this.shareText,
    required this.savedAt,
    this.practiceNote,
  });

  final String playerLabel;
  final String completionDateLabel;
  final String outcome;
  final String mainTargetResult;
  final String adherenceResult;
  final String takeaway;
  final String nextStep;
  final String shareText;
  final DateTime savedAt;
  final String? practiceNote;

  Map<String, dynamic> toJson() {
    return {
      'playerLabel': playerLabel,
      'completionDateLabel': completionDateLabel,
      'outcome': outcome,
      'mainTargetResult': mainTargetResult,
      'adherenceResult': adherenceResult,
      'takeaway': takeaway,
      'nextStep': nextStep,
      'shareText': shareText,
      'savedAt': savedAt.toUtc().toIso8601String(),
      'practiceNote': practiceNote,
    };
  }

  SavedBlockSummary copyWith({DateTime? savedAt, String? practiceNote}) {
    return SavedBlockSummary(
      playerLabel: playerLabel,
      completionDateLabel: completionDateLabel,
      outcome: outcome,
      mainTargetResult: mainTargetResult,
      adherenceResult: adherenceResult,
      takeaway: takeaway,
      nextStep: nextStep,
      shareText: shareText,
      savedAt: savedAt ?? this.savedAt,
      practiceNote: practiceNote ?? this.practiceNote,
    );
  }

  static SavedBlockSummary? fromJsonOrNull(Map<String, dynamic> json) {
    final playerLabel = json['playerLabel'] as String?;
    final completionDateLabel = json['completionDateLabel'] as String?;
    final outcome = json['outcome'] as String?;
    final mainTargetResult = json['mainTargetResult'] as String?;
    final adherenceResult = json['adherenceResult'] as String?;
    final takeaway = json['takeaway'] as String?;
    final nextStep = json['nextStep'] as String?;
    final shareText = json['shareText'] as String?;
    final savedAt = _readDateTime(json['savedAt'] as String?);

    if (playerLabel == null ||
        completionDateLabel == null ||
        outcome == null ||
        mainTargetResult == null ||
        adherenceResult == null ||
        takeaway == null ||
        nextStep == null ||
        shareText == null ||
        savedAt == null) {
      return null;
    }

    return SavedBlockSummary(
      playerLabel: playerLabel,
      completionDateLabel: completionDateLabel,
      outcome: outcome,
      mainTargetResult: mainTargetResult,
      adherenceResult: adherenceResult,
      takeaway: takeaway,
      nextStep: nextStep,
      shareText: shareText,
      savedAt: savedAt,
      practiceNote: _readPracticeNote(json['practiceNote'] as String?),
    );
  }

  static DateTime? _readDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value)?.toUtc();
  }

  static String? _readPracticeNote(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
