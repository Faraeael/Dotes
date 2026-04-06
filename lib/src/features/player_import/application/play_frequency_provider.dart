import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/play_frequency.dart';
import '../domain/services/play_frequency_service.dart';
import 'imported_player_provider.dart';

/// Computes the player's [PlayFrequency] from their imported recent matches.
///
/// Returns `null` when no player is imported or when there are no recent
/// matches to work with.
final playFrequencyProvider = Provider<PlayFrequency?>((ref) {
  final player = ref.watch(importedPlayerProvider);
  if (player == null || player.recentMatches.isEmpty) return null;
  return const PlayFrequencyService().compute(player.recentMatches);
});
