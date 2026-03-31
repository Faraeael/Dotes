import '../models/playtest_summary.dart';
import '../models/tester_feedback.dart';
import '../models/tester_feedback_record.dart';

class PlaytestSummaryService {
  const PlaytestSummaryService();

  PlaytestSummary build({
    required List<TesterFeedbackRecord> records,
    required TesterFeedbackRating? activeFilter,
  }) {
    final clearCount = _countByRating(records, TesterFeedbackRating.clear);
    final somewhatClearCount = _countByRating(
      records,
      TesterFeedbackRating.somewhatClear,
    );
    final confusingCount = _countByRating(
      records,
      TesterFeedbackRating.confusing,
    );
    final filtered = [
      for (final record in records)
        if (activeFilter == null || record.feedback.rating == activeFilter)
          record,
    ]..sort(_compareRecords);

    return PlaytestSummary(
      activeFilter: activeFilter,
      clearCount: clearCount,
      somewhatClearCount: somewhatClearCount,
      confusingCount: confusingCount,
      entries: [
        for (final record in filtered)
          PlaytestSummaryEntry(
            accountId: record.accountId,
            playerLabel: record.feedback.trimmedPlayerLabel ??
                'Account ${record.accountId}',
            accountLabel: record.feedback.hasPlayerLabel
                ? 'Account ${record.accountId}'
                : null,
            rating: record.feedback.rating,
            ratingLabel: record.feedback.rating.label,
            note: record.feedback.hasNote
                ? record.feedback.trimmedNote
                : 'No note yet.',
            savedAtLabel: _formatSavedAt(record.feedback.savedAt),
          ),
      ],
      emptyMessage: _emptyMessage(records, activeFilter),
    );
  }

  int _countByRating(
    List<TesterFeedbackRecord> records,
    TesterFeedbackRating rating,
  ) {
    return records.where((record) => record.feedback.rating == rating).length;
  }

  int _compareRecords(TesterFeedbackRecord left, TesterFeedbackRecord right) {
    final leftSavedAt = left.feedback.savedAt;
    final rightSavedAt = right.feedback.savedAt;
    if (leftSavedAt != null && rightSavedAt != null) {
      final timestampCompare = rightSavedAt.compareTo(leftSavedAt);
      if (timestampCompare != 0) {
        return timestampCompare;
      }
    } else if (leftSavedAt != null) {
      return -1;
    } else if (rightSavedAt != null) {
      return 1;
    }

    return left.accountId.compareTo(right.accountId);
  }

  String _emptyMessage(
    List<TesterFeedbackRecord> records,
    TesterFeedbackRating? activeFilter,
  ) {
    if (records.isEmpty) {
      return 'No local playtest notes yet.';
    }

    if (activeFilter == null) {
      return 'No playtest notes found.';
    }

    return 'No notes marked ${activeFilter.label} yet.';
  }

  String? _formatSavedAt(DateTime? savedAt) {
    if (savedAt == null) {
      return null;
    }

    final utc = savedAt.toUtc();
    final year = utc.year.toString().padLeft(4, '0');
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    final hour = utc.hour.toString().padLeft(2, '0');
    final minute = utc.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute UTC';
  }
}
