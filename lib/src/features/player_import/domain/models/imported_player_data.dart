import 'player_profile_summary.dart';
import 'recent_match.dart';

class ImportedPlayerData {
  const ImportedPlayerData({
    required this.profile,
    required this.recentMatches,
  });

  final PlayerProfileSummary profile;
  final List<RecentMatch> recentMatches;
}
