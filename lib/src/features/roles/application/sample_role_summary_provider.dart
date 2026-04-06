import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../meta_reference/application/hero_meta_reference_providers.dart';
import '../../player_import/application/imported_player_provider.dart';
import '../domain/models/sample_role_summary.dart';
import '../domain/services/role_inference_service.dart';

final roleInferenceServiceProvider = Provider<RoleInferenceService>((ref) {
  return const RoleInferenceService();
});

final sampleRoleSummaryProvider = Provider<SampleRoleSummary?>((ref) {
  final importedPlayer = ref.watch(importedPlayerProvider);
  if (importedPlayer == null) {
    return null;
  }

  final roleInferenceService = ref.watch(roleInferenceServiceProvider);
  final heroMetaReferenceRepository = ref.watch(
    heroMetaReferenceRepositoryProvider,
  );
  return roleInferenceService.summarizeSample(
    importedPlayer.recentMatches,
    heroRoleHintLabelForHero: (heroId) {
      return heroMetaReferenceRepository.loadForHero(heroId)?.roleLabel;
    },
  );
});
