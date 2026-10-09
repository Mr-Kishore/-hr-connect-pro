import 'package:dio/dio.dart';

import 'ssl_pinning_config.dart';
import 'ssl_pinning_adapter_stub.dart'
    if (dart.library.io) 'ssl_pinning_adapter_io.dart'
    if (dart.library.js_interop) 'ssl_pinning_adapter_web.dart';

HttpClientAdapter getSslPinningAdapter(SslPinningConfig config) {
  return createPinningAdapter(config);
}
