import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/candidate_flow_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;
  bool _isExistingUser = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleProceedPhone() async {
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.length < 10) {
      setState(() => _errorMessage = 'Please enter a valid 10-digit mobile number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final formattedPhone = rawPhone.startsWith('+91') ? rawPhone : '+91$rawPhone';
    final exists = await ref.read(candidateProfileProvider.notifier).checkUserExists(formattedPhone);

    setState(() {
      _isLoading = false;
      _otpSent = true;
      _isExistingUser = exists;
      _otpController.text = '5432'; // Pre-filled OTP for rapid preview
    });
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      setState(() => _errorMessage = 'Enter 4-digit verification code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final rawPhone = _phoneController.text.trim();
    final formattedPhone = rawPhone.startsWith('+91') ? rawPhone : '+91$rawPhone';
    final profile = await ref.read(candidateProfileProvider.notifier).loginOrRegister(formattedPhone, otp);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (profile.onboardingCompleted) {
      context.go(RouteConstants.home);
    } else {
      context.go('/resume-upload');
    }
  }

  void _fillSampleUser({required bool existing}) {
    if (existing) {
      _phoneController.text = '9876543210';
    } else {
      _phoneController.text = '9123456780';
    }
    setState(() {
      _otpSent = false;
      _errorMessage = null;
    });
    _handleProceedPhone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Brand mark & Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.work_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'HR Connect Pro',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

              const SizedBox(height: 36),

              const Text(
                'Candidate Portal',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: AppColors.textPrimaryLight,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              const SizedBox(height: 8),

              const Text(
                'Verify your mobile number to discover role alignment, bridge skill gaps, and connect with industry mentors.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: AppColors.textSecondaryLight,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 32),

              // Deduplication Status Notice
              if (_otpSent)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _isExistingUser
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isExistingUser
                          ? const Color(0xFFBBF7D0)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isExistingUser
                            ? Icons.verified_user_outlined
                            : Icons.person_add_alt_1_outlined,
                        color: _isExistingUser
                            ? AppColors.accent
                            : AppColors.textSecondaryLight,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isExistingUser
                                  ? 'Existing Account Verified'
                                  : 'New Registration',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _isExistingUser
                                    ? AppColors.accent
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isExistingUser
                                  ? 'Welcome back. Verifying will load your profile and roadmap.'
                                  : 'New candidate profile will be initialized with resume parsing.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, end: 0),

              // Mobile Input Field
              const Text(
                'Mobile Number',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: !_otpSent,
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+91',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          height: 20,
                          child: VerticalDivider(color: Color(0xFFCBD5E1), width: 1),
                        ),
                      ],
                    ),
                  ),
                  hintText: '98765 43210',
                  suffixIcon: _otpSent
                      ? IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          tooltip: 'Change Number',
                          onPressed: () => setState(() => _otpSent = false),
                        )
                      : null,
                ),
              ),

              // OTP Input Field (Animated Reveal)
              if (_otpSent) ...[
                const SizedBox(height: 24),
                const Text(
                  'Verification Code',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  style: const TextStyle(
                    fontSize: 20,
                    letterSpacing: 8,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '••••',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, end: 0),
              ],

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (_otpSent ? _handleVerifyOtp : _handleProceedPhone),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(_otpSent ? 'Verify & Continue' : 'Get Verification Code'),
              ),

              const SizedBox(height: 36),

              // Fast Demo Helpers for Testing / Client Review
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
                    const Text(
                      'Interactive Demo Presets',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            onPressed: () => _fillSampleUser(existing: false),
                            child: const Text(
                              'Test New User',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            onPressed: () => _fillSampleUser(existing: true),
                            child: const Text(
                              'Test Existing User',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
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
      ),
    );
  }
}
