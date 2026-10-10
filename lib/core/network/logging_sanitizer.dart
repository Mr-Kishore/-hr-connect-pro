import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingSanitizer {
  LoggingSanitizer._();

  static const String redactedPlaceholder = '[REDACTED]';

  /// Set of header names that must always be redacted.
  static const Set<String> sensitiveHeaders = {
    'authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
    'x-auth-token',
    'proxy-authorization',
  };

  /// Set of payload/query keys that contain sensitive authentication or financial PII.
  static const Set<String> sensitiveKeys = {
    'password',
    'confirm_password',
    'current_password',
    'new_password',
    'token',
    'access_token',
    'refresh_token',
    'id_token',
    'jwt',
    'otp',
    'code',
    'verification_code',
    'pin',
    'secret',
    'client_secret',
    'private_key',
    'pan',
    'aadhaar',
    'tax_id',
    'account_number',
    'bank_account_number',
    'card_number',
    'cvv',
    'vpa',
  };

  /// Keys for which partial masking is applied (e.g. phone numbers and emails).
  static const Set<String> maskedKeys = {
    'phone',
    'phone_number',
    'mobile',
    'mobile_number',
    'email',
  };

  /// Sanitizes an HTTP header map by redacting sensitive header values.
  static Map<String, dynamic> sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = <String, dynamic>{};
    headers.forEach((key, value) {
      if (sensitiveHeaders.contains(key.toLowerCase())) {
        if (key.toLowerCase() == 'authorization' &&
            value is String &&
            value.startsWith('Bearer ')) {
          sanitized[key] = 'Bearer $redactedPlaceholder';
        } else {
          sanitized[key] = redactedPlaceholder;
        }
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  /// Recursively sanitizes any payload data (Map, List, or primitives).
  static dynamic sanitizeData(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final sanitizedMap = <String, dynamic>{};
      data.forEach((key, value) {
        final keyStr = key.toString().toLowerCase();

        if (sensitiveKeys.contains(keyStr)) {
          sanitizedMap[key.toString()] = redactedPlaceholder;
        } else if (maskedKeys.contains(keyStr) && value is String) {
          sanitizedMap[key.toString()] = maskPii(keyStr, value);
        } else {
          sanitizedMap[key.toString()] = sanitizeData(value);
        }
      });
      return sanitizedMap;
    }

    if (data is List) {
      return data.map((item) => sanitizeData(item)).toList();
    }

    if (data is FormData) {
      final sanitizedFields = data.fields.map((field) {
        final keyLower = field.key.toLowerCase();
        if (sensitiveKeys.contains(keyLower)) {
          return MapEntry(field.key, redactedPlaceholder);
        }
        return field;
      }).toList();

      final sanitizedFiles = data.files.map((file) {
        return MapEntry(
          file.key,
          '[BINARY FILE: ${file.value.filename}, size: ${file.value.length} bytes]',
        );
      }).toList();

      return {'fields': sanitizedFields, 'files': sanitizedFiles};
    }

    if (data is String) {
      // Try parsing JSON string if applicable
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map || decoded is List) {
          return jsonEncode(sanitizeData(decoded));
        }
      } catch (_) {
        // Not a JSON string, retain raw string
      }
    }

    return data;
  }

  /// Sanitizes URL query parameters.
  static Uri sanitizeUri(Uri uri) {
    if (!uri.hasQuery) return uri;

    final sanitizedQueryParams = <String, String>{};
    uri.queryParameters.forEach((key, value) {
      if (sensitiveKeys.contains(key.toLowerCase())) {
        sanitizedQueryParams[key] = redactedPlaceholder;
      } else if (maskedKeys.contains(key.toLowerCase())) {
        sanitizedQueryParams[key] = maskPii(key, value);
      } else {
        sanitizedQueryParams[key] = value;
      }
    });

    return uri.replace(queryParameters: sanitizedQueryParams);
  }

  /// Masks Phone numbers (+91 98******10) and Emails (a****a@domain.com) for safe debugging.
  static String maskPii(String fieldType, String value) {
    if (value.isEmpty) return value;

    if (fieldType.contains('email')) {
      final parts = value.split('@');
      if (parts.length == 2 && parts[0].isNotEmpty) {
        final user = parts[0];
        final domain = parts[1];
        if (user.length <= 2) {
          return '${user[0]}*@$domain';
        }
        return '${user[0]}${'*' * (user.length - 2)}${user[user.length - 1]}@$domain';
      }
    }

    if (fieldType.contains('phone') || fieldType.contains('mobile')) {
      final digitsOnly = value.replaceAll(RegExp(r'\s+'), '');
      if (digitsOnly.length > 4) {
        final prefix = digitsOnly.substring(0, digitsOnly.length - 4);
        final suffix = digitsOnly.substring(digitsOnly.length - 4);
        final maskedPrefix = prefix.length > 3
            ? '${prefix.substring(0, 3)}${'*' * (prefix.length - 3)}'
            : '*' * prefix.length;
        return '$maskedPrefix$suffix';
      }
    }

    return redactedPlaceholder;
  }
}

/// Dio Interceptor that securely logs sanitized requests and responses.
class LoggingSanitizerInterceptor extends Interceptor {
  final bool isEnabled;
  final void Function(String message)? logPrinter;

  LoggingSanitizerInterceptor({this.isEnabled = true, this.logPrinter});

  void _log(String message) {
    if (!isEnabled) return;
    if (logPrinter != null) {
      logPrinter!(message);
    } else {
      debugPrint(message);
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (isEnabled) {
      final sanitizedUri = LoggingSanitizer.sanitizeUri(options.uri);
      final sanitizedHeaders = LoggingSanitizer.sanitizeHeaders(
        options.headers,
      );
      final sanitizedData = LoggingSanitizer.sanitizeData(options.data);

      _log('┌─── [HTTP REQUEST] ${options.method} $sanitizedUri');
      _log('│ Headers: $sanitizedHeaders');
      if (sanitizedData != null) {
        _log('│ Body: $sanitizedData');
      }
      _log('└─── [END REQUEST]');
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (isEnabled) {
      final sanitizedUri = LoggingSanitizer.sanitizeUri(
        response.requestOptions.uri,
      );
      final sanitizedData = LoggingSanitizer.sanitizeData(response.data);

      _log('┌─── [HTTP RESPONSE] ${response.statusCode} $sanitizedUri');
      if (sanitizedData != null) {
        _log('│ Body: $sanitizedData');
      }
      _log('└─── [END RESPONSE]');
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (isEnabled) {
      final sanitizedUri = LoggingSanitizer.sanitizeUri(err.requestOptions.uri);
      final sanitizedResponse = LoggingSanitizer.sanitizeData(
        err.response?.data,
      );

      _log(
        '┌─── [HTTP ERROR] ${err.response?.statusCode ?? 'N/A'} $sanitizedUri',
      );
      _log('│ Message: ${err.message}');
      if (sanitizedResponse != null) {
        _log('│ Error Response: $sanitizedResponse');
      }
      _log('└─── [END ERROR]');
    }
    return handler.next(err);
  }
}
