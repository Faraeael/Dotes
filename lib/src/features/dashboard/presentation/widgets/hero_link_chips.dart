import 'package:flutter/material.dart';

class HeroLinkChipData {
  const HeroLinkChipData({
    required this.heroId,
    required this.label,
    this.detail,
  });

  final int heroId;
  final String label;
  final String? detail;
}

class HeroLinkChips extends StatelessWidget {
  const HeroLinkChips({
    required this.heroes,
    required this.onSelectHero,
    super.key,
  });

  final List<HeroLinkChipData> heroes;
  final ValueChanged<int> onSelectHero;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: heroes
          .map(
            (hero) => ActionChip(
              label: Text(_labelFor(hero)),
              onPressed: () => onSelectHero(hero.heroId),
            ),
          )
          .toList(growable: false),
    );
  }

  String _labelFor(HeroLinkChipData hero) {
    if (hero.detail == null || hero.detail!.isEmpty) {
      return hero.label;
    }

    return '${hero.label} (${hero.detail})';
  }
}
