import 'package:dio/dio.dart';

class OpenDotaPlayerService {
  OpenDotaPlayerService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> fetchPlayerProfile(String accountId) async {
    final response = await _dio.get<Map<String, dynamic>>('/players/$accountId');
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<List<Map<String, dynamic>>> fetchRecentMatches(String accountId) async {
    final response = await _dio.get<List<dynamic>>(
      '/players/$accountId/recentMatches',
    );

    final items = response.data ?? const [];
    return items
        .whereType<Map<dynamic, dynamic>>()
        .map(Map<String, dynamic>.from)
        .toList();
  }
}
