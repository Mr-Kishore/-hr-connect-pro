import 'package:dio/dio.dart';
import 'ssl_pinning_config.dart';

HttpClientAdapter createPinningAdapter(SslPinningConfig config) {
  throw UnsupportedError('Cannot create SSL pinning adapter on unsupported platform');
}
