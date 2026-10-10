import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../candidate_flow/domain/models/interview_booking.dart';
import '../../candidate_flow/domain/models/mentor_profile.dart';
import '../../candidate_flow/presentation/providers/candidate_flow_providers.dart';

class InterviewsScreen extends ConsumerStatefulWidget {
  const InterviewsScreen({super.key});

  @override
  ConsumerState<InterviewsScreen> createState() => _InterviewsScreenState();
}

class _InterviewsScreenState extends ConsumerState<InterviewsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleJoinRoom(InterviewBooking interview) {
    final panelist = MentorProfile(
      id: 'panel_${interview.id}',
      name: interview.interviewerName,
      role: interview.interviewerRole,
      company: interview.company,
      experienceYears: 10,
      rating: 4.9,
      totalMentees: 85,
      hourlyRateInr: 0,
      expertise: ['Stage Evaluation', interview.stage],
    );
    context.push(RouteConstants.videoRoom, extra: panelist);
  }

  void _showScorecardModal(BuildContext context, InterviewBooking interview) {
    final scorecard = interview.scorecard;
    if (scorecard == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_outlined, color: AppColors.accent, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Evaluation Scorecard',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Text(
                '${interview.company} • ${interview.jobTitle} (${interview.stage})',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    // Recommendation Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Interviewer Recommendation',
                                style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                scorecard.recommendation,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF166534),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < scorecard.overallRating ? Icons.star_rounded : Icons.star_border_rounded,
                                color: const Color(0xFFF59E0B),
                                size: 20,
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Competency Breakdown',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    ...scorecard.competencyScores.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                entry.key,
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimaryLight),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: LinearProgressIndicator(
                                value: entry.value / 5.0,
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${entry.value}/5',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 18),
                    const Text(
                      'Candidate-Facing Feedback Notes',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        scorecard.interviewerNotes,
                        style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimaryLight),
                      ),
                    ),
                    if (scorecard.strengths.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Observed Strengths',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF15803D)),
                      ),
                      const SizedBox(height: 6),
                      ...scorecard.strengths.map(
                        (s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF15803D)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(s, style: const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (scorecard.areasToImprove.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Key Areas for Further Development',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFD97706)),
                      ),
                      const SizedBox(height: 6),
                      ...scorecard.areasToImprove.map(
                        (a) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline, size: 14, color: Color(0xFFD97706)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(a, style: const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleReschedule(InterviewBooking interview) {
    if (interview.reschedulesLeft <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Maximum reschedule limit reached (2 attempts per round per PRD SCH-05). Please contact Talent HR.',
          ),
        ),
      );
      return;
    }

    String selectedReason = 'Scheduling conflict with current work';
    final reasons = [
      'Scheduling conflict with current work',
      'Personal emergency / Health reason',
      'Need additional technical prep time',
      'Timezone mismatch',
    ];

    showDatePicker(
      context: context,
      initialDate: interview.scheduledAt.add(const Duration(days: 2)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    ).then((selectedDate) {
      if (selectedDate != null && mounted) {
        showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 14, minute: 0),
        ).then((selectedTime) {
          if (selectedTime != null && mounted) {
            final newDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );

            showDialog(
              context: context,
              builder: (ctx) => StatefulBuilder(
                builder: (dialogCtx, setDialogState) {
                  return AlertDialog(
                    title: const Text('Confirm Reschedule Request'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Proposed Time:\n${newDateTime.day}/${newDateTime.month}/${newDateTime.year} at ${selectedTime.format(context)} IST',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        const Text('Reason for Rescheduling:', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: selectedReason,
                          isExpanded: true,
                          items: reasons
                              .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 12))))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => selectedReason = val);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Notice: You have ${interview.reschedulesLeft} attempts remaining. After this, ${interview.reschedulesLeft - 1} will remain.',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          try {
                            await ref.read(interviewsProvider.notifier).reschedule(
                                  interviewId: interview.id,
                                  newDateTime: newDateTime,
                                  reason: selectedReason,
                                );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.accent,
                                  content: Text(
                                    'Interview rescheduled to ${newDateTime.day}/${newDateTime.month}/${newDateTime.year} at ${selectedTime.format(context)} IST',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(backgroundColor: AppColors.error, content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('Confirm Reschedule'),
                      ),
                    ],
                  );
                },
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final interviewsAsync = ref.watch(interviewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Pipeline Hub'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondaryLight,
          tabs: const [
            Tab(text: 'Active Pipeline'),
            Tab(text: 'Completed & Scorecards'),
          ],
        ),
      ),
      body: interviewsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load interviews: $err')),
        data: (interviews) {
          final activeInterviews =
              interviews.where((i) => i.status != InterviewStatus.completed).toList();
          final pastInterviews =
              interviews.where((i) => i.status == InterviewStatus.completed).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildInterviewList(activeInterviews, isPast: false),
              _buildInterviewList(pastInterviews, isPast: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInterviewList(List<InterviewBooking> list, {required bool isPast}) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPast ? Icons.assignment_turned_in_outlined : Icons.calendar_today_outlined,
                size: 56,
                color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                isPast
                    ? 'No completed interviews yet'
                    : 'No active interviews scheduled right now',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                isPast
                    ? 'Once you complete an interview round, your detailed scorecard and feedback will appear here.'
                    : 'Browse matched jobs and self-book an interview slot directly in just 4 taps.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
              ),
              if (!isPast) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.go(RouteConstants.jobs),
                  icon: const Icon(Icons.work_outline, size: 16),
                  label: const Text('Explore Matched Jobs'),
                ),
              ],
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
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final interview = list[index];
        return _buildInterviewCard(interview, isPast: isPast);
      },
    );
  }

  Widget _buildInterviewCard(InterviewBooking interview, {required bool isPast}) {
    final dateStr =
        '${interview.scheduledAt.day}/${interview.scheduledAt.month}/${interview.scheduledAt.year} at ${interview.scheduledAt.hour.toString().padLeft(2, '0')}:${interview.scheduledAt.minute.toString().padLeft(2, '0')} IST';

    return RepaintBoundary(
      child: Card(
        elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        interview.company,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        interview.jobTitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPast
                        ? const Color(0xFFF0FDF4)
                        : AppColors.info.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPast ? 'Completed' : 'Stage ${interview.stageNumber} of ${interview.totalStages}',
                    style: TextStyle(
                      color: isPast ? const Color(0xFF15803D) : AppColors.info,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology_alt_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Round: ${interview.stage}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.event_outlined, size: 16, color: AppColors.textSecondaryLight),
                const SizedBox(width: 6),
                Text(
                  isPast ? 'Conducted on: $dateStr' : 'Scheduled: $dateStr',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondaryLight),
                const SizedBox(width: 6),
                Text(
                  'Panel: ${interview.interviewerName} (${interview.interviewerRole})',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isPast) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    minimumSize: const Size(double.infinity, 42),
                  ),
                  onPressed: () => _showScorecardModal(context, interview),
                  icon: const Icon(Icons.assessment_outlined, size: 16),
                  label: const Text('View Full Scorecard & Hiring Notes'),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 42),
                      ),
                      onPressed: interview.reschedulesLeft > 0
                          ? () => _handleReschedule(interview)
                          : null,
                      child: Text(
                        interview.reschedulesLeft > 0
                            ? 'Reschedule (${interview.reschedulesLeft} left)'
                            : 'No reschedules left',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        minimumSize: const Size(0, 42),
                      ),
                      onPressed: () => _handleJoinRoom(interview),
                      icon: const Icon(Icons.video_call_rounded, size: 18),
                      label: const Text('Join Room', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ));
  }
}
