import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../insights/application/coaching_insights_provider.dart';
import '../../matches/presentation/utils/hero_labels.dart';
import '../../meta_reference/application/hero_meta_reference_providers.dart';
import '../../player_import/application/imported_player_provider.dart';
import '../../progress/application/progress_check_provider.dart';
import '../../roles/application/sample_role_summary_provider.dart';
import '../../training_preferences/application/training_preferences_providers.dart';
import '../domain/models/session_plan.dart';
import '../domain/models/session_plan_meta_sanity.dart';
import '../domain/services/session_plan_meta_sanity_service.dart';
import '../domain/services/session_plan_service.dart';
import 'comfort_core_provider.dart';
import 'dashboard_verdict_provider.dart';

final sessionPlanServiceProvider = Provider<SessionPlanService>((ref) {
  return const SessionPlanService();
});

final sessionPlanMetaSanityServiceProvider =
    Provider<SessionPlanMetaSanityService>((ref) {
      return SessionPlanMetaSanityService(
        freshnessService: ref.watch(heroMetaFreshnessServiceProvider),
      );
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
    trainingPreferences: ref.watch(currentTrainingPreferencesProvider),
  );
});

final sessionPlanMetaSanityProvider = Provider<SessionPlanMetaSanity?>((ref) {
  final importedPlayer = ref.watch(importedPlayerProvider);
  final plan = ref.watch(sessionPlanProvider);
  if (importedPlayer == null || plan == null) {
    return null;
  }

  final repository = ref.watch(heroMetaReferenceRepositoryProvider);
  return ref.watch(sessionPlanMetaSanityServiceProvider).build(
        plan: plan,
        currentSupportedPatchLabel: ref.watch(currentSupportedPatchLabelProvider),
        comfortCore: ref.watch(comfortCoreProvider),
        metaReferenceFor: repository.loadForHero,
      );
});
