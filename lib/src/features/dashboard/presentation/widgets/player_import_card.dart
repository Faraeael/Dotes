import 'package:flutter/material.dart';

import '../../../player_import/domain/models/imported_player_data.dart';
import 'section_card.dart';

class PlayerImportCard extends StatelessWidget {
  const PlayerImportCard({
    required this.importedPlayer,
    required this.onGoToImport,
    super.key,
  });

  final ImportedPlayerData importedPlayer;
  final VoidCallback onGoToImport;

  @override
  Widget build(BuildContext context) {
    final isDemo = importedPlayer.source.isDemo;

    return SectionCard(
      title: isDemo ? 'Return to import flow' : 'Import another account',
      body: isDemo
          ? 'Go back to the import screen to switch to a real OpenDota account or another local demo scenario. Demo state stays on its own synthetic account.'
          : 'Switch to a different account without mixing checkpoint history between testers.',
      action: OutlinedButton(
        onPressed: onGoToImport,
        child: Text(isDemo ? 'Back to import' : 'Import another account'),
      ),
    );
  }
}
