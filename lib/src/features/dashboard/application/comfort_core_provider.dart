import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../player_import/application/imported_player_provider.dart';
import '../domain/models/comfort_core_summary.dart';
import '../domain/services/comfort_core_service.dart';

final comfortCoreServiceProvider = Provider<ComfortCoreService>((ref) {
  return const ComfortCoreService();
});

final comfortCoreProvider = Provider<ComfortCoreSummary?>((ref) {
  final importedPlayer = ref.watch(importedPlayerProvider);
  if (importedPlayer == null) {
    return null;
  }

  final service = ref.watch(comfortCoreServiceProvider);
  return service.build(importedPlayer.recentMatches);
});
