import 'package:dotes/src/features/tester_feedback/data/local/tester_feedback_local_store.dart';
import 'package:dotes/src/features/tester_feedback/data/repositories/local_tester_feedback_repository.dart';
import 'package:dotes/src/features/tester_feedback/domain/models/tester_feedback.dart';
import 'package:dotes/src/features/tester_feedback/domain/models/tester_feedback_record.dart';
import 'package:dotes/src/features/tester_feedback/domain/repositories/tester_feedback_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalTesterFeedbackRepository', () {
    late InMemoryTesterFeedbackLocalStore store;
    late TesterFeedbackRepository repository;

    setUp(() {
      store = InMemoryTesterFeedbackLocalStore();
      repository = LocalTesterFeedbackRepository(store);
    });

    test('saves feedback for one account locally', () async {
      const feedback = TesterFeedback(
        rating: TesterFeedbackRating.clear,
        note: 'The session plan felt easy to follow.',
      );

      await repository.saveForAccount(86745912, feedback);
      final loaded = await repository.loadForAccount(86745912);

      expect(loaded?.rating, TesterFeedbackRating.clear);
      expect(loaded?.trimmedNote, 'The session plan felt easy to follow.');
    });

    test('different accounts do not share feedback', () async {
      await repository.saveForAccount(
        86745912,
        const TesterFeedback(
          rating: TesterFeedbackRating.somewhatClear,
          note: 'Helpful, but I wanted more context.',
        ),
      );
      await repository.saveForAccount(
        2222,
        const TesterFeedback(
          rating: TesterFeedbackRating.confusing,
          note: 'I was not sure which card to trust first.',
        ),
      );

      final firstLoaded = await repository.loadForAccount(86745912);
      final secondLoaded = await repository.loadForAccount(2222);

      expect(firstLoaded?.rating, TesterFeedbackRating.somewhatClear);
      expect(firstLoaded?.trimmedNote, 'Helpful, but I wanted more context.');
      expect(secondLoaded?.rating, TesterFeedbackRating.confusing);
      expect(secondLoaded?.trimmedNote, 'I was not sure which card to trust first.');
    });

    test('loads saved feedback correctly', () async {
      await repository.saveForAccount(
        86745912,
        const TesterFeedback(
          rating: TesterFeedbackRating.confusing,
          note: 'Block review made sense after a re-import.',
        ),
      );

      final loaded = await repository.loadForAccount(86745912);

      expect(loaded, isNotNull);
      expect(loaded?.rating.label, 'Confusing');
      expect(loaded?.hasNote, isTrue);
      expect(loaded?.trimmedNote, 'Block review made sense after a re-import.');
    });

    test('loads multiple accounts for the playtest summary', () async {
      await repository.saveForAccount(
        86745912,
        TesterFeedback(
          rating: TesterFeedbackRating.clear,
          note: 'This was easy to understand.',
          playerLabel: 'Week 1 Player',
          savedAt: DateTime.utc(2026, 3, 31, 8, 30),
        ),
      );
      await repository.saveForAccount(
        2222,
        TesterFeedback(
          rating: TesterFeedbackRating.confusing,
          note: 'I needed help reading the block review.',
          playerLabel: 'Second Tester',
          savedAt: DateTime.utc(2026, 3, 31, 9, 0),
        ),
      );

      final loaded = await repository.loadAll();

      expect(
        loaded,
        [
          isA<TesterFeedbackRecord>()
              .having((entry) => entry.accountId, 'accountId', 2222),
          isA<TesterFeedbackRecord>()
              .having((entry) => entry.accountId, 'accountId', 86745912),
        ],
      );
    });

    test('replacing feedback updates the stored note', () async {
      await repository.saveForAccount(
        86745912,
        const TesterFeedback(
          rating: TesterFeedbackRating.somewhatClear,
          note: 'The role read felt noisy.',
        ),
      );
      await repository.saveForAccount(
        86745912,
        const TesterFeedback(
          rating: TesterFeedbackRating.clear,
          note: 'Manual setup made the plan clearer.',
        ),
      );

      final loaded = await repository.loadForAccount(86745912);
      final allEntries = await repository.loadAll();

      expect(loaded?.rating, TesterFeedbackRating.clear);
      expect(loaded?.trimmedNote, 'Manual setup made the plan clearer.');
      expect(allEntries, hasLength(1));
      expect(allEntries.single.feedback.trimmedNote, 'Manual setup made the plan clearer.');
    });
  });
}

class InMemoryTesterFeedbackLocalStore implements TesterFeedbackLocalStore {
  final Map<String, String> _values = {};

  @override
  Future<Set<String>> getKeys() async {
    return _values.keys.toSet();
  }

  @override
  Future<String?> getString(String key) async {
    return _values[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }
}
