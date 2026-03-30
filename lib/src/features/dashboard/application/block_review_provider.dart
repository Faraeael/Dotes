import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../checkpoints/application/coaching_checkpoint_providers.dart';
import '../../player_import/application/imported_player_provider.dart';
import '../../progress/application/progress_check_provider.dart';
import '../domain/models/block_review.dart';
import '../domain/services/block_review_service.dart';
import 'session_plan_provider.dart';

final blockReviewServiceProvider = Provider<BlockReviewService>((ref) {
  return const BlockReviewService();
});

final blockReviewProvider = Provider<BlockReview?>((ref) {
  final importedPlayer = ref.watch(importedPlayerProvider);
  final previousCheckpoint = ref.watch(previousCoachingCheckpointProvider);
  if (importedPlayer == null || previousCheckpoint == null) {
    return null;
  }

  final service = ref.watch(blockReviewServiceProvider);
  return service.build(
    previousCheckpoint: previousCheckpoint,
    currentImport: importedPlayer,
    sessionPlan: ref.watch(sessionPlanProvider),
    followThroughCheck: ref.watch(focusFollowThroughProvider),
    progressCheck: ref.watch(progressCheckProvider),
  );
});
