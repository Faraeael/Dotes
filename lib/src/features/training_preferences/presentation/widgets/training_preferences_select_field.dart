import 'package:flutter/material.dart';

class TrainingPreferencesSelectField<T> extends StatelessWidget {
  const TrainingPreferencesSelectField({
    required this.label,
    required this.value,
    required this.options,
    required this.optionLabel,
    required this.onChanged,
    super.key,
  });

  final String label;
  final T value;
  final List<T> options;
  final String Function(T value) optionLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(optionLabel(option))),
      ],
      onChanged: (value) => value == null ? null : onChanged(value),
    );
  }
}
