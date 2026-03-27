import '../../../checkpoints/domain/models/coaching_checkpoint.dart';
import '../../../insights/domain/models/coaching_insight.dart';
import '../models/focus_follow_through_check.dart';

class FocusFollowThroughService {
  const FocusFollowThroughService();

  FocusFollowThroughCheck build({
    required CoachingCheckpoint previousCheckpoint,
    required CoachingCheckpointSample currentSample,
  }) {
    if (previousCheckpoint.sample.matchesAnalyzed < 5 ||
        currentSample.matchesAnalyzed < 5) {
      return const FocusFollowThroughCheck.waiting(
        fallbackMessage: 'Need a bigger block before judging follow-through.',
      );
    }

    switch (previousCheckpoint.topInsightType) {
      case CoachingInsightType.earlyDeathRisk:
        return _judgeDeathsFocus(
          currentSample.averageDeaths,
          previousCheckpoint.sample.averageDeaths,
        );
      case CoachingInsightType.heroPoolSpread:
      case CoachingInsightType.comfortHeroDependence:
        return _judgeHeroPoolFocus(
          currentSample.uniqueHeroesPlayed,
          previousCheckpoint.sample.uniqueHeroesPlayed,
        );
      case CoachingInsightType.specializationRecommendation:
      case CoachingInsightType.weakRecentTrend:
      case CoachingInsightType.limitedConfidence:
      case null:
        return _judgeStableBlockFocus(
          currentSample: currentSample,
          previousSample: previousCheckpoint.sample,
        );
    }
  }

  FocusFollowThroughCheck _judgeDeathsFocus(
    double currentAverageDeaths,
    double previousAverageDeaths,
  ) {
    if (currentAverageDeaths <= previousAverageDeaths - 1) {
      return const FocusFollowThroughCheck.ready(
        status: FocusFollowThroughStatus.onTrack,
        detail: 'Average deaths are down since the last checkpoint.',
      );
    }

    if (currentAverageDeaths >= previousAverageDeaths + 1) {
      return const FocusFollowThroughCheck.ready(
        status: FocusFollowThroughStatus.offTrack,
        detail: 'Average deaths are up since the last checkpoint.',
      );
    }

    return const FocusFollowThroughCheck.ready(
        status: FocusFollowThroughStatus.mixed,
        detail: 'Average deaths look mostly flat since the last checkpoint.',
      );
  }

  FocusFollowThroughCheck _judgeHeroPoolFocus(
    int currentUniqueHeroes,
    int previousUniqueHeroes,
  ) {
    if (currentUniqueHeroes < previousUniqueHeroes) {
      return const FocusFollowThroughCheck.ready(
        status: FocusFollowThroughStatus.onTrack,
        detail: 'Hero usage is narrower than the last checkpoint.',
      );
    }

    if (currentUniqueHeroes > previousUniqueHeroes) {
      return const FocusFollowThroughCheck.ready(
        status: FocusFollowThroughStatus.offTrack,
        detail: 'Hero usage is wider than the last checkpoint.',
      );
    }

    return const FocusFollowThroughCheck.ready(
        status: FocusFollowThroughStatus.mixed,
        detail: 'Hero usage looks steady since the last checkpoint.',
      );
  }

  FocusFollowThroughCheck _judgeStableBlockFocus({
    required CoachingCheckpointSample currentSample,
    required CoachingCheckpointSample previousSample,
  }) {
    final roleSignal = _roleConsistencySignal(
      currentSample,
      previousSample,
    );
    final heroPoolDirection = _compareHeroPool(
      currentSample.uniqueHeroesPlayed,
      previousSample.uniqueHeroesPlayed,
    );
    final score = _heroPoolScore(heroPoolDirection) + roleSignal.score;

    if (score >= 2) {
      return FocusFollowThroughCheck.ready(
        status: FocusFollowThroughStatus.onTrack,
        detail: _stableBlockDetail(
          heroPoolDirection: heroPoolDirection,
          roleSignal: roleSignal,
          onTrack: true,
        ),
      );
    }

    if (score <= -2) {
      return FocusFollowThroughCheck.ready(
        status: FocusFollowThroughStatus.offTrack,
        detail: _stableBlockDetail(
          heroPoolDirection: heroPoolDirection,
          roleSignal: roleSignal,
          onTrack: false,
        ),
      );
    }

    return FocusFollowThroughCheck.ready(
      status: FocusFollowThroughStatus.mixed,
      detail: _mixedStableBlockDetail(
        heroPoolDirection: heroPoolDirection,
        roleSignal: roleSignal,
      ),
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

  String _stableBlockDetail({
    required _HeroPoolDirection heroPoolDirection,
    required _RoleConsistencySignal roleSignal,
    required bool onTrack,
  }) {
    if (heroPoolDirection == _HeroPoolDirection.narrower &&
        roleSignal == _RoleConsistencySignal.positive) {
      return onTrack
          ? 'Since the last checkpoint, the sample is tighter on heroes and more consistent on role pattern.'
          : 'Since the last checkpoint, the sample is broader on heroes and less consistent on role pattern.';
    }

    if (heroPoolDirection == _HeroPoolDirection.narrower) {
      return 'Hero usage is tighter since the last checkpoint.';
    }

    if (heroPoolDirection == _HeroPoolDirection.wider) {
      return 'The sample is broader than the last checkpoint focus asked for.';
    }

    if (roleSignal == _RoleConsistencySignal.positive) {
      return 'The role pattern looks a bit cleaner since the last checkpoint.';
    }

    return 'The sample is not lining up cleanly with the last checkpoint focus yet.';
  }

  String _mixedStableBlockDetail({
    required _HeroPoolDirection heroPoolDirection,
    required _RoleConsistencySignal roleSignal,
  }) {
    if (heroPoolDirection == _HeroPoolDirection.narrower &&
        roleSignal != _RoleConsistencySignal.negative) {
      return 'Hero usage is tighter, but the role pattern is not fully settled yet.';
    }

    if (heroPoolDirection == _HeroPoolDirection.same &&
        roleSignal == _RoleConsistencySignal.positive) {
      return 'Hero usage is steady, and the role pattern still looks consistent.';
    }

    if (heroPoolDirection == _HeroPoolDirection.wider &&
        roleSignal == _RoleConsistencySignal.positive) {
      return 'The role pattern still looks consistent, but hero usage is still broad.';
    }

    return 'The current sample only partly matches the last checkpoint focus.';
  }
}

enum _RoleConsistencySignal {
  positive(1),
  neutral(0),
  negative(-1);

  const _RoleConsistencySignal(this.score);

  final int score;
}

enum _HeroPoolDirection {
  narrower,
  same,
  wider,
}
