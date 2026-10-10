import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../candidate_flow/domain/models/mentor_profile.dart';
import '../../candidate_flow/presentation/providers/candidate_flow_providers.dart';

class ExpertsScreen extends ConsumerStatefulWidget {
  const ExpertsScreen({super.key});

  @override
  ConsumerState<ExpertsScreen> createState() => _ExpertsScreenState();
}

class _ExpertsScreenState extends ConsumerState<ExpertsScreen> {
  String _selectedDomain = 'All';
  final List<String> _domains = ['All', 'System Architecture', 'Leadership', 'Flutter', 'Performance'];

  void _handleBookSession(BuildContext context, MentorProfile mentor) async {
    // Conflict check (EXP-07): Check if candidate's target company has a conflict
    final profile = ref.read(candidateProfileProvider);
    final targetRoleOrCompany = profile?.targetRole ?? '';
    final repo = ref.read(candidateRepositoryProvider);

    final conflictResult = await repo.checkExpertConflict(
      expertId: mentor.id,
      targetCompany: targetRoleOrCompany,
    );

    if (!context.mounted) return;

    if (conflictResult['hasConflict'] == true) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.error),
              SizedBox(width: 8),
              Text('Conflict of Interest Guard', style: TextStyle(fontSize: 16)),
            ],
          ),
          content: Text(
            conflictResult['conflictReason'] as String? ??
                'This expert has an active conflict of interest with your target company.',
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Understood'),
            ),
          ],
        ),
      );
      return;
    }

    _showBookingSheet(context, mentor);
  }

  void _showBookingSheet(BuildContext context, MentorProfile mentor) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 17, minute: 0);
    String selectedTopic = '1:1 Technical & System Architecture Mock';
    bool dualConsent = false;

    final topics = [
      '1:1 Technical & System Architecture Mock',
      'Hiring Manager / Behavioral Mock Round',
      'Resume Diagnostic & Skill Gap Alignment',
      'Offer Evaluation & Compensation Strategy',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setSheetState) {
            final rate = mentor.hourlyRateInr;
            final platformFee = (rate * 0.20).round();
            final expertPayout = rate - platformFee;

            return Container(
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.88,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.handshake_outlined, color: AppColors.accent, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Book Advisory Session',
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
                    'Advisor: ${mentor.name} (${mentor.role} @ ${mentor.company})',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                  const Divider(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        const Text(
                          'Select Advisory Topic:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: selectedTopic,
                          isExpanded: true,
                          items: topics
                              .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12))))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setSheetState(() => selectedTopic = val);
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Session Slot (Date & Time):',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime.now().add(const Duration(days: 1)),
                                    lastDate: DateTime.now().add(const Duration(days: 14)),
                                  );
                                  if (d != null) setSheetState(() => selectedDate = d);
                                },
                                icon: const Icon(Icons.calendar_today, size: 14),
                                label: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}', style: const TextStyle(fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final t = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTime,
                                  );
                                  if (t != null) setSheetState(() => selectedTime = t);
                                },
                                icon: const Icon(Icons.access_time, size: 14),
                                label: Text(selectedTime.format(context), style: const TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Escrow & RBI Compliance Breakdown Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Payment & Escrow Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('RBI Nodal Compliant', style: TextStyle(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Session Fee (45 min):', style: TextStyle(fontSize: 12)),
                                  Text('₹$rate', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Platform Fee (20% retained):', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                                  Text('₹$platformFee', style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Expert Payout (80% settled post-call):', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                                  Text('₹$expertPayout', style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                                ],
                              ),
                              const Divider(height: 16),
                              const Text(
                                '• Live 1-on-1 personal service (Apple Guideline 3.1.3d exempt)\n• 100% refund if cancelled >24 hrs prior to session',
                                style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: dualConsent,
                          onChanged: (val) => setSheetState(() => dualConsent = val ?? false),
                          title: const Text(
                            'Opt-in to Dual Recording for private candidate playback (DPDP 2023 Consent)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      minimumSize: const Size(double.infinity, 46),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final scheduledDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      try {
                        await ref.read(expertBookingsProvider.notifier).bookSession(
                              expertId: mentor.id,
                              scheduledAt: scheduledDateTime,
                              durationMinutes: 45,
                              topic: selectedTopic,
                              consentForRecording: dualConsent,
                            );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.accent,
                              content: Text(
                                'Session with ${mentor.name} successfully booked for ${selectedDate.day}/${selectedDate.month} at ${selectedTime.format(context)}!',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(backgroundColor: AppColors.error, content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    child: Text('Confirm & Reserve Session (₹$rate)'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mentorsAsync = ref.watch(mentorsProvider);
    final bookingsAsync = ref.watch(expertBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Career Advisory Marketplace')),
      body: CustomScrollView(
        slivers: [
          // Active Bookings Banner (if any)
          bookingsAsync.when(
            data: (bookings) {
              if (bookings.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.alarm_on_rounded, color: AppColors.secondary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upcoming Session: ${bookings.first.expertName}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                              ),
                              Text(
                                '${bookings.first.sessionTopic} • ${bookings.first.scheduledAt.day}/${bookings.first.scheduledAt.month}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            final panelist = MentorProfile(
                              id: bookings.first.expertId,
                              name: bookings.first.expertName,
                              role: bookings.first.expertRole,
                              company: bookings.first.expertCompany,
                              experienceYears: 10,
                              rating: 4.9,
                              totalMentees: 80,
                              hourlyRateInr: bookings.first.sessionRateInr,
                              expertise: [bookings.first.sessionTopic],
                            );
                            context.push(RouteConstants.videoRoom, extra: panelist);
                          },
                          child: const Text('Join Room', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: _domains.map((domain) {
                  final isSelected = _selectedDomain == domain;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(domain, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.textPrimaryLight)),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedDomain = domain);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Mentors list
          mentorsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(child: Text('Failed to load expert advisors: $err')),
            ),
            data: (mentors) {
              final filteredMentors = _selectedDomain == 'All'
                  ? mentors
                  : mentors.where((m) => m.expertise.any((e) => e.toLowerCase().contains(_selectedDomain.toLowerCase()))).toList();

              if (filteredMentors.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No experts match this filter.')),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList.separated(
                  itemCount: filteredMentors.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final mentor = filteredMentors[index];
                    return _buildExpertCard(context, mentor);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpertCard(BuildContext context, MentorProfile mentor) {
    return RepaintBoundary(
      child: Card(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${mentor.hourlyRateInr}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'per 45m session',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
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
                        backgroundColor: AppColors.accent,
                        minimumSize: const Size(0, 40),
                      ),
                      icon: const Icon(Icons.calendar_month_outlined, size: 16),
                      label: const Text('Book 1:1'),
                      onPressed: () => _handleBookSession(context, mentor),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
