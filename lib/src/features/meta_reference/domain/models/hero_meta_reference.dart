enum HeroMetaTier {
  top('Top meta'),
  strong('Strong meta'),
  neutral('Playable'),
  niche('Niche');

  const HeroMetaTier(this.label);

  final String label;

  bool get isHighMeta => this == HeroMetaTier.top || this == HeroMetaTier.strong;

  bool get isLowMeta => this == HeroMetaTier.niche;
}

class HeroMetaReference {
  const HeroMetaReference({
    required this.heroId,
    required this.patchLabel,
    required this.tier,
    required this.roleLabel,
    required this.coreItemDirection,
    this.skillBuildDirection,
  });

  final int heroId;
  final String patchLabel;
  final HeroMetaTier tier;
  final String roleLabel;
  final String coreItemDirection;
  final String? skillBuildDirection;
}
