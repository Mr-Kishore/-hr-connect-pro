import 'package:dio/dio.dart';
import 'ssl_pinning_config.dart';

HttpClientAdapter createPinningAdapter(SslPinningConfig config) {
  // Web platforms execute inside the browser security sandbox.
  // The browser enforces system TLS and certificate checks natively.
  return HttpClientAdapter();
}
