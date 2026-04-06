import 'package:flutter/material.dart';

import '../../domain/models/training_preferences.dart';
import 'training_preferences_goal_field.dart';
import 'training_preferences_hero_field.dart';
import 'training_preferences_select_field.dart';

class TrainingPreferencesFormFields extends StatelessWidget {
  const TrainingPreferencesFormFields({
    required this.coachingMode,
    required this.preferredRole,
    required this.focusPriority,
    required this.coachingStyle,
    required this.queuePreference,
    required this.heroOneId,
    required this.heroTwoId,
    required this.coachingNoteController,
    required this.onCoachingModeChanged,
    required this.onPreferredRoleChanged,
    required this.onFocusPriorityChanged,
    required this.onCoachingStyleChanged,
    required this.onQueuePreferenceChanged,
    required this.onHeroOneChanged,
    required this.onHeroTwoChanged,
    super.key,
  });

  final TrainingCoachingMode coachingMode;
  final TrainingRolePreference preferredRole;
  final TrainingFocusPriority focusPriority;
  final TrainingCoachingStyle coachingStyle;
  final TrainingQueuePreference queuePreference;
  final int? heroOneId;
  final int? heroTwoId;
  final TextEditingController coachingNoteController;
  final ValueChanged<TrainingCoachingMode> onCoachingModeChanged;
  final ValueChanged<TrainingRolePreference> onPreferredRoleChanged;
  final ValueChanged<TrainingFocusPriority> onFocusPriorityChanged;
  final ValueChanged<TrainingCoachingStyle> onCoachingStyleChanged;
  final ValueChanged<TrainingQueuePreference> onQueuePreferenceChanged;
  final ValueChanged<int?> onHeroOneChanged;
  final ValueChanged<int?> onHeroTwoChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TrainingPreferencesSelectField<TrainingCoachingMode>(
          label: 'Coaching mode',
          value: coachingMode,
          options: TrainingCoachingMode.values,
          optionLabel: (mode) => mode.label,
          onChanged: onCoachingModeChanged,
        ),
        const SizedBox(height: 12),
        TrainingPreferencesSelectField<TrainingRolePreference>(
          label: 'Preferred training role',
          value: preferredRole,
          options: TrainingRolePreference.values,
          optionLabel: (role) => role.label,
          onChanged: onPreferredRoleChanged,
        ),
        const SizedBox(height: 12),
        TrainingPreferencesSelectField<TrainingFocusPriority>(
          label: 'Current coaching priority',
          value: focusPriority,
          options: TrainingFocusPriority.values,
          optionLabel: (priority) => priority.label,
          onChanged: onFocusPriorityChanged,
        ),
        const SizedBox(height: 12),
        TrainingPreferencesSelectField<TrainingCoachingStyle>(
          label: 'Coaching style',
          value: coachingStyle,
          options: TrainingCoachingStyle.values,
          optionLabel: (style) => style.label,
          onChanged: onCoachingStyleChanged,
        ),
        const SizedBox(height: 12),
        TrainingPreferencesSelectField<TrainingQueuePreference>(
          label: 'Queue discipline',
          value: queuePreference,
          options: TrainingQueuePreference.values,
          optionLabel: (queuePreference) => queuePreference.label,
          onChanged: onQueuePreferenceChanged,
        ),
        const SizedBox(height: 12),
        TrainingPreferencesHeroField(
          label: 'Locked hero 1',
          initialValue: heroOneId,
          onChanged: onHeroOneChanged,
        ),
        const SizedBox(height: 12),
        TrainingPreferencesHeroField(
          label: 'Locked hero 2',
          initialValue: heroTwoId,
          onChanged: onHeroTwoChanged,
        ),
        const SizedBox(height: 12),
        TrainingPreferencesGoalField(controller: coachingNoteController),
      ],
    );
  }
}
