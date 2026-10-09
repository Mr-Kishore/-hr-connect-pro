import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/route_constants.dart';
import '../../../../app/theme/app_colors.dart';

class DemoControllerSheet extends StatelessWidget {
  const DemoControllerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const DemoControllerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Investor Pitch Navigation Tool',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
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
          const Text(
            'Jump directly to any milestone in Flow 1 without resetting flow progression.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 18),
          _buildJumpTile(
            context,
            icon: Icons.phonelink_lock_outlined,
            title: '1. Auth & Deduplication',
            subtitle: 'Phone OTP & duplicate account detection',
            route: RouteConstants.candidateAuth,
          ),
          _buildJumpTile(
            context,
            icon: Icons.document_scanner_outlined,
            title: '2. Resume Laser Scanner',
            subtitle: 'AI competency parsing & 45% Endowed Progress',
            route: RouteConstants.resumeUpload,
          ),
          _buildJumpTile(
            context,
            icon: Icons.alt_route_rounded,
            title: '3. Role Intent Planning',
            subtitle: 'Current vs Target role alignment (70% Progress)',
            route: RouteConstants.roleIntent,
          ),
          _buildJumpTile(
            context,
            icon: Icons.dashboard_outlined,
            title: '4. Candidate Dashboard',
            subtitle: 'Readiness gauge, course recommendations, job feed',
            route: RouteConstants.home,
          ),
          _buildJumpTile(
            context,
            icon: Icons.handshake_outlined,
            title: '5. Mentors & Escrow Booking',
            subtitle: '20% platform fee breakdown & verified specialists',
            route: RouteConstants.mentorConnect,
          ),
          _buildJumpTile(
            context,
            icon: Icons.shield_outlined,
            title: '6. Encrypted Chat with Leak Guard',
            subtitle: 'Real-time phone/email disintermediation defense',
            route: RouteConstants.mentorChat,
          ),
          _buildJumpTile(
            context,
            icon: Icons.videocam_outlined,
            title: '7. In-App Video Call Room',
            subtitle: 'Embedded WebRTC call screen with PiP & controls',
            route: RouteConstants.videoRoom,
          ),
        ],
      ),
    );
  }

  Widget _buildJumpTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18),
      onTap: () {
        Navigator.pop(context);
        context.push(route);
      },
    );
  }
}
