import 'package:dotes/src/features/training_preferences/domain/models/coaching_source_summary.dart';
import 'package:dotes/src/features/training_preferences/presentation/widgets/training_setup_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrainingSetupCard', () {
    testWidgets('shows the coaching source summary when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrainingSetupCard(
              summary: const CoachingSourceSummary(
                headline: 'Coaching source: Manual setup',
                detail: 'Role: Mid | Hero block: Slardar',
              ),
              onEdit: () {},
            ),
          ),
        ),
      );

      expect(find.text('Training setup'), findsOneWidget);
      expect(find.text('Coaching source: Manual setup'), findsOneWidget);
      expect(find.text('Role: Mid | Hero block: Slardar'), findsOneWidget);
      expect(find.text('Edit setup'), findsOneWidget);
    });

    testWidgets('shows the how coaching works action when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrainingSetupCard(
              summary: const CoachingSourceSummary(
                headline: 'Coaching source: App read',
                detail: 'Using the app read for role and hero block.',
              ),
              onEdit: () {},
              onShowHowItWorks: () {},
            ),
          ),
        ),
      );

      expect(find.text('View guide'), findsOneWidget);
    });
  });
}
