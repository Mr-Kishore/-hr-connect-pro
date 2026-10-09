import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/candidate_flow_providers.dart';

class ResumeUploadScreen extends ConsumerStatefulWidget {
  const ResumeUploadScreen({super.key});

  @override
  ConsumerState<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends ConsumerState<ResumeUploadScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  bool _isScanning = false;
  bool _isParsed = false;
  String? _selectedFile;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _triggerResumeScan(String fileName) async {
    setState(() {
      _selectedFile = fileName;
      _isScanning = true;
      _isParsed = false;
    });

    _scanController.repeat(reverse: true);

    await ref.read(candidateProfileProvider.notifier).parseResume(fileName: fileName);

    if (!mounted) return;
    _scanController.stop();

    setState(() {
      _isScanning = false;
      _isParsed = true;
    });
  }

  Future<void> _handlePickRealFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
      );
      if (files.isNotEmpty) {
        final name = files.first.name;
        _triggerResumeScan(name);
      }
    } catch (_) {
      _triggerResumeScan('Candidate_Resume.pdf');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(candidateProfileProvider);
    final skills = profile?.extractedSkills ?? [];
    final progressVal = _isParsed ? 0.45 : 0.10;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Resume Analysis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/auth'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Endowed Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Step 1 of 3: Skill Parsing',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondaryLight,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Text(
                    '${(progressVal * 100).toInt()}% Complete',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.1, end: progressVal),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    minHeight: 6,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Upload your resume',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Our RAG analysis extracts your technical competencies to calculate accurate role fit scores.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.textSecondaryLight,
                ),
              ),

              const SizedBox(height: 24),

              // Document Scanner Card
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                    decoration: BoxDecoration(
                      color: _isParsed
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isParsed
                            ? const Color(0xFF86EFAC)
                            : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _isParsed
                                ? const Color(0xFFDCFCE7)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isParsed
                                ? Icons.task_alt_rounded
                                : Icons.description_outlined,
                            size: 28,
                            color: _isParsed ? AppColors.accent : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFile ?? 'Select or drop your PDF / DOCX',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _isParsed
                                ? AppColors.accent
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isScanning
                              ? 'Scanning document vectors & skills...'
                              : (_isParsed
                                  ? 'Skills successfully mapped to profile'
                                  : 'PDF or DOCX format, up to 5 MB'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.file_upload_outlined, size: 18),
                              label: const Text('Browse File'),
                              onPressed: _isScanning ? null : _handlePickRealFile,
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              icon: const Icon(Icons.auto_awesome, size: 16),
                              label: const Text('Use Sample Resume'),
                              onPressed: _isScanning
                                  ? null
                                  : () => _triggerResumeScan('Aditya_Flutter_Lead.pdf'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Animated Emerald Laser Scan Beam
                  if (_isScanning)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedBuilder(
                          animation: _scanController,
                          builder: (context, child) {
                            return Align(
                              alignment: Alignment(0, (_scanController.value * 2) - 1),
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent.withValues(alpha: 0.8),
                                      blurRadius: 16,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                  color: AppColors.accent,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 28),

              // Extracted Skills Cloud (Staggered Reveal)
              if (_isParsed && skills.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.accent, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Detected Competencies (${skills.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 36),

                // Next Step CTA
                ElevatedButton(
                  onPressed: () => context.go('/role-intent'),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Continue to Role Planning'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
