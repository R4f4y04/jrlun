import 'package:dio/dio.dart';
import 'package:frontend/models/insight_model.dart';
import 'package:frontend/services/api_config.dart';

/// Real HTTP service for AI insights, backed by Dio.
///
/// Replaces [MockInsightService] for live backend integration.
class InsightService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Fetch the current AI-generated insight for the dashboard hero card.
  Future<InsightModel> getCurrentInsight() async {
    try {
      final response = await _dio.get(ApiConfig.insightPath);
      return InsightModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final errorMsg = _extractErrorMessage(e);
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
