import 'package:dotes/src/features/tester_feedback/domain/models/tester_feedback.dart';
import 'package:dotes/src/features/tester_feedback/domain/models/tester_feedback_record.dart';
import 'package:dotes/src/features/tester_feedback/domain/services/playtest_summary_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaytestSummaryService', () {
    const service = PlaytestSummaryService();

    test('feedback ratings group correctly', () {
      final summary = service.build(
        records: _records(),
        activeFilter: TesterFeedbackRating.confusing,
      );

      expect(summary.clearCount, 1);
      expect(summary.somewhatClearCount, 1);
      expect(summary.confusingCount, 2);
      expect(summary.entries, hasLength(2));
      expect(summary.entries.every((entry) => entry.rating == TesterFeedbackRating.confusing), isTrue);
    });

    test('empty-state fallback stays clear', () {
      final summary = service.build(records: const [], activeFilter: null);

      expect(summary.hasEntries, isFalse);
      expect(summary.emptyMessage, 'No local playtest notes yet.');
    });
  });
}

List<TesterFeedbackRecord> _records() {
  return [
    TesterFeedbackRecord(
      accountId: 86745912,
      feedback: TesterFeedback(
        rating: TesterFeedbackRating.clear,
        note: 'I would follow this plan.',
        playerLabel: 'Week 1 Player',
        savedAt: DateTime.utc(2026, 3, 31, 8, 0),
      ),
    ),
    TesterFeedbackRecord(
      accountId: 2222,
      feedback: TesterFeedback(
        rating: TesterFeedbackRating.somewhatClear,
        note: 'The verdict took a second read.',
        playerLabel: 'Second Tester',
        savedAt: DateTime.utc(2026, 3, 31, 9, 0),
      ),
    ),
    TesterFeedbackRecord(
      accountId: 3333,
      feedback: TesterFeedback(
        rating: TesterFeedbackRating.confusing,
        note: 'I was not sure which section mattered first.',
        playerLabel: 'Third Tester',
        savedAt: DateTime.utc(2026, 3, 31, 10, 0),
      ),
    ),
    TesterFeedbackRecord(
      accountId: 4444,
      feedback: TesterFeedback(
        rating: TesterFeedbackRating.confusing,
        note: 'The focus card felt noisy.',
        savedAt: DateTime.utc(2026, 3, 31, 7, 30),
      ),
    ),
  ];
}
