import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CustomInterceptor extends Interceptor {
  // bool _isRefreshing = false;
  // List<RequestOptions> _pendingRequests = [];

  CustomInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? token = await AuthStorageService().getToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Content-Type'] =
        options.data is FormData ? 'multipart/form-data' : 'application/json';

    debugPrint("Request: ${options.method} ${options.path}");
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint("Response: ${response.statusCode} ${response.data}");
    super.onResponse(response, handler);
  }

  // @override
  // void onError(DioException err, ErrorInterceptorHandler handler) async {
  //   if (err.response?.statusCode == 401) {
  //     log("401 Unauthorized - Attempting token refresh");

  //     if (!_isRefreshing) {
  //       _isRefreshing = true;

  //       try {
  //         final newAccessToken = await _refreshToken();
  //         if (newAccessToken != null) {
  //           log("Token refreshed successfully");

  //           // Retry all pending requests with the new token
  //           for (var request in List<RequestOptions>.from(_pendingRequests)) {
  //             _pendingRequests.remove(request);
  //             request.headers['Authorization'] = 'Bearer $newAccessToken';
  //             Response response = await Dio().fetch(request);
  //             // dio.fetch(request);
  //           }

  //           handler.resolve(
  //               await _retryRequest(err.requestOptions, newAccessToken));
  //           return;
  //         } else {
  //           log("Refresh token expired. Logging out...");
  //           // await UserCredentials.deleteToken();
  //         }
  //       } catch (e) {
  //         log("Error refreshing token: $e");
  //       } finally {
  //         _isRefreshing = false;
  //       }
  //     }

  //     // Add the failed request to the queue only if it's not already there
  //     if (!_pendingRequests.contains(err.requestOptions)) {
  //       _pendingRequests.add(err.requestOptions);
  //     }

  //     return;
  //   }

  //   super.onError(err, handler);
  // }

  // Future<String?> _refreshToken() async {
  //   try {
  //     // Use a separate Dio instance for refresh request
  //     Dio refreshDio = Dio();

  //     // Retrieve the refresh token from secure storage
  //     final refreshToken = await UserCredentials.getRefreshToken();

  //     if (refreshToken == null) {
  //       log("No refresh token found.");
  //       return null;
  //     }

  //     log("Refresh token:::${refreshToken.toString()}");

  //     // Make the refresh request using the refresh token in the Authorization header
  //     final response = await refreshDio.post(
  //       // 'https://schooltest.altezzai.com/api/refresh',
  //       "https://schoolmanagement.altezzai.com/api/refresh",
  //       options: Options(
  //         headers: {
  //           "Content-Type": "application/json",
  //           "Authorization":
  //               "Bearer $refreshToken", // Send refresh token as Bearer token
  //         },
  //       ),
  //     );

  //     log("Refresh token response=============${response.data}");

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       // Assuming the new access token is in the response
  //       final newAccessToken = response.data["token"];

  //       if (newAccessToken != null) {
  //         // Save the new access token
  //         await UserCredentials.saveAccessToken(newAccessToken);
  //         return newAccessToken;
  //       } else {
  //         log("No access token received from the refresh API.");
  //       }
  //     } else {
  //       log("Failed to refresh token: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     log("Failed to refresh token: $e");
  //   }
  //   return null;
  // }

  // Future<Response> _retryRequest(
  //   RequestOptions requestOptions,
  //   String newToken,
  // ) async {
  //   requestOptions.headers['Authorization'] = 'Bearer $newToken';
  //   Response response = await Dio().fetch(requestOptions);
  //   return response;
  // }
}
