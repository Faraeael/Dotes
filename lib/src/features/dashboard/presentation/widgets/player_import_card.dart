import 'package:flutter/material.dart';

import 'section_card.dart';

class PlayerImportCard extends StatelessWidget {
  const PlayerImportCard({
    required this.onGoToImport,
    super.key,
  });

  final VoidCallback onGoToImport;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Import another account',
      body:
          'Switch to a different account without mixing checkpoint history between testers.',
      action: OutlinedButton(
        onPressed: onGoToImport,
        child: const Text('Import another account'),
      ),
    );
  }
}
