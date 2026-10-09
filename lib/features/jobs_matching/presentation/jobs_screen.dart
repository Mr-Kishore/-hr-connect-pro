import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../candidate_flow/domain/models/job_opportunity.dart';
import '../../candidate_flow/presentation/providers/candidate_flow_providers.dart';

class JobsScreen extends ConsumerWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(matchedJobsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Matched Jobs')),
      body: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Failed to load opportunities: $err'),
            ],
          ),
        ),
        data: (jobs) {
          if (jobs.isEmpty) {
            return const Center(
              child: Text('No matching jobs found right now.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: jobs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final job = jobs[index];
              return _buildJobCard(context, job);
            },
          );
        },
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, JobOpportunity job) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: InkWell(
        onTap: () => context.push(RouteConstants.jobDetail, extra: job),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${job.fitScore}% Match',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${job.company} • ${job.location}',
                style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job.salaryRange,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (job.matchedSkills.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Matched Skills:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: job.matchedSkills
                      .map(
                        (s) => Chip(
                          avatar: const Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.accent,
                          ),
                          label: Text(s, style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],
              if (job.missingSkills.isNotEmpty) ...[
                const SizedBox(height: 6),
                const Text(
                  'Identified Skill Gaps:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: job.missingSkills
                      .map(
                        (s) => Chip(
                          avatar: const Icon(
                            Icons.info_outline,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          label: Text(s, style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.push(RouteConstants.jobDetail, extra: job),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('View Role & Self-Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
