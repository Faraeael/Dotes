/// How often a player plays Dota 2, inferred from recent match timestamps.
enum PlayCadence {
  /// ≥ 7 games in the last 7 days.
  daily,

  /// 3–6 games in the last 7 days.
  severalTimesAWeek,

  /// 1–2 games in last 7 days AND ≥ 3 in last 14 days.
  weekly,

  /// Any other active cadence that doesn't meet the above thresholds.
  occasional,

  /// No match in the last 30 days.
  returning;
}

/// Derived value object describing how frequently the player plays.
///
/// Created by [PlayFrequencyService] from the player's recent match history.
class PlayFrequency {
  const PlayFrequency({
    required this.gamesLast7Days,
    required this.gamesLast14Days,
    required this.daysSinceLastMatch,
    required this.cadence,
  });

  final int gamesLast7Days;
  final int gamesLast14Days;
  final int daysSinceLastMatch;
  final PlayCadence cadence;

  /// Recommended game-block size based on cadence.
  ///
  /// Daily players get 10-game blocks for richer signal.
  /// All others get 5-game blocks (conservative default).
  int get recommendedBlockSize =>
      cadence == PlayCadence.daily ? 10 : 5;

  /// Short human-readable label for the context banner.
  String get cadenceLabel => switch (cadence) {
    PlayCadence.daily => 'daily player',
    PlayCadence.severalTimesAWeek => '~$gamesLast7Days×/week',
    PlayCadence.weekly => '~1–2×/week',
    PlayCadence.occasional => 'occasional',
    PlayCadence.returning => 'returning player',
  };
}
