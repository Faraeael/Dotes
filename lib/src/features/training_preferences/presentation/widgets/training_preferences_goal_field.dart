import 'package:flutter/material.dart';

class TrainingPreferencesGoalField extends StatelessWidget {
  const TrainingPreferencesGoalField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: 120,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Current coaching goal',
        hintText: 'Example: practice safer lane exits and fewer greedy fights.',
      ),
    );
  }
}
