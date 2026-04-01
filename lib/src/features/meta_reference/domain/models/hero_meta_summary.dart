import 'hero_meta_reference.dart';
import 'hero_meta_freshness.dart';

class HeroMetaSummary {
  const HeroMetaSummary({
    required this.reference,
    required this.freshness,
    required this.interpretation,
    required this.fallbackMessage,
    this.staleWarning,
  });

  final HeroMetaReference? reference;
  final HeroMetaFreshness? freshness;
  final String interpretation;
  final String fallbackMessage;
  final String? staleWarning;

  bool get hasReference => reference != null;

  bool get isFresh => freshness?.isCurrent ?? false;

  bool get isStale => freshness?.isOutdated ?? false;
}
