import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../checkpoints/application/coaching_checkpoint_providers.dart';
import '../domain/models/end_block_summary.dart';
import '../domain/services/end_block_summary_service.dart';
import 'block_review_provider.dart';
import '../../progress/application/progress_check_provider.dart';
import 'session_plan_provider.dart';

final endBlockSummaryServiceProvider = Provider<EndBlockSummaryService>((ref) {
  return const EndBlockSummaryService();
});

final endBlockSummaryProvider = Provider<EndBlockSummary?>((ref) {
  return ref
      .watch(endBlockSummaryServiceProvider)
      .build(
        activeStartedCheckpoint: ref.watch(previousCoachingCheckpointProvider),
        reviewedBlock: ref.watch(blockReviewProvider),
        sessionPlan: ref.watch(sessionPlanProvider),
        followThrough: ref.watch(focusFollowThroughProvider),
      );
});
