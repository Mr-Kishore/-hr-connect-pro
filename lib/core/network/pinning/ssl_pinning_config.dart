class SslPinningConfig {
  final bool isEnabled;
  final Map<String, List<String>> pinnedFingerprints;

  const SslPinningConfig({
    required this.isEnabled,
    required this.pinnedFingerprints,
  });

  /// Normalizes a SHA-256 fingerprint string by removing colons, spaces, and converting to lowercase.
  static String normalizeFingerprint(String fingerprint) {
    return fingerprint
        .replaceAll(':', '')
        .replaceAll(' ', '')
        .trim()
        .toLowerCase();
  }

  /// Verifies whether the provided [certSha256Hex] matches any configured pinned fingerprint for [host].
  bool isCertificateValid(String host, String certSha256Hex) {
    if (!isEnabled) return true;

    final normalizedCert = normalizeFingerprint(certSha256Hex);
    final allowedFingerprints = pinnedFingerprints[host];

    if (allowedFingerprints == null || allowedFingerprints.isEmpty) {
      // If pinning is enabled and host is unlisted in pin configuration, reject by default
      return false;
    }

    for (final pin in allowedFingerprints) {
      if (normalizeFingerprint(pin) == normalizedCert) {
        return true;
      }
    }

    return false;
  }

  /// Default HR Connect Pro Production & Staging pinned SHA-256 certificate fingerprints (Primary & Backup rotation)
  static const SslPinningConfig production = SslPinningConfig(
    isEnabled: true,
    pinnedFingerprints: {
      'api.hrconnectpro.app': [
        // Primary Leaf Certificate SHA-256
        '4A:8B:2F:10:9C:5D:7E:33:F1:66:88:AA:BC:DD:EE:FF:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:01',
        // Backup Intermediate / Root CA SHA-256 for Zero-Downtime Key Rotation (RFC 7469)
        'B2:1C:33:55:77:99:AA:CC:EE:01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:02',
      ],
      'api-staging.hrconnectpro.app': [
        '5C:9E:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:CD',
        '6D:0F:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:02:34:56:78:9A:BC:DE:F0:12:34:56:78:9A:BC:DE:F1',
      ],
    },
  );

  static const SslPinningConfig disabled = SslPinningConfig(
    isEnabled: false,
    pinnedFingerprints: {},
  );
}
