class RouteConstants {
  RouteConstants._();

  static const String splash = '/';
  static const String login = '/login';
  static const String otpVerify = '/otp-verify';

  // Candidate Bottom Navigation Shell
  static const String home = '/home';
  static const String jobs = '/jobs';
  static const String interviews = '/interviews';
  static const String experts = '/experts';
  static const String profile = '/profile';

  // Details & Flows
  static const String jobDetail = '/job-detail';
  static const String jobMatch = '/jobs/:id/match';
  static const String bookInterviewSlot = '/jobs/:id/book';

  static const String interviewDetail = '/interviews/:id';
  static const String interviewRoom = '/interviews/:id/room';

  static const String expertDetail = '/experts/:id';
  static const String candidateAuth = '/auth';
  static const String resumeUpload = '/resume-upload';
  static const String roleIntent = '/role-intent';
  static const String mentorConnect = '/mentor-connect';
  static const String mentorChat = '/mentor-chat';
  static const String videoRoom = '/video-room';

  static const String aiCareerCoach = '/ai-coach';
}
