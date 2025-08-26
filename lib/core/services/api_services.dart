import 'package:acadobs/core/interceptor/custom_interceptor.dart';
import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:dio/dio.dart';

class ApiServices {
  static final Dio _dio = Dio(
      BaseOptions(
        baseUrl: BaseUrls.api,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        followRedirects: true,
        validateStatus: (_) => true,
        headers: {'Content-Type': 'application/json'},
      ),
    )
    ..interceptors.addAll([
      CustomInterceptor(),
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    ]);

  /// Generic GET request
  static Future<Response> get(String endpoint, {dynamic data}) async {
    try {
      return await _dio.get(endpoint, data: data);
    } on DioException catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  /// Generic POST request
  static Future<Response> post(
    String endpoint,
    dynamic data, {
    bool isFormData = false,
  }) async {
    try {
      final requestData = _formatData(data, isFormData);
      return await _dio.post(endpoint, data: requestData);
    } on DioException catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  /// Generic PUT request
  static Future<Response> put(
    String endpoint,
    dynamic data, {
    bool isFormData = false,
  }) async {
    try {
      final requestData = _formatData(data, isFormData);
      return await _dio.put(endpoint, data: requestData);
    } on DioException catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  /// Generic DELETE request
  static Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } on DioException catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  /// Generic patch request
  static Future<Response> patch(String endpoint) async {
    try {
      return await _dio.patch(endpoint);
    } on DioException catch (e) {
      throw Exception('PATCH request failed: $e');
    }
  }

  /// Logout (POST without body)
  static Future<Response> logout(String endpoint) async {
    try {
      return await _dio.post(endpoint);
    } on DioException catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  /// Helper to convert to FormData if needed
  static dynamic _formatData(dynamic data, bool isFormData) {
    if (isFormData && data is Map<String, dynamic>) {
      return FormData.fromMap(data);
    }
    return data;
  }
}
