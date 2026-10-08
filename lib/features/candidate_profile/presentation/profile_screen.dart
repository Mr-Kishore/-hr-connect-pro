import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/core_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile & Privacy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Aditya Sharma', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('Senior Flutter Engineer • Bangalore', style: TextStyle(color: AppColors.textSecondaryLight)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.85,
                    backgroundColor: AppColors.borderLight,
                    color: AppColors.accent,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 6),
                  const Text('Profile Completeness: 85% (Self-Booking Active)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Ingest & Parse Resume'),
            subtitle: const Text('PDF, DOC, DOCX up to 10MB'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download My Data (DPDP Act)'),
            subtitle: const Text('Export all profile records in JSON/ZIP format'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: const Text('Request Account Erasure', style: TextStyle(color: AppColors.error)),
            subtitle: const Text('30-day grace period per DPDP Act regulations'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go(RouteConstants.login);
              }
            },
          ),
        ],
      ),
    );
  }
}
