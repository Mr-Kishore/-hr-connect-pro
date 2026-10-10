import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/device_security_service.dart';
import '../services/secure_storage_service.dart';
import '../network/api_client.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final deviceSecurityServiceProvider = Provider<DeviceSecurityService>((ref) {
  return DeviceSecurityService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return ApiClient(storageService: storage);
});

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? role;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.role,
    this.isLoading = true,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? role,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Asynchronously check initial token on startup
    Future.microtask(() => _checkAuthStatus());
    return const AuthState(isLoading: true);
  }

  Future<void> _checkAuthStatus() async {
    final storage = ref.read(secureStorageServiceProvider);
    final hasToken = await storage.hasValidSession();
    if (hasToken) {
      final userId = await storage.getUserId();
      final role = await storage.getUserRole();
      state = AuthState(
        isAuthenticated: true,
        userId: userId,
        role: role ?? 'candidate',
        isLoading: false,
      );
    } else {
      state = const AuthState(isAuthenticated: false, isLoading: false);
    }
  }

  Future<void> login({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
  }) async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.saveAuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await storage.saveUserDetails(userId: userId, role: role);
    state = AuthState(
      isAuthenticated: true,
      userId: userId,
      role: role,
      isLoading: false,
    );
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.clearAuth();
    state = const AuthState(isAuthenticated: false, isLoading: false);
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
