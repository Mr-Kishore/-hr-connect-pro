import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../candidate_flow/domain/models/mentor_profile.dart';
import '../../candidate_flow/presentation/providers/candidate_flow_providers.dart';

class ExpertsScreen extends ConsumerWidget {
  const ExpertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mentorsAsync = ref.watch(mentorsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Career Advisory Experts')),
      body: mentorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Failed to load expert advisors: $err')),
        data: (mentors) {
          if (mentors.isEmpty) {
            return const Center(child: Text('No experts available right now.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: mentors.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final mentor = mentors[index];
              return _buildExpertCard(context, mentor);
            },
          );
        },
      ),
    );
  }

  Widget _buildExpertCard(BuildContext context, MentorProfile mentor) {
    return Card(
      elevation: 0,
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
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    mentor.name.isNotEmpty ? mentor.name[0] : 'M',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mentor.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${mentor.role} @ ${mentor.company}',
                        style: const TextStyle(
                          color: AppColors.textSecondaryLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.warning, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${mentor.rating}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: mentor.expertise
                  .map(
                    (d) => Chip(
                      label: Text(d, style: const TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(
                    '₹${mentor.hourlyRateInr} / session',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 42),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                        label: const Text('Chat'),
                        onPressed: () => context.push(
                          RouteConstants.mentorChat,
                          extra: mentor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 42),
                        ),
                        icon: const Icon(
                          Icons.video_camera_front_outlined,
                          size: 16,
                        ),
                        label: const Text('Consult 1:1'),
                        onPressed: () => context.push(
                          RouteConstants.videoRoom,
                          extra: mentor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
