import '../../domain/models/hero_meta_reference.dart';

class LocalMetaPatchPack {
  const LocalMetaPatchPack({
    required this.patchLabel,
    required this.heroReferences,
  });

  final String patchLabel;
  final Map<int, HeroMetaReference> heroReferences;

  HeroMetaReference? loadForHero(int heroId) {
    return heroReferences[heroId];
  }
}
