import 'package:dio/dio.dart';
import '../errors/app_exception.dart';
import '../services/secure_storage_service.dart';
import '../../app/config/environment.dart';
import 'auth_interceptor.dart';
import 'logging_sanitizer.dart';
import 'pinning/ssl_pinning_adapter.dart';

class ApiClient {
  late final Dio dio;
  final SecureStorageService storageService;

  ApiClient({
    required this.storageService,
    Dio? customDio,
  }) {
    final baseDio = customDio ??
        Dio(
          BaseOptions(
            baseUrl: AppEnvironment.current.apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    // Attach SSL/TLS Certificate Pinning Adapter
    baseDio.httpClientAdapter = getSslPinningAdapter(
      AppEnvironment.current.sslPinningConfig,
    );

    baseDio.interceptors.add(
      AuthInterceptor(
        storageService: storageService,
        dio: baseDio,
      ),
    );

    // Attach Logging Sanitizer Interceptor (redacts tokens & PII, active per environment config)
    baseDio.interceptors.add(
      LoggingSanitizerInterceptor(
        isEnabled: AppEnvironment.current.enableDebugLogging,
      ),
    );

    dio = baseDio;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  AppException handleDioError(DioException error) {
    // Detect SSL/TLS certificate pinning or handshake failures
    final rawError = error.error?.toString().toLowerCase() ?? '';
    final rawMessage = error.message?.toLowerCase() ?? '';
    if (rawError.contains('certificate') ||
        rawError.contains('handshake') ||
        rawMessage.contains('certificate') ||
        rawMessage.contains('handshake')) {
      return const TlsSecurityException();
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkException(
        message: 'Unable to connect to HR Connect Pro server. Please check your network connection.',
      );
    }

    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    if (statusCode == 409) {
      if (responseData is Map && responseData['error'] is Map) {
        final errMap = responseData['error'] as Map;
        if (errMap['code'] == 'SLOT_ALREADY_RESERVED') {
          return const SlotConflictException();
        }
      }
    }

    if (statusCode == 401) {
      return const AuthException(
        message: 'Your session has expired or is invalid. Please sign in again.',
      );
    }

    if (statusCode == 422 || statusCode == 400) {
      final message = responseData is Map && responseData['message'] != null
          ? responseData['message'].toString()
          : 'Invalid request data provided.';
      return ValidationException(message: message, details: responseData);
    }

    final message = responseData is Map && responseData['message'] != null
        ? responseData['message'].toString()
        : 'An unexpected server error occurred.';

    return ServerException(
      message: message,
      statusCode: statusCode,
      details: responseData,
    );
  }
}
