import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../checkpoints/application/coaching_checkpoint_providers.dart';
import '../../dashboard/application/comfort_core_provider.dart';
import '../../dashboard/application/block_review_provider.dart';
import '../../dashboard/application/session_plan_provider.dart';
import '../../matches/presentation/utils/hero_labels.dart';
import '../../meta_reference/application/hero_meta_reference_providers.dart';
import '../../player_import/application/imported_player_provider.dart';
import '../domain/models/hero_detail.dart';
import '../domain/services/hero_detail_service.dart';

final heroDetailServiceProvider = Provider<HeroDetailService>((ref) {
  return const HeroDetailService();
});

final heroDetailProvider = Provider.family<HeroDetail?, int>((ref, heroId) {
  final importedPlayer = ref.watch(importedPlayerProvider);
  if (importedPlayer == null) {
    return null;
  }

  final service = ref.watch(heroDetailServiceProvider);
  return service.build(
    heroId: heroId,
    allMatches: importedPlayer.recentMatches,
    heroLabelFor: heroDisplayName,
    metaReference: ref.watch(heroMetaReferenceProvider(heroId)),
    currentSupportedPatchLabel: ref.watch(currentSupportedPatchLabelProvider),
    comfortCore: ref.watch(comfortCoreProvider),
    blockReview: ref.watch(blockReviewProvider),
    previousCheckpoint: ref.watch(previousCoachingCheckpointProvider),
    sessionPlan: ref.watch(sessionPlanProvider),
  );
});
