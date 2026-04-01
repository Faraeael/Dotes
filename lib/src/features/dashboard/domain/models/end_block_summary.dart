import 'block_review.dart';

class EndBlockSummary {
  const EndBlockSummary({
    required this.outcome,
    required this.mainTargetResult,
    required this.adherenceResult,
    required this.takeaway,
    required this.nextStepSuggestion,
  });

  final BlockReviewOutcome outcome;
  final String mainTargetResult;
  final String adherenceResult;
  final String takeaway;
  final String nextStepSuggestion;
}
