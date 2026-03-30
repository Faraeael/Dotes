import '../../../player_import/domain/models/recent_match.dart';
import '../models/comfort_core_summary.dart';

class ComfortCoreService {
  const ComfortCoreService();

  static const int _minimumReliableSample = 5;

  ComfortCoreSummary build(List<RecentMatch> matches) {
    if (matches.length < _minimumReliableSample) {
      return ComfortCoreSummary(
        conclusionType: ComfortCoreConclusionType.tinySample,
        conclusion:
            'Need at least $_minimumReliableSample recent matches before this comfort core read becomes useful.',
        totalMatches: matches.length,
        minimumMatches: _minimumReliableSample,
        topHeroes: const [],
        topHeroWins: 0,
        topHeroLosses: 0,
        otherHeroWins: 0,
        otherHeroLosses: 0,
      );
    }

    final heroUsage = _heroUsageCounts(matches);
    final heroWins = _heroWinCounts(matches);
    final sortedHeroIds = heroUsage.keys.toList()
      ..sort((left, right) {
        final usageCompare = heroUsage[right]!.compareTo(heroUsage[left]!);
        if (usageCompare != 0) {
          return usageCompare;
        }

        return left.compareTo(right);
      });

    final topHeroIds = sortedHeroIds.take(2).toList(growable: false);
    final topHeroes = topHeroIds
        .map(
          (heroId) => ComfortCoreHeroUsage(
            heroId: heroId,
            matches: heroUsage[heroId]!,
          ),
        )
        .toList(growable: false);
    final topHeroMatches = topHeroIds.fold<int>(
      0,
      (sum, heroId) => sum + heroUsage[heroId]!,
    );
    final totalWins = matches.where((match) => match.didWin).length;
    final topHeroWins = topHeroIds.fold<int>(
      0,
      (sum, heroId) => sum + (heroWins[heroId] ?? 0),
    );
    final topHeroLosses = topHeroMatches - topHeroWins;
    final otherHeroWins = totalWins - topHeroWins;
    final otherHeroMatches = matches.length - topHeroMatches;
    final otherHeroLosses = otherHeroMatches - otherHeroWins;
    final conclusionType = _chooseConclusionType(
      totalMatches: matches.length,
      totalWins: totalWins,
      topHeroMatches: topHeroMatches,
      topHeroWins: topHeroWins,
      otherHeroMatches: otherHeroMatches,
      otherHeroWins: otherHeroWins,
    );

    return ComfortCoreSummary(
      conclusionType: conclusionType,
      conclusion: _conclusionLabel(conclusionType),
      totalMatches: matches.length,
      minimumMatches: _minimumReliableSample,
      topHeroes: topHeroes,
      topHeroWins: topHeroWins,
      topHeroLosses: topHeroLosses,
      otherHeroWins: otherHeroWins,
      otherHeroLosses: otherHeroLosses,
    );
  }

  Map<int, int> _heroUsageCounts(List<RecentMatch> matches) {
    final usage = <int, int>{};

    for (final match in matches) {
      usage.update(match.heroId, (count) => count + 1, ifAbsent: () => 1);
    }

    return usage;
  }

  Map<int, int> _heroWinCounts(List<RecentMatch> matches) {
    final wins = <int, int>{};

    for (final match in matches) {
      if (!match.didWin) {
        continue;
      }

      wins.update(match.heroId, (count) => count + 1, ifAbsent: () => 1);
    }

    return wins;
  }

  ComfortCoreConclusionType _chooseConclusionType({
    required int totalMatches,
    required int totalWins,
    required int topHeroMatches,
    required int topHeroWins,
    required int otherHeroMatches,
    required int otherHeroWins,
  }) {
    final topHeroMatchShare = topHeroMatches / totalMatches;
    final topHeroWinShare = totalWins == 0 ? 0.0 : topHeroWins / totalWins;
    final topHeroWinRate = topHeroMatches == 0
        ? 0.0
        : topHeroWins / topHeroMatches;
    final otherHeroWinRate = otherHeroMatches == 0
        ? 0.0
        : otherHeroWins / otherHeroMatches;

    if (topHeroMatchShare >= 0.6 && totalWins > 0 && topHeroWinShare >= 0.75) {
      return ComfortCoreConclusionType.successInsideCore;
    }

    if (
      otherHeroMatches > 0 &&
      topHeroMatchShare >= 0.5 &&
      topHeroWinRate - otherHeroWinRate >= 0.25
    ) {
      return ComfortCoreConclusionType.outsideWeaker;
    }

    return ComfortCoreConclusionType.noClearCore;
  }

  String _conclusionLabel(ComfortCoreConclusionType type) {
    return switch (type) {
      ComfortCoreConclusionType.successInsideCore =>
        'Most of your recent success is inside a small comfort core.',
      ComfortCoreConclusionType.outsideWeaker =>
        'Results outside your top heroes are much weaker.',
      ComfortCoreConclusionType.noClearCore =>
        'Your sample is too spread out to identify a clear comfort core.',
      ComfortCoreConclusionType.tinySample =>
        'Need at least $_minimumReliableSample recent matches before this comfort core read becomes useful.',
    };
  }
}
