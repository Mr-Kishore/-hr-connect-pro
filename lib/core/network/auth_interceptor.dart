import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../services/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService storageService;
  final Dio dio;

  AuthInterceptor({required this.storageService, required this.dio});

  static const Set<String> _publicAuthEndpoints = {
    ApiEndpoints.authSendOtp,
    ApiEndpoints.authVerifyOtp,
    ApiEndpoints.authGoogleSignIn,
    ApiEndpoints.authAppleSignIn,
    ApiEndpoints.authRefreshToken,
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Accept'] = 'application/json';

    // Honor explicit opt-out or public authentication endpoints
    final requiresAuth = options.headers.remove('Requires-Auth') != false;
    final isPublicEndpoint = _publicAuthEndpoints.contains(options.path);

    if (requiresAuth && !isPublicEndpoint) {
      final token = await storageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Guard against infinite recursive loops if the refresh endpoint itself returns 401
      if (err.requestOptions.path == ApiEndpoints.authRefreshToken) {
        await storageService.clearAuth();
        return handler.next(err);
      }

      // Attempt token refresh
      final refreshToken = await storageService.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final refreshResponse = await dio.post(
            ApiEndpoints.authRefreshToken,
            data: {'refresh_token': refreshToken},
            options: Options(headers: {'Requires-Auth': false}),
          );

          if (refreshResponse.statusCode == 200 &&
              refreshResponse.data is Map) {
            final data = refreshResponse.data['data'];
            if (data is Map && data['access_token'] != null) {
              final newAccess = data['access_token'] as String;
              final newRefresh =
                  (data['refresh_token'] as String?) ?? refreshToken;

              await storageService.saveAuthTokens(
                accessToken: newAccess,
                refreshToken: newRefresh,
              );

              // Retry original request with newly acquired access token
              final retryOptions = err.requestOptions;
              retryOptions.headers['Authorization'] = 'Bearer $newAccess';
              retryOptions.headers.remove('Requires-Auth');

              final retryResponse = await dio.fetch(retryOptions);
              return handler.resolve(retryResponse);
            }
          }
        } catch (_) {
          // Token refresh failed or revoked; invalidate session securely
          await storageService.clearAuth();
        }
      } else {
        await storageService.clearAuth();
      }
    }
    return handler.next(err);
  }
}
