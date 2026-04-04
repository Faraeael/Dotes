import '../../../checkpoints/domain/models/coaching_checkpoint.dart';
import '../../../insights/domain/models/coaching_insight.dart';
import '../../../player_import/domain/models/imported_player_data.dart';
import '../../../player_import/domain/models/recent_match.dart';
import '../../../progress/domain/models/focus_follow_through_check.dart';
import '../../../progress/domain/models/progress_check.dart';
import '../../../roles/domain/models/player_role.dart';
import '../../../roles/domain/services/role_inference_service.dart';
import '../models/block_review.dart';
import '../models/session_plan.dart';
import 'reviewed_block_window_service.dart';

class BlockReviewService {
  const BlockReviewService({
    RoleInferenceService roleInferenceService = const RoleInferenceService(),
    ReviewedBlockWindowService reviewedBlockWindowService =
        const ReviewedBlockWindowService(),
  }) : _roleInferenceService = roleInferenceService,
       _reviewedBlockWindowService = reviewedBlockWindowService;

  final RoleInferenceService _roleInferenceService;
  final ReviewedBlockWindowService _reviewedBlockWindowService;

  BlockReview build({
    required CoachingCheckpoint previousCheckpoint,
    required ImportedPlayerData currentImport,
    required SessionPlan? sessionPlan,
    required FocusFollowThroughCheck? followThroughCheck,
    required ProgressCheck? progressCheck,
  }) {
    final blockMatches = _postCheckpointBlock(
      previousCheckpoint: previousCheckpoint,
      currentMatches: currentImport.recentMatches,
    );
    final blockStatus =
        blockMatches.length >= ReviewedBlockWindowService.blockSize
        ? BlockReviewStatus.completed
        : BlockReviewStatus.inProgress;
    final adherence = _judgeAdherence(
      previousCheckpoint: previousCheckpoint,
      sessionPlan: sessionPlan,
      blockMatches: blockMatches,
    );
    final targetType = _targetType(
      previousCheckpoint: previousCheckpoint,
      sessionPlan: sessionPlan,
    );
    final targetResult = _judgeTargetResult(
      targetType: targetType,
      previousCheckpoint: previousCheckpoint,
      sessionPlan: sessionPlan,
      blockMatches: blockMatches,
      progressCheck: progressCheck,
    );
    final overallOutcome = _judgeOverallOutcome(
      blockStatus: blockStatus,
      adherence: adherence,
      targetResult: targetResult,
      followThroughCheck: followThroughCheck,
    );

    return BlockReview(
      blockStatus: blockStatus,
      gamesLogged: blockMatches.length,
      blockSize: ReviewedBlockWindowService.blockSize,
      adherence: adherence,
      targetResult: targetResult,
      overallOutcome: overallOutcome,
    );
  }

  List<RecentMatch> _postCheckpointBlock({
    required CoachingCheckpoint previousCheckpoint,
    required List<RecentMatch> currentMatches,
  }) {
    return _reviewedBlockWindowService.build(
      previousCheckpoint: previousCheckpoint,
      currentMatches: currentMatches,
    );
  }

  BlockReviewAdherence _judgeAdherence({
    required CoachingCheckpoint previousCheckpoint,
    required SessionPlan? sessionPlan,
    required List<RecentMatch> blockMatches,
  }) {
    if (blockMatches.isEmpty) {
      return BlockReviewAdherence.notEnoughGames;
    }

    final heroBlockIds = _heroBlockIds(
      previousCheckpoint: previousCheckpoint,
      sessionPlan: sessionPlan,
    );
    if (heroBlockIds.isNotEmpty) {
      final matchingGames = blockMatches
          .where((match) => heroBlockIds.contains(match.heroId))
          .length;
      return _adherenceFromMatchCount(
        matchingGames: matchingGames,
        totalGames: blockMatches.length,
      );
    }

    final roleBlock = _roleBlock(previousCheckpoint, sessionPlan);
    if (roleBlock != null) {
      final matchingGames = blockMatches
          .where(
            (match) =>
                _roleInferenceService.inferMatchRole(match).role == roleBlock,
          )
          .length;
      return _adherenceFromMatchCount(
        matchingGames: matchingGames,
        totalGames: blockMatches.length,
      );
    }

    return BlockReviewAdherence.noBlockSet;
  }

  BlockReviewAdherence _adherenceFromMatchCount({
    required int matchingGames,
    required int totalGames,
  }) {
    final share = totalGames == 0 ? 0.0 : matchingGames / totalGames;
    if (share >= 0.8) {
      return BlockReviewAdherence.stayedInsideBlock;
    }

    if (share >= 0.4) {
      return BlockReviewAdherence.partialDrift;
    }

    return BlockReviewAdherence.offBlock;
  }

  SessionPlanTargetType _targetType({
    required CoachingCheckpoint previousCheckpoint,
    required SessionPlan? sessionPlan,
  }) {
    final savedTargetType = previousCheckpoint.savedSessionPlan?.targetType;
    if (savedTargetType != null) {
      return savedTargetType;
    }

    return switch (previousCheckpoint.topInsightType) {
      CoachingInsightType.earlyDeathRisk => SessionPlanTargetType.deaths,
      CoachingInsightType.heroPoolSpread ||
      CoachingInsightType.specializationRecommendation ||
      CoachingInsightType.weakRecentTrend ||
      CoachingInsightType.limitedConfidence => SessionPlanTargetType.heroPool,
      CoachingInsightType.comfortHeroDependence =>
        previousCheckpoint.focusHeroBlock != null ||
                sessionPlan?.hasHeroSpecificBlock == true
            ? SessionPlanTargetType.comfortBlock
            : SessionPlanTargetType.heroPool,
      null => sessionPlan?.targetType ?? SessionPlanTargetType.heroPool,
    };
  }

  BlockReviewTargetResult _judgeTargetResult({
    required SessionPlanTargetType targetType,
    required CoachingCheckpoint previousCheckpoint,
    required SessionPlan? sessionPlan,
    required List<RecentMatch> blockMatches,
    required ProgressCheck? progressCheck,
  }) {
    return switch (targetType) {
      SessionPlanTargetType.deaths => _judgeDeathsTarget(
        previousCheckpoint: previousCheckpoint,
        blockMatches: blockMatches,
        progressCheck: progressCheck,
      ),
      SessionPlanTargetType.heroPool => _judgeHeroPoolTarget(
        previousCheckpoint: previousCheckpoint,
        blockMatches: blockMatches,
        progressCheck: progressCheck,
      ),
      SessionPlanTargetType.comfortBlock => _judgeComfortBlockTarget(
        previousCheckpoint: previousCheckpoint,
        sessionPlan: sessionPlan,
        blockMatches: blockMatches,
      ),
    };
  }

  BlockReviewTargetResult _judgeDeathsTarget({
    required CoachingCheckpoint previousCheckpoint,
    required List<RecentMatch> blockMatches,
    required ProgressCheck? progressCheck,
  }) {
    final comparison = _comparisonFor(progressCheck, 'Deaths');
    if (comparison != null && progressCheck!.isReady) {
      return switch (comparison.direction) {
        ProgressDirection.down => BlockReviewTargetResult.improved,
        ProgressDirection.same => BlockReviewTargetResult.flat,
        ProgressDirection.up => BlockReviewTargetResult.worse,
        ProgressDirection.narrower ||
        ProgressDirection.wider => BlockReviewTargetResult.flat,
      };
    }

    if (blockMatches.isEmpty) {
      return BlockReviewTargetResult.flat;
    }

    final currentAverageDeaths =
        blockMatches.fold<int>(0, (sum, match) => sum + match.deaths) /
        blockMatches.length;
    final previousAverageDeaths = previousCheckpoint.sample.averageDeaths;

    if (currentAverageDeaths <= previousAverageDeaths - 1) {
      return BlockReviewTargetResult.improved;
    }

    if (currentAverageDeaths >= previousAverageDeaths + 1) {
      return BlockReviewTargetResult.worse;
    }

    return BlockReviewTargetResult.flat;
  }

  BlockReviewTargetResult _judgeHeroPoolTarget({
    required CoachingCheckpoint previousCheckpoint,
    required List<RecentMatch> blockMatches,
    required ProgressCheck? progressCheck,
  }) {
    final comparison = _comparisonFor(progressCheck, 'Hero pool');
    if (comparison != null &&
        progressCheck!.isReady &&
        blockMatches.length >= ReviewedBlockWindowService.blockSize) {
      return switch (comparison.direction) {
        ProgressDirection.narrower => BlockReviewTargetResult.improved,
        ProgressDirection.same => BlockReviewTargetResult.flat,
        ProgressDirection.wider => BlockReviewTargetResult.worse,
        ProgressDirection.up ||
        ProgressDirection.down => BlockReviewTargetResult.flat,
      };
    }

    if (blockMatches.isEmpty) {
      return BlockReviewTargetResult.flat;
    }

    final currentUniqueHeroes = blockMatches
        .map((match) => match.heroId)
        .toSet()
        .length;
    final previousUniqueHeroes = previousCheckpoint.sample.uniqueHeroesPlayed;

    if (blockMatches.length < ReviewedBlockWindowService.blockSize) {
      if (currentUniqueHeroes > previousUniqueHeroes) {
        return BlockReviewTargetResult.worse;
      }

      if (blockMatches.length >= 4 &&
          currentUniqueHeroes + 1 < previousUniqueHeroes) {
        return BlockReviewTargetResult.improved;
      }

      return BlockReviewTargetResult.flat;
    }

    if (currentUniqueHeroes < previousUniqueHeroes) {
      return BlockReviewTargetResult.improved;
    }

    if (currentUniqueHeroes > previousUniqueHeroes) {
      return BlockReviewTargetResult.worse;
    }

    return BlockReviewTargetResult.flat;
  }

  BlockReviewTargetResult _judgeComfortBlockTarget({
    required CoachingCheckpoint previousCheckpoint,
    required SessionPlan? sessionPlan,
    required List<RecentMatch> blockMatches,
  }) {
    final heroBlockIds = _heroBlockIds(
      previousCheckpoint: previousCheckpoint,
      sessionPlan: sessionPlan,
    );
    if (heroBlockIds.isEmpty) {
      return BlockReviewTargetResult.flat;
    }

    final insideBlockMatches = blockMatches
        .where((match) => heroBlockIds.contains(match.heroId))
        .toList(growable: false);
    if (insideBlockMatches.isEmpty) {
      return BlockReviewTargetResult.worse;
    }

    if (insideBlockMatches.length < 2) {
      return BlockReviewTargetResult.flat;
    }

    final currentWinRate =
        insideBlockMatches.where((match) => match.didWin).length /
        insideBlockMatches.length;
    final previousWinRate = _previousHeroBlockWinRate(
      previousCheckpoint: previousCheckpoint,
      sessionPlan: sessionPlan,
      heroBlockIds: heroBlockIds,
    );

    if (currentWinRate >= previousWinRate + 0.1) {
      return BlockReviewTargetResult.improved;
    }

    if (currentWinRate <= previousWinRate - 0.1) {
      return BlockReviewTargetResult.worse;
    }

    return BlockReviewTargetResult.flat;
  }

  double _previousHeroBlockWinRate({
    required CoachingCheckpoint previousCheckpoint,
    required SessionPlan? sessionPlan,
    required List<int> heroBlockIds,
  }) {
    final savedSessionPlanHeroBlock = previousCheckpoint.savedSessionPlanHeroBlock;
    if (savedSessionPlanHeroBlock != null) {
      return savedSessionPlanHeroBlock.matches == 0
          ? previousCheckpoint.sample.winRate
          : savedSessionPlanHeroBlock.winRate;
    }

    if (sessionPlan?.usesManualHeroBlock == true) {
      final previousBlockMatches = previousCheckpoint.sample.recentMatchesWindow
          .where((match) => heroBlockIds.contains(match.heroId))
          .toList(growable: false);
      if (previousBlockMatches.isEmpty) {
        return previousCheckpoint.sample.winRate;
      }

      final wins = previousBlockMatches.where((match) => match.didWin).length;
      return wins / previousBlockMatches.length;
    }

    return previousCheckpoint.focusHeroBlock?.winRate ??
        previousCheckpoint.sample.winRate;
  }

  BlockReviewOutcome _judgeOverallOutcome({
    required BlockReviewStatus blockStatus,
    required BlockReviewAdherence adherence,
    required BlockReviewTargetResult targetResult,
    required FocusFollowThroughCheck? followThroughCheck,
  }) {
    if (blockStatus == BlockReviewStatus.inProgress ||
        adherence == BlockReviewAdherence.notEnoughGames) {
      return BlockReviewOutcome.mixed;
    }

    if (adherence == BlockReviewAdherence.noBlockSet) {
      if (targetResult == BlockReviewTargetResult.improved) {
        return BlockReviewOutcome.onTrack;
      }

      if (targetResult == BlockReviewTargetResult.worse) {
        return BlockReviewOutcome.offTrack;
      }

      if (followThroughCheck?.isReady == true) {
        return switch (followThroughCheck!.status!) {
          FocusFollowThroughStatus.onTrack => BlockReviewOutcome.onTrack,
          FocusFollowThroughStatus.mixed => BlockReviewOutcome.mixed,
          FocusFollowThroughStatus.offTrack => BlockReviewOutcome.offTrack,
        };
      }

      return BlockReviewOutcome.mixed;
    }

    if (adherence == BlockReviewAdherence.offBlock) {
      return targetResult == BlockReviewTargetResult.improved
          ? BlockReviewOutcome.mixed
          : BlockReviewOutcome.offTrack;
    }

    if (adherence == BlockReviewAdherence.partialDrift) {
      return targetResult == BlockReviewTargetResult.worse
          ? BlockReviewOutcome.offTrack
          : BlockReviewOutcome.mixed;
    }

    return targetResult == BlockReviewTargetResult.improved
        ? BlockReviewOutcome.onTrack
        : BlockReviewOutcome.mixed;
  }

  ProgressMetricComparison? _comparisonFor(
    ProgressCheck? progressCheck,
    String label,
  ) {
    if (progressCheck == null || !progressCheck.isReady) {
      return null;
    }

    for (final comparison in progressCheck.comparisons) {
      if (comparison.label == label) {
        return comparison;
      }
    }

    return null;
  }

  List<int> _heroBlockIds({
    required CoachingCheckpoint previousCheckpoint,
    required SessionPlan? sessionPlan,
  }) {
    final savedSessionPlanHeroBlock = previousCheckpoint.savedSessionPlanHeroBlock;
    if (savedSessionPlanHeroBlock != null &&
        savedSessionPlanHeroBlock.heroIds.isNotEmpty) {
      return savedSessionPlanHeroBlock.heroIds;
    }

    if (sessionPlan?.usesManualHeroBlock == true) {
      return sessionPlan!.heroBlockHeroIds;
    }

    final savedHeroBlock = previousCheckpoint.focusHeroBlock;
    if (savedHeroBlock != null && savedHeroBlock.heroIds.isNotEmpty) {
      return savedHeroBlock.heroIds;
    }

    if (sessionPlan?.hasHeroSpecificBlock == true) {
      return sessionPlan!.heroBlockHeroIds;
    }

    return const [];
  }

  PlayerRole? _roleBlock(
    CoachingCheckpoint previousCheckpoint,
    SessionPlan? sessionPlan,
  ) {
    final savedSessionPlanRole = _playerRoleForKey(
      previousCheckpoint.savedSessionPlan?.roleBlockKey,
    );
    if (savedSessionPlanRole != null) {
      return savedSessionPlanRole;
    }

    final checkpointRole = _playerRoleForKey(
      _checkpointRoleBlockKey(previousCheckpoint),
    );
    if (checkpointRole != null) {
      return checkpointRole;
    }

    return _playerRoleForKey(sessionPlan?.roleBlockKey);
  }

  String? _checkpointRoleBlockKey(CoachingCheckpoint previousCheckpoint) {
    final roleKey = previousCheckpoint.sample.primaryRoleKey;
    final role = _playerRoleForKey(roleKey);
    if (role == null || role == PlayerRole.unknown) {
      return null;
    }

    return previousCheckpoint.sample.likelyRoleSummaryLabel == role.label
        ? roleKey
        : null;
  }

  PlayerRole? _playerRoleForKey(String? value) {
    if (value == null) {
      return null;
    }

    for (final role in PlayerRole.values) {
      if (role.name == value) {
        return role;
      }
    }

    return null;
  }
}
