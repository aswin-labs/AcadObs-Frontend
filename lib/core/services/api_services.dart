import 'dart:developer';

import 'package:acadobs/core/interceptor/custom_interceptor.dart';
import 'package:acadobs/core/services/session_manager.dart';
import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:dio/dio.dart';

class ApiServices {
  static late SessionManager sessionManager;

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: BaseUrls.api,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      followRedirects: true,
      validateStatus: (status) {
        return status != null && status < 300;
      },
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static void initialize(SessionManager manager) {
    sessionManager = manager;

    log('INTERCEPTOR INITIALIZED', name: 'API_SERVICE');

    dio.interceptors.clear();

    dio.interceptors.add(CustomInterceptor(dio, sessionManager));
  }

  /// Generic GET request
  static Future<Response> get(String endpoint, {dynamic data}) async {
    return await dio.get(endpoint, queryParameters: data);
  }

  /// Generic POST request
  static Future<Response> post(
    String endpoint,
    dynamic data, {
    bool isFormData = false,
    ProgressCallback? onSendProgress,
  }) async {
    final requestData = _formatData(data, isFormData);

    return await dio.post(
      endpoint,
      data: requestData,
      onSendProgress: onSendProgress,
    );
  }

  /// Generic PUT request
  static Future<Response> put(
    String endpoint,
    dynamic data, {
    bool isFormData = false,
  }) async {
    final requestData = _formatData(data, isFormData);

    return await dio.put(endpoint, data: requestData);
  }

  /// Generic DELETE request
  static Future<Response> delete(String endpoint) async {
    return await dio.delete(endpoint);
  }

  /// Generic PATCH request
  static Future<Response> patch(
    String endpoint, {
    dynamic data,
    bool isFormData = false,
  }) async {
    final requestData = _formatData(data, isFormData);

    return await dio.patch(endpoint, data: requestData);
  }

  /// Logout request
  static Future<Response> logout(String endpoint) async {
    return await dio.post(endpoint);
  }

  /// Convert Map to FormData if needed
  static dynamic _formatData(dynamic data, bool isFormData) {
    if (isFormData && data is Map<String, dynamic>) {
      return FormData.fromMap(data);
    }

    return data;
  }

  /// File download
  static Future<void> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    await dio.download(
      url,
      savePath,
      onReceiveProgress: onReceiveProgress,
      options: Options(
        headers: dio.options.headers,
        responseType: ResponseType.bytes,
      ),
    );
  }

  /// Example helper API
  static Future<List<dynamic>> getStops(int routeId) async {
    final response = await get("/stop", data: {"route_id": routeId});

    if (response.statusCode == 200) {
      return response.data["data"];
    }

    throw Exception("Failed to load stops");
  }
}
