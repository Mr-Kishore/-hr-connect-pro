import 'dart:io' show Platform, File;
import 'package:flutter/foundation.dart';
import '../errors/app_exception.dart';

enum DeviceRiskLevel {
  none,
  low,
  medium,
  high,
  critical,
}

class DeviceSecurityAssessment {
  final bool isCompromised;
  final DeviceRiskLevel riskLevel;
  final List<String> detectedThreats;
  final bool isRooted;
  final bool isJailbroken;
  final bool isEmulator;
  final bool isDebuggerAttached;
  final DateTime timestamp;

  const DeviceSecurityAssessment({
    required this.isCompromised,
    required this.riskLevel,
    required this.detectedThreats,
    this.isRooted = false,
    this.isJailbroken = false,
    this.isEmulator = false,
    this.isDebuggerAttached = false,
    required this.timestamp,
  });

  static DeviceSecurityAssessment clean() {
    return DeviceSecurityAssessment(
      isCompromised: false,
      riskLevel: DeviceRiskLevel.none,
      detectedThreats: const [],
      timestamp: DateTime.now(),
    );
  }
}

/// Interface for injectable file existence checker (allows deterministic unit testing).
typedef FileExistenceChecker = bool Function(String path);

class DeviceSecurityService {
  final FileExistenceChecker _fileChecker;
  final bool Function()? _debuggerChecker;

  DeviceSecurityService({
    FileExistenceChecker? fileChecker,
    this._debuggerChecker,
  }) : _fileChecker = fileChecker ?? _defaultFileChecker;

  static bool _defaultFileChecker(String path) {
    if (kIsWeb) return false;
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  /// Android root indicator paths (su binaries, root management apps)
  static const List<String> androidSuPaths = [
    '/system/bin/su',
    '/system/xbin/su',
    '/sbin/su',
    '/system/sd/xbin/su',
    '/system/bin/failsafe/su',
    '/data/local/xbin/su',
    '/data/local/bin/su',
    '/data/local/su',
    '/su/bin/su',
    '/su/xbin/su',
  ];

  static const List<String> androidRootAppPaths = [
    '/system/app/Superuser.apk',
    '/system/app/SuperSU.apk',
    '/system/app/Magisk.apk',
    '/data/data/com.topjohnwu.magisk',
    '/data/data/eu.chainfire.supersu',
    '/data/data/com.noshufou.android.su',
  ];

  /// iOS Jailbreak indicator paths (Cydia, Substrate, SSH, APT)
  static const List<String> iosJailbreakPaths = [
    '/Applications/Cydia.app',
    '/Applications/Sileo.app',
    '/Applications/Zebra.app',
    '/Library/MobileSubstrate/MobileSubstrate.dylib',
    '/bin/bash',
    '/usr/sbin/sshd',
    '/etc/apt',
    '/usr/bin/ssh',
    '/private/var/lib/apt/',
    '/private/var/lib/cydia/',
  ];

  /// Performs a comprehensive scan of device integrity.
  Future<DeviceSecurityAssessment> assessIntegrity() async {
    // Web environments operate inside the browser sandbox
    if (kIsWeb) {
      return DeviceSecurityAssessment.clean();
    }

    final threats = <String>[];
    bool isRooted = false;
    bool isJailbroken = false;
    bool isDebuggerAttached = false;

    // Check debugger status
    if (_debuggerChecker != null && _debuggerChecker()) {
      isDebuggerAttached = true;
      threats.add('DEBUGGER_ATTACHED');
    } else if (kDebugMode) {
      // In flutter debug mode, debugger is expected; note as low risk informational only
    }

    // Platform-specific file checks
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        for (final suPath in androidSuPaths) {
          if (_fileChecker(suPath)) {
            isRooted = true;
            threats.add('ANDROID_SU_BINARY_FOUND: $suPath');
            break;
          }
        }

        for (final appPath in androidRootAppPaths) {
          if (_fileChecker(appPath)) {
            isRooted = true;
            threats.add('ANDROID_ROOT_MANAGER_FOUND: $appPath');
            break;
          }
        }
      } else if (Platform.isIOS) {
        for (final jbPath in iosJailbreakPaths) {
          if (_fileChecker(jbPath)) {
            isJailbroken = true;
            threats.add('IOS_JAILBREAK_FILE_FOUND: $jbPath');
            break;
          }
        }
      }
    }

    // Compute Risk Level
    DeviceRiskLevel risk = DeviceRiskLevel.none;
    if (isRooted || isJailbroken) {
      risk = DeviceRiskLevel.critical;
    } else if (threats.contains('DEBUGGER_ATTACHED') && kReleaseMode) {
      risk = DeviceRiskLevel.high;
    } else if (threats.isNotEmpty) {
      risk = DeviceRiskLevel.medium;
    }

    final isCompromised = risk == DeviceRiskLevel.critical || risk == DeviceRiskLevel.high;

    return DeviceSecurityAssessment(
      isCompromised: isCompromised,
      riskLevel: risk,
      detectedThreats: threats,
      isRooted: isRooted,
      isJailbroken: isJailbroken,
      isDebuggerAttached: isDebuggerAttached,
      timestamp: DateTime.now(),
    );
  }

  /// Asserts device security and throws [DeviceCompromisedException] if critical threats exist.
  Future<void> assertDeviceIntegrity({bool blockOnHighRisk = true}) async {
    final assessment = await assessIntegrity();
    if (assessment.isCompromised && blockOnHighRisk) {
      throw DeviceCompromisedException(
        detectedThreats: assessment.detectedThreats,
        message: 'Application execution blocked: Unauthorized device tampering detected '
            '(${assessment.detectedThreats.join(', ')}).',
      );
    }
  }
}
