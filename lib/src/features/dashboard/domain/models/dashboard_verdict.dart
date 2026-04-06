class DashboardVerdict {
  const DashboardVerdict({
    this.biggestLeak,
    this.biggestEdge,
    this.fallbackMessage,
    this.confidenceLabel = 'Conservative read',
    this.reasonLabel,
    this.contextNote,
  });

  final DashboardVerdictLine? biggestLeak;
  final DashboardVerdictLine? biggestEdge;
  final String? fallbackMessage;
  final String confidenceLabel;
  final String? reasonLabel;

  /// Optional rank-tier-specific coaching note shown below the verdict body.
  ///
  /// Only set for [CoachingRankTier.introductory] and
  /// [CoachingRankTier.advanced] when there is an actual signal.
  final String? contextNote;

  bool get hasSignal => biggestLeak != null || biggestEdge != null;
}

class DashboardVerdictLine {
  const DashboardVerdictLine({required this.message});

  final String message;
}

