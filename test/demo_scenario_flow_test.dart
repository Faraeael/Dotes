import 'package:dotes/src/app/router/app_router.dart';
import 'package:dotes/src/core/result/result.dart';
import 'package:dotes/src/features/checkpoints/application/coaching_checkpoint_providers.dart';
import 'package:dotes/src/features/checkpoints/domain/models/coaching_checkpoint.dart';
import 'package:dotes/src/features/checkpoints/domain/repositories/coaching_checkpoint_repository.dart';
import 'package:dotes/src/features/dashboard/application/dashboard_onboarding_providers.dart';
import 'package:dotes/src/features/dashboard/domain/repositories/dashboard_onboarding_repository.dart';
import 'package:dotes/src/features/player_import/application/saved_accounts_providers.dart';
import 'package:dotes/src/features/player_import/data/repositories/opendota_player_repository.dart';
import 'package:dotes/src/features/player_import/domain/models/player_profile_summary.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:dotes/src/features/player_import/domain/models/saved_account_entry.dart';
import 'package:dotes/src/features/player_import/domain/repositories/player_import_repository.dart';
import 'package:dotes/src/features/player_import/domain/repositories/saved_account_repository.dart';
import 'package:dotes/src/features/tester_feedback/application/tester_feedback_providers.dart';
import 'package:dotes/src/features/tester_feedback/domain/models/tester_feedback.dart';
import 'package:dotes/src/features/tester_feedback/domain/models/tester_feedback_record.dart';
import 'package:dotes/src/features/tester_feedback/domain/repositories/tester_feedback_repository.dart';
import 'package:dotes/src/features/training_preferences/application/training_preferences_providers.dart';
import 'package:dotes/src/features/training_preferences/domain/models/training_preferences.dart';
import 'package:dotes/src/features/training_preferences/domain/repositories/training_preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('demo scenario flow', () {
    testWidgets('selecting a demo scenario renders the expected coaching state', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(900, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Completed on-track block'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(
        find.widgetWithText(FilledButton, 'Load demo').at(3),
      );
      await tester.pumpAndSettle();

      expect(find.text('Demo scenario: Completed on-track block'), findsOneWidget);
      expect(find.text('End block summary'), findsOneWidget);
      expect(
        find.text('Takeaway: You stayed inside the block and deaths improved.'),
        findsOneWidget,
      );
      expect(find.text('On-Track Block Demo'), findsWidgets);
    });

    testWidgets('can switch back from a demo scenario to the real import flow', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(900, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Strong comfort core'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(
        find.widgetWithText(FilledButton, 'Load demo').first,
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Back to import'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      final backToImportButton = find.widgetWithText(
        OutlinedButton,
        'Back to import',
      );
      await tester.ensureVisible(backToImportButton);
      expect(backToImportButton, findsOneWidget);

      await tester.tap(backToImportButton);
      await tester.pumpAndSettle();

      expect(find.text('Import player'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Import account'),
        findsOneWidget,
      );
      expect(find.text('Account ID'), findsOneWidget);
      expect(find.text('Demo scenarios'), findsOneWidget);
      expect(find.text('Demo scenario: Strong comfort core'), findsNothing);
    });
  });
}

Widget _app() {
  return ProviderScope(
    overrides: [
      playerImportRepositoryProvider.overrideWithValue(
        FakePlayerImportRepository(),
      ),
      coachingCheckpointRepositoryProvider.overrideWithValue(
        FakeCoachingCheckpointRepository(),
      ),
      testerFeedbackRepositoryProvider.overrideWithValue(
        FakeTesterFeedbackRepository(),
      ),
      trainingPreferencesRepositoryProvider.overrideWithValue(
        FakeTrainingPreferencesRepository(),
      ),
      savedAccountRepositoryProvider.overrideWithValue(
        FakeSavedAccountRepository(),
      ),
      dashboardOnboardingRepositoryProvider.overrideWithValue(
        FakeDashboardOnboardingRepository(),
      ),
    ],
    child: MaterialApp(
      initialRoute: AppRoutes.importPlayer,
      onGenerateRoute: AppRouter.onGenerateRoute,
    ),
  );
}

class FakePlayerImportRepository implements PlayerImportRepository {
  @override
  Future<Result<PlayerProfileSummary>> fetchPlayerProfileSummary(
    String accountId,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<RecentMatch>>> fetchRecentMatches(String accountId) async {
    throw UnimplementedError();
  }
}

class FakeCoachingCheckpointRepository implements CoachingCheckpointRepository {
  @override
  Future<CoachingCheckpoint?> loadForAccount(int accountId) async {
    return null;
  }

  @override
  Future<List<CoachingCheckpoint>> loadHistoryForAccount(int accountId) async {
    return const [];
  }

  @override
  Future<CoachingCheckpoint> saveDraft(CoachingCheckpointDraft draft) async {
    return draft.toCheckpoint(DateTime.utc(2026, 4, 1));
  }
}

class FakeTesterFeedbackRepository implements TesterFeedbackRepository {
  @override
  Future<List<TesterFeedbackRecord>> loadAll() async {
    return const [];
  }

  @override
  Future<TesterFeedback?> loadForAccount(int accountId) async {
    return null;
  }

  @override
  Future<void> saveForAccount(int accountId, TesterFeedback feedback) async {}
}

class FakeTrainingPreferencesRepository
    implements TrainingPreferencesRepository {
  @override
  Future<TrainingPreferences> loadForAccount(int accountId) async {
    return const TrainingPreferences();
  }

  @override
  Future<void> saveForAccount(
    int accountId,
    TrainingPreferences preferences,
  ) async {}
}

class FakeSavedAccountRepository implements SavedAccountRepository {
  @override
  Future<List<SavedAccountEntry>> loadAll() async {
    return const [];
  }

  @override
  Future<void> remove(int accountId) async {}

  @override
  Future<void> saveEntry(SavedAccountEntry entry) async {}

  @override
  Future<void> setPinnedAccount(int? accountId) async {}
}

class FakeDashboardOnboardingRepository
    implements DashboardOnboardingRepository {
  @override
  Future<bool> loadDismissed() async {
    return false;
  }

  @override
  Future<void> saveDismissed(bool dismissed) async {}
}
