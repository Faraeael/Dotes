import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/playtest_summary.dart';
import '../domain/models/tester_feedback.dart';
import '../domain/models/tester_feedback_record.dart';
import '../domain/services/playtest_summary_service.dart';
import 'tester_feedback_providers.dart';

final playtestSummaryServiceProvider = Provider<PlaytestSummaryService>((ref) {
  return const PlaytestSummaryService();
});

final playtestSummaryFilterProvider = StateProvider<TesterFeedbackRating?>(
  (ref) => null,
);

final playtestFeedbackRecordsProvider = FutureProvider<List<TesterFeedbackRecord>>((
  ref,
) async {
  ref.watch(testerFeedbackCollectionRevisionProvider);
  final repository = ref.watch(testerFeedbackRepositoryProvider);
  return repository.loadAll();
});

final playtestSummaryProvider = Provider<AsyncValue<PlaytestSummary>>((ref) {
  final records = ref.watch(playtestFeedbackRecordsProvider);
  final activeFilter = ref.watch(playtestSummaryFilterProvider);
  final service = ref.watch(playtestSummaryServiceProvider);
  return records.whenData(
    (value) => service.build(records: value, activeFilter: activeFilter),
  );
});
