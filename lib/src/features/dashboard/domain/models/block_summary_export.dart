class BlockSummaryExport {
  const BlockSummaryExport({
    required this.playerLabel,
    required this.completionDateLabel,
    required this.focusLabel,
    required this.queueLabel,
    required this.heroBlockLabel,
    required this.targetLabel,
    required this.reviewWindowLabel,
    required this.outcome,
    required this.mainTargetResult,
    required this.adherenceResult,
    required this.takeaway,
    required this.nextStep,
    required this.shareText,
    this.practiceNote,
  });

  final String playerLabel;
  final String completionDateLabel;
  final String focusLabel;
  final String queueLabel;
  final String heroBlockLabel;
  final String targetLabel;
  final String reviewWindowLabel;
  final String outcome;
  final String mainTargetResult;
  final String adherenceResult;
  final String takeaway;
  final String nextStep;
  final String shareText;
  final String? practiceNote;
}
