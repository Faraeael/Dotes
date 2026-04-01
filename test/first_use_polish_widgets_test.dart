import 'package:dotes/src/features/dashboard/domain/models/block_summary_export.dart';
import 'package:dotes/src/features/dashboard/presentation/widgets/block_summary_export_dialog.dart';
import 'package:dotes/src/features/dashboard/presentation/widgets/dashboard_empty_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('First-use polish widgets', () {
    testWidgets('empty dashboard explains the first-use loop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DashboardEmptyView(onGoToImport: () {})),
      );

      expect(find.text('Start with one account import'), findsOneWidget);
      expect(
        find.textContaining(
          'The first pass gives you the current read and one focused 5-game block.',
        ),
        findsOneWidget,
      );
      expect(find.text('Import account'), findsOneWidget);
    });

    testWidgets('summary dialog reads like a tester handoff', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BlockSummaryExportDialog(
              summary: BlockSummaryExport(
                playerLabel: 'Player (Account 86745912)',
                completionDateLabel: 'Apr 1, 2026',
                outcome: 'On track',
                mainTargetResult: 'Improved',
                adherenceResult: 'Stayed in block',
                takeaway: 'You stayed inside the block and deaths improved.',
                nextStep: 'Run the same block again.',
                shareText: 'summary text',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Summary ready to share'), findsOneWidget);
      expect(
        find.text(
          'Copy this result into tester notes, chat, or a handoff doc.',
        ),
        findsOneWidget,
      );
      expect(find.text('Copy for sharing'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });
  });
}
