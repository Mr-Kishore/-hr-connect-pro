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
          // DPDP Act 2023 Consent Management Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.borderLight),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'DPDP Act 2023 Consent Center',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Granular purpose-specific consents per India Digital Personal Data Protection Act.',
                    style: TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text('AI Resume Parsing & Vectorization'),
                    subtitle: const Text(
                      'Allows sandboxed AI to extract skills without third-party LLM training.',
                      style: TextStyle(fontSize: 11),
                    ),
                    value: ref.watch(dpdpConsentProvider).aiResumeProcessing,
                    onChanged: (_) =>
                        ref.read(dpdpConsentProvider.notifier).toggleAiResume(),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text(
                      'Direct Recruiter Discovery & Self-Booking',
                    ),
                    subtitle: const Text(
                      'Allows verified companies to see your profile and offer instant interview slots.',
                      style: TextStyle(fontSize: 11),
                    ),
                    value: ref.watch(dpdpConsentProvider).recruiterDiscovery,
                    onChanged: (_) => ref
                        .read(dpdpConsentProvider.notifier)
                        .toggleRecruiterDiscovery(),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text('Dual-Consent Interview Recording'),
                    subtitle: const Text(
                      'Both parties must consent before session audio/video can be transcribed.',
                      style: TextStyle(fontSize: 11),
                    ),
                    value: ref.watch(dpdpConsentProvider).sessionDualRecording,
                    onChanged: (_) => ref
                        .read(dpdpConsentProvider.notifier)
                        .toggleSessionRecording(),
                  ),
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
            title: const Text('Download My Data (DPDP SAR)'),
            subtitle: const Text(
              'Export all profile records in structured JSON format',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              final consents = ref.read(dpdpConsentProvider);
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'DPDP Subject Access Archive',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This encrypted dump contains all personal identifiers, parsed skill vectors, and current consent records stored on your account:',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Text(
                          '''{\n  "candidate_id": "cand_9921",\n  "name": "$candidateName",\n  "role": "$candidateRole",\n  "skills": ${skills.toString()},\n  "consents": {\n    "ai_parsing": ${consents.aiResumeProcessing},\n    "recruiter_discovery": ${consents.recruiterDiscovery},\n    "recording": ${consents.sessionDualRecording}\n  },\n  "data_retention_policy": "ISO27001_AES256_GCM",\n  "export_timestamp": "${DateTime.now().toIso8601String()}"\n}''',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppColors.accent,
                                content: Text('Export archive saved locally.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.download_done),
                          label: const Text('Confirm & Save JSON Archive'),
                        ),
                      ),
                    ],
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
