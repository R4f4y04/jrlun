import 'package:dio/dio.dart';
import 'package:frontend/models/journal_entry.dart';
import 'package:frontend/services/api_config.dart';

/// Real HTTP service for journal entries, backed by Dio.
///
/// Replaces [MockJournalService] for live backend integration.
/// Implements the same interface so Providers can swap seamlessly.
class JournalService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Fetch paginated historical entries from the backend.
  Future<List<JournalEntry>> getHistoricalEntries({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      print('🌍 [Frontend] GET request to ${ApiConfig.baseUrl}${ApiConfig.entriesPath}?limit=$limit&offset=$offset');
      final response = await _dio.get(
        ApiConfig.entriesPath,
        queryParameters: {'limit': limit, 'offset': offset},
      );
      print('✅ [Frontend] GET response received: \${response.statusCode}');

      final data = response.data;
      final List<dynamic> entriesJson = data['data'] ?? [];
      return entriesJson
          .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('❌ [Frontend] GET request failed: \${e.message}');
      final errorMsg = _extractErrorMessage(e);
      print('❌ [Frontend] Error parsed: $errorMsg');
      throw Exception(errorMsg);
    }
  }

  /// Submit a new journal entry and receive the enriched result.
  Future<JournalEntry> submitEntry(String rawText) async {
    try {
      print('🌍 [Frontend] POST request to ${ApiConfig.baseUrl}${ApiConfig.entriesPath} with payload: $rawText');
      final response = await _dio.post(
        ApiConfig.entriesPath,
        data: {'raw_text': rawText},
      );
      print('✅ [Frontend] POST response received: \${response.statusCode} - \${response.data}');

      return JournalEntry.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ [Frontend] POST request failed: \${e.message}');
      if (e.response != null) {
        print('❌ [Frontend] Error response data: \${e.response?.data}');
      }
      final errorMsg = _extractErrorMessage(e);
      print('❌ [Frontend] Error parsed: $errorMsg');
      throw Exception(errorMsg);
    }
  }

  /// Parse the standard error format from the JSON contract.
  String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      final error = e.response!.data['error'];
      if (error is Map) {
        return error['message'] ?? 'An unknown error occurred.';
      }
    }
    return e.message ?? 'Failed to connect to the server.';
  }
}
