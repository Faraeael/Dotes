import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../insights/application/coaching_insights_provider.dart';
import '../../matches/presentation/utils/hero_labels.dart';
import '../../player_import/application/imported_player_provider.dart';
import '../../progress/application/progress_check_provider.dart';
import '../../roles/application/sample_role_summary_provider.dart';
import '../domain/models/session_plan.dart';
import '../domain/services/session_plan_service.dart';
import 'comfort_core_provider.dart';
import 'dashboard_verdict_provider.dart';

final sessionPlanServiceProvider = Provider<SessionPlanService>((ref) {
  return const SessionPlanService();
});

final sessionPlanProvider = Provider<SessionPlan?>((ref) {
  final importedPlayer = ref.watch(importedPlayerProvider);
  if (importedPlayer == null) {
    return null;
  }

  final service = ref.watch(sessionPlanServiceProvider);
  return service.build(
    verdict: ref.watch(dashboardVerdictProvider),
    nextGamesFocus: ref.watch(nextGamesFocusProvider),
    comfortCore: ref.watch(comfortCoreProvider),
    roleSummary: ref.watch(sampleRoleSummaryProvider),
    followThroughCheck: ref.watch(focusFollowThroughProvider),
    heroLabelFor: heroDisplayName,
  );
});
