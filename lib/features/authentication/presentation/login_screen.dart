import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/core_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  void _handleSendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your mobile phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulated Phase 0 OTP verification logic
    Future.delayed(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      await ref.read(authStateProvider.notifier).login(
            accessToken: 'phase0_mock_jwt_access',
            refreshToken: 'phase0_mock_jwt_refresh',
            userId: 'phase0-test-user-id',
            role: 'candidate',
          );
      setState(() => _isLoading = false);
      if (mounted) {
        context.go(RouteConstants.home);
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'HR Connect Pro',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Discover matched jobs, self-book interviews, and connect with top industry experts.',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: '+91 98765 43210',
                  prefixIcon: Icon(Icons.phone_android),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSendOtp,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Continue with OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
