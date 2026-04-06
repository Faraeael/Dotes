import '../models/play_frequency.dart';
import '../models/recent_match.dart';

/// Computes a [PlayFrequency] value object from a player's recent match list.
///
/// This is a pure, stateless service — no constructor dependencies.
class PlayFrequencyService {
  const PlayFrequencyService();

  /// Derives play cadence and recommended block size from [matches].
  ///
  /// Returns null when [matches] is empty (no data to work with).
  PlayFrequency? compute(List<RecentMatch> matches) {
    if (matches.isEmpty) return null;

    final now = DateTime.now();
    final cutoff7 = now.subtract(const Duration(days: 7));
    final cutoff14 = now.subtract(const Duration(days: 14));
    final cutoff30 = now.subtract(const Duration(days: 30));

    // Sort descending so first entry is the most recent match.
    final sorted = [...matches]..sort(
      (a, b) => b.startedAt.compareTo(a.startedAt),
    );

    final lastMatchTime = sorted.first.startedAt;
    final daysSince = now.difference(lastMatchTime).inDays;

    final gamesLast7 =
        sorted.where((m) => m.startedAt.isAfter(cutoff7)).length;
    final gamesLast14 =
        sorted.where((m) => m.startedAt.isAfter(cutoff14)).length;
    final hasAnyIn30Days = sorted.any((m) => m.startedAt.isAfter(cutoff30));

    final cadence = _computeCadence(
      daysSince: daysSince,
      gamesLast7: gamesLast7,
      gamesLast14: gamesLast14,
      hasAnyIn30Days: hasAnyIn30Days,
    );

    return PlayFrequency(
      gamesLast7Days: gamesLast7,
      gamesLast14Days: gamesLast14,
      daysSinceLastMatch: daysSince,
      cadence: cadence,
    );
  }

  PlayCadence _computeCadence({
    required int daysSince,
    required int gamesLast7,
    required int gamesLast14,
    required bool hasAnyIn30Days,
  }) {
    if (!hasAnyIn30Days) return PlayCadence.returning;
    if (gamesLast7 >= 7) return PlayCadence.daily;
    if (gamesLast7 >= 3) return PlayCadence.severalTimesAWeek;
    if (gamesLast7 >= 1 && gamesLast14 >= 3) return PlayCadence.weekly;
    return PlayCadence.occasional;
  }
}
