import 'dart:developer';

import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class CustomInterceptor extends Interceptor {
  final Dio dio;

  CustomInterceptor(this.dio);

  final AuthStorageService storage = AuthStorageService();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.getToken();

    log('================ REQUEST ================', name: 'API_SERVICE');

    log('URL => ${options.uri}', name: 'API_SERVICE');

    log('METHOD => ${options.method}', name: 'API_SERVICE');

    log('BODY => ${options.data}', name: 'API_SERVICE');

    final isRefreshApi = options.path == ApiEndpoints.refreshToken;

    log('IS REFRESH API => $isRefreshApi', name: 'API_SERVICE');

    if (!isRefreshApi && token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Content-Type'] =
        options.data is FormData ? 'multipart/form-data' : 'application/json';

    log('FINAL HEADERS => ${options.headers}', name: 'API_SERVICE');

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    log('================ ERROR ================', name: 'API_SERVICE');

    log('FAILED URL => ${err.requestOptions.uri}', name: 'API_SERVICE');

    log('STATUS CODE => ${err.response?.statusCode}', name: 'API_SERVICE');

    log('ERROR DATA => ${err.response?.data}', name: 'API_SERVICE');

    if (err.response?.statusCode == 401) {
      try {
        log(
          '================ REFRESH FLOW STARTED ================',
          name: 'API_SERVICE',
        );

        final refreshToken = await storage.getRefreshToken();

        log('STORED REFRESH TOKEN => $refreshToken', name: 'API_SERVICE');

        if (refreshToken == null) {
          log('NO REFRESH TOKEN FOUND', name: 'API_SERVICE');

          await storage.logout();

          return handler.next(err);
        }

        log('CALLING REFRESH API...', name: 'API_SERVICE');

        final response = await dio.post(
          ApiEndpoints.refreshToken,
          data: {'refreshToken': refreshToken},
        );

        log('REFRESH API SUCCESS => ${response.data}', name: 'API_SERVICE');

        final newAccessToken = response.data['token'];

        final newRefreshToken = response.data['refreshToken'];

        log('NEW ACCESS TOKEN => $newAccessToken', name: 'API_SERVICE');

        log('NEW REFRESH TOKEN => $newRefreshToken', name: 'API_SERVICE');
        await storage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        log('NEW TOKENS SAVED SUCCESSFULLY', name: 'API_SERVICE');

        final request = err.requestOptions;

        request.headers['Authorization'] = 'Bearer $newAccessToken';

        log('RETRYING ORIGINAL REQUEST...', name: 'API_SERVICE');

        final retryResponse = await dio.fetch(request);

        log('RETRY SUCCESS => ${retryResponse.data}', name: 'API_SERVICE');

        return handler.resolve(retryResponse);
      } catch (e, stackTrace) {
        log(
          '================ REFRESH FAILED ================',
          name: 'API_SERVICE',
          error: e,
          stackTrace: stackTrace,
        );

        await storage.logout();

        return handler.next(err);
      }
    }

    return handler.next(err);
  }
}
// class CustomInterceptor extends Interceptor {
//   final Dio _dio = ApiServices.dio;
//   final AuthStorageService _storage = AuthStorageService();
//   @override
//   void onRequest(
//     RequestOptions options,
//     RequestInterceptorHandler handler,
//   ) async {
//     final token = await _storage.getToken();
//     log('================ REQUEST ================', name: 'API_SERVICE');
//     log('URL => ${options.uri}', name: 'API_SERVICE');
//     log('METHOD => ${options.method}', name: 'API_SERVICE');
//     log('BODY => ${options.data}', name: 'API_SERVICE');
//     final isRefreshApi = options.path.contains(ApiEndpoints.refreshToken);
//     log('IS REFRESH API => $isRefreshApi', name: 'API_SERVICE');
//     if (!isRefreshApi && token != null) {
//       options.headers['Authorization'] = 'Bearer $token';
//     }
//     options.headers['Content-Type'] =
//         options.data is FormData ? 'multipart/form-data' : 'application/json';
//     log('FINAL HEADERS => ${options.headers}', name: 'API_SERVICE');
//     handler.next(options);
//   }

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     log('================ ERROR ================', name: 'API_SERVICE');
//     log('FAILED URL => ${err.requestOptions.uri}', name: 'API_SERVICE');
//     log('STATUS CODE => ${err.response?.statusCode}', name: 'API_SERVICE');
//     log('ERROR DATA => ${err.response?.data}', name: 'API_SERVICE');
//     if (err.response?.statusCode == 401) {
//       try {
//         log(
//           '================ REFRESH FLOW STARTED ================',
//           name: 'API_SERVICE',
//         );
//         final refreshToken = await _storage.getRefreshToken();
//         log('STORED REFRESH TOKEN => $refreshToken', name: 'API_SERVICE');
//         if (refreshToken == null) {
//           log('NO REFRESH TOKEN FOUND', name: 'API_SERVICE');
//           await _storage.logout();
//           return handler.next(err);
//         }
//         log('CALLING REFRESH API...', name: 'API_SERVICE');
//         final response = await _dio.post(
//           ApiEndpoints.refreshToken,
//           data: {'refreshToken': refreshToken},
//         );
//         log('REFRESH API SUCCESS => ${response.data}', name: 'API_SERVICE');
//         final newAccessToken = response.data['token'];
//         final newRefreshToken = response.data['refreshToken'];
//         log('NEW ACCESS TOKEN => $newAccessToken', name: 'API_SERVICE');
//         log('NEW REFRESH TOKEN => $newRefreshToken', name: 'API_SERVICE');
//         await _storage.saveTokens(
//           accessToken: newAccessToken,
//           refreshToken: newRefreshToken,
//         );
//         log('NEW TOKENS SAVED SUCCESSFULLY', name: 'API_SERVICE');
//         final request = err.requestOptions;
//         request.headers['Authorization'] = 'Bearer $newAccessToken';
//         log('RETRYING ORIGINAL REQUEST...', name: 'API_SERVICE');
//         final retryResponse = await _dio.fetch(request);
//         log('RETRY SUCCESS => ${retryResponse.data}', name: 'API_SERVICE');
//         return handler.resolve(retryResponse);
//       } catch (e, stackTrace) {
//         log(
//           '================ REFRESH FAILED ================',
//           name: 'API_SERVICE',
//           error: e,
//           stackTrace: stackTrace,
//         );
//         await _storage.logout();
//         return handler.next(err);
//       }
//     }
//     return handler.next(err);
//   }
// }
