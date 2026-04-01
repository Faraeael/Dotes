import '../models/hero_meta_reference.dart';

abstract interface class HeroMetaReferenceRepository {
  HeroMetaReference? loadForHero(int heroId);
}
