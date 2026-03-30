class DashboardVerdict {
  const DashboardVerdict({
    this.biggestLeak,
    this.biggestEdge,
    this.fallbackMessage,
  });

  final DashboardVerdictLine? biggestLeak;
  final DashboardVerdictLine? biggestEdge;
  final String? fallbackMessage;

  bool get hasSignal => biggestLeak != null || biggestEdge != null;
}

class DashboardVerdictLine {
  const DashboardVerdictLine({
    required this.message,
  });

  final String message;
}
