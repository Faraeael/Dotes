import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../checkpoints/application/coaching_checkpoint_providers.dart';
import '../../insights/application/coaching_insights_provider.dart';
import '../../player_import/application/imported_player_provider.dart';
import '../../progress/application/progress_check_provider.dart';
import '../domain/models/dashboard_verdict.dart';
import '../domain/services/dashboard_verdict_service.dart';
import 'comfort_core_provider.dart';

final dashboardVerdictServiceProvider = Provider<DashboardVerdictService>((ref) {
  return const DashboardVerdictService();
});

final dashboardVerdictProvider = Provider<DashboardVerdict?>((ref) {
  final importedPlayer = ref.watch(importedPlayerProvider);
  if (importedPlayer == null) {
    return null;
  }

  final service = ref.watch(dashboardVerdictServiceProvider);
  return service.build(
    insights: ref.watch(coachingInsightsProvider),
    nextGamesFocus: ref.watch(nextGamesFocusProvider),
    comfortCore: ref.watch(comfortCoreProvider),
    progressCheck: ref.watch(progressCheckProvider),
    followThroughCheck: ref.watch(focusFollowThroughProvider),
    previousCheckpoint: ref.watch(previousCoachingCheckpointProvider),
  );
});
