import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_meta_patch_config.dart';
import '../data/repositories/local_hero_meta_reference_repository.dart';
import '../domain/models/hero_meta_reference.dart';
import '../domain/repositories/hero_meta_reference_repository.dart';
import '../domain/services/hero_meta_freshness_service.dart';
import '../domain/services/hero_meta_summary_service.dart';

final currentSupportedPatchLabelProvider = Provider<String>((ref) {
  return currentSupportedMetaPatchLabel;
});

final heroMetaReferenceRepositoryProvider =
    Provider<HeroMetaReferenceRepository>((ref) {
      return const LocalHeroMetaReferenceRepository();
    });

final heroMetaReferenceProvider = Provider.family<HeroMetaReference?, int>((
  ref,
  heroId,
) {
  return ref.watch(heroMetaReferenceRepositoryProvider).loadForHero(heroId);
});

final heroMetaFreshnessServiceProvider = Provider<HeroMetaFreshnessService>((
  ref,
) {
  return const HeroMetaFreshnessService();
});

final heroMetaSummaryServiceProvider = Provider<HeroMetaSummaryService>((ref) {
  return HeroMetaSummaryService(
    freshnessService: ref.watch(heroMetaFreshnessServiceProvider),
  );
});
