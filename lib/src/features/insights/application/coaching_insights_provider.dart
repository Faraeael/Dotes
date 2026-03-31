import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/application/comfort_core_provider.dart';
import '../../matches/presentation/utils/hero_labels.dart';
import '../../player_import/application/imported_player_provider.dart';
import '../../roles/application/sample_role_summary_provider.dart';
import '../../training_preferences/application/training_preferences_providers.dart';
import '../domain/models/coaching_insight.dart';
import '../domain/models/next_games_focus.dart';
import '../domain/services/coaching_insights_analyzer.dart';
import '../domain/services/next_games_focus_generator.dart';

final coachingInsightsAnalyzerProvider = Provider<CoachingInsightsAnalyzer>((
  ref,
) {
  return const CoachingInsightsAnalyzer();
});

final nextGamesFocusGeneratorProvider = Provider<NextGamesFocusGenerator>((
  ref,
) {
  return const NextGamesFocusGenerator();
});

final coachingInsightsProvider = Provider<List<CoachingInsight>>((ref) {
  final importedPlayer = ref.watch(importedPlayerProvider);
  final sampleRoleSummary = ref.watch(sampleRoleSummaryProvider);
  if (importedPlayer == null || sampleRoleSummary == null) {
    return const [];
  }

  final analyzer = ref.watch(coachingInsightsAnalyzerProvider);
  return analyzer.analyze(importedPlayer, sampleRoleSummary);
});

final nextGamesFocusProvider = Provider<NextGamesFocus?>((ref) {
  final importedPlayer = ref.watch(importedPlayerProvider);
  final sampleRoleSummary = ref.watch(sampleRoleSummaryProvider);
  if (importedPlayer == null || sampleRoleSummary == null) {
    return null;
  }

  final insights = ref.watch(coachingInsightsProvider);
  final comfortCore = ref.watch(comfortCoreProvider);
  final generator = ref.watch(nextGamesFocusGeneratorProvider);
  return generator.generate(
    insights,
    sampleRoleSummary,
    comfortCore: comfortCore,
    recentMatches: importedPlayer.recentMatches,
    heroLabelFor: heroDisplayName,
    trainingPreferences: ref.watch(currentTrainingPreferencesProvider),
  );
});
