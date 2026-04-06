import 'package:flutter/material.dart';

import '../../domain/models/training_preferences.dart';
import 'training_preferences_form_fields.dart';

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
  late TrainingFocusPriority _focusPriority;
  late TrainingCoachingStyle _coachingStyle;
  late TrainingQueuePreference _queuePreference;
  late int? _heroOneId;
  late int? _heroTwoId;
  late final TextEditingController _coachingNoteController;

  @override
  void initState() {
    super.initState();
    final heroIds = widget.initialPreferences.normalizedLockedHeroIds;
    _coachingMode = widget.initialPreferences.coachingMode;
    _preferredRole = widget.initialPreferences.preferredRole;
    _focusPriority = widget.initialPreferences.focusPriority;
    _coachingStyle = widget.initialPreferences.coachingStyle;
    _queuePreference = widget.initialPreferences.queuePreference;
    _heroOneId = heroIds.isEmpty ? null : heroIds.first;
    _heroTwoId = heroIds.length < 2 ? null : heroIds[1];
    _coachingNoteController = TextEditingController(
      text: widget.initialPreferences.trimmedCoachingNote ?? '',
    );
  }

  @override
  void dispose() {
    _coachingNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Training preferences'),
      content: SingleChildScrollView(
        child: TrainingPreferencesFormFields(
          coachingMode: _coachingMode,
          preferredRole: _preferredRole,
          focusPriority: _focusPriority,
          coachingStyle: _coachingStyle,
          queuePreference: _queuePreference,
          heroOneId: _heroOneId,
          heroTwoId: _heroTwoId,
          coachingNoteController: _coachingNoteController,
          onCoachingModeChanged: (value) =>
              setState(() => _coachingMode = value),
          onPreferredRoleChanged: (value) =>
              setState(() => _preferredRole = value),
          onFocusPriorityChanged: (value) =>
              setState(() => _focusPriority = value),
          onCoachingStyleChanged: (value) =>
              setState(() => _coachingStyle = value),
          onQueuePreferenceChanged: (value) =>
              setState(() => _queuePreference = value),
          onHeroOneChanged: (value) {
            setState(() {
              _heroOneId = value;
              if (_heroOneId == _heroTwoId) {
                _heroTwoId = null;
              }
            });
          },
          onHeroTwoChanged: (value) {
            setState(() {
              _heroTwoId = value == _heroOneId ? null : value;
            });
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_buildPreferences()),
          child: const Text('Save'),
        ),
      ],
    );
  }

  TrainingPreferences _buildPreferences() {
    return TrainingPreferences(
      coachingMode: _coachingMode,
      preferredRole: _preferredRole,
      focusPriority: _focusPriority,
      coachingStyle: _coachingStyle,
      queuePreference: _queuePreference,
      lockedHeroIds: [
        _heroOneId,
        _heroTwoId,
      ].whereType<int>().toList(growable: false),
      coachingNote: _coachingNoteController.text,
    );
  }
}
