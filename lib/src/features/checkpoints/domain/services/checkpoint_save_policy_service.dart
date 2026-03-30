import '../models/coaching_checkpoint.dart';

enum CheckpointSaveDecisionReason {
  firstCheckpoint,
  differentAccount,
  noNewMatches,
  overlappingBlock,
  insufficientNewSignal,
  meaningfulNewState,
}

class CheckpointSaveDecision {
  const CheckpointSaveDecision({
    required this.shouldSave,
    required this.reason,
    required this.newWindowMatchCount,
    required this.overlapCount,
  });

  final bool shouldSave;
  final CheckpointSaveDecisionReason reason;
  final int newWindowMatchCount;
  final int overlapCount;
}

class CheckpointSavePolicyService {
  const CheckpointSavePolicyService();

  static const int _heavyOverlapThreshold = 4;
  static const int _meaningfulNewWindowThreshold = 3;
  static const int _minimumPartialRefresh = 2;

  CheckpointSaveDecision evaluate({
    required CoachingCheckpointDraft currentDraft,
    required CoachingCheckpoint? lastCheckpoint,
  }) {
    if (lastCheckpoint == null) {
      return const CheckpointSaveDecision(
        shouldSave: true,
        reason: CheckpointSaveDecisionReason.firstCheckpoint,
        newWindowMatchCount: 5,
        overlapCount: 0,
      );
    }

    if (lastCheckpoint.accountId != currentDraft.accountId) {
      return const CheckpointSaveDecision(
        shouldSave: true,
        reason: CheckpointSaveDecisionReason.differentAccount,
        newWindowMatchCount: 5,
        overlapCount: 0,
      );
    }

    final currentTokens = currentDraft.sample.recentWindowTokens;
    final previousTokens = lastCheckpoint.sample.recentWindowTokens.toSet();
    final newWindowMatchCount = currentTokens
        .where((token) => !previousTokens.contains(token))
        .length;
    final overlapCount = currentTokens.length - newWindowMatchCount;
    final currentLatestMatchId = currentDraft.sample.latestMatchId;
    final previousLatestMatchId = lastCheckpoint.sample.latestMatchId;

    if (currentLatestMatchId != null &&
        previousLatestMatchId != null &&
        currentLatestMatchId == previousLatestMatchId) {
      return CheckpointSaveDecision(
        shouldSave: false,
        reason: CheckpointSaveDecisionReason.noNewMatches,
        newWindowMatchCount: newWindowMatchCount,
        overlapCount: overlapCount,
      );
    }

    if (newWindowMatchCount == 0 ||
        currentDraft.sample.reviewedBlockSignature ==
            lastCheckpoint.sample.reviewedBlockSignature) {
      return CheckpointSaveDecision(
        shouldSave: false,
        reason: CheckpointSaveDecisionReason.noNewMatches,
        newWindowMatchCount: newWindowMatchCount,
        overlapCount: overlapCount,
      );
    }

    if (overlapCount >= _heavyOverlapThreshold) {
      return CheckpointSaveDecision(
        shouldSave: false,
        reason: CheckpointSaveDecisionReason.overlappingBlock,
        newWindowMatchCount: newWindowMatchCount,
        overlapCount: overlapCount,
      );
    }

    if (newWindowMatchCount >= _meaningfulNewWindowThreshold ||
        _hasMaterialCycleShift(currentDraft, lastCheckpoint,
            newWindowMatchCount: newWindowMatchCount)) {
      return CheckpointSaveDecision(
        shouldSave: true,
        reason: CheckpointSaveDecisionReason.meaningfulNewState,
        newWindowMatchCount: newWindowMatchCount,
        overlapCount: overlapCount,
      );
    }

    return CheckpointSaveDecision(
      shouldSave: false,
      reason: CheckpointSaveDecisionReason.insufficientNewSignal,
      newWindowMatchCount: newWindowMatchCount,
      overlapCount: overlapCount,
    );
  }

  bool _hasMaterialCycleShift(
    CoachingCheckpointDraft currentDraft,
    CoachingCheckpoint lastCheckpoint, {
    required int newWindowMatchCount,
  }) {
    if (newWindowMatchCount < _minimumPartialRefresh) {
      return false;
    }

    if (currentDraft.topInsightType != lastCheckpoint.topInsightType) {
      return true;
    }

    if (currentDraft.focusSourceLabel != lastCheckpoint.focusSourceLabel) {
      return true;
    }

    if (currentDraft.focusHeroBlock?.heroIds.join(',') !=
        lastCheckpoint.focusHeroBlock?.heroIds.join(',')) {
      return true;
    }

    if ((currentDraft.sample.winRate - lastCheckpoint.sample.winRate).abs() >=
        0.1) {
      return true;
    }

    if ((currentDraft.sample.averageDeaths -
                lastCheckpoint.sample.averageDeaths)
            .abs() >=
        1) {
      return true;
    }

    if (currentDraft.sample.uniqueHeroesPlayed !=
        lastCheckpoint.sample.uniqueHeroesPlayed) {
      return true;
    }

    if (currentDraft.sample.primaryRoleKey != lastCheckpoint.sample.primaryRoleKey) {
      return true;
    }

    if (currentDraft.sample.hasClearRoleEstimate !=
        lastCheckpoint.sample.hasClearRoleEstimate) {
      return true;
    }

    return false;
  }
}
