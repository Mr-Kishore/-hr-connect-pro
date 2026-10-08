import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../services/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService storageService;
  final Dio dio;

  AuthInterceptor({
    required this.storageService,
    required this.dio,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Attempt token refresh
      final refreshToken = await storageService.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final refreshResponse = await dio.post(
            ApiEndpoints.authRefreshToken,
            data: {'refresh_token': refreshToken},
            options: Options(headers: {'Requires-Auth': false}),
          );

          if (refreshResponse.statusCode == 200) {
            final newAccess = refreshResponse.data['data']['access_token'];
            final newRefresh = refreshResponse.data['data']['refresh_token'];

            await storageService.saveAuthTokens(
              accessToken: newAccess,
              refreshToken: newRefresh,
            );

            // Retry the original request
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccess';

            final retryResponse = await dio.fetch(options);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          await storageService.clearAuth();
        }
      } else {
        await storageService.clearAuth();
      }
    }
    return handler.next(err);
  }
}
