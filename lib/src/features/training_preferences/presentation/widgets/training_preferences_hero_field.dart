import 'package:flutter/material.dart';

import '../../../matches/presentation/utils/hero_labels.dart';

class TrainingPreferencesHeroField extends StatelessWidget {
  const TrainingPreferencesHeroField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    super.key,
  });

  final String label;
  final int? initialValue;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: label),
      items: _heroItems,
      onChanged: onChanged,
    );
  }
}

final _heroItems = [
  const DropdownMenuItem<int?>(value: null, child: Text('None')),
  for (final entry in _sortedHeroEntries)
    DropdownMenuItem<int?>(value: entry.key, child: Text(entry.value)),
];

final _sortedHeroEntries = heroNamesById.entries.toList(growable: false)
  ..sort((left, right) => left.value.compareTo(right.value));
