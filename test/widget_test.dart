import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dotes/src/app/app.dart';
import 'package:dotes/src/features/player_import/application/saved_accounts_providers.dart';
import 'package:dotes/src/features/player_import/domain/models/saved_account_entry.dart';
import 'package:dotes/src/features/player_import/domain/repositories/saved_account_repository.dart';

void main() {
  testWidgets('shows the player import screen on launch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savedAccountRepositoryProvider.overrideWithValue(
            _FakeSavedAccountRepository(),
          ),
        ],
        child: const DotesApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Import account'), findsAtLeastNWidgets(2));
    expect(find.text('Import player'), findsOneWidget);
    expect(find.text('How coaching works'), findsOneWidget);
    expect(find.text('How to find account ID'), findsOneWidget);
    expect(
      find.text(
        'First import builds the current read and session plan. Later import reviews the finished block after 5 newer games.',
      ),
      findsOneWidget,
    );

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect((appBar.title as Text).data, 'Import account');
  });
}

class _FakeSavedAccountRepository implements SavedAccountRepository {
  @override
  Future<List<SavedAccountEntry>> loadAll() async => const [];

  @override
  Future<void> remove(int accountId) async {}

  @override
  Future<void> saveEntry(SavedAccountEntry entry) async {}

  @override
  Future<void> setPinnedAccount(int? accountId) async {}
}
