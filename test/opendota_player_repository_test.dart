import 'package:dio/dio.dart';
import 'package:dotes/src/core/failures/app_failure.dart';
import 'package:dotes/src/core/result/result.dart';
import 'package:dotes/src/features/player_import/data/repositories/opendota_player_repository.dart';
import 'package:dotes/src/features/player_import/data/services/opendota_player_service.dart';
import 'package:dotes/src/features/player_import/domain/models/player_profile_summary.dart';
import 'package:dotes/src/features/player_import/domain/models/recent_match.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OpenDotaPlayerRepository', () {
    test('returns a not-found failure when profile payload is empty', () async {
      final repository = OpenDotaPlayerRepository(
        _FakeOpenDotaPlayerService(profileJson: const {}),
      );

      final result = await repository.fetchPlayerProfileSummary('86745912');

      expect(result, isA<Failure<PlayerProfileSummary>>());
      final failure = result as Failure<PlayerProfileSummary>;
      expect(failure.error.type, AppFailureType.notFound);
      expect(
        failure.error.message,
        'We could not find a public OpenDota profile for that account ID. Check the digits and make sure the player has public match data enabled.',
      );
    });

    test('maps timeout failures to actionable retry copy', () async {
      final repository = OpenDotaPlayerRepository(
        _FakeOpenDotaPlayerService(
          profileError: DioException(
            requestOptions: RequestOptions(path: '/players/86745912'),
            type: DioExceptionType.connectionTimeout,
          ),
        ),
      );

      final result = await repository.fetchPlayerProfileSummary('86745912');

      expect(result, isA<Failure<PlayerProfileSummary>>());
      final failure = result as Failure<PlayerProfileSummary>;
      expect(failure.error.type, AppFailureType.timeout);
      expect(
        failure.error.message,
        'OpenDota took too long to respond. Please wait a moment and retry the import.',
      );
    });

    test('maps connection failures to actionable network copy', () async {
      final repository = OpenDotaPlayerRepository(
        _FakeOpenDotaPlayerService(
          profileError: DioException(
            requestOptions: RequestOptions(path: '/players/86745912'),
            type: DioExceptionType.connectionError,
          ),
        ),
      );

      final result = await repository.fetchPlayerProfileSummary('86745912');

      expect(result, isA<Failure<PlayerProfileSummary>>());
      final failure = result as Failure<PlayerProfileSummary>;
      expect(failure.error.type, AppFailureType.network);
      expect(
        failure.error.message,
        'We could not reach OpenDota. Check your internet connection and try the import again.',
      );
    });

    test('maps rate limits to wait-and-retry copy', () async {
      final repository = OpenDotaPlayerRepository(
        _FakeOpenDotaPlayerService(
          recentMatchesError: DioException(
            requestOptions: RequestOptions(
              path: '/players/86745912/recentMatches',
            ),
            response: Response<void>(
              requestOptions: RequestOptions(
                path: '/players/86745912/recentMatches',
              ),
              statusCode: 429,
            ),
            type: DioExceptionType.badResponse,
          ),
        ),
      );

      final result = await repository.fetchRecentMatches('86745912');

      expect(result, isA<Failure<List<RecentMatch>>>());
      final failure = result as Failure<List<RecentMatch>>;
      expect(failure.error.type, AppFailureType.rateLimited);
      expect(
        failure.error.message,
        'OpenDota is rate-limiting requests right now. Please wait a moment and retry the import.',
      );
    });
  });
}

class _FakeOpenDotaPlayerService extends OpenDotaPlayerService {
  _FakeOpenDotaPlayerService({
    this.profileJson,
    this.profileError,
    this.recentMatchesError,
  }) : super(Dio());

  final Map<String, dynamic>? profileJson;
  final DioException? profileError;
  final DioException? recentMatchesError;

  @override
  Future<Map<String, dynamic>> fetchPlayerProfile(String accountId) async {
    if (profileError != null) {
      throw profileError!;
    }

    return profileJson ?? const {};
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRecentMatches(
    String accountId,
  ) async {
    if (recentMatchesError != null) {
      throw recentMatchesError!;
    }

    return const [];
  }
}
