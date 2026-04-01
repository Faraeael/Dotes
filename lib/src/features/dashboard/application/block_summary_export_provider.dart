import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../checkpoints/application/coaching_checkpoint_providers.dart';
import '../../player_import/application/imported_player_provider.dart';
import '../domain/models/block_summary_export.dart';
import '../domain/services/block_summary_export_service.dart';
import 'end_block_summary_provider.dart';

final blockSummaryExportServiceProvider = Provider<BlockSummaryExportService>((
  ref,
) {
  return const BlockSummaryExportService();
});

final blockSummaryExportProvider = Provider<BlockSummaryExport?>((ref) {
  return ref
      .watch(blockSummaryExportServiceProvider)
      .build(
        completedSummary: ref.watch(endBlockSummaryProvider),
        activeStartedCheckpoint: ref.watch(previousCoachingCheckpointProvider),
        importedPlayer: ref.watch(importedPlayerProvider),
      );
});
