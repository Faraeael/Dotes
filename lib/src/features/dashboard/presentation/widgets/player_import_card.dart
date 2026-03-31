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
      title: 'Change player',
      body:
          'Import a different account to refresh the coaching read.',
      action: OutlinedButton(
        onPressed: onGoToImport,
        child: const Text('Go to import'),
      ),
    );
  }
}
