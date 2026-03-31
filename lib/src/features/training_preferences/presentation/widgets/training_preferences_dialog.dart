import 'package:flutter/material.dart';

import '../../domain/models/training_preferences.dart';
import 'training_preferences_hero_field.dart';

class TrainingPreferencesDialog extends StatefulWidget {
  const TrainingPreferencesDialog({
    required this.initialPreferences,
    super.key,
  });

  final TrainingPreferences initialPreferences;

  static Future<TrainingPreferences?> show(
    BuildContext context, {
    required TrainingPreferences initialPreferences,
  }) {
    return showDialog<TrainingPreferences>(
      context: context,
      builder: (_) =>
          TrainingPreferencesDialog(initialPreferences: initialPreferences),
    );
  }

  @override
  State<TrainingPreferencesDialog> createState() =>
      _TrainingPreferencesDialogState();
}

class _TrainingPreferencesDialogState extends State<TrainingPreferencesDialog> {
  late TrainingCoachingMode _coachingMode;
  late TrainingRolePreference _preferredRole;
  late int? _heroOneId;
  late int? _heroTwoId;

  @override
  void initState() {
    super.initState();
    final heroIds = widget.initialPreferences.normalizedLockedHeroIds;
    _coachingMode = widget.initialPreferences.coachingMode;
    _preferredRole = widget.initialPreferences.preferredRole;
    _heroOneId = heroIds.isEmpty ? null : heroIds.first;
    _heroTwoId = heroIds.length < 2 ? null : heroIds[1];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Training preferences'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModeField(),
            const SizedBox(height: 12),
            _buildRoleField(),
            const SizedBox(height: 12),
            TrainingPreferencesHeroField(
              label: 'Locked hero 1',
              initialValue: _heroOneId,
              onChanged: (value) {
                setState(() {
                  _heroOneId = value;
                  if (_heroOneId == _heroTwoId) {
                    _heroTwoId = null;
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            TrainingPreferencesHeroField(
              label: 'Locked hero 2',
              initialValue: _heroTwoId,
              onChanged: (value) {
                setState(() {
                  _heroTwoId = value == _heroOneId ? null : value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              TrainingPreferences(
                coachingMode: _coachingMode,
                preferredRole: _preferredRole,
                lockedHeroIds: [
                  _heroOneId,
                  _heroTwoId,
                ].whereType<int>().toList(growable: false),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildModeField() {
    return DropdownButtonFormField<TrainingCoachingMode>(
      initialValue: _coachingMode,
      decoration: const InputDecoration(labelText: 'Coaching mode'),
      items: [
        for (final mode in TrainingCoachingMode.values)
          DropdownMenuItem(value: mode, child: Text(mode.label)),
      ],
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() => _coachingMode = value);
      },
    );
  }

  Widget _buildRoleField() {
    return DropdownButtonFormField<TrainingRolePreference>(
      initialValue: _preferredRole,
      decoration: const InputDecoration(labelText: 'Preferred training role'),
      items: [
        for (final role in TrainingRolePreference.values)
          DropdownMenuItem(value: role, child: Text(role.label)),
      ],
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() => _preferredRole = value);
      },
    );
  }
}
