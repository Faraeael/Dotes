import '../../domain/models/hero_meta_reference.dart';
import '../../domain/repositories/hero_meta_reference_repository.dart';
import '../patch_packs/local_meta_patch_pack.dart';
import '../patch_packs/local_meta_patch_registry.dart';

class LocalHeroMetaReferenceRepository implements HeroMetaReferenceRepository {
  const LocalHeroMetaReferenceRepository({
    this.patchPack = latestAvailableLocalMetaPatchPack,
  });

  final LocalMetaPatchPack patchPack;

  @override
  HeroMetaReference? loadForHero(int heroId) {
    return patchPack.loadForHero(heroId);
  }
}
