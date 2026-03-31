import 'package:dotes/src/features/checkpoints/domain/services/checkpoint_save_policy_service.dart';
import 'package:dotes/src/features/checkpoints/domain/services/checkpoint_save_status_summary_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = CheckpointSaveStatusSummaryService();

  group('CheckpointSaveStatusSummaryService', () {
    test('maps saved to a calm success message', () {
      final summary = service.build(
        const CheckpointSaveDecision(
          accountId: 86745912,
          status: CheckpointSaveStatus.saved,
          newWindowMatchCount: 5,
          overlapCount: 0,
          blockFingerprint: 'm5|m4|m3|m2|m1',
        ),
      );

      expect(summary.headline, 'New coaching cycle saved.');
      expect(summary.detail, isNull);
    });

    test('maps skippedNoNewMatches to the no-new-matches message', () {
      final summary = service.build(
        const CheckpointSaveDecision(
          accountId: 86745912,
          status: CheckpointSaveStatus.skippedNoNewMatches,
          newWindowMatchCount: 0,
          overlapCount: 5,
          blockFingerprint: 'm5|m4|m3|m2|m1',
        ),
      );

      expect(summary.headline, 'No new matches since the last checkpoint.');
      expect(
        summary.detail,
        'History updates only when the block is meaningfully new.',
      );
    });

    test('maps skippedDuplicateBlock to the overlap message', () {
      final summary = service.build(
        const CheckpointSaveDecision(
          accountId: 86745912,
          status: CheckpointSaveStatus.skippedDuplicateBlock,
          newWindowMatchCount: 1,
          overlapCount: 4,
          blockFingerprint: 'm6|m5|m4|m3|m2',
        ),
      );

      expect(
        summary.headline,
        'Recent games still overlap too much with the last saved cycle.',
      );
      expect(
        summary.detail,
        'History updates only when the block is meaningfully new.',
      );
    });

    test('maps skippedNotMeaningfullyNew to the distinct-block message', () {
      final summary = service.build(
        const CheckpointSaveDecision(
          accountId: 86745912,
          status: CheckpointSaveStatus.skippedNotMeaningfullyNew,
          newWindowMatchCount: 2,
          overlapCount: 3,
          blockFingerprint: 'm7|m6|m5|m4|m3',
        ),
      );

      expect(
        summary.headline,
        'Waiting for a more distinct block before saving.',
      );
      expect(
        summary.detail,
        'History updates only when the block is meaningfully new.',
      );
    });
  });
}
