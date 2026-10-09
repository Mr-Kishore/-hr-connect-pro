import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_connect_pro/core/network/logging_sanitizer.dart';

void main() {
  group('LoggingSanitizer Unit Tests', () {
    test(
      'Redacts sensitive HTTP headers including Bearer token and Cookies',
      () {
        final headers = {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.testToken',
          'Cookie': 'sessionId=abc123xyz; secure=true',
          'X-Api-Key': 'secret-client-api-key',
          'Accept': 'application/json',
        };

        final sanitized = LoggingSanitizer.sanitizeHeaders(headers);

        expect(sanitized['Content-Type'], 'application/json');
        expect(sanitized['Accept'], 'application/json');
        expect(sanitized['Authorization'], 'Bearer [REDACTED]');
        expect(sanitized['Cookie'], '[REDACTED]');
        expect(sanitized['X-Api-Key'], '[REDACTED]');
      },
    );

    test('Recursively redacts sensitive payload fields (passwords, tokens, OTPs, financial PII)', () {
      final payload = {
        'user': {
          'id': 'usr_123',
          'name': 'Aditya Sharma',
          'password': 'SuperSecretPassword123!',
          'tokens': {
            'access_token': 'secret_access_jwt',
            'refresh_token': 'secret_refresh_jwt',
          },
          'banking': {
            'bank_account_number': '123456789012',
            'pan': 'ABCDE1234F',
          },
        },
        'verification': {'otp': '987654', 'pin': '1234'},
        'public_flag': true,
      };

      final sanitized =
          LoggingSanitizer.sanitizeData(payload) as Map<String, dynamic>;

      expect(sanitized['public_flag'], isTrue);
      expect(sanitized['user']['id'], 'usr_123');
      expect(sanitized['user']['name'], 'Aditya Sharma');
      expect(sanitized['user']['password'], '[REDACTED]');
      expect(sanitized['user']['tokens']['access_token'], '[REDACTED]');
      expect(sanitized['user']['tokens']['refresh_token'], '[REDACTED]');
      expect(sanitized['user']['banking']['bank_account_number'], '[REDACTED]');
      expect(sanitized['user']['banking']['pan'], '[REDACTED]');
      expect(sanitized['verification']['otp'], '[REDACTED]');
      expect(sanitized['verification']['pin'], '[REDACTED]');
    });

    test(
      'Masks phone numbers and emails for safe debugging without PII leakage',
      () {
        final phone = LoggingSanitizer.maskPii('phone_number', '+919876543210');
        expect(phone.contains('3210'), isTrue);
        expect(phone.contains('98765'), isFalse);

        final email = LoggingSanitizer.maskPii(
          'email',
          'aditya.sharma@hrconnectpro.app',
        );
        expect(email.startsWith('a'), isTrue);
        expect(email.endsWith('@hrconnectpro.app'), isTrue);
        expect(email.contains('sharma'), isFalse);
      },
    );

    test('Sanitizes URI query parameters', () {
      final uri = Uri.parse(
        'https://api.hrconnectpro.app/v1/verify?token=mySecretToken&page=2&otp=54321',
      );
      final sanitized = LoggingSanitizer.sanitizeUri(uri);

      expect(sanitized.queryParameters['token'], '[REDACTED]');
      expect(sanitized.queryParameters['otp'], '[REDACTED]');
      expect(sanitized.queryParameters['page'], '2');
    });

    test('LoggingSanitizerInterceptor records sanitized output and suppresses when disabled', () {
      final loggedMessages = <String>[];
      final interceptor = LoggingSanitizerInterceptor(
        isEnabled: true,
        logPrinter: (msg) => loggedMessages.add(msg),
      );

      final options = RequestOptions(
        path: '/api/v1/auth/login',
        baseUrl: 'https://api.hrconnectpro.app',
        method: 'POST',
        headers: {'Authorization': 'Bearer superSecretToken123'},
        data: {'phone': '+919876543210', 'otp': '123456'},
      );

      interceptor.onRequest(options, RequestInterceptorHandler());

      expect(loggedMessages.isNotEmpty, isTrue);
      final logContent = loggedMessages.join('\n');
      expect(logContent.contains('superSecretToken123'), isFalse);
      expect(logContent.contains('123456'), isFalse);
      expect(logContent.contains('[REDACTED]'), isTrue);

      // Verify disabled mode suppresses logging completely (Production mode)
      final disabledMessages = <String>[];
      final disabledInterceptor = LoggingSanitizerInterceptor(
        isEnabled: false,
        logPrinter: (msg) => disabledMessages.add(msg),
      );

      disabledInterceptor.onRequest(options, RequestInterceptorHandler());
      expect(disabledMessages.isEmpty, isTrue);
    });
  });
}
