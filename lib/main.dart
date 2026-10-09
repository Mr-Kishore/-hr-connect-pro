import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/config/environment.dart';
import 'app/routes/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/services/device_security_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppEnvironment.initialize(EnvironmentType.dev);

  // Proactively assess device integrity against tampering (root/jailbreak/debugger)
  try {
    final securityService = DeviceSecurityService();
    await securityService.assertDeviceIntegrity(blockOnHighRisk: kReleaseMode);
  } catch (e) {
    debugPrint('[SECURITY ALERT] Device integrity verification: $e');
  }

  runApp(const ProviderScope(child: HRConnectProApp()));
}

class HRConnectProApp extends ConsumerWidget {
  const HRConnectProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'HR Connect Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
