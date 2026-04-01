import 'package:flutter/material.dart';

import '../../../../app/widgets/app_card_header.dart';
import '../../domain/models/saved_account_entry.dart';
import 'saved_account_tile.dart';

class SavedAccountsSection extends StatelessWidget {
  const SavedAccountsSection({
    required this.entries,
    required this.lastOpenedEntry,
    required this.isSubmitting,
    required this.onContinueWithLast,
    required this.onOpen,
    required this.onTogglePinned,
    required this.onRemove,
    super.key,
  });

  final List<SavedAccountEntry> entries;
  final SavedAccountEntry? lastOpenedEntry;
  final bool isSubmitting;
  final Future<void> Function(SavedAccountEntry entry) onContinueWithLast;
  final Future<void> Function(SavedAccountEntry entry) onOpen;
  final Future<void> Function(SavedAccountEntry entry) onTogglePinned;
  final Future<void> Function(SavedAccountEntry entry) onRemove;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppCardHeader(
              title: 'Recent accounts',
              subtitle:
                  'Reopen a previous local account with one tap without retyping the account ID.',
            ),
            if (lastOpenedEntry != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: isSubmitting
                      ? null
                      : () => onContinueWithLast(lastOpenedEntry!),
                  child: Text('Continue with ${lastOpenedEntry!.displayName}'),
                ),
              ),
            ],
            const SizedBox(height: 16),
            for (final entry in entries) ...[
              SavedAccountTile(
                entry: entry,
                isSubmitting: isSubmitting,
                onOpen: () => onOpen(entry),
                onTogglePinned: () => onTogglePinned(entry),
                onRemove: () => onRemove(entry),
              ),
              if (entry != entries.last) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
