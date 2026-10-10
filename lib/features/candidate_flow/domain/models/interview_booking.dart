class ScorecardData {
  final Map<String, int>
  competencyScores; // e.g. {'Architecture': 4, 'Problem Solving': 5}
  final int overallRating; // 1-5
  final String recommendation; // 'Strong Hire', 'Hire', 'Borderline'
  final String interviewerNotes; // Candidate-facing constructive feedback
  final List<String> strengths;
  final List<String> areasToImprove;

  const ScorecardData({
    required this.competencyScores,
    required this.overallRating,
    required this.recommendation,
    required this.interviewerNotes,
    this.strengths = const [],
    this.areasToImprove = const [],
  });
}

class InterviewSlot {
  final String id;
  final DateTime dateTime;
  final int durationMinutes;
  final String interviewerName;
  final bool isAvailable;

  const InterviewSlot({
    required this.id,
    required this.dateTime,
    this.durationMinutes = 45,
    required this.interviewerName,
    this.isAvailable = true,
  });
}

enum InterviewStatus { scheduled, completed, rescheduled, cancelled }

class InterviewBooking {
  final String id;
  final String jobId;
  final String jobTitle;
  final String company;
  final String stage; // e.g. 'L1 Technical Screening', 'L2 Coding', 'L3 System Design', 'HR Round'
  final int stageNumber; // 1, 2, 3...
  final int totalStages; // e.g. 4
  final String interviewerName;
  final String interviewerRole;
  final DateTime scheduledAt;
  final InterviewStatus status;
  final int reschedulesLeft;
  final String meetingUrl;
  final ScorecardData? scorecard;

  const InterviewBooking({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.company,
    required this.stage,
    this.stageNumber = 1,
    this.totalStages = 3,
    required this.interviewerName,
    required this.interviewerRole,
    required this.scheduledAt,
    this.status = InterviewStatus.scheduled,
    this.reschedulesLeft = 2,
    this.meetingUrl = 'https://meet.hrconnectpro.app/room/instant',
    this.scorecard,
  });

  InterviewBooking copyWith({
    String? id,
    String? jobId,
    String? jobTitle,
    String? company,
    String? stage,
    int? stageNumber,
    int? totalStages,
    String? interviewerName,
    String? interviewerRole,
    DateTime? scheduledAt,
    InterviewStatus? status,
    int? reschedulesLeft,
    String? meetingUrl,
    ScorecardData? scorecard,
  }) {
    return InterviewBooking(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      stage: stage ?? this.stage,
      stageNumber: stageNumber ?? this.stageNumber,
      totalStages: totalStages ?? this.totalStages,
      interviewerName: interviewerName ?? this.interviewerName,
      interviewerRole: interviewerRole ?? this.interviewerRole,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      reschedulesLeft: reschedulesLeft ?? this.reschedulesLeft,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      scorecard: scorecard ?? this.scorecard,
    );
  }
}
