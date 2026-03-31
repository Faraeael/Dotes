import 'package:flutter/material.dart';

import 'dashboard_shell.dart';
import 'section_card.dart';

class DashboardEmptyView extends StatelessWidget {
  const DashboardEmptyView({
    required this.onGoToImport,
    super.key,
  });

  final VoidCallback onGoToImport;

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Dashboard',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SectionCard(
              title: 'No player loaded',
              body:
                  'Import a Dota account to build the dashboard from recent matches.',
              action: OutlinedButton(
                onPressed: onGoToImport,
                child: const Text('Import player'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
