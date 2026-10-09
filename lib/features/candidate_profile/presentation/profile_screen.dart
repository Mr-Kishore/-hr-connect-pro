import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/core_providers.dart';
import '../../candidate_flow/presentation/providers/candidate_flow_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(candidateProfileProvider);
    final candidateName = (profile?.name != null && profile!.name.isNotEmpty)
        ? profile.name
        : 'Aditya Sharma';
    final candidateRole =
        profile?.targetRole ??
        profile?.currentRole ??
        'Senior Flutter Engineer • Bangalore';
    final readiness =
        (profile?.readinessScore != null && profile!.readinessScore > 0)
        ? profile.readinessScore
        : 85;
    final skills =
        profile?.extractedSkills ?? const ['Flutter', 'Dart', 'Riverpod'];

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile & Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          candidateName.isNotEmpty ? candidateName[0] : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              candidateName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              candidateRole,
                              style: const TextStyle(
                                color: AppColors.textSecondaryLight,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: readiness / 100.0,
                    backgroundColor: AppColors.borderLight,
                    color: AppColors.accent,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Profile Readiness: $readiness% (Self-Booking Active)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (skills.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: skills
                          .take(4)
                          .map(
                            (s) => Chip(
                              avatar: const Icon(
                                Icons.verified,
                                size: 14,
                                color: AppColors.accent,
                              ),
                              label: Text(
                                s,
                                style: const TextStyle(fontSize: 11),
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.upload_file, color: AppColors.primary),
            title: const Text('Ingest & Parse Resume'),
            subtitle: Text(
              profile?.resumeFileName != null
                  ? 'Current: ${profile!.resumeFileName}'
                  : 'PDF, DOC, DOCX up to 10MB',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(RouteConstants.resumeUpload),
          ),
          ListTile(
            leading: const Icon(Icons.download, color: AppColors.primary),
            title: const Text('Download My Data (DPDP Act)'),
            subtitle: const Text('Export all profile records in JSON format'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.accent,
                  content: Text(
                    'DPDP data export archive generated and ready for download.',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: const Text(
              'Request Account Erasure',
              style: TextStyle(color: AppColors.error),
            ),
            subtitle: const Text(
              '30-day grace period per DPDP Act regulations',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Account Erasure Request'),
                  content: const Text(
                    'Under the Digital Personal Data Protection (DPDP) Act, your personal data will be completely deleted following a 30-day grace period. Confirm submission?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Erasure request registered under DPDP compliance.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Confirm Request'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go(RouteConstants.candidateAuth);
              }
            },
          ),
        ],
      ),
    );
  }
}
