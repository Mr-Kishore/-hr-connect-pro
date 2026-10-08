import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/job_opportunity.dart';

class JobDetailScreen extends StatefulWidget {
  final JobOpportunity job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isApplied = false;

  void _handleDirectApply() {
    setState(() => _isApplied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.accent,
        content: Text(
          'Application submitted to ${widget.job.company} Talent Team with your verified profile.',
        ),
      ),
    );
  }

  void _openInAppPortal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_outline, size: 16, color: AppColors.textSecondaryLight),
                      const SizedBox(width: 6),
                      Text(
                        'In-App Career Gateway • ${widget.job.company}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Redirecting inside HR Connect Pro Secure Sandbox',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Destination: ${widget.job.portalUrl}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                    ),
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(
                      backgroundColor: Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.public, size: 48, color: Color(0xFF94A3B8)),
                      SizedBox(height: 12),
                      Text(
                        'Sandboxed Browser Active',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your profile credentials are protected. No external redirection out of the app.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(job.company),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${job.company} • ${job.location}',
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Text(
                    '${job.fitScore}% Fit',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Compensation: ${job.salaryRange}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // SKILL GAP EXPLAINABILITY CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.analytics_outlined, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Competency Fit Breakdown',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Matched Skills
                  const Text(
                    'Skills You Possess (Matched)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.matchedSkills.map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check, size: 14, color: Color(0xFF15803D)),
                            const SizedBox(width: 4),
                            Text(
                              s,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Missing Skills
                  const Text(
                    'Skills Required to Bridge Gap',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD97706),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.missingSkills.map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_circle_outline, size: 14, color: Color(0xFFB45309)),
                            const SizedBox(width: 4),
                            Text(
                              s,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 10),

                  // Actionable Step
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Action to qualify: Complete the recommended "${job.missingSkills.first}" module to increase your interview match rate.',
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms),

            const SizedBox(height: 28),

            // Role Description
            const Text(
              'About the Position',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              job.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondaryLight,
              ),
            ),

            const SizedBox(height: 40),

            // Apply CTA Actions
            if (_isApplied)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.accent),
                    SizedBox(width: 8),
                    Text(
                      'Application Successfully Submitted',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleDirectApply,
                      child: const Text('1-Click Apply'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _openInAppPortal,
                      child: const Text('In-App Webview'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
