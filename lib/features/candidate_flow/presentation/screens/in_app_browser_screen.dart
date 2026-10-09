import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/job_opportunity.dart';

class InAppBrowserScreen extends StatefulWidget {
  final JobOpportunity job;

  const InAppBrowserScreen({super.key, required this.job});

  @override
  State<InAppBrowserScreen> createState() => _InAppBrowserScreenState();
}

class _InAppBrowserScreenState extends State<InAppBrowserScreen> {
  bool _isLoading = false;
  bool _isSubmitted = false;

  void _handleSubmitPortal() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSubmitted = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_rounded, size: 13, color: AppColors.accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  job.portalUrl,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.refresh_rounded, size: 15, color: AppColors.textSecondaryLight),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 19),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Sandboxed Security Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFF0FDF4),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, size: 15, color: Color(0xFF166534)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sandboxed Session • Candidate identity & verified credentials auto-filled.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Webview Content simulation
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Simulated Company Header
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              job.company.substring(0, 1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${job.company} Careers Portal',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Verified Employer Partner',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    Text(
                      'Direct Application: ${job.title}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Location: ${job.location} | Package: ${job.salaryRange}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                    ),

                    const SizedBox(height: 24),

                    // Pre-filled Application Fields
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
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                              SizedBox(width: 6),
                              Text(
                                'HR Connect Pro Smart Fill',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildField('Full Name', 'Aditya Sharma'),
                          const SizedBox(height: 10),
                          _buildField('Contact', '+91 98765 43210'),
                          const SizedBox(height: 10),
                          _buildField('Target Role', job.title),
                          const SizedBox(height: 10),
                          _buildField('Attached Resume', 'Aditya_Flutter_Lead.pdf (Verified)'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    if (_isSubmitted)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 36),
                            const SizedBox(height: 8),
                            const Text(
                              'Application Received by Employer',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF166534),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Your verified candidate score and match details were delivered to their ATS.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Color(0xFF166534)),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Return to App Dashboard'),
                            ),
                          ],
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmitPortal,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Submit Application on Portal'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
