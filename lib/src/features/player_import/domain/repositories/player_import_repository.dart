import '../../../../core/result/result.dart';
import '../models/player_profile_summary.dart';
import '../models/recent_match.dart';

abstract class PlayerImportRepository {
  Future<Result<PlayerProfileSummary>> fetchPlayerProfileSummary(
    String accountId,
  );

  Future<Result<List<RecentMatch>>> fetchRecentMatches(String accountId);
}
