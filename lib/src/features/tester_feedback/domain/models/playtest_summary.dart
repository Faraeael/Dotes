import 'tester_feedback.dart';

class PlaytestSummary {
  const PlaytestSummary({
    required this.activeFilter,
    required this.clearCount,
    required this.somewhatClearCount,
    required this.confusingCount,
    required this.entries,
    required this.emptyMessage,
  });

  final TesterFeedbackRating? activeFilter;
  final int clearCount;
  final int somewhatClearCount;
  final int confusingCount;
  final List<PlaytestSummaryEntry> entries;
  final String emptyMessage;

  bool get hasEntries => entries.isNotEmpty;
}

class PlaytestSummaryEntry {
  const PlaytestSummaryEntry({
    required this.accountId,
    required this.playerLabel,
    required this.rating,
    required this.ratingLabel,
    required this.note,
    this.accountLabel,
    this.savedAtLabel,
  });

  final int accountId;
  final String playerLabel;
  final String? accountLabel;
  final TesterFeedbackRating rating;
  final String ratingLabel;
  final String note;
  final String? savedAtLabel;
}
