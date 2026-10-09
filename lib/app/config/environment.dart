import '../../core/network/pinning/ssl_pinning_config.dart';

enum EnvironmentType { dev, staging, prod }

class AppEnvironment {
  final EnvironmentType type;
  final String apiBaseUrl;
  final String wsBaseUrl;
  final String razorpayKeyId;
  final String videoSdkAppId;
  final bool enableDebugLogging;
  final SslPinningConfig sslPinningConfig;

  const AppEnvironment({
    required this.type,
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    required this.razorpayKeyId,
    required this.videoSdkAppId,
    required this.enableDebugLogging,
    required this.sslPinningConfig,
  });

  static AppEnvironment _current = dev;

  static AppEnvironment get current => _current;

  static void initialize(EnvironmentType type) {
    switch (type) {
      case EnvironmentType.dev:
        _current = dev;
        break;
      case EnvironmentType.staging:
        _current = staging;
        break;
      case EnvironmentType.prod:
        _current = prod;
        break;
    }
  }

  static const AppEnvironment dev = AppEnvironment(
    type: EnvironmentType.dev,
    apiBaseUrl: 'https://api-dev.hrconnectpro.app',
    wsBaseUrl: 'wss://ws-dev.hrconnectpro.app',
    razorpayKeyId: 'rzp_test_placeholderKeyDev',
    videoSdkAppId: '100ms_dev_placeholderAppId',
    enableDebugLogging: true,
    sslPinningConfig: SslPinningConfig.disabled,
  );

  static const AppEnvironment staging = AppEnvironment(
    type: EnvironmentType.staging,
    apiBaseUrl: 'https://api-staging.hrconnectpro.app',
    wsBaseUrl: 'wss://ws-staging.hrconnectpro.app',
    razorpayKeyId: 'rzp_test_placeholderKeyStg',
    videoSdkAppId: '100ms_stg_placeholderAppId',
    enableDebugLogging: true,
    sslPinningConfig: SslPinningConfig.production,
  );

  static const AppEnvironment prod = AppEnvironment(
    type: EnvironmentType.prod,
    apiBaseUrl: 'https://api.hrconnectpro.app',
    wsBaseUrl: 'wss://ws.hrconnectpro.app',
    razorpayKeyId: 'rzp_live_placeholderKeyProd',
    videoSdkAppId: '100ms_live_placeholderAppId',
    enableDebugLogging: false,
    sslPinningConfig: SslPinningConfig.production,
  );
}
