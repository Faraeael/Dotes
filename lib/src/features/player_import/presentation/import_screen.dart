import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_router.dart';
import '../application/player_import_controller.dart';
import 'widgets/player_id_form.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Import player')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: PlayerIdForm(
                controller: _playerIdController,
                isSubmitting: state.isSubmitting,
                errorText: state.errorMessage,
                onChanged: ref
                    .read(playerImportControllerProvider.notifier)
                    .updatePlayerId,
                onSubmit: _submit,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
