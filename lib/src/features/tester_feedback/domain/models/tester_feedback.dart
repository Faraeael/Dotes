enum TesterFeedbackRating {
  clear,
  somewhatClear,
  confusing;

  String get label => switch (this) {
    TesterFeedbackRating.clear => 'Clear',
    TesterFeedbackRating.somewhatClear => 'Somewhat clear',
    TesterFeedbackRating.confusing => 'Confusing',
  };

  static TesterFeedbackRating? fromName(String? value) {
    for (final rating in TesterFeedbackRating.values) {
      if (rating.name == value) {
        return rating;
      }
    }

    return null;
  }
}

class TesterFeedback {
  const TesterFeedback({
    required this.rating,
    this.note = '',
    this.playerLabel,
    this.savedAt,
  });

  final TesterFeedbackRating rating;
  final String note;
  final String? playerLabel;
  final DateTime? savedAt;

  bool get hasNote => trimmedNote.isNotEmpty;

  String get trimmedNote => note.trim();

  bool get hasPlayerLabel => trimmedPlayerLabel != null;

  String? get trimmedPlayerLabel {
    final trimmed = playerLabel?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating.name,
      'note': trimmedNote,
      if (trimmedPlayerLabel != null) 'playerLabel': trimmedPlayerLabel,
      if (savedAt != null) 'savedAt': savedAt!.toUtc().toIso8601String(),
    };
  }

  TesterFeedback copyWith({
    TesterFeedbackRating? rating,
    String? note,
    String? playerLabel,
    DateTime? savedAt,
  }) {
    return TesterFeedback(
      rating: rating ?? this.rating,
      note: note ?? this.note,
      playerLabel: playerLabel ?? this.playerLabel,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  static TesterFeedback? fromJsonOrNull(Map<String, dynamic> json) {
    final rating = TesterFeedbackRating.fromName(json['rating'] as String?);
    if (rating == null) {
      return null;
    }

    return TesterFeedback(
      rating: rating,
      note: json['note'] as String? ?? '',
      playerLabel: json['playerLabel'] as String?,
      savedAt: _readDateTime(json['savedAt'] as String?),
    );
  }

  static DateTime? _readDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value)?.toUtc();
  }
}
