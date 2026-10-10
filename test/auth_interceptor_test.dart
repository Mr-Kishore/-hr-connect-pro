import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_connect_pro/core/constants/api_endpoints.dart';
import 'package:hr_connect_pro/core/network/auth_interceptor.dart';
import 'package:hr_connect_pro/core/services/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  group('AuthInterceptor & Token Security Tests', () {
    late SecureStorageService storageService;
    late Dio dio;
    late AuthInterceptor interceptor;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({
        'auth_access_token': 'initial_access_jwt',
        'auth_refresh_token': 'initial_refresh_jwt',
      });
      storageService = SecureStorageService();
      dio = Dio(BaseOptions(baseUrl: 'https://api.hrconnectpro.app'));
      interceptor = AuthInterceptor(storageService: storageService, dio: dio);
    });

    test('SEC-1: Attaches Bearer authorization token on protected endpoint requests', () async {
      final options = RequestOptions(
        path: '/api/v1/candidates/profile',
        headers: {},
      );

      final handler = _TestRequestInterceptorHandler();
      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer initial_access_jwt');
      expect(options.headers['Accept'], 'application/json');
    });

    test('SEC-2: Omits Bearer token on public auth endpoints (prevents token leakage)', () async {
      final options = RequestOptions(
        path: ApiEndpoints.authSendOtp,
        headers: {},
      );

      final handler = _TestRequestInterceptorHandler();
      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
    });

    test('SEC-3: Honors explicit Requires-Auth: false flag and removes the internal header', () async {
      final options = RequestOptions(
        path: '/api/v1/public-health-check',
        headers: {'Requires-Auth': false},
      );

      final handler = _TestRequestInterceptorHandler();
      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      expect(options.headers.containsKey('Requires-Auth'), isFalse);
    });

    test(
      'SEC-4: Refresh endpoint 401 clears auth and halts recursion immediately',
      () async {
        final err = DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.authRefreshToken),
          response: Response(
            requestOptions: RequestOptions(path: ApiEndpoints.authRefreshToken),
            statusCode: 401,
          ),
        );

        final handler = _TestErrorInterceptorHandler();
        await interceptor.onError(err, handler);

        expect(handler.nextCalled, isTrue);
        final hasToken = await storageService.hasValidSession();
        expect(
          hasToken,
          isFalse,
          reason: 'Auth storage must be purged when refresh token is rejected',
        );
      },
    );
  });
}

class _TestRequestInterceptorHandler extends RequestInterceptorHandler {
  bool nextCalled = false;
  @override
  void next(RequestOptions requestOptions) {
    nextCalled = true;
  }
}

class _TestErrorInterceptorHandler extends ErrorInterceptorHandler {
  bool nextCalled = false;
  @override
  void next(DioException err) {
    nextCalled = true;
  }
}
