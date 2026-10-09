import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../candidate_flow/domain/models/mentor_profile.dart';

class InterviewsScreen extends StatefulWidget {
  const InterviewsScreen({super.key});

  @override
  State<InterviewsScreen> createState() => _InterviewsScreenState();
}

class _InterviewsScreenState extends State<InterviewsScreen> {
  String _scheduledTime = 'Oct 12, 2026 at 10:00 AM IST';
  int _reschedulesLeft = 1;

  void _handleReschedule() {
    if (_reschedulesLeft <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No reschedule attempts remaining for this round.'),
        ),
      );
      return;
    }

    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    ).then((selectedDate) {
      if (selectedDate != null && mounted) {
        showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 10, minute: 0),
        ).then((selectedTime) {
          if (selectedTime != null && mounted) {
            setState(() {
              _scheduledTime =
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} at ${selectedTime.format(context)} IST';
              _reschedulesLeft--;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.accent,
                content: Text(
                  'Interview successfully rescheduled to $_scheduledTime',
                ),
              ),
            );
          }
        });
      }
    });
  }

  void _handleJoinRoom() {
    const interviewPanelist = MentorProfile(
      id: 'panel_01',
      name: 'Priya Sundaram (Technical Panel)',
      role: 'Staff Engineer & Interviewer',
      company: 'Fintech Innovations',
      experienceYears: 11,
      rating: 4.9,
      totalMentees: 92,
      hourlyRateInr: 0,
      expertise: ['L1 System Evaluation', 'Flutter Architecture'],
    );
    context.push(RouteConstants.videoRoom, extra: interviewPanelist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Scheduled Interviews')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Fintech Innovations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Round: L1 Technical',
                          style: TextStyle(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.event_outlined,
                        size: 16,
                        color: AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Scheduled: $_scheduledTime',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _reschedulesLeft > 0
                              ? _handleReschedule
                              : null,
                          child: Text(
                            _reschedulesLeft > 0
                                ? 'Reschedule ($_reschedulesLeft of 2 left)'
                                : 'No reschedules left',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleJoinRoom,
                          icon: const Icon(Icons.video_call, size: 18),
                          label: const Text('Join Room'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
