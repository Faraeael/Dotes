import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_router.dart';
import '../application/player_import_controller.dart';
import '../application/saved_accounts_providers.dart';
import '../domain/models/demo_player_scenario.dart';
import '../domain/models/saved_account_entry.dart';
import 'widgets/demo_scenario_section.dart';
import 'widgets/player_id_form.dart';
import 'widgets/saved_accounts_section.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  late final TextEditingController _playerIdController;

  @override
  void initState() {
    super.initState();
    _playerIdController = TextEditingController();
  }

  @override
  void dispose() {
    _playerIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (ref.read(playerImportControllerProvider).isSubmitting) {
      return;
    }

    final controller = ref.read(playerImportControllerProvider.notifier);
    final normalizedPlayerId = _playerIdController.text.trim();
    if (_playerIdController.text != normalizedPlayerId) {
      _playerIdController.value = TextEditingValue(
        text: normalizedPlayerId,
        selection: TextSelection.collapsed(offset: normalizedPlayerId.length),
      );
    }

    controller.updatePlayerId(normalizedPlayerId);

    final success = await controller.submit();
    _goToDashboardIfReady(success);
  }

  Future<void> _loadDemoScenario(DemoPlayerScenario scenario) async {
    final success = await ref
        .read(playerImportControllerProvider.notifier)
        .importDemoScenario(scenario);
    _goToDashboardIfReady(success);
  }

  Future<void> _openSavedEntry(SavedAccountEntry entry) async {
    final success = await ref
        .read(playerImportControllerProvider.notifier)
        .submitSavedAccount(entry);
    _goToDashboardIfReady(success);
  }

  void _goToDashboardIfReady(bool success) {
    if (!mounted || !success) {
      return;
    }

    final currentRoute = ModalRoute.of(context);
    if (currentRoute != null && !currentRoute.isCurrent) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playerImportControllerProvider);
    final demoScenarios = ref.watch(demoPlayerScenariosProvider);
    final savedAccounts = ref.watch(recentSavedAccountsProvider);
    final lastOpenedAccount = ref.watch(lastOpenedSavedAccountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Import account')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SavedAccountsSection(
                      entries: savedAccounts,
                      lastOpenedEntry: lastOpenedAccount,
                      isSubmitting: state.isSubmitting,
                      onContinueWithLast: _openSavedEntry,
                      onOpen: _openSavedEntry,
                      onTogglePinned: (entry) => ref
                          .read(savedAccountsControllerProvider.notifier)
                          .togglePinnedAccount(entry.accountId),
                      onRemove: (entry) => ref
                          .read(savedAccountsControllerProvider.notifier)
                          .removeAccount(entry.accountId),
                    ),
                    if (savedAccounts.isNotEmpty) const SizedBox(height: 16),
                    PlayerIdForm(
                      controller: _playerIdController,
                      isSubmitting: state.isSubmitting,
                      errorText: state.errorMessage,
                      onChanged: ref
                          .read(playerImportControllerProvider.notifier)
                          .updatePlayerId,
                      onSubmit: _submit,
                    ),
                    const SizedBox(height: 16),
                    DemoScenarioSection(
                      scenarios: demoScenarios,
                      isSubmitting: state.isSubmitting,
                      onSelectScenario: _loadDemoScenario,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
