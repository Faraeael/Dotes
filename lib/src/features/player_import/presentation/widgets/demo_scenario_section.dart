import 'package:flutter/material.dart';

import '../../../../app/widgets/app_card_header.dart';
import '../../domain/models/demo_player_scenario.dart';

class DemoScenarioSection extends StatelessWidget {
  const DemoScenarioSection({
    required this.scenarios,
    required this.isSubmitting,
    required this.onSelectScenario,
    super.key,
  });

  final List<DemoPlayerScenario> scenarios;
  final bool isSubmitting;
  final ValueChanged<DemoPlayerScenario> onSelectScenario;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppCardHeader(
              title: 'Demo scenarios',
              subtitle:
                  'Load local seeded coaching states for testing without OpenDota or real accounts.',
            ),
            const SizedBox(height: 12),
            Text(
              'Each scenario uses deterministic local data and synthetic account IDs so demo state stays isolated.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            for (final scenario in scenarios) ...[
              _DemoScenarioTile(
                scenario: scenario,
                isSubmitting: isSubmitting,
                onPressed: () => onSelectScenario(scenario),
              ),
              if (scenario != scenarios.last) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _DemoScenarioTile extends StatelessWidget {
  const _DemoScenarioTile({
    required this.scenario,
    required this.isSubmitting,
    required this.onPressed,
  });

  final DemoPlayerScenario scenario;
  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scenario.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(scenario.description),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: isSubmitting ? null : onPressed,
                child: const Text('Load demo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
