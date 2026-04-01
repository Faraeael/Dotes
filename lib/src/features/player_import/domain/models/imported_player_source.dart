enum ImportedPlayerSourceType { openDota, demoScenario }

class ImportedPlayerSource {
  const ImportedPlayerSource.openDota()
    : type = ImportedPlayerSourceType.openDota,
      scenarioId = null,
      scenarioLabel = null;

  const ImportedPlayerSource.demoScenario({
    required this.scenarioId,
    required this.scenarioLabel,
  }) : type = ImportedPlayerSourceType.demoScenario;

  final ImportedPlayerSourceType type;
  final String? scenarioId;
  final String? scenarioLabel;

  bool get isDemo => type == ImportedPlayerSourceType.demoScenario;
}
