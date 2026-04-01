import 'player_profile_summary.dart';
import 'imported_player_source.dart';
import 'recent_match.dart';

class ImportedPlayerData {
  const ImportedPlayerData({
    required this.profile,
    required this.recentMatches,
    this.source = const ImportedPlayerSource.openDota(),
  });

  final PlayerProfileSummary profile;
  final List<RecentMatch> recentMatches;
  final ImportedPlayerSource source;
}
