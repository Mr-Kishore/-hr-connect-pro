import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/candidate_flow_providers.dart';

class RoleIntentScreen extends ConsumerStatefulWidget {
  const RoleIntentScreen({super.key});

  @override
  ConsumerState<RoleIntentScreen> createState() => _RoleIntentScreenState();
}

class _RoleIntentScreenState extends ConsumerState<RoleIntentScreen> {
  String _selectedCurrentRole = 'Junior Mobile Developer';
  String _selectedTargetRole = 'Senior Flutter Engineer';
  bool _isSaving = false;

  final List<String> _currentRoleOptions = [
    'Fresher / Student',
    'Junior Mobile Developer',
    'Flutter Developer (1-2 yrs)',
    'Frontend Engineer',
    'Backend Engineer',
  ];

  final List<String> _targetRoleOptions = [
    'Senior Flutter Engineer',
    'Lead Mobile Architect',
    'Full-Stack Mobile Engineer',
    'Staff Mobile Specialist',
  ];

  Future<void> _handleConfirmRoadmap() async {
    setState(() => _isSaving = true);

    await ref.read(candidateProfileProvider.notifier).updateRoleIntent(
          currentRole: _selectedCurrentRole,
          targetRole: _selectedTargetRole,
        );

    setState(() => _isSaving = false);

    if (!mounted) return;
    context.go(RouteConstants.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Role Alignment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/resume-upload'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar (70% complete)
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step 2 of 3: Role Planning',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondaryLight,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Text(
                    '70% Complete',
                    style: TextStyle(
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
                child: const LinearProgressIndicator(
                  value: 0.70,
                  backgroundColor: Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation(AppColors.accent),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Define your career trajectory',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'This maps your existing skills against market expectations to pinpoint exact missing courses and high-match job opportunities.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.textSecondaryLight,
                ),
              ),

              const SizedBox(height: 32),

              // Section 1: Current Role
              const Text(
                'Current Status / Level',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _currentRoleOptions.map((role) {
                  final isSelected = _selectedCurrentRole == role;
                  return ChoiceChip(
                    label: Text(role),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedCurrentRole = role);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                    ),
                    backgroundColor: const Color(0xFFF8FAFC),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Section 2: Target Role
              const Text(
                'Target / Expected Role',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _targetRoleOptions.map((role) {
                  final isSelected = _selectedTargetRole == role;
                  return ChoiceChip(
                    label: Text(role),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedTargetRole = role);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                    ),
                    backgroundColor: const Color(0xFFF8FAFC),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 48),

              // Confirm CTA
              ElevatedButton(
                onPressed: _isSaving ? null : _handleConfirmRoadmap,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Generate Career Roadmap & Jobs'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ).animate().fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
