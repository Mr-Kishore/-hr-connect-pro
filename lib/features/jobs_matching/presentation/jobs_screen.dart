import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../candidate_flow/domain/models/job_opportunity.dart';
import '../../candidate_flow/presentation/providers/candidate_flow_providers.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(jobFilterProvider);
    final jobsAsync = ref.watch(filteredJobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matched Opportunities'),
        actions: [
          IconButton(
            tooltip: 'Reset Filters',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _searchController.clear();
              ref.read(jobFilterProvider.notifier).reset();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: const Border(
                bottom: BorderSide(color: AppColors.borderLight, width: 0.8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search roles, skills, or companies...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(jobFilterProvider.notifier)
                                  .setSearchQuery('');
                              setState(() {});
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    ref.read(jobFilterProvider.notifier).setSearchQuery(val);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('⚡ Instant Booking'),
                        selected: filterState.onlyInstantInterview,
                        onSelected: (_) {
                          ref
                              .read(jobFilterProvider.notifier)
                              .toggleInstantInterview();
                        },
                        selectedColor: AppColors.primary.withValues(
                          alpha: 0.15,
                        ),
                        checkmarkColor: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('⭐ 80%+ Top Match'),
                        selected: filterState.onlyHighMatch,
                        onSelected: (_) {
                          ref
                              .read(jobFilterProvider.notifier)
                              .toggleHighMatch();
                        },
                        selectedColor: AppColors.accent.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Jobs List View
          Expanded(
            child: jobsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    Text('Failed to load opportunities: $err'),
                  ],
                ),
              ),
              data: (jobs) {
                if (jobs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.filter_alt_off_outlined,
                            size: 52,
                            color: AppColors.textSecondaryLight.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No jobs match your current filters.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try clearing the instant booking filter or search query.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              _searchController.clear();
                              ref.read(jobFilterProvider.notifier).reset();
                            },
                            child: const Text('Reset All Filters'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  scrollCacheExtent: const ScrollCacheExtent.pixels(120.0),
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  itemCount: jobs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return _buildJobCard(context, job);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, JobOpportunity job) {
    final availableSlotsCount = job.availableSlots
        .where((s) => s.isAvailable)
        .length;

    return RepaintBoundary(
      child: Card(
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
                if (job.hasInstantInterview) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bolt,
                          size: 15,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Direct Self-Booking Enabled • $availableSlotsCount slot${availableSlotsCount == 1 ? '' : 's'} open',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            context.push(RouteConstants.jobDetail, extra: job),
                        child: const Text('View JD & Details'),
                      ),
                    ),
                    if (job.hasInstantInterview) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push(
                            RouteConstants.jobDetail,
                            extra: job,
                          ),
                          icon: const Icon(Icons.bolt, size: 16),
                          label: const Text('Instant Book'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
