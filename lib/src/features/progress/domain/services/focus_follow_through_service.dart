import '../../../checkpoints/domain/models/coaching_checkpoint.dart';
import '../../../insights/domain/models/coaching_insight.dart';
import '../models/focus_follow_through_check.dart';

class FocusFollowThroughService {
  const FocusFollowThroughService();

  FocusFollowThroughCheck build({
    required CoachingCheckpoint previousCheckpoint,
    required CoachingCheckpointSample currentSample,
    List<int> manualHeroBlockIds = const [],
    List<String> manualHeroBlockLabels = const [],
  }) {
    final savedHeroBlock = previousCheckpoint.savedSessionPlanHeroBlock;
    final manualHeroBlock = savedHeroBlock == null
        ? _manualHeroBlock(
            previousCheckpoint: previousCheckpoint,
            manualHeroBlockIds: manualHeroBlockIds,
            manualHeroBlockLabels: manualHeroBlockLabels,
          )
        : null;
    final checkpointSavedAt = previousCheckpoint.savedAt;
    final previousFocusLabel =
        savedHeroBlock?.label ??
        manualHeroBlock?.label ??
        _previousFocusLabel(previousCheckpoint);
    final comparisonLabel = savedHeroBlock != null
        ? 'Compared against the active 5-game block on staying inside the ${savedHeroBlock.label}.'
        : manualHeroBlock == null
        ? _comparisonLabel(previousCheckpoint)
        : 'Compared against your active manual setup on staying inside the ${manualHeroBlock.label}.';

    if (previousCheckpoint.sample.matchesAnalyzed < 5 ||
        currentSample.matchesAnalyzed < 5) {
      return FocusFollowThroughCheck.waiting(
        fallbackMessage: 'Need a bigger block before judging follow-through.',
        checkpointSavedAt: checkpointSavedAt,
        previousFocusLabel: previousFocusLabel,
        comparisonLabel: comparisonLabel,
      );
    }

    final previousHeroBlock =
        savedHeroBlock ?? manualHeroBlock ?? previousCheckpoint.focusHeroBlock;
    if (previousHeroBlock != null && previousHeroBlock.heroIds.isNotEmpty) {
      if (currentSample.recentMatchesWindow.length < 5) {
        return FocusFollowThroughCheck.waiting(
          fallbackMessage: 'Need a bigger block before judging follow-through.',
          checkpointSavedAt: checkpointSavedAt,
          previousFocusLabel: previousFocusLabel,
          comparisonLabel: comparisonLabel,
        );
      }

      return _judgeNamedHeroBlockFocus(
        previousHeroBlock: previousHeroBlock,
        currentSample: currentSample,
        checkpointSavedAt: checkpointSavedAt,
        previousFocusLabel: previousFocusLabel,
        comparisonLabel: comparisonLabel,
        blockDescriptor: savedHeroBlock != null
            ? 'the active 5-game block'
            : manualHeroBlock == null
            ? 'the last recommended hero block'
            : 'your active manual hero block',
      );
    }

    switch (previousCheckpoint.topInsightType) {
      case CoachingInsightType.earlyDeathRisk:
        return _judgeDeathsFocus(
          currentSample.averageDeaths,
          previousCheckpoint.sample.averageDeaths,
          checkpointSavedAt: checkpointSavedAt,
          previousFocusLabel: previousFocusLabel,
          comparisonLabel: comparisonLabel,
        );
      case CoachingInsightType.heroPoolSpread:
      case CoachingInsightType.comfortHeroDependence:
        return _judgeHeroPoolFocus(
          currentSample.uniqueHeroesPlayed,
          previousCheckpoint.sample.uniqueHeroesPlayed,
          checkpointSavedAt: checkpointSavedAt,
          previousFocusLabel: previousFocusLabel,
          comparisonLabel: comparisonLabel,
        );
      case CoachingInsightType.specializationRecommendation:
      case CoachingInsightType.weakRecentTrend:
      case CoachingInsightType.limitedConfidence:
      case null:
        return _judgeStableBlockFocus(
          currentSample: currentSample,
          previousSample: previousCheckpoint.sample,
          checkpointSavedAt: checkpointSavedAt,
          previousFocusLabel: previousFocusLabel,
          comparisonLabel: comparisonLabel,
        );
    }
  }

  FocusFollowThroughCheck _judgeNamedHeroBlockFocus({
    required CoachingCheckpointHeroBlock previousHeroBlock,
    required CoachingCheckpointSample currentSample,
    required DateTime checkpointSavedAt,
    required String previousFocusLabel,
    required String comparisonLabel,
    required String blockDescriptor,
  }) {
    final recentWindow = currentSample.recentMatchesWindow
        .take(5)
        .toList(growable: false);
    final insideBlockMatches = recentWindow
        .where((match) => previousHeroBlock.heroIds.contains(match.heroId))
        .toList(growable: false);
    final insideBlockCount = insideBlockMatches.length;
    final insideBlockWins = insideBlockMatches
        .where((match) => match.didWin)
        .length;
    final currentBlockWinRate = insideBlockCount == 0
        ? 0.0
        : insideBlockWins / insideBlockCount;
    final previousBlockWinRate = previousHeroBlock.winRate;

    if (insideBlockCount >= 4) {
      final status = currentBlockWinRate >= previousBlockWinRate
          ? FocusFollowThroughStatus.onTrack
          : FocusFollowThroughStatus.mixed;

      return FocusFollowThroughCheck.ready(
        status: status,
        detail: _namedHeroBlockResultLine(
          previousHeroBlock: previousHeroBlock,
          insideBlockCount: insideBlockCount,
          currentBlockWinRate: currentBlockWinRate,
          previousBlockWinRate: previousBlockWinRate,
        ),
        checkpointSavedAt: checkpointSavedAt,
        previousFocusLabel: previousFocusLabel,
        comparisonLabel: comparisonLabel,
      );
    }

    if (insideBlockCount >= 2) {
      return FocusFollowThroughCheck.ready(
        status: FocusFollowThroughStatus.mixed,
        detail:
            'You stayed inside the ${previousHeroBlock.label} in $insideBlockCount of the last 5 games. That is too much drift to judge the trend cleanly.',
        checkpointSavedAt: checkpointSavedAt,
        previousFocusLabel: previousFocusLabel,
        comparisonLabel: comparisonLabel,
      );
    }

    final detail = insideBlockCount == 0
        ? 'You drifted outside $blockDescriptor.'
        : 'You drifted outside $blockDescriptor. Only 1 of the last 5 games stayed in the ${previousHeroBlock.label}.';

    return FocusFollowThroughCheck.ready(
      status: FocusFollowThroughStatus.offTrack,
      detail: detail,
      checkpointSavedAt: checkpointSavedAt,
      previousFocusLabel: previousFocusLabel,
      comparisonLabel: comparisonLabel,
    );
  }

  FocusFollowThroughCheck _judgeDeathsFocus(
    double currentAverageDeaths,
    double previousAverageDeaths, {
    required DateTime checkpointSavedAt,
    required String previousFocusLabel,
    required String comparisonLabel,
  }) {
    if (currentAverageDeaths <= previousAverageDeaths - 1) {
      return FocusFollowThroughCheck.ready(
        status: FocusFollowThroughStatus.onTrack,
        detail: _deathsResultLine(
          currentAverageDeaths: currentAverageDeaths,
          previousAverageDeaths: previousAverageDeaths,
        ),
        checkpointSavedAt: checkpointSavedAt,
        previousFocusLabel: previousFocusLabel,
        comparisonLabel: comparisonLabel,
      );
    }

    if (currentAverageDeaths >= previousAverageDeaths + 1) {
      return FocusFollowThroughCheck.ready(
        status: FocusFollowThroughStatus.offTrack,
        detail: _deathsResultLine(
          currentAverageDeaths: currentAverageDeaths,
          previousAverageDeaths: previousAverageDeaths,
        ),
        checkpointSavedAt: checkpointSavedAt,
        previousFocusLabel: previousFocusLabel,
        comparisonLabel: comparisonLabel,
      );
    }

    return FocusFollowThroughCheck.ready(
      status: FocusFollowThroughStatus.mixed,
      detail: _deathsResultLine(
        currentAverageDeaths: currentAverageDeaths,
        previousAverageDeaths: previousAverageDeaths,
      ),
      checkpointSavedAt: checkpointSavedAt,
      previousFocusLabel: previousFocusLabel,
      comparisonLabel: comparisonLabel,
    );
  }

  FocusFollowThroughCheck _judgeHeroPoolFocus(
    int currentUniqueHeroes,
    int previousUniqueHeroes, {
    required DateTime checkpointSavedAt,
    required String previousFocusLabel,
    required String comparisonLabel,
  }) {
    if (currentUniqueHeroes < previousUniqueHeroes) {
      return FocusFollowThroughCheck.ready(
        status: FocusFollowThroughStatus.onTrack,
        detail: _heroPoolResultLine(
          currentUniqueHeroes: currentUniqueHeroes,
          previousUniqueHeroes: previousUniqueHeroes,
        ),
        checkpointSavedAt: checkpointSavedAt,
        previousFocusLabel: previousFocusLabel,
        comparisonLabel: comparisonLabel,
      );
    }

    if (currentUniqueHeroes > previousUniqueHeroes) {
      return FocusFollowThroughCheck.ready(
        status: FocusFollowThroughStatus.offTrack,
        detail: _heroPoolResultLine(
          currentUniqueHeroes: currentUniqueHeroes,
          previousUniqueHeroes: previousUniqueHeroes,
        ),
        checkpointSavedAt: checkpointSavedAt,
        previousFocusLabel: previousFocusLabel,
        comparisonLabel: comparisonLabel,
      );
    }

    return FocusFollowThroughCheck.ready(
      status: FocusFollowThroughStatus.mixed,
      detail: _heroPoolResultLine(
        currentUniqueHeroes: currentUniqueHeroes,
        previousUniqueHeroes: previousUniqueHeroes,
      ),
      checkpointSavedAt: checkpointSavedAt,
      previousFocusLabel: previousFocusLabel,
      comparisonLabel: comparisonLabel,
    );
  }

  FocusFollowThroughCheck _judgeStableBlockFocus({
    required CoachingCheckpointSample currentSample,
    required CoachingCheckpointSample previousSample,
    required DateTime checkpointSavedAt,
    required String previousFocusLabel,
    required String comparisonLabel,
  }) {
    final roleSignal = _roleConsistencySignal(currentSample, previousSample);
    final heroPoolDirection = _compareHeroPool(
      currentSample.uniqueHeroesPlayed,
      previousSample.uniqueHeroesPlayed,
    );
    final score = _heroPoolScore(heroPoolDirection) + roleSignal.score;

    if (score >= 2) {
      return FocusFollowThroughCheck.ready(
        status: FocusFollowThroughStatus.onTrack,
        detail: _stableBlockResultLine(
          currentSample: currentSample,
          previousSample: previousSample,
          heroPoolDirection: heroPoolDirection,
          roleSignal: roleSignal,
        ),
        checkpointSavedAt: checkpointSavedAt,
        previousFocusLabel: previousFocusLabel,
        comparisonLabel: comparisonLabel,
      );
    }

    if (score <= -2) {
      return FocusFollowThroughCheck.ready(
        status: FocusFollowThroughStatus.offTrack,
        detail: _stableBlockResultLine(
          currentSample: currentSample,
          previousSample: previousSample,
          heroPoolDirection: heroPoolDirection,
          roleSignal: roleSignal,
        ),
        checkpointSavedAt: checkpointSavedAt,
        previousFocusLabel: previousFocusLabel,
        comparisonLabel: comparisonLabel,
      );
    }

    return FocusFollowThroughCheck.ready(
      status: FocusFollowThroughStatus.mixed,
      detail: _stableBlockResultLine(
        currentSample: currentSample,
        previousSample: previousSample,
        heroPoolDirection: heroPoolDirection,
        roleSignal: roleSignal,
      ),
      checkpointSavedAt: checkpointSavedAt,
      previousFocusLabel: previousFocusLabel,
      comparisonLabel: comparisonLabel,
    );
  }

  String _previousFocusLabel(CoachingCheckpoint checkpoint) {
    if (checkpoint.focusHeroBlock != null) {
      return checkpoint.focusHeroBlock!.label;
    }

    final label = checkpoint.focusSourceLabel.trim();
    if (label.isNotEmpty) {
      return label;
    }

    return switch (checkpoint.topInsightType) {
      CoachingInsightType.earlyDeathRisk => 'Early death risk',
      CoachingInsightType.heroPoolSpread => 'Hero pool spread',
      CoachingInsightType.comfortHeroDependence => 'Comfort hero dependence',
      CoachingInsightType.weakRecentTrend => 'Weak recent trend',
      CoachingInsightType.limitedConfidence => 'Limited confidence',
      CoachingInsightType.specializationRecommendation =>
        'Specialization recommendation',
      null => 'Saved coaching focus',
    };
  }

  String _comparisonLabel(CoachingCheckpoint checkpoint) {
    if (checkpoint.focusHeroBlock != null) {
      return 'Compared against your last saved focus on staying inside the ${checkpoint.focusHeroBlock!.label}.';
    }

    return switch (checkpoint.topInsightType) {
      CoachingInsightType.earlyDeathRisk =>
        'Compared against your last saved focus on reducing deaths.',
      CoachingInsightType.heroPoolSpread =>
        'Compared against your last saved focus on narrowing your hero pool.',
      CoachingInsightType.comfortHeroDependence =>
        'Compared against your last saved focus on leaning into your comfort heroes.',
      CoachingInsightType.weakRecentTrend =>
        'Compared against your last saved focus on staying on one role and a stable hero block.',
      CoachingInsightType.specializationRecommendation =>
        'Compared against your last saved focus on narrowing to one role and a small hero block.',
      CoachingInsightType.limitedConfidence =>
        'Compared against your last saved focus on building a clearer sample before judging results.',
      null => 'Compared against your last saved coaching focus.',
    };
  }

  CoachingCheckpointHeroBlock? _manualHeroBlock({
    required CoachingCheckpoint previousCheckpoint,
    required List<int> manualHeroBlockIds,
    required List<String> manualHeroBlockLabels,
  }) {
    if (manualHeroBlockIds.isEmpty ||
        manualHeroBlockIds.length != manualHeroBlockLabels.length) {
      return null;
    }

    final previousBlockMatches = previousCheckpoint.sample.recentMatchesWindow
        .where((match) => manualHeroBlockIds.contains(match.heroId))
        .toList(growable: false);
    final wins = previousBlockMatches.where((match) => match.didWin).length;

    return CoachingCheckpointHeroBlock(
      heroIds: manualHeroBlockIds,
      heroLabels: manualHeroBlockLabels,
      wins: wins,
      losses: previousBlockMatches.length - wins,
    );
  }

  _RoleConsistencySignal _roleConsistencySignal(
    CoachingCheckpointSample currentSample,
    CoachingCheckpointSample previousSample,
  ) {
    if (currentSample.hasClearRoleEstimate) {
      if (!previousSample.hasClearRoleEstimate ||
          currentSample.primaryRoleKey == previousSample.primaryRoleKey) {
        return _RoleConsistencySignal.positive;
      }
    }

    if (!currentSample.hasClearRoleEstimate &&
        previousSample.hasClearRoleEstimate) {
      return _RoleConsistencySignal.negative;
    }

    return _RoleConsistencySignal.neutral;
  }

  _HeroPoolDirection _compareHeroPool(int currentHeroes, int previousHeroes) {
    if (currentHeroes < previousHeroes) {
      return _HeroPoolDirection.narrower;
    }

    if (currentHeroes > previousHeroes) {
      return _HeroPoolDirection.wider;
    }

    return _HeroPoolDirection.same;
  }

  int _heroPoolScore(_HeroPoolDirection direction) {
    return switch (direction) {
      _HeroPoolDirection.narrower => 2,
      _HeroPoolDirection.same => 0,
      _HeroPoolDirection.wider => -2,
    };
  }

  String _deathsResultLine({
    required double currentAverageDeaths,
    required double previousAverageDeaths,
  }) {
    if (currentAverageDeaths <= previousAverageDeaths - 1) {
      return 'Average deaths dropped from ${_formatAverageDeaths(previousAverageDeaths)} to ${_formatAverageDeaths(currentAverageDeaths)}.';
    }

    if (currentAverageDeaths >= previousAverageDeaths + 1) {
      return 'Average deaths rose from ${_formatAverageDeaths(previousAverageDeaths)} to ${_formatAverageDeaths(currentAverageDeaths)}.';
    }

    return 'Average deaths stayed mostly flat, moving from ${_formatAverageDeaths(previousAverageDeaths)} to ${_formatAverageDeaths(currentAverageDeaths)}.';
  }

  String _heroPoolResultLine({
    required int currentUniqueHeroes,
    required int previousUniqueHeroes,
  }) {
    if (currentUniqueHeroes < previousUniqueHeroes) {
      return 'Your hero pool narrowed from ${_heroCount(previousUniqueHeroes)} to ${_heroCount(currentUniqueHeroes)}.';
    }

    if (currentUniqueHeroes > previousUniqueHeroes) {
      return 'Your hero pool widened from ${_heroCount(previousUniqueHeroes)} to ${_heroCount(currentUniqueHeroes)}.';
    }

    return 'Your hero pool stayed at ${_heroCount(currentUniqueHeroes)}.';
  }

  String _stableBlockResultLine({
    required CoachingCheckpointSample currentSample,
    required CoachingCheckpointSample previousSample,
    required _HeroPoolDirection heroPoolDirection,
    required _RoleConsistencySignal roleSignal,
  }) {
    final heroLine = switch (heroPoolDirection) {
      _HeroPoolDirection.narrower =>
        'Your hero pool narrowed from ${_heroCount(previousSample.uniqueHeroesPlayed)} to ${_heroCount(currentSample.uniqueHeroesPlayed)}',
      _HeroPoolDirection.same =>
        'Your hero pool stayed at ${_heroCount(currentSample.uniqueHeroesPlayed)}',
      _HeroPoolDirection.wider =>
        'Your hero pool widened from ${_heroCount(previousSample.uniqueHeroesPlayed)} to ${_heroCount(currentSample.uniqueHeroesPlayed)}',
    };

    if (roleSignal == _RoleConsistencySignal.neutral) {
      if (heroPoolDirection == _HeroPoolDirection.same) {
        return '$heroLine, and your role pattern is still mixed.';
      }

      return '$heroLine.';
    }

    final conjunction = roleSignal == _RoleConsistencySignal.positive
        ? 'and'
        : 'but';
    final roleLine = roleSignal == _RoleConsistencySignal.positive
        ? 'your role pattern looks more consistent'
        : 'your role pattern looks less consistent';

    return '$heroLine, $conjunction $roleLine.';
  }

  String _namedHeroBlockResultLine({
    required CoachingCheckpointHeroBlock previousHeroBlock,
    required int insideBlockCount,
    required double currentBlockWinRate,
    required double previousBlockWinRate,
  }) {
    final adherenceLine =
        'You stayed inside the ${previousHeroBlock.label} in $insideBlockCount of the last 5 games.';

    if (currentBlockWinRate > previousBlockWinRate) {
      return '$adherenceLine Results there improved from ${_formatPercent(previousBlockWinRate)} to ${_formatPercent(currentBlockWinRate)}.';
    }

    if (currentBlockWinRate < previousBlockWinRate) {
      return '$adherenceLine Results there slipped from ${_formatPercent(previousBlockWinRate)} to ${_formatPercent(currentBlockWinRate)}.';
    }

    return '$adherenceLine Results there stayed stable at ${_formatPercent(currentBlockWinRate)}.';
  }

  String _formatAverageDeaths(double value) => value.toStringAsFixed(1);

  String _formatPercent(double value) => '${(value * 100).round()}%';

  String _heroCount(int count) => '$count ${count == 1 ? 'hero' : 'heroes'}';
}

enum _RoleConsistencySignal {
  positive(1),
  neutral(0),
  negative(-1);

  const _RoleConsistencySignal(this.score);

  final int score;
}

enum _HeroPoolDirection { narrower, same, wider }
