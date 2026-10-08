import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_connect_pro/core/network/pinning/ssl_pinning_config.dart';
import 'package:hr_connect_pro/core/network/pinning/ssl_pinning_adapter.dart';
import 'package:hr_connect_pro/core/network/api_client.dart';
import 'package:hr_connect_pro/core/services/secure_storage_service.dart';
import 'package:hr_connect_pro/core/errors/app_exception.dart';

void main() {
  group('Phase 0.4: Automated Testing & Quality Checks (ssl_pinning_test.dart)', () {
    const prodHost = 'api.hrconnectpro.app';
    const stagingHost = 'api-staging.hrconnectpro.app';
    const primaryPin = '4A:8B:2F:10:9C:5D:7E:33:F1:66:88:AA:BC:DD:EE:FF:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:01';
    const backupPin = 'B2:1C:33:55:77:99:AA:CC:EE:01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:02';
    const stagingPin = '5C:9E:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:CD';
    const fakeProxyPin = '00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF';

    final multiHostConfig = SslPinningConfig(
      isEnabled: true,
      pinnedFingerprints: {
        prodHost: [primaryPin, backupPin],
        stagingHost: [stagingPin],
      },
    );

    // 1. Normalization & Formatting Checks
    test('QC-1: normalizeFingerprint removes colons, spaces, and normalizes casing', () {
      final formattedWithColons = primaryPin;
      final rawHex = primaryPin.replaceAll(':', '').toLowerCase();
      final spaced = primaryPin.replaceAll(':', ' ');

      expect(SslPinningConfig.normalizeFingerprint(formattedWithColons), rawHex);
      expect(SslPinningConfig.normalizeFingerprint(spaced), rawHex);
      expect(SslPinningConfig.normalizeFingerprint(rawHex), rawHex);
    });

    // 2. Primary Pin Validation
    test('QC-2: Approves valid primary pinned certificate fingerprint', () {
      final isValid = multiHostConfig.isCertificateValid(prodHost, primaryPin);
      expect(isValid, isTrue);
    });

    // 3. Backup Pin Rotation Validation
    test('QC-3: Approves valid backup pinned fingerprint for zero-downtime rotation (RFC 7469)', () {
      final isValid = multiHostConfig.isCertificateValid(prodHost, backupPin);
      expect(isValid, isTrue);
    });

    // 4. Raw Hex without Colons Validation
    test('QC-4: Approves fingerprint supplied as raw OpenSSL hex string without colons', () {
      final rawHexPin = primaryPin.replaceAll(':', '');
      final isValid = multiHostConfig.isCertificateValid(prodHost, rawHexPin);
      expect(isValid, isTrue);
    });

    // 5. MitM & Rogue Certificate Rejection
    test('QC-5: Rejects rogue proxy, Burp/Charles, or attacker certificate fingerprint', () {
      final isValid = multiHostConfig.isCertificateValid(prodHost, fakeProxyPin);
      expect(isValid, isFalse);
    });

    // 6. Host Isolation Defense
    test('QC-6: Enforces host isolation (staging cert presented to prod host is rejected)', () {
      // Prevents cross-host certificate reuse/spoofing attacks
      final isValid = multiHostConfig.isCertificateValid(prodHost, stagingPin);
      expect(isValid, isFalse);
    });

    // 7. Unlisted Domain Defense
    test('QC-7: Rejects certificates from unlisted domains when pinning is active', () {
      final isValid = multiHostConfig.isCertificateValid('untrusted.hrconnectpro.app', primaryPin);
      expect(isValid, isFalse);
    });

    // 8. Dev Mode Bypass Validation
    test('QC-8: Permits mock/local certificates when pinning is disabled (Dev mode)', () {
      const disabledConfig = SslPinningConfig.disabled;
      final isValid = disabledConfig.isCertificateValid(prodHost, fakeProxyPin);
      expect(isValid, isTrue);
    });

    // 9. Production Baseline Defaults Validation
    test('QC-9: SslPinningConfig.production has pinning enabled with primary and backup pins', () {
      final prodConfig = SslPinningConfig.production;
      expect(prodConfig.isEnabled, isTrue);
      expect(prodConfig.pinnedFingerprints.containsKey(prodHost), isTrue);

      final prodPins = prodConfig.pinnedFingerprints[prodHost]!;
      expect(prodPins.length, greaterThanOrEqualTo(2), reason: 'Must have at least 1 backup pin for key rotation');
    });

    // 10. Adapter Instantiation
    test('QC-10: getSslPinningAdapter instantiates adapter across platform targets', () {
      final adapter = getSslPinningAdapter(multiHostConfig);
      expect(adapter, isNotNull);
    });

    // 11. ApiClient Error Mapping for TLS Failures
    test('QC-11: ApiClient maps TLS handshake and certificate errors to TlsSecurityException', () {
      final mockDio = Dio(BaseOptions(baseUrl: 'https://api.hrconnectpro.app'));
      final mockStorage = SecureStorageService();
      final client = ApiClient(storageService: mockStorage, customDio: mockDio);

      // Simulate a DioException with a certificate handshake failure
      final tlsError = DioException(
        requestOptions: RequestOptions(path: '/api/v1/jobs'),
        error: 'HandshakeException: Certificate validation failed for host api.hrconnectpro.app',
        type: DioExceptionType.unknown,
      );

      // Verify that ApiClient maps this to TlsSecurityException
      expect(
        () => throw client.handleDioError(tlsError),
        throwsA(isA<TlsSecurityException>()),
      );
    });
  });
}
