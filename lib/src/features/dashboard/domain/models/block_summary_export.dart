class BlockSummaryExport {
  const BlockSummaryExport({
    required this.playerLabel,
    required this.completionDateLabel,
    required this.outcome,
    required this.mainTargetResult,
    required this.adherenceResult,
    required this.takeaway,
    required this.nextStep,
    required this.shareText,
  });

  final String playerLabel;
  final String completionDateLabel;
  final String outcome;
  final String mainTargetResult;
  final String adherenceResult;
  final String takeaway;
  final String nextStep;
  final String shareText;
}
