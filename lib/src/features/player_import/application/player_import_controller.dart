import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result/result.dart';
import '../../checkpoints/application/coaching_checkpoint_providers.dart';
import '../../dashboard/application/saved_block_summary_providers.dart';
import '../../tester_feedback/application/tester_feedback_providers.dart';
import '../../training_preferences/application/training_preferences_providers.dart';
import '../data/demo/demo_player_scenarios.dart';
import '../data/repositories/opendota_player_repository.dart';
import '../domain/models/demo_player_scenario.dart';
import '../domain/models/imported_player_data.dart';
import '../domain/models/saved_account_entry.dart';
import '../domain/repositories/player_import_repository.dart';
import 'imported_player_provider.dart';
import 'saved_accounts_providers.dart';

final demoPlayerScenariosProvider = Provider<List<DemoPlayerScenario>>((ref) {
  return demoPlayerScenarios;
});

final playerImportControllerProvider =
    StateNotifierProvider<PlayerImportController, PlayerImportState>((ref) {
      final repository = ref.watch(playerImportRepositoryProvider);
      return PlayerImportController(ref, repository);
    });

class PlayerImportController extends StateNotifier<PlayerImportState> {
  PlayerImportController(this._ref, this._repository)
    : super(const PlayerImportState());

  final Ref _ref;
  final PlayerImportRepository _repository;

  void reset() {
    _clearCheckpointSession();
    _clearTesterFeedbackSession();
    _clearTrainingPreferencesSession();
    _clearSavedBlockSummarySession();
    _clearImportedPlayer();
    state = const PlayerImportState();
  }

  void updatePlayerId(String value) {
    final normalizedValue = _normalizePlayerId(value);
    state = state.copyWith(
      playerId: normalizedValue,
      errorMessage: null,
      isSubmitting: false,
    );
  }

  Future<bool> submit() async {
    if (state.isSubmitting) {
      return false;
    }

    final trimmed = _normalizePlayerId(state.playerId);
    _clearCheckpointSession();
    _clearTesterFeedbackSession();
    _clearTrainingPreferencesSession();
    _clearSavedBlockSummarySession();
    _clearImportedPlayer();

    final errorMessage = _validatePlayerId(trimmed);

    if (errorMessage != null) {
      state = state.copyWith(
        playerId: trimmed,
        errorMessage: errorMessage,
        isSubmitting: false,
      );
      return false;
    }

    state = state.copyWith(
      playerId: trimmed,
      errorMessage: null,
      isSubmitting: true,
    );

    try {
      final profileResult = await _repository.fetchPlayerProfileSummary(
        trimmed,
      );
      switch (profileResult) {
        case Failure():
          state = state.copyWith(
            playerId: trimmed,
            errorMessage: profileResult.error.message,
            isSubmitting: false,
          );
          return false;
        case Success():
          final matchesResult = await _repository.fetchRecentMatches(trimmed);
          switch (matchesResult) {
            case Failure():
              state = state.copyWith(
                playerId: trimmed,
                errorMessage: matchesResult.error.message,
                isSubmitting: false,
              );
              return false;
            case Success():
              final importedPlayer = ImportedPlayerData(
                profile: profileResult.value,
                recentMatches: matchesResult.value,
              );
              await _ref
                  .read(checkpointPersistenceControllerProvider)
                  .loadPreviousForAccount(importedPlayer.profile.accountId);
              await _ref
                  .read(testerFeedbackControllerProvider)
                  .loadForAccount(importedPlayer.profile.accountId);
              await _ref
                  .read(trainingPreferencesControllerProvider)
                  .loadForAccount(importedPlayer.profile.accountId);
              await _ref
                  .read(savedBlockSummaryControllerProvider)
                  .loadForAccount(importedPlayer.profile.accountId);
              try {
                await _ref
                    .read(savedAccountsControllerProvider.notifier)
                    .saveRealAccount(importedPlayer.profile);
              } catch (_) {}
              _ref.read(importedPlayerProvider.notifier).state = importedPlayer;
              state = state.copyWith(
                playerId: trimmed,
                errorMessage: null,
                isSubmitting: false,
              );
              return true;
          }
      }
    } catch (_) {
      state = state.copyWith(
        playerId: trimmed,
        errorMessage: 'Something went wrong while importing this player.',
        isSubmitting: false,
      );
      return false;
    }
  }

  Future<bool> importDemoScenario(DemoPlayerScenario scenario) async {
    if (state.isSubmitting) {
      return false;
    }

    _clearCheckpointSession();
    _clearTesterFeedbackSession();
    _clearTrainingPreferencesSession();
    _clearSavedBlockSummarySession();
    _clearImportedPlayer();
    state = state.copyWith(
      playerId: '',
      errorMessage: null,
      isSubmitting: true,
    );

    try {
      await _ref
          .read(checkpointPersistenceControllerProvider)
          .loadSeededHistoryForAccount(
            scenario.importedPlayer.profile.accountId,
            [...scenario.checkpointHistory],
          );
      await _ref
          .read(testerFeedbackControllerProvider)
          .loadSeededForAccount(
            scenario.importedPlayer.profile.accountId,
            scenario.testerFeedback,
          );
      await _ref
          .read(trainingPreferencesControllerProvider)
          .loadSeededForAccount(
            scenario.importedPlayer.profile.accountId,
            scenario.trainingPreferences,
          );
      await _ref
          .read(savedBlockSummaryControllerProvider)
          .loadSeededForAccount(
            scenario.importedPlayer.profile.accountId,
            const [],
          );
      _ref.read(importedPlayerProvider.notifier).state =
          scenario.importedPlayer;
      state = const PlayerImportState();
      return true;
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Something went wrong while loading this demo scenario.',
        isSubmitting: false,
      );
      return false;
    }
  }

  Future<bool> submitSavedAccount(SavedAccountEntry entry) async {
    updatePlayerId(entry.accountId.toString());
    return submit();
  }

  String _normalizePlayerId(String value) {
    return value.trim();
  }

  void _clearImportedPlayer() {
    _ref.read(importedPlayerProvider.notifier).state = null;
  }

  void _clearCheckpointSession() {
    _ref.read(checkpointPersistenceControllerProvider).clearSession();
  }

  void _clearTesterFeedbackSession() {
    _ref.read(testerFeedbackControllerProvider).clearSession();
  }

  void _clearTrainingPreferencesSession() {
    _ref.read(trainingPreferencesControllerProvider).clearSession();
  }

  void _clearSavedBlockSummarySession() {
    _ref.read(savedBlockSummaryControllerProvider).clearSession();
  }

  String? _validatePlayerId(String value) {
    if (value.isEmpty) {
      return 'Enter the numeric account ID from the player profile you want to review.';
    }

    final digitsOnly = RegExp(r'^\d+$');
    if (!digitsOnly.hasMatch(value)) {
      return 'Use digits only for the account ID, not a display name or profile link.';
    }

    if (value.length < 4) {
      return 'That account ID looks too short. Enter at least 4 digits.';
    }

    if (value.length > 20) {
      return 'That account ID looks too long. Use 20 digits or fewer.';
    }

    return null;
  }
}

class PlayerImportState {
  const PlayerImportState({
    this.playerId = '',
    this.errorMessage,
    this.isSubmitting = false,
  });

  final String playerId;
  final String? errorMessage;
  final bool isSubmitting;

  PlayerImportState copyWith({
    String? playerId,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return PlayerImportState(
      playerId: playerId ?? this.playerId,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
