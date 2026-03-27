import '../../../player_import/domain/models/recent_match.dart';
import '../models/progress_check.dart';

class ProgressCheckService {
  const ProgressCheckService();

  static const int _smallBlockSize = 5;
  static const int _largeBlockSize = 10;

  ProgressCheck build(List<RecentMatch> matches) {
    final orderedMatches = [...matches]..sort(_compareMatchesByRecency);
    final blockSize = _selectBlockSize(orderedMatches.length);

    if (blockSize == null) {
      return const ProgressCheck.tooSmall(
        fallbackMessage:
            'Need at least 10 recent matches before this progress check becomes useful.',
      );
    }

    final currentBlock = orderedMatches.take(blockSize).toList(growable: false);
    final previousBlock = orderedMatches
        .skip(blockSize)
        .take(blockSize)
        .toList(growable: false);

    return ProgressCheck.ready(
      blockSize: blockSize,
      comparisons: [
        _buildWinRateComparison(currentBlock, previousBlock),
        _buildDeathsComparison(currentBlock, previousBlock),
        _buildHeroPoolComparison(currentBlock, previousBlock),
      ],
    );
  }

  ProgressMetricComparison _buildWinRateComparison(
    List<RecentMatch> currentBlock,
    List<RecentMatch> previousBlock,
  ) {
    final currentWinRate = _winRate(currentBlock);
    final previousWinRate = _winRate(previousBlock);

    return ProgressMetricComparison(
      label: 'Win rate',
      direction: _compareWinRate(currentWinRate, previousWinRate),
      currentValueLabel: _formatPercent(currentWinRate),
      previousValueLabel: _formatPercent(previousWinRate),
    );
  }

  ProgressMetricComparison _buildDeathsComparison(
    List<RecentMatch> currentBlock,
    List<RecentMatch> previousBlock,
  ) {
    final currentAverageDeaths = _averageDeaths(currentBlock);
    final previousAverageDeaths = _averageDeaths(previousBlock);

    return ProgressMetricComparison(
      label: 'Deaths',
      direction: _compareAverageDeaths(
        currentAverageDeaths,
        previousAverageDeaths,
      ),
      currentValueLabel: currentAverageDeaths.toStringAsFixed(1),
      previousValueLabel: previousAverageDeaths.toStringAsFixed(1),
    );
  }

  ProgressMetricComparison _buildHeroPoolComparison(
    List<RecentMatch> currentBlock,
    List<RecentMatch> previousBlock,
  ) {
    final currentUniqueHeroes = _uniqueHeroCount(currentBlock);
    final previousUniqueHeroes = _uniqueHeroCount(previousBlock);

    return ProgressMetricComparison(
      label: 'Hero pool',
      direction: _compareHeroPool(currentUniqueHeroes, previousUniqueHeroes),
      currentValueLabel: '$currentUniqueHeroes heroes',
      previousValueLabel: '$previousUniqueHeroes heroes',
    );
  }

  int? _selectBlockSize(int matchCount) {
    if (matchCount >= _largeBlockSize * 2) {
      return _largeBlockSize;
    }

    if (matchCount >= _smallBlockSize * 2) {
      return _smallBlockSize;
    }

    return null;
  }

  int _compareMatchesByRecency(RecentMatch left, RecentMatch right) {
    final startedAtCompare = right.startedAt.compareTo(left.startedAt);
    if (startedAtCompare != 0) {
      return startedAtCompare;
    }

    return right.matchId.compareTo(left.matchId);
  }

  double _winRate(List<RecentMatch> matches) {
    final wins = matches.where((match) => match.didWin).length;
    return wins / matches.length;
  }

  double _averageDeaths(List<RecentMatch> matches) {
    final totalDeaths = matches.fold<int>(
      0,
      (sum, match) => sum + match.deaths,
    );

    return totalDeaths / matches.length;
  }

  int _uniqueHeroCount(List<RecentMatch> matches) {
    return matches.map((match) => match.heroId).toSet().length;
  }

  ProgressDirection _compareWinRate(double current, double previous) {
    if (current >= previous + 0.1) {
      return ProgressDirection.up;
    }

    if (current <= previous - 0.1) {
      return ProgressDirection.down;
    }

    return ProgressDirection.same;
  }

  ProgressDirection _compareAverageDeaths(double current, double previous) {
    if (current <= previous - 1) {
      return ProgressDirection.down;
    }

    if (current >= previous + 1) {
      return ProgressDirection.up;
    }

    return ProgressDirection.same;
  }

  ProgressDirection _compareHeroPool(int current, int previous) {
    if (current < previous) {
      return ProgressDirection.narrower;
    }

    if (current > previous) {
      return ProgressDirection.wider;
    }

    return ProgressDirection.same;
  }

  String _formatPercent(double value) {
    return '${(value * 100).round()}%';
  }
}
