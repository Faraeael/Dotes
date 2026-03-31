import '../models/coaching_checkpoint.dart';

enum CheckpointSaveStatus {
  saved,
  skippedNoNewMatches,
  skippedDuplicateBlock,
  skippedNotMeaningfullyNew,
}

class CheckpointSaveDecision {
  const CheckpointSaveDecision({
    required this.accountId,
    required this.status,
    required this.newWindowMatchCount,
    required this.overlapCount,
    required this.blockFingerprint,
  });

  final int accountId;
  final CheckpointSaveStatus status;
  final int newWindowMatchCount;
  final int overlapCount;
  final String blockFingerprint;

  bool get shouldSave => status == CheckpointSaveStatus.saved;
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
      return CheckpointSaveDecision(
        accountId: currentDraft.accountId,
        status: CheckpointSaveStatus.saved,
        newWindowMatchCount: currentDraft.sample.recentMatchesWindow.length,
        overlapCount: 0,
        blockFingerprint: currentDraft.blockFingerprint,
      );
    }

    if (lastCheckpoint.accountId != currentDraft.accountId) {
      return CheckpointSaveDecision(
        accountId: currentDraft.accountId,
        status: CheckpointSaveStatus.saved,
        newWindowMatchCount: currentDraft.sample.recentMatchesWindow.length,
        overlapCount: 0,
        blockFingerprint: currentDraft.blockFingerprint,
      );
    }

    final currentTokens = currentDraft.sample.recentWindowTokens;
    final overlapCount = _countWindowOverlap(
      currentTokens: currentTokens,
      previousTokens: lastCheckpoint.sample.recentWindowTokens,
    );
    final newWindowMatchCount = currentTokens.length - overlapCount;
    final currentLatestMatchId = currentDraft.sample.latestMatchId;
    final previousLatestMatchId = lastCheckpoint.sample.latestMatchId;

    if (currentLatestMatchId != null &&
        previousLatestMatchId != null &&
        currentLatestMatchId <= previousLatestMatchId) {
      return CheckpointSaveDecision(
        accountId: currentDraft.accountId,
        status: CheckpointSaveStatus.skippedNoNewMatches,
        newWindowMatchCount: newWindowMatchCount,
        overlapCount: overlapCount,
        blockFingerprint: currentDraft.blockFingerprint,
      );
    }

    if (newWindowMatchCount == 0) {
      return CheckpointSaveDecision(
        accountId: currentDraft.accountId,
        status: CheckpointSaveStatus.skippedNoNewMatches,
        newWindowMatchCount: newWindowMatchCount,
        overlapCount: overlapCount,
        blockFingerprint: currentDraft.blockFingerprint,
      );
    }

    if (overlapCount >= _heavyOverlapThreshold) {
      return CheckpointSaveDecision(
        accountId: currentDraft.accountId,
        status: CheckpointSaveStatus.skippedDuplicateBlock,
        newWindowMatchCount: newWindowMatchCount,
        overlapCount: overlapCount,
        blockFingerprint: currentDraft.blockFingerprint,
      );
    }

    if (newWindowMatchCount >= _meaningfulNewWindowThreshold ||
        _hasMaterialCycleShift(
          currentDraft,
          lastCheckpoint,
          newWindowMatchCount: newWindowMatchCount,
        )) {
      return CheckpointSaveDecision(
        accountId: currentDraft.accountId,
        status: CheckpointSaveStatus.saved,
        newWindowMatchCount: newWindowMatchCount,
        overlapCount: overlapCount,
        blockFingerprint: currentDraft.blockFingerprint,
      );
    }

    return CheckpointSaveDecision(
      accountId: currentDraft.accountId,
      status: CheckpointSaveStatus.skippedNotMeaningfullyNew,
      newWindowMatchCount: newWindowMatchCount,
      overlapCount: overlapCount,
      blockFingerprint: currentDraft.blockFingerprint,
    );
  }

  int _countWindowOverlap({
    required List<String> currentTokens,
    required List<String> previousTokens,
  }) {
    final remainingCounts = <String, int>{};
    for (final token in previousTokens) {
      remainingCounts.update(token, (count) => count + 1, ifAbsent: () => 1);
    }

    var overlapCount = 0;
    for (final token in currentTokens) {
      final remaining = remainingCounts[token] ?? 0;
      if (remaining == 0) {
        continue;
      }

      overlapCount++;
      if (remaining == 1) {
        remainingCounts.remove(token);
      } else {
        remainingCounts[token] = remaining - 1;
      }
    }

    return overlapCount;
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

    if (currentDraft.sample.primaryRoleKey !=
        lastCheckpoint.sample.primaryRoleKey) {
      return true;
    }

    if (currentDraft.sample.hasClearRoleEstimate !=
        lastCheckpoint.sample.hasClearRoleEstimate) {
      return true;
    }

    return false;
  }
}
