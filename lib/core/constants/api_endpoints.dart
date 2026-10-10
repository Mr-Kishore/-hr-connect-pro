class ApiEndpoints {
  ApiEndpoints._();

  // Authentication
  static const String authSendOtp = '/api/v1/auth/otp/send';
  static const String authVerifyOtp = '/api/v1/auth/otp/verify';
  static const String authGoogleSignIn = '/api/v1/auth/google';
  static const String authAppleSignIn = '/api/v1/auth/apple';
  static const String authRefreshToken = '/api/v1/auth/token/refresh';
  static const String authRevokeToken = '/api/v1/auth/token/revoke';

  // Candidate Profile & Resume Ingestion
  static const String candidateProfile = '/api/v1/candidates/profile';
  static const String resumeUpload = '/api/v1/candidates/resume/upload';
  static const String candidateConsent = '/api/v1/candidates/consent';
  static const String candidateExportData = '/api/v1/candidates/data/export';
  static const String candidateDeleteAccount =
      '/api/v1/candidates/account/delete';

  // Job Catalog & Matching
  static const String jobsList = '/api/v1/jobs';
  static String jobDetail(String id) => '/api/v1/jobs/$id';
  static String jobMatchExplanation(String id) =>
      '/api/v1/jobs/$id/match-explanation';

  // Scheduling & Interviews
  static String jobAvailableSlots(String jobId) =>
      '/api/v1/interviews/jobs/$jobId/slots';
  static const String bookInterviewSlot = '/api/v1/interviews/slots/book';
  static const String myInterviews = '/api/v1/interviews/my';
  static String interviewDetail(String id) => '/api/v1/interviews/$id';
  static String rescheduleInterview(String id) =>
      '/api/v1/interviews/$id/reschedule';
  static String interviewRoomToken(String id) =>
      '/api/v1/interviews/$id/room-token';

  // Expert Marketplace
  static const String expertsList = '/api/v1/experts';
  static String expertDetail(String id) => '/api/v1/experts/$id';
  static String expertAvailableSlots(String expertId) =>
      '/api/v1/experts/$expertId/slots';
  static const String bookExpertSession = '/api/v1/experts/sessions/book';
  static const String myExpertSessions = '/api/v1/experts/sessions/my';
  static String expertSessionDetail(String id) =>
      '/api/v1/experts/sessions/$id';

  // AI Assistants
  static const String aiCareerCoachQuery = '/api/v1/ai/career-coach/chat';
  static const String aiGenerateMockQuestions =
      '/api/v1/ai/mock-interview/generate';
}
