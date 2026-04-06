import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures/app_failure.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/result/result.dart';
import '../../domain/models/player_profile_summary.dart';
import '../../domain/models/recent_match.dart';
import '../../domain/repositories/player_import_repository.dart';
import '../services/opendota_player_service.dart';

final openDotaPlayerServiceProvider = Provider<OpenDotaPlayerService>((ref) {
  final dio = ref.watch(dioProvider);
  return OpenDotaPlayerService(dio);
});

final playerImportRepositoryProvider = Provider<PlayerImportRepository>((ref) {
  final service = ref.watch(openDotaPlayerServiceProvider);
  return OpenDotaPlayerRepository(service);
});

class OpenDotaPlayerRepository implements PlayerImportRepository {
  OpenDotaPlayerRepository(this._service);

  final OpenDotaPlayerService _service;

  @override
  Future<Result<PlayerProfileSummary>> fetchPlayerProfileSummary(
    String accountId,
  ) async {
    try {
      final json = await _service.fetchPlayerProfile(accountId);
      final profile = PlayerProfileSummary.fromJson(json);

      if (!profile.hasProfile) {
        return Failure(
          AppFailure(
            type: AppFailureType.notFound,
            message:
                'We could not find a public OpenDota profile for that account ID. Check the digits and make sure the player has public match data enabled.',
            statusCode: 404,
          ),
        );
      }

      return Success(profile);
    } on DioException catch (error) {
      return Failure(_mapDioFailure(error));
    } on FormatException {
      return const Failure(
        AppFailure(
          type: AppFailureType.parsing,
          message:
              'OpenDota returned data in an unexpected format. Please try again.',
        ),
      );
    } catch (_) {
      return const Failure(
        AppFailure(
          type: AppFailureType.unknown,
          message: 'Something went wrong while importing the player.',
        ),
      );
    }
  }

  @override
  Future<Result<List<RecentMatch>>> fetchRecentMatches(String accountId) async {
    try {
      final json = await _service.fetchRecentMatches(accountId);
      final matches = json.map(RecentMatch.fromJson).toList(growable: false);
      return Success(matches);
    } on DioException catch (error) {
      return Failure(_mapDioFailure(error));
    } on FormatException {
      return const Failure(
        AppFailure(
          type: AppFailureType.parsing,
          message:
              'Recent match data came back in an unexpected format. Please try again.',
        ),
      );
    } catch (_) {
      return const Failure(
        AppFailure(
          type: AppFailureType.unknown,
          message: 'Something went wrong while loading recent matches.',
        ),
      );
    }
  }

  AppFailure _mapDioFailure(DioException error) {
    final statusCode = error.response?.statusCode;

    if (statusCode == 404) {
      return AppFailure(
        type: AppFailureType.notFound,
        message:
            'We could not find a public OpenDota profile for that account ID. Check the digits and make sure the player has public match data enabled.',
        statusCode: statusCode,
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const AppFailure(
        type: AppFailureType.timeout,
        message:
            'OpenDota took too long to respond. Please wait a moment and retry the import.',
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return const AppFailure(
        type: AppFailureType.network,
        message:
            'We could not reach OpenDota. Check your internet connection and try the import again.',
      );
    }

    if (statusCode == 429) {
      return AppFailure(
        type: AppFailureType.rateLimited,
        message:
            'OpenDota is rate-limiting requests right now. Please wait a moment and retry the import.',
        statusCode: statusCode,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return AppFailure(
        type: AppFailureType.server,
        message: 'OpenDota is having trouble right now. Please try again soon.',
        statusCode: statusCode,
      );
    }

    if (statusCode != null) {
      return AppFailure(
        type: AppFailureType.unknown,
        message: 'OpenDota returned an unexpected response. Please try again.',
        statusCode: statusCode,
      );
    }

    return const AppFailure(
      type: AppFailureType.unknown,
      message: 'Something unexpected happened while talking to OpenDota.',
    );
  }
}
