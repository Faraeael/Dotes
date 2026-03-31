import '../models/checkpoint_save_status_summary.dart';
import 'checkpoint_save_policy_service.dart';

class CheckpointSaveStatusSummaryService {
  const CheckpointSaveStatusSummaryService();

  static const String _historyIntegrityDetail =
      'History updates only when the block is meaningfully new.';

  CheckpointSaveStatusSummary build(CheckpointSaveDecision decision) {
    return switch (decision.status) {
      CheckpointSaveStatus.saved => const CheckpointSaveStatusSummary(
        headline: 'New coaching cycle saved.',
      ),
      CheckpointSaveStatus.skippedNoNewMatches =>
        const CheckpointSaveStatusSummary(
          headline: 'No new matches since the last checkpoint.',
          detail: _historyIntegrityDetail,
        ),
      CheckpointSaveStatus.skippedDuplicateBlock =>
        const CheckpointSaveStatusSummary(
          headline:
              'Recent games still overlap too much with the last saved cycle.',
          detail: _historyIntegrityDetail,
        ),
      CheckpointSaveStatus.skippedNotMeaningfullyNew =>
        const CheckpointSaveStatusSummary(
          headline: 'Waiting for a more distinct block before saving.',
          detail: _historyIntegrityDetail,
        ),
    };
  }
}
