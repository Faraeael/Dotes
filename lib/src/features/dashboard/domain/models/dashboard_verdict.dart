class DashboardVerdict {
  const DashboardVerdict({
    this.biggestLeak,
    this.biggestEdge,
    this.fallbackMessage,
    this.confidenceLabel = 'Conservative read',
    this.reasonLabel,
  });

  final DashboardVerdictLine? biggestLeak;
  final DashboardVerdictLine? biggestEdge;
  final String? fallbackMessage;
  final String confidenceLabel;
  final String? reasonLabel;

  bool get hasSignal => biggestLeak != null || biggestEdge != null;
}

class DashboardVerdictLine {
  const DashboardVerdictLine({required this.message});

  final String message;
}
