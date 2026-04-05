import '../../../matches/presentation/utils/hero_labels.dart';
import '../../../player_import/domain/models/imported_player_data.dart';
import '../../../roles/domain/models/sample_role_summary.dart';

class HeroWinRateStat {
  const HeroWinRateStat({
    required this.heroName,
    required this.games,
    required this.winRatePercent,
  });

  final String heroName;
  final int games;
  final int winRatePercent;
}

class ImportedSampleSummary {
  const ImportedSampleSummary({
    required this.matchesAnalyzed,
    required this.wins,
    required this.losses,
    required this.winRateLabel,
    required this.uniqueHeroesPlayed,
    required this.mostPlayedHeroLabel,
    required this.primaryRoleLabel,
    required this.roleReasonLabel,
    required this.roleMixDetailsLabel,
    required this.roleReadLabel,
    required this.primaryRoleAdherenceLabel,
    required this.topHeroes,
  });

  final int matchesAnalyzed;
  final int wins;
  final int losses;
  final String winRateLabel;
  final int uniqueHeroesPlayed;
  final String? mostPlayedHeroLabel;
  final String primaryRoleLabel;
  final String roleReasonLabel;
  final String? roleMixDetailsLabel;
  final String roleReadLabel;
  final String? primaryRoleAdherenceLabel;
  final List<HeroWinRateStat> topHeroes;

  factory ImportedSampleSummary.fromImportedPlayer(
    ImportedPlayerData importedPlayer,
    SampleRoleSummary roleSummary,
  ) {
    final matches = importedPlayer.recentMatches;
    final wins = matches.where((match) => match.didWin).length;
    final losses = matches.length - wins;
    final winRate = matches.isEmpty ? 0 : ((wins / matches.length) * 100).round();
    final heroUsage = <int, int>{};

    for (final match in matches) {
      heroUsage.update(match.heroId, (count) => count + 1, ifAbsent: () => 1);
    }

    final mostPlayedHeroId = heroUsage.entries.fold<int?>(
      null,
      (currentBest, entry) {
        if (currentBest == null) {
          return entry.key;
        }

        final currentBestCount = heroUsage[currentBest]!;
        if (entry.value > currentBestCount) {
          return entry.key;
        }

        if (entry.value == currentBestCount && entry.key < currentBest) {
          return entry.key;
        }

        return currentBest;
      },
    );

    // Compute per-hero win rates for top heroes section.
    final heroWins = <int, int>{};
    for (final match in matches) {
      heroWins.update(
        match.heroId,
        (w) => w + (match.didWin ? 1 : 0),
        ifAbsent: () => match.didWin ? 1 : 0,
      );
    }
    final qualifyingHeroes = heroUsage.entries
        .where((e) => e.value >= 3)
        .toList()
      ..sort((a, b) {
        final byGames = b.value.compareTo(a.value);
        if (byGames != 0) return byGames;
        return a.key.compareTo(b.key);
      });
    final topHeroes = qualifyingHeroes.length < 2
        ? const <HeroWinRateStat>[]
        : qualifyingHeroes.take(3).map((e) {
            final games = e.value;
            final w = heroWins[e.key] ?? 0;
            return HeroWinRateStat(
              heroName: heroDisplayName(e.key),
              games: games,
              winRatePercent: (w / games * 100).round(),
            );
          }).toList();

    // Compute role adherence label (null when read is unreliable).
    final primaryRoleAdherenceLabel =
        roleSummary.readType != SampleRoleReadType.smallSample &&
                roleSummary.readType != SampleRoleReadType.unclearSignals
            ? '${(roleSummary.primaryRoleShare * 100).toStringAsFixed(0)}%'
            : null;

    return ImportedSampleSummary(
      matchesAnalyzed: matches.length,
      wins: wins,
      losses: losses,
      winRateLabel: '$winRate%',
      uniqueHeroesPlayed: heroUsage.length,
      mostPlayedHeroLabel: mostPlayedHeroId == null
          ? null
          : heroDisplayName(mostPlayedHeroId),
      primaryRoleLabel: roleSummary.primaryRoleLabel,
      roleReasonLabel: roleSummary.reasonLabel,
      roleMixDetailsLabel: roleSummary.roleMixDetailsLabel,
      roleReadLabel: roleSummary.estimateStrengthLabel,
      primaryRoleAdherenceLabel: primaryRoleAdherenceLabel,
      topHeroes: topHeroes,
    );
  }
}
