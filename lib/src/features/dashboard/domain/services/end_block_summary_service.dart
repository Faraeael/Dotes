import '../../../checkpoints/domain/models/coaching_checkpoint.dart';
import '../../../progress/domain/models/focus_follow_through_check.dart';
import '../models/block_review.dart';
import '../models/end_block_summary.dart';
import '../models/session_plan.dart';

class EndBlockSummaryService {
  const EndBlockSummaryService();

  EndBlockSummary? build({
    required CoachingCheckpoint? activeStartedCheckpoint,
    required BlockReview? reviewedBlock,
    required SessionPlan? sessionPlan,
    required FocusFollowThroughCheck? followThrough,
  }) {
    if (activeStartedCheckpoint == null || reviewedBlock == null) {
      return null;
    }

    final hasStartedSnapshot = activeStartedCheckpoint.savedSessionPlan != null;
    if (!hasStartedSnapshot ||
        reviewedBlock.blockStatus != BlockReviewStatus.completed) {
      return null;
    }

    final targetType =
        activeStartedCheckpoint.savedSessionPlan?.targetType ??
        sessionPlan?.targetType ??
        SessionPlanTargetType.heroPool;

    return EndBlockSummary(
      outcome: reviewedBlock.overallOutcome,
      mainTargetResult: reviewedBlock.targetResult.label,
      adherenceResult: reviewedBlock.adherence.label,
      takeaway: _takeawayFor(
        targetType: targetType,
        review: reviewedBlock,
        checkpoint: activeStartedCheckpoint,
        followThrough: followThrough,
      ),
      nextStepSuggestion: _nextStepSuggestionFor(
        review: reviewedBlock,
        checkpoint: activeStartedCheckpoint,
      ),
    );
  }

  String _takeawayFor({
    required SessionPlanTargetType targetType,
    required BlockReview review,
    required CoachingCheckpoint checkpoint,
    required FocusFollowThroughCheck? followThrough,
  }) {
    if (review.adherence == BlockReviewAdherence.offBlock) {
      final hasHeroBlock =
          checkpoint.savedSessionPlanHeroBlock != null ||
          checkpoint.focusHeroBlock != null;
      return hasHeroBlock
          ? 'You drifted outside the planned hero block.'
          : 'You drifted outside the planned block.';
    }

    if (review.adherence == BlockReviewAdherence.stayedInsideBlock &&
        review.targetResult == BlockReviewTargetResult.flat) {
      return 'You followed the block cleanly, but there is no clear improvement yet.';
    }

    if (review.overallOutcome == BlockReviewOutcome.mixed) {
      return 'The block finished, but the signal stayed mixed.';
    }

    if (review.adherence == BlockReviewAdherence.stayedInsideBlock &&
        review.targetResult == BlockReviewTargetResult.improved) {
      return switch (targetType) {
        SessionPlanTargetType.deaths =>
          'You stayed inside the block and deaths improved.',
        SessionPlanTargetType.heroPool =>
          'You stayed inside the block and hero spread tightened.',
        SessionPlanTargetType.comfortBlock =>
          'You stayed inside the block and comfort results improved.',
      };
    }

    if (review.overallOutcome == BlockReviewOutcome.offTrack) {
      return 'The block finished and landed off track.';
    }

    if (followThrough?.isReady == true &&
        followThrough!.status == FocusFollowThroughStatus.offTrack) {
      return 'The block finished, but follow-through stayed off track.';
    }

    return 'The block finished with a clear on-track read.';
  }

  String _nextStepSuggestionFor({
    required BlockReview review,
    required CoachingCheckpoint checkpoint,
  }) {
    if (review.overallOutcome == BlockReviewOutcome.onTrack) {
      return 'Run the same block again.';
    }

    if (review.adherence == BlockReviewAdherence.stayedInsideBlock &&
        review.targetResult == BlockReviewTargetResult.flat) {
      return 'Run the same block again.';
    }

    if (review.adherence == BlockReviewAdherence.offBlock ||
        review.adherence == BlockReviewAdherence.partialDrift) {
      final hasHeroBlock =
          checkpoint.savedSessionPlanHeroBlock != null ||
          checkpoint.focusHeroBlock != null;
      if (hasHeroBlock) {
        return 'Tighten the hero block before restarting.';
      }
    }

    return 'Keep the role, change the hero pair.';
  }
}
