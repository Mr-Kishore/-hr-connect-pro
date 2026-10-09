import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/core_providers.dart';
import '../../features/authentication/presentation/login_screen.dart';
import '../../features/candidate_flow/presentation/providers/candidate_flow_providers.dart';
import '../../features/candidate_flow/presentation/screens/auth_screen.dart';
import '../../features/candidate_flow/presentation/screens/resume_upload_screen.dart';
import '../../features/candidate_flow/presentation/screens/role_intent_screen.dart';
import '../../features/candidate_flow/presentation/screens/student_dashboard_screen.dart';
import '../../features/candidate_flow/presentation/screens/job_detail_screen.dart';
import '../../features/candidate_flow/presentation/screens/mentor_connect_screen.dart';
import '../../features/candidate_flow/presentation/screens/encrypted_chat_screen.dart';
import '../../features/candidate_flow/presentation/screens/video_call_room_screen.dart';
import '../../features/candidate_flow/domain/models/job_opportunity.dart';
import '../../features/candidate_flow/domain/models/mentor_profile.dart';
import '../../features/jobs_matching/presentation/jobs_screen.dart';
import '../../features/interview_pipeline/presentation/interviews_screen.dart';
import '../../features/expert_marketplace/presentation/experts_screen.dart';
import '../../features/candidate_profile/presentation/profile_screen.dart';
import '../../features/ai_assistants/presentation/ai_coach_screen.dart';
import 'main_shell.dart';
import 'route_constants.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Build the router once. Watching authStateProvider here used to create a
  // new GoRouter on every login/logout, which reset navigation to
  // initialLocation and ran redirects against stale auth state. Auth changes
  // now re-run the redirect on this same router via refreshListenable.
  final authRefresh = ValueNotifier<AuthState>(ref.read(authStateProvider));
  ref.listen<AuthState>(
    authStateProvider,
    (_, next) => authRefresh.value = next,
  );

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteConstants.candidateAuth,
    refreshListenable: authRefresh,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authStateProvider);
      if (authState.isLoading) return null;

      final path = state.uri.path;
      final isSignInRoute =
          path == RouteConstants.candidateAuth || path == RouteConstants.login;

      // Signed-out users can only reach the sign-in screens.
      if (!authState.isAuthenticated) {
        return isSignInRoute ? null : RouteConstants.candidateAuth;
      }

      // Signed-in users skip the sign-in screens, unless they're still
      // onboarding (the resume upload screen's back button returns to /auth).
      if (isSignInRoute) {
        final profile = ref.read(candidateProfileProvider);
        final isOnboarding = profile != null && !profile.onboardingCompleted;
        return isOnboarding ? null : RouteConstants.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteConstants.candidateAuth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.resumeUpload,
        builder: (context, state) => const ResumeUploadScreen(),
      ),
      GoRoute(
        path: RouteConstants.roleIntent,
        builder: (context, state) => const RoleIntentScreen(),
      ),
      GoRoute(
        path: RouteConstants.jobDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final job =
              state.extra as JobOpportunity? ??
              const JobOpportunity(
                id: 'fallback',
                title: 'Senior Flutter Engineer',
                company: 'Razorpay',
                location: 'Bengaluru',
                salaryRange: '₹22 - 30 LPA',
                fitScore: 84,
                matchedSkills: ['Flutter', 'Dart', 'State Management'],
                missingSkills: ['GraphQL', 'CI/CD Pipelines'],
                description: 'Build robust payment experiences.',
                portalUrl: 'https://razorpay.com/careers',
              );
          return JobDetailScreen(job: job);
        },
      ),
      GoRoute(
        path: RouteConstants.mentorConnect,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MentorConnectScreen(),
      ),
      GoRoute(
        path: RouteConstants.mentorChat,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final mentor =
              state.extra as MentorProfile? ??
              const MentorProfile(
                id: 'men_01',
                name: 'Kavita Menon',
                role: 'Staff Mobile Engineer',
                company: 'Google',
                experienceYears: 9,
                rating: 4.9,
                totalMentees: 74,
                hourlyRateInr: 1500,
                expertise: ['System Architecture'],
              );
          return EncryptedChatScreen(mentor: mentor);
        },
      ),
      GoRoute(
        path: RouteConstants.videoRoom,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final mentor =
              state.extra as MentorProfile? ??
              const MentorProfile(
                id: 'men_01',
                name: 'Kavita Menon',
                role: 'Staff Mobile Engineer',
                company: 'Google',
                experienceYears: 9,
                rating: 4.9,
                totalMentees: 74,
                hourlyRateInr: 1500,
                expertise: ['System Architecture'],
              );
          return VideoCallRoomScreen(mentor: mentor);
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteConstants.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: StudentDashboardScreen()),
          ),
          GoRoute(
            path: RouteConstants.jobs,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: JobsScreen()),
          ),
          GoRoute(
            path: RouteConstants.interviews,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InterviewsScreen()),
          ),
          GoRoute(
            path: RouteConstants.experts,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ExpertsScreen()),
          ),
          GoRoute(
            path: RouteConstants.profile,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: RouteConstants.aiCareerCoach,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AiCoachScreen(),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    authRefresh.dispose();
  });

  return router;
});
