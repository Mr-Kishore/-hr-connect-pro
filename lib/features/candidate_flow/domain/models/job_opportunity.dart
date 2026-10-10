import 'interview_booking.dart';

class JobOpportunity {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salaryRange;
  final int fitScore;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final String description;
  final String portalUrl;
  final bool isDirectApply;
  final String postedAgo;
  final bool hasInstantInterview;
  final List<InterviewSlot> availableSlots;
  final List<String> interviewRounds;

  const JobOpportunity({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salaryRange,
    required this.fitScore,
    required this.matchedSkills,
    required this.missingSkills,
    required this.description,
    required this.portalUrl,
    this.isDirectApply = true,
    this.postedAgo = '2 days ago',
    this.hasInstantInterview = true,
    this.availableSlots = const [],
    this.interviewRounds = const [
      'L1 Technical Screening',
      'L2 Coding & Problem Solving',
      'HR Final',
    ],
  });
}
