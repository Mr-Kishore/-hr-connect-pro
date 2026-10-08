import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'ssl_pinning_config.dart';

HttpClientAdapter createPinningAdapter(SslPinningConfig config) {
  final adapter = IOHttpClientAdapter();

  if (!config.isEnabled) {
    return adapter;
  }

  adapter.createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      final certFingerprint = sha256.convert(cert.der).toString();
      final isValid = config.isCertificateValid(host, certFingerprint);
      return isValid;
    };
    return client;
  };

  adapter.validateCertificate = (X509Certificate? cert, String host, int port) {
    if (cert == null) return false;
    final certFingerprint = sha256.convert(cert.der).toString();
    return config.isCertificateValid(host, certFingerprint);
  };

  return adapter;
}
