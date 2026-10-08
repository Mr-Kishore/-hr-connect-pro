import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserRole = 'auth_user_role';

  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> saveUserDetails({
    required String userId,
    required String role,
  }) async {
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyUserRole, value: role);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: _keyUserRole);
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUserRole);
  }

  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
