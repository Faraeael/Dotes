import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../checkpoints/application/coaching_checkpoint_providers.dart';
import '../../player_import/application/imported_player_provider.dart';
import '../domain/models/focus_follow_through_check.dart';
import '../domain/models/progress_check.dart';
import '../domain/services/focus_follow_through_service.dart';
import '../domain/services/progress_check_service.dart';

final progressCheckServiceProvider = Provider<ProgressCheckService>((ref) {
  return const ProgressCheckService();
});

final focusFollowThroughServiceProvider = Provider<FocusFollowThroughService>((
  ref,
) {
  return const FocusFollowThroughService();
});

final progressCheckProvider = Provider<ProgressCheck?>((ref) {
  final importedPlayer = ref.watch(importedPlayerProvider);
  if (importedPlayer == null) {
    return null;
  }

  final service = ref.watch(progressCheckServiceProvider);
  return service.build(importedPlayer.recentMatches);
});

final focusFollowThroughProvider = Provider<FocusFollowThroughCheck?>((ref) {
  final previousCheckpoint = ref.watch(previousCoachingCheckpointProvider);
  final currentCheckpointDraft = ref.watch(currentCoachingCheckpointDraftProvider);
  if (currentCheckpointDraft == null) {
    return null;
  }

  if (previousCheckpoint == null) {
    return const FocusFollowThroughCheck.waiting(
      fallbackMessage: 'No previous coaching checkpoint yet.',
    );
  }

  final service = ref.watch(focusFollowThroughServiceProvider);
  return service.build(
    previousCheckpoint: previousCheckpoint,
    currentSample: currentCheckpointDraft.sample,
  );
});
