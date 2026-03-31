import '../../../checkpoints/domain/models/coaching_checkpoint.dart';
import '../../../player_import/domain/models/recent_match.dart';

class ReviewedBlockWindowService {
  const ReviewedBlockWindowService();

  static const int blockSize = 5;

  List<RecentMatch> build({
    required CoachingCheckpoint previousCheckpoint,
    required List<RecentMatch> currentMatches,
  }) {
    final matches =
        currentMatches
            .where(
              (match) => match.startedAt.isAfter(previousCheckpoint.savedAt),
            )
            .toList()
          ..sort(_compareMatchesByStartedAt);

    if (matches.length <= blockSize) {
      return matches;
    }

    return matches.take(blockSize).toList(growable: false);
  }

  int _compareMatchesByStartedAt(RecentMatch left, RecentMatch right) {
    final startedAtCompare = left.startedAt.compareTo(right.startedAt);
    if (startedAtCompare != 0) {
      return startedAtCompare;
    }

    return left.matchId.compareTo(right.matchId);
  }
}
