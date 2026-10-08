abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code = 'NETWORK_ERROR',
    super.details,
  });
}

class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code = 'AUTH_ERROR',
    super.details,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.details,
  });
}

class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code = 'SERVER_ERROR',
    this.statusCode,
    super.details,
  });
}

class SlotConflictException extends AppException {
  const SlotConflictException({
    super.message = 'The requested interview slot is no longer available.',
    super.code = 'SLOT_ALREADY_RESERVED',
    super.details,
  });
}

class TlsSecurityException extends AppException {
  const TlsSecurityException({
    super.message = 'Security validation failed: Untrusted or mismatched TLS certificate detected.',
    super.code = 'TLS_CERTIFICATE_PIN_MISMATCH',
    super.details,
  });
}

class DeviceCompromisedException extends AppException {
  final List<String> detectedThreats;

  const DeviceCompromisedException({
    super.message = 'Device security check failed: Potential root/jailbreak or unauthorized environment detected.',
    super.code = 'DEVICE_INTEGRITY_COMPROMISED',
    this.detectedThreats = const [],
    super.details,
  });
}
