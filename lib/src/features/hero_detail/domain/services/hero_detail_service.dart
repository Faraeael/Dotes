import '../../../checkpoints/domain/models/coaching_checkpoint.dart';
import '../../../dashboard/domain/models/comfort_core_summary.dart';
import '../../../dashboard/domain/models/block_review.dart';
import '../../../dashboard/domain/models/session_plan.dart';
import '../../../dashboard/domain/services/reviewed_block_window_service.dart';
import '../../../meta_reference/domain/models/hero_meta_reference.dart';
import '../../../meta_reference/domain/services/hero_meta_summary_service.dart';
import '../../../player_import/domain/models/recent_match.dart';
import '../models/hero_detail.dart';

class HeroDetailService {
  const HeroDetailService({
    ReviewedBlockWindowService reviewedBlockWindowService =
        const ReviewedBlockWindowService(),
    HeroMetaSummaryService heroMetaSummaryService =
        const HeroMetaSummaryService(),
  }) : _reviewedBlockWindowService = reviewedBlockWindowService,
       _heroMetaSummaryService = heroMetaSummaryService;

  static const int minimumMatchesForStrongRead = 3;
  static const int _minimumHeroHistoryMatches = 2;
  static const double _strongerPickMargin = 0.1;
  static const double _weakerBlockMargin = 0.15;
  static const double _heroTrendMargin = 0.1;

  final ReviewedBlockWindowService _reviewedBlockWindowService;
  final HeroMetaSummaryService _heroMetaSummaryService;

  HeroDetail build({
    required int heroId,
    required List<RecentMatch> allMatches,
    required String Function(int heroId) heroLabelFor,
    HeroMetaReference? metaReference,
    String currentSupportedPatchLabel = '',
    ComfortCoreSummary? comfortCore,
    SessionPlan? sessionPlan,
    CoachingCheckpoint? previousCheckpoint,
    BlockReview? blockReview,
  }) {
    final heroMatches = allMatches
        .where((match) => match.heroId == heroId)
        .toList(growable: false);
    final sortedHeroMatches = heroMatches.toList()
      ..sort((left, right) {
        final startedAtCompare = right.startedAt.compareTo(left.startedAt);
        if (startedAtCompare != 0) {
          return startedAtCompare;
        }

        return right.matchId.compareTo(left.matchId);
      });

    final wins = heroMatches.where((match) => match.didWin).length;
    final losses = heroMatches.length - wins;
    final heroWinRate = heroMatches.isEmpty ? 0.0 : wins / heroMatches.length;
    final stableComfortCoreHeroIds = _stableComfortCoreHeroIds(comfortCore);
    final planHeroIds = sessionPlan?.heroBlockHeroIds ?? const <int>[];
    final hasNamedHeroBlock = planHeroIds.isNotEmpty;
    final isInComfortCore = stableComfortCoreHeroIds.contains(heroId);
    final isInCurrentPlan = planHeroIds.contains(heroId);
    final isOutsideCurrentPlan = hasNamedHeroBlock && !isInCurrentPlan;
    final benchmarkHeroIds = hasNamedHeroBlock
        ? planHeroIds
        : stableComfortCoreHeroIds;
    final benchmarkWinRate = _combinedWinRate(allMatches, benchmarkHeroIds);
    final overallWinRate =
        _combinedWinRate(
          allMatches,
          allMatches.map((match) => match.heroId).toSet().toList(),
        ) ??
        0.0;
    final hasStrongRead = heroMatches.length >= minimumMatchesForStrongRead;
    final isStrongerRecentPick =
        hasStrongRead && heroWinRate >= overallWinRate + _strongerPickMargin;
    final isWeakerThanTopBlock =
        hasStrongRead &&
        benchmarkWinRate != null &&
        !benchmarkHeroIds.contains(heroId) &&
        heroWinRate <= benchmarkWinRate - _weakerBlockMargin;
    final blockContext = _blockContext(
      heroId: heroId,
      allMatches: allMatches,
      previousCheckpoint: previousCheckpoint,
      blockReview: blockReview,
    );
    final tags = _buildTags(
      isInComfortCore: isInComfortCore,
      isInCurrentPlan: isInCurrentPlan,
      isOutsideCurrentPlan: isOutsideCurrentPlan,
    );
    final metaSummary = _heroMetaSummaryService.build(
      reference: metaReference,
      currentSupportedPatchLabel: currentSupportedPatchLabel,
      hasStrongRead: hasStrongRead,
      isInComfortCore: isInComfortCore,
      isInCurrentPlan: isInCurrentPlan,
      isOutsideCurrentPlan: isOutsideCurrentPlan,
      isStrongerRecentPick: isStrongerRecentPick,
      isWeakerThanTopBlock: isWeakerThanTopBlock,
    );

    return HeroDetail(
      heroId: heroId,
      heroName: heroLabelFor(heroId),
      matchesInSample: heroMatches.length,
      wins: wins,
      losses: losses,
      winRatePercentage: (heroWinRate * 100).round(),
      averageDeaths: _averageDouble(
        heroMatches.map((match) => match.deaths.toDouble()),
      ),
      averageKda: _averageDouble(heroMatches.map(_kdaRatio)),
      averageMatchDuration: _averageDuration(
        heroMatches.map((match) => match.duration),
      ),
      tags: tags,
      coachingRead: _coachingRead(
        hasStrongRead: hasStrongRead,
        isInComfortCore: isInComfortCore,
        isInCurrentPlan: isInCurrentPlan,
        isOutsideCurrentPlan: isOutsideCurrentPlan,
        isStrongerRecentPick: isStrongerRecentPick,
        isWeakerThanTopBlock: isWeakerThanTopBlock,
      ),
      rationaleLines: _rationaleLines(
        matchesInSample: heroMatches.length,
        isInComfortCore: isInComfortCore,
        isInCurrentPlan: isInCurrentPlan,
        isOutsideCurrentPlan: isOutsideCurrentPlan,
        isStrongerRecentPick: isStrongerRecentPick,
        isWeakerThanTopBlock: isWeakerThanTopBlock,
        blockContext: blockContext,
      ),
      trainingDecision: _trainingDecision(
        hasStrongRead: hasStrongRead,
        isInComfortCore: isInComfortCore,
        isInCurrentPlan: isInCurrentPlan,
        isStrongerRecentPick: isStrongerRecentPick,
        isOutsideCurrentPlan: isOutsideCurrentPlan,
        isWeakerThanTopBlock: isWeakerThanTopBlock,
      ),
      blockContext: blockContext,
      metaSummary: metaSummary,
      recentMatches: sortedHeroMatches,
    );
  }

  List<String> _rationaleLines({
    required int matchesInSample,
    required bool isInComfortCore,
    required bool isInCurrentPlan,
    required bool isOutsideCurrentPlan,
    required bool isStrongerRecentPick,
    required bool isWeakerThanTopBlock,
    required HeroBlockContext? blockContext,
  }) {
    final lines = <String>[
      if (matchesInSample < minimumMatchesForStrongRead)
        'Only $matchesInSample recent ${matchesInSample == 1 ? 'game' : 'games'} on this hero, so the read stays conservative.',
      if (isInCurrentPlan)
        'This hero is already inside your current named block.',
      if (isOutsideCurrentPlan)
        'This hero sits outside the current named block for now.',
      if (isInComfortCore)
        'Recent wins still point back to this hero as part of your comfort core.',
      if (isStrongerRecentPick)
        'Its recent win rate is stronger than your overall sample baseline.',
      if (isWeakerThanTopBlock)
        'Its recent results are trailing the heroes carrying your current block.',
    ];

    if (blockContext != null) {
      lines.add(_blockContextReason(blockContext));
    }

    if (lines.isEmpty) {
      return const [
        'This hero does not stand out strongly from the current sample yet.',
      ];
    }

    return lines;
  }

  String _blockContextReason(HeroBlockContext blockContext) {
    final appearanceLabel =
        '${blockContext.reviewedBlockAppearances} of ${blockContext.reviewedBlockGames} review games';
    return switch (blockContext.lastPlanStatus) {
      HeroLastPlanStatus.inLastNamedBlock =>
        'The last started block used this hero in $appearanceLabel.',
      HeroLastPlanStatus.outsideLastNamedBlock =>
        'The last started block moved outside this hero, with $appearanceLabel on it.',
      HeroLastPlanStatus.noNamedHeroBlock => blockContext.trendDetail,
    };
  }

  HeroBlockContext? _blockContext({
    required int heroId,
    required List<RecentMatch> allMatches,
    required CoachingCheckpoint? previousCheckpoint,
    required BlockReview? blockReview,
  }) {
    if (previousCheckpoint == null || blockReview == null) {
      return null;
    }

    final reviewedBlock = _reviewedBlockWindowService.build(
      previousCheckpoint: previousCheckpoint,
      currentMatches: allMatches,
    );
    final reviewedHeroMatches = reviewedBlock
        .where((match) => match.heroId == heroId)
        .toList(growable: false);
    final baselineMatches = previousCheckpoint.sample.recentMatchesWindow
        .where((match) => match.heroId == heroId)
        .toList(growable: false);
    final lastPlanStatus = _lastPlanStatus(previousCheckpoint, heroId);
    final trendStatus = _heroTrendStatus(
      baselineMatches: baselineMatches,
      reviewedBlockMatches: reviewedHeroMatches,
    );
    final baselineWinRate = _heroSampleWinRateFromCheckpoint(baselineMatches);
    final reviewedBlockWinRate = _heroSampleWinRateFromRecent(
      reviewedHeroMatches,
    );

    return HeroBlockContext(
      lastPlanStatus: lastPlanStatus,
      reviewedBlockAppearances: reviewedHeroMatches.length,
      reviewedBlockGames: blockReview.gamesLogged,
      trendStatus: trendStatus,
      trendDetail: _trendDetail(
        trendStatus: trendStatus,
        baselineWinRate: baselineWinRate,
        reviewedBlockWinRate: reviewedBlockWinRate,
      ),
      baselineWinRatePercentage: _toPercentOrNull(baselineWinRate),
      reviewedBlockWinRatePercentage: _toPercentOrNull(reviewedBlockWinRate),
    );
  }

  List<HeroDetailTag> _buildTags({
    required bool isInComfortCore,
    required bool isInCurrentPlan,
    required bool isOutsideCurrentPlan,
  }) {
    final tags = <HeroDetailTag>[];
    if (isInComfortCore) {
      tags.add(HeroDetailTag.comfortCore);
    }
    if (isInCurrentPlan) {
      tags.add(HeroDetailTag.inCurrentPlan);
    }
    if (isOutsideCurrentPlan) {
      tags.add(HeroDetailTag.outsideCurrentPlan);
    }

    return tags;
  }

  HeroLastPlanStatus _lastPlanStatus(
    CoachingCheckpoint previousCheckpoint,
    int heroId,
  ) {
    final savedHeroBlock =
        previousCheckpoint.savedSessionPlanHeroBlock ??
        previousCheckpoint.focusHeroBlock;
    if (savedHeroBlock == null || savedHeroBlock.heroIds.isEmpty) {
      return HeroLastPlanStatus.noNamedHeroBlock;
    }

    return savedHeroBlock.heroIds.contains(heroId)
        ? HeroLastPlanStatus.inLastNamedBlock
        : HeroLastPlanStatus.outsideLastNamedBlock;
  }

  HeroBlockTrendStatus _heroTrendStatus({
    required List<CoachingCheckpointMatchSummary> baselineMatches,
    required List<RecentMatch> reviewedBlockMatches,
  }) {
    if (baselineMatches.length < _minimumHeroHistoryMatches ||
        reviewedBlockMatches.length < _minimumHeroHistoryMatches) {
      return HeroBlockTrendStatus.notEnoughHistory;
    }

    final baselineWinRate =
        baselineMatches.where((match) => match.didWin).length /
        baselineMatches.length;
    final currentWinRate =
        reviewedBlockMatches.where((match) => match.didWin).length /
        reviewedBlockMatches.length;

    if (currentWinRate >= baselineWinRate + _heroTrendMargin) {
      return HeroBlockTrendStatus.improved;
    }

    if (currentWinRate <= baselineWinRate - _heroTrendMargin) {
      return HeroBlockTrendStatus.worse;
    }

    return HeroBlockTrendStatus.flat;
  }

  String _trendDetail({
    required HeroBlockTrendStatus trendStatus,
    required double? baselineWinRate,
    required double? reviewedBlockWinRate,
  }) {
    final baselineLabel = _percentageLabel(baselineWinRate);
    final reviewedLabel = _percentageLabel(reviewedBlockWinRate);

    return switch (trendStatus) {
      HeroBlockTrendStatus.improved ||
      HeroBlockTrendStatus.flat ||
      HeroBlockTrendStatus.worse =>
        'Win rate moved from $baselineLabel before the block to $reviewedLabel in the review window.',
      HeroBlockTrendStatus.notEnoughHistory =>
        'Need at least 2 baseline and 2 block games on this hero.',
    };
  }

  double? _heroSampleWinRateFromCheckpoint(
    List<CoachingCheckpointMatchSummary> matches,
  ) {
    if (matches.isEmpty) {
      return null;
    }

    final wins = matches.where((match) => match.didWin).length;
    return wins / matches.length;
  }

  double? _heroSampleWinRateFromRecent(List<RecentMatch> matches) {
    if (matches.isEmpty) {
      return null;
    }

    final wins = matches.where((match) => match.didWin).length;
    return wins / matches.length;
  }

  int? _toPercentOrNull(double? value) {
    if (value == null) {
      return null;
    }

    return (value * 100).round();
  }

  String _percentageLabel(double? value) {
    if (value == null) {
      return '-';
    }

    return '${(value * 100).round()}%';
  }

  List<int> _stableComfortCoreHeroIds(ComfortCoreSummary? comfortCore) {
    if (comfortCore == null || !comfortCore.isReady) {
      return const [];
    }

    final hasStableBlock =
        comfortCore.conclusionType ==
            ComfortCoreConclusionType.successInsideCore ||
        comfortCore.conclusionType == ComfortCoreConclusionType.outsideWeaker;
    if (!hasStableBlock) {
      return const [];
    }

    return comfortCore.topHeroes
        .map((hero) => hero.heroId)
        .toList(growable: false);
  }

  double? _combinedWinRate(List<RecentMatch> matches, List<int> heroIds) {
    if (heroIds.isEmpty) {
      return null;
    }

    final heroIdSet = heroIds.toSet();
    final filteredMatches = matches
        .where((match) => heroIdSet.contains(match.heroId))
        .toList(growable: false);
    if (filteredMatches.isEmpty) {
      return null;
    }

    final wins = filteredMatches.where((match) => match.didWin).length;
    return wins / filteredMatches.length;
  }

  double _kdaRatio(RecentMatch match) {
    final deaths = match.deaths == 0 ? 1 : match.deaths;
    return (match.kills + match.assists) / deaths;
  }

  double? _averageDouble(Iterable<double> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) {
      return null;
    }

    final total = list.fold<double>(0, (sum, value) => sum + value);
    return total / list.length;
  }

  Duration? _averageDuration(Iterable<Duration> durations) {
    final list = durations.toList(growable: false);
    if (list.isEmpty) {
      return null;
    }

    final totalSeconds = list.fold<int>(
      0,
      (sum, duration) => sum + duration.inSeconds,
    );
    return Duration(seconds: (totalSeconds / list.length).round());
  }

  String _coachingRead({
    required bool hasStrongRead,
    required bool isInComfortCore,
    required bool isInCurrentPlan,
    required bool isOutsideCurrentPlan,
    required bool isStrongerRecentPick,
    required bool isWeakerThanTopBlock,
  }) {
    if (!hasStrongRead) {
      return 'Too little recent data for a strong read.';
    }

    if (isInCurrentPlan && !isInComfortCore) {
      return 'This hero is currently in your session plan.';
    }

    if (isInComfortCore) {
      return 'This hero is currently part of your comfort core.';
    }

    if (isWeakerThanTopBlock) {
      return 'Results on this hero are weaker than your top block.';
    }

    if (isStrongerRecentPick) {
      return 'This hero is one of your stronger recent picks.';
    }

    if (isOutsideCurrentPlan) {
      return 'This hero sits outside the current plan for now.';
    }

    return 'This hero is not giving a strong recent signal yet.';
  }

  HeroTrainingDecision _trainingDecision({
    required bool hasStrongRead,
    required bool isInComfortCore,
    required bool isInCurrentPlan,
    required bool isStrongerRecentPick,
    required bool isOutsideCurrentPlan,
    required bool isWeakerThanTopBlock,
  }) {
    if (!hasStrongRead) {
      return HeroTrainingDecision.tooLittleData;
    }

    if (isInCurrentPlan) {
      return HeroTrainingDecision.keepInBlock;
    }

    if (isInComfortCore || isStrongerRecentPick) {
      return HeroTrainingDecision.goodBackupHero;
    }

    if (isOutsideCurrentPlan || isWeakerThanTopBlock) {
      return HeroTrainingDecision.testLaterNotNow;
    }

    return HeroTrainingDecision.testLaterNotNow;
  }
}
