import 'dart:async';

import '../domain/models/candidate_profile.dart';
import '../domain/models/job_opportunity.dart';
import '../domain/models/recommended_course.dart';
import '../domain/models/mentor_profile.dart';
import '../domain/models/chat_message.dart';
import '../domain/models/interview_booking.dart';
import '../domain/models/expert_booking.dart';
import '../../../core/errors/app_exception.dart';

abstract class CandidateRepository {
  Future<bool> checkUserExists(String phone);
  Future<CandidateProfile> loginOrRegister(String phone, String otp);
  Future<CandidateProfile> parseResume({required String fileName});
  Future<CandidateProfile> updateRoleIntent({
    required String currentRole,
    required String targetRole,
  });
  Future<List<JobOpportunity>> getMatchedJobs();
  Future<List<RecommendedCourse>> getRecommendedCourses();
  Future<List<MentorProfile>> getMentors();
  Future<ChatMessage> sendChatMessage({
    required String mentorId,
    required String text,
  });
  List<ChatMessage> getChatHistory(String mentorId);

  // Phase 1 & 2: Interviews Pipeline & Scheduling
  Future<List<InterviewBooking>> getInterviews();
  Future<InterviewBooking> bookInterviewSlot({
    required String jobId,
    required String slotId,
    required DateTime scheduledAt,
  });
  Future<InterviewBooking> rescheduleInterview({
    required String interviewId,
    required DateTime newDateTime,
    required String reason,
  });

  // Phase 1: Expert Marketplace & Escrow
  Future<List<ExpertBooking>> getExpertBookings();
  Future<ExpertBooking> bookExpertSession({
    required String expertId,
    required DateTime scheduledAt,
    required int durationMinutes,
    required String topic,
    bool consentForRecording = false,
  });
  Future<Map<String, dynamic>> checkExpertConflict({
    required String expertId,
    required String targetCompany,
  });

  // Phase 1: AI Assistant & Mock Interview Simulator
  Future<List<String>> generateMockInterviewQuestions({
    required String role,
    required List<String> focusSkills,
    required String stage,
  });
  Future<Map<String, dynamic>> evaluateMockAnswer({
    required String question,
    required String candidateAnswer,
  });
}

class MockCandidateRepository implements CandidateRepository {
  // In-memory registered user database for deduplication
  final Map<String, CandidateProfile> _registeredUsers = {
    '+919876543210': const CandidateProfile(
      id: 'usr_existing_01',
      phone: '+919876543210',
      name: 'Aditya Sharma',
      currentRole: 'Junior Flutter Developer',
      targetRole: 'Senior Mobile Engineer',
      extractedSkills: [
        'Flutter',
        'Dart',
        'Riverpod',
        'REST APIs',
        'Git',
        'Firebase',
      ],
      readinessScore: 82,
      resumeFileName: 'Aditya_Sharma_Resume.pdf',
      onboardingCompleted: true,
    ),
  };

  CandidateProfile? _currentProfile;
  final Map<String, List<ChatMessage>> _chatHistories = {};
  late final List<InterviewBooking> _interviews;
  late final List<ExpertBooking> _expertBookings;

  MockCandidateRepository() {
    _initializeDefaultChats();
    _initializeDefaultInterviews();
    _initializeDefaultExpertBookings();
  }

  void _initializeDefaultChats() {
    _chatHistories['men_01'] = [
      ChatMessage(
        id: 'msg_01',
        senderId: 'men_01',
        text: 'Hello! I noticed you are preparing for Senior Mobile roles. Feel free to ask any technical or architecture questions.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isFromCandidate: false,
      ),
    ];
  }

  void _initializeDefaultInterviews() {
    _interviews = [
      InterviewBooking(
        id: 'int_01',
        jobId: 'job_01',
        jobTitle: 'Senior Flutter Engineer',
        company: 'Fintech Innovations',
        stage: 'L1 Technical Screening',
        stageNumber: 1,
        totalStages: 3,
        interviewerName: 'Priya Sundaram (Technical Panel)',
        interviewerRole: 'Staff Engineer & Interviewer',
        scheduledAt: DateTime.now().add(const Duration(days: 2, hours: 3)),
        status: InterviewStatus.scheduled,
        reschedulesLeft: 2,
      ),
      InterviewBooking(
        id: 'int_02',
        jobId: 'job_03',
        jobTitle: 'Mobile SDE-2',
        company: 'Zomato',
        stage: 'L2 Coding & Problem Solving',
        stageNumber: 2,
        totalStages: 3,
        interviewerName: 'Arjun Rao',
        interviewerRole: 'Senior Engineering Manager',
        scheduledAt: DateTime.now().add(const Duration(days: 5, hours: 1)),
        status: InterviewStatus.scheduled,
        reschedulesLeft: 1,
      ),
      InterviewBooking(
        id: 'int_03',
        jobId: 'job_legacy',
        jobTitle: 'Senior Frontend Engineer',
        company: 'Swiggy',
        stage: 'L1 Technical Screening',
        stageNumber: 1,
        totalStages: 3,
        interviewerName: 'Karthik Raja',
        interviewerRole: 'Staff Mobile Architect',
        scheduledAt: DateTime.now().subtract(const Duration(days: 3)),
        status: InterviewStatus.completed,
        reschedulesLeft: 0,
        scorecard: const ScorecardData(
          overallRating: 4,
          recommendation: 'Strong Hire',
          interviewerNotes:
              'Candidate demonstrated exceptional grasp of Riverpod architecture, state immutability, and offline-first resilience. Clear communication when discussing distributed lock tradeoffs.',
          competencyScores: {
            'Clean Architecture': 5,
            'State Management': 5,
            'API Resilience': 4,
            'System Design': 4,
          },
          strengths: [
            'Deep understanding of reactive state models',
            'Production experience with SSL Pinning and mobile security',
          ],
          areasToImprove: [
            'Brush up on GraphQL schema federations',
            'Practice Kotlin / Swift native platform channels',
          ],
        ),
      ),
    ];
  }

  void _initializeDefaultExpertBookings() {
    _expertBookings = [
      ExpertBooking(
        id: 'exp_book_01',
        expertId: 'men_01',
        expertName: 'Kavita Menon',
        expertRole: 'Staff Mobile Engineer',
        expertCompany: 'Google',
        scheduledAt: DateTime.now().add(const Duration(days: 1, hours: 4)),
        durationMinutes: 45,
        sessionRateInr: 1500,
        platformCommissionInr: 300,
        expertPayoutInr: 1200,
        status: ExpertBookingStatus.confirmed,
        sessionTopic: 'Senior Mobile System Architecture & Concurrency',
        hasDualConsentForRecording: true,
      ),
    ];
  }

  @override
  Future<bool> checkUserExists(String phone) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final normalized = phone.replaceAll(' ', '').trim();
    return _registeredUsers.containsKey(normalized);
  }

  @override
  Future<CandidateProfile> loginOrRegister(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final normalized = phone.replaceAll(' ', '').trim();

    if (_registeredUsers.containsKey(normalized)) {
      _currentProfile = _registeredUsers[normalized]!;
      return _currentProfile!;
    }

    // New User registration
    final newProfile = CandidateProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      phone: normalized,
      name: 'Candidate',
      readinessScore: 0,
      onboardingCompleted: false,
    );
    _registeredUsers[normalized] = newProfile;
    _currentProfile = newProfile;
    return newProfile;
  }

  @override
  Future<CandidateProfile> parseResume({required String fileName}) async {
    // Simulate AI / RAG extraction latency
    await Future.delayed(const Duration(milliseconds: 1400));

    final extracted = [
      'Flutter',
      'Dart',
      'State Management (Riverpod)',
      'RESTful APIs',
      'Git & Version Control',
      'Clean Architecture',
      'SQLite',
    ];

    _currentProfile =
        (_currentProfile ??
                const CandidateProfile(
                  id: 'temp',
                  phone: '',
                  name: 'Candidate',
                ))
            .copyWith(
              resumeFileName: fileName,
              extractedSkills: extracted,
              readinessScore: 45, // Endowed progress score jump
            );

    return _currentProfile!;
  }

  @override
  Future<CandidateProfile> updateRoleIntent({
    required String currentRole,
    required String targetRole,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _currentProfile =
        (_currentProfile ??
                const CandidateProfile(
                  id: 'temp',
                  phone: '',
                  name: 'Candidate',
                ))
            .copyWith(
              currentRole: currentRole,
              targetRole: targetRole,
              readinessScore:
                  78, // Progress advances as profile gains role alignment
              onboardingCompleted: true,
            );

    return _currentProfile!;
  }

  @override
  Future<List<JobOpportunity>> getMatchedJobs() async {
    await Future.delayed(const Duration(milliseconds: 350));
    final now = DateTime.now();
    return [
      JobOpportunity(
        id: 'job_01',
        title: 'Senior Flutter Engineer',
        company: 'Razorpay',
        location: 'Bengaluru (Hybrid)',
        salaryRange: '₹22 - 30 LPA',
        fitScore: 84,
        matchedSkills: const [
          'Flutter',
          'Dart',
          'State Management',
          'Clean Architecture',
        ],
        missingSkills: const ['GraphQL', 'CI/CD Pipelines'],
        description: 'Lead mobile development for high-throughput payment SDKs and checkout flows.',
        portalUrl: 'https://razorpay.com/careers/mobile-lead',
        isDirectApply: true,
        postedAgo: 'Just now',
        hasInstantInterview: true,
        availableSlots: [
          InterviewSlot(
            id: 'slot_rzp_1',
            dateTime: DateTime(now.year, now.month, now.day + 1, 10, 0),
            interviewerName: 'Priya Sundaram (Lead Mobile Architect)',
            durationMinutes: 45,
          ),
          InterviewSlot(
            id: 'slot_rzp_2',
            dateTime: DateTime(now.year, now.month, now.day + 1, 14, 30),
            interviewerName: 'Priya Sundaram (Lead Mobile Architect)',
            durationMinutes: 45,
          ),
          InterviewSlot(
            id: 'slot_rzp_3',
            dateTime: DateTime(now.year, now.month, now.day + 2, 11, 0),
            interviewerName: 'Priya Sundaram (Lead Mobile Architect)',
            durationMinutes: 45,
          ),
        ],
        interviewRounds: const [
          'L1 Technical Screening',
          'L2 Architecture & Problem Solving',
          'HR & Compensation Round',
        ],
      ),
      JobOpportunity(
        id: 'job_02',
        title: 'Lead Mobile Developer',
        company: 'Flipkart',
        location: 'Bengaluru (On-site)',
        salaryRange: '₹28 - 38 LPA',
        fitScore: 79,
        matchedSkills: const ['Flutter', 'RESTful APIs', 'Git', 'Clean Architecture'],
        missingSkills: const [
          'Automated Testing (Widget/Integration)',
          'Kotlin Native Interop',
        ],
        description: 'Architect customer-facing catalog experiences with fluid 60fps micro-animations.',
        portalUrl: 'https://flipkartcareers.com/job/lead-mobile',
        isDirectApply: false,
        postedAgo: '1 day ago',
        hasInstantInterview: true,
        availableSlots: [
          InterviewSlot(
            id: 'slot_fk_1',
            dateTime: DateTime(now.year, now.month, now.day + 2, 11, 0),
            interviewerName: 'Vikram Malhotra (Staff Director)',
            durationMinutes: 60,
          ),
          InterviewSlot(
            id: 'slot_fk_2',
            dateTime: DateTime(now.year, now.month, now.day + 3, 15, 0),
            interviewerName: 'Vikram Malhotra (Staff Director)',
            durationMinutes: 60,
          ),
        ],
        interviewRounds: const [
          'L1 System Architecture',
          'L2 Coding Simulation',
          'Bar Raiser Leadership',
        ],
      ),
      JobOpportunity(
        id: 'job_03',
        title: 'Mobile SDE-2',
        company: 'Zomato',
        location: 'Gurugram / Remote',
        salaryRange: '₹18 - 25 LPA',
        fitScore: 92,
        matchedSkills: const ['Flutter', 'Dart', 'Riverpod', 'RESTful APIs', 'Git'],
        missingSkills: const ['WebSocket Streaming'],
        description: 'Build real-time tracking interfaces and quick commerce dispatch workflows.',
        portalUrl: 'https://zomato.com/careers/sde2-flutter',
        isDirectApply: true,
        postedAgo: '3 days ago',
        hasInstantInterview: true,
        availableSlots: [
          InterviewSlot(
            id: 'slot_zom_1',
            dateTime: DateTime(now.year, now.month, now.day + 1, 16, 0),
            interviewerName: 'Arjun Rao (Senior Manager)',
            durationMinutes: 45,
          ),
          InterviewSlot(
            id: 'slot_zom_2',
            dateTime: DateTime(now.year, now.month, now.day + 2, 10, 30),
            interviewerName: 'Arjun Rao (Senior Manager)',
            durationMinutes: 45,
          ),
        ],
        interviewRounds: const [
          'L1 Live Problem Solving',
          'L2 Real-Time Dispatch System Design',
          'Culture Fit',
        ],
      ),
    ];
  }

  @override
  Future<List<RecommendedCourse>> getRecommendedCourses() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const [
      RecommendedCourse(
        id: 'crs_01',
        title: 'Production GraphQL with Flutter & Dart',
        provider: 'Coursera',
        duration: '3.5 Hours',
        rating: 4.8,
        skillTarget: 'GraphQL',
        externalUrl: 'https://coursera.org/learn/graphql-flutter',
        level: 'Intermediate',
      ),
      RecommendedCourse(
        id: 'crs_02',
        title: 'Automated CI/CD for Flutter with Fastlane & GitHub Actions',
        provider: 'Udemy',
        duration: '4.0 Hours',
        rating: 4.9,
        skillTarget: 'CI/CD Pipelines',
        externalUrl: 'https://udemy.com/course/flutter-cicd-mastery',
        level: 'Advanced',
      ),
      RecommendedCourse(
        id: 'crs_03',
        title: 'Comprehensive Flutter Testing (Unit, Widget & Mocking)',
        provider: 'Coursera',
        duration: '2.5 Hours',
        rating: 4.7,
        skillTarget: 'Automated Testing',
        externalUrl: 'https://coursera.org/learn/flutter-testing-patterns',
        level: 'Intermediate',
      ),
    ];
  }

  @override
  Future<List<MentorProfile>> getMentors() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      MentorProfile(
        id: 'men_01',
        name: 'Kavita Menon',
        role: 'Staff Mobile Engineer',
        company: 'Google',
        experienceYears: 9,
        rating: 4.9,
        totalMentees: 74,
        hourlyRateInr: 1500,
        expertise: [
          'System Architecture',
          'Senior SDE Interviews',
          'Code Reviews',
        ],
        isAvailableNow: true,
      ),
      MentorProfile(
        id: 'men_02',
        name: 'Rohan Deshmukh',
        role: 'Engineering Manager (Mobile)',
        company: 'Flipkart',
        experienceYears: 11,
        rating: 4.85,
        totalMentees: 92,
        hourlyRateInr: 1800,
        expertise: [
          'Leadership Rounds',
          'Hiring Manager Mock',
          'Salary Negotiation',
        ],
        isAvailableNow: false,
      ),
      MentorProfile(
        id: 'men_03',
        name: 'Ananya Sen',
        role: 'Principal Mobile Architect',
        company: 'Razorpay',
        experienceYears: 8,
        rating: 4.95,
        totalMentees: 58,
        hourlyRateInr: 1400,
        expertise: [
          'Flutter Performance',
          'SDK Security',
          'Mock Technical Rounds',
        ],
        isAvailableNow: true,
      ),
    ];
  }

  @override
  Future<ChatMessage> sendChatMessage({
    required String mentorId,
    required String text,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    // ACTIVE PII & CONTACT LEAK DEFENSE FILTER
    // Comprehensive protection against off-platform disintermediation & sensitive data exposure (OWASP / MSTG)
    // 1. Phone numbers: 10 digits with optional country code (+91), spaces, dashes, dots, or parentheses (including spaced evasions)
    final phoneRegex = RegExp(
      r'(?:\+?91[\s.-]?)?(?:\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}|\b(?:\d[\s.-]?){9}\d\b|\b\d{5}[\s.-]?\d{5}\b)',
    );

    // 2. Email addresses: standard (user@domain.com) and bracketed obfuscations (user [at] domain [dot] com, user(at)domain(dot)com)
    final emailRegex = RegExp(
      r'[a-zA-Z0-9._%+-]+(?:\s*@\s*|\s*\[at\]\s*|\s*\(at\)\s*)[a-zA-Z0-9.-]+(?:\s*\.\s*|\s*\[dot\]\s*|\s*\(dot\)\s*)[a-zA-Z]{2,}',
      caseSensitive: false,
    );

    // 3. External links, messaging handles, video conferencing, calendaring, and URL paths
    final linkRegex = RegExp(
      r'(?:https?:\/\/[^\s]+|wa\.me\/?[^\s]*|t\.me\/?[^\s]*|telegram\.me\/?[^\s]*|discord\.gg\/?[^\s]*|(?:[a-zA-Z0-9-]+\.)+(?:com|in|org|net|me|io|co|ai|app|dev)(?:\/[^\s]*)?)\b',
      caseSensitive: false,
    );

    bool containsLeak = false;
    String sanitizedText = text;

    if (phoneRegex.hasMatch(text) ||
        emailRegex.hasMatch(text) ||
        linkRegex.hasMatch(text)) {
      containsLeak = true;
      sanitizedText = sanitizedText
          .replaceAll(phoneRegex, '[Phone Number Redacted]')
          .replaceAll(emailRegex, '[Email Redacted]')
          .replaceAll(linkRegex, '[External Link Redacted]');
    }

    final message = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _currentProfile?.id ?? 'candidate_usr',
      text: sanitizedText,
      timestamp: DateTime.now(),
      isFromCandidate: true,
      isRedacted: containsLeak,
      safetyNotice: containsLeak
          ? 'Contact details are masked to safeguard your session guarantee and identity.'
          : null,
    );

    if (!_chatHistories.containsKey(mentorId)) {
      _chatHistories[mentorId] = [];
    }
    _chatHistories[mentorId]!.add(message);

    return message;
  }

  @override
  List<ChatMessage> getChatHistory(String mentorId) {
    return _chatHistories[mentorId] ?? [];
  }

  @override
  Future<List<InterviewBooking>> getInterviews() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_interviews);
  }

  @override
  Future<InterviewBooking> bookInterviewSlot({
    required String jobId,
    required String slotId,
    required DateTime scheduledAt,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final jobs = await getMatchedJobs();
    final matchedJob = jobs.firstWhere(
      (j) => j.id == jobId,
      orElse: () => jobs.first,
    );

    // Conflict prevention check: Check if slot is already reserved
    final conflict = _interviews.any(
      (i) =>
          i.scheduledAt.year == scheduledAt.year &&
          i.scheduledAt.month == scheduledAt.month &&
          i.scheduledAt.day == scheduledAt.day &&
          i.scheduledAt.hour == scheduledAt.hour &&
          i.status == InterviewStatus.scheduled,
    );
    if (conflict) {
      throw const SlotConflictException(
        message: 'The selected slot conflicts with an existing confirmed interview in your schedule.',
      );
    }

    final newBooking = InterviewBooking(
      id: 'int_${DateTime.now().millisecondsSinceEpoch}',
      jobId: matchedJob.id,
      jobTitle: matchedJob.title,
      company: matchedJob.company,
      stage: matchedJob.interviewRounds.isNotEmpty
          ? matchedJob.interviewRounds.first
          : 'L1 Technical Screening',
      stageNumber: 1,
      totalStages: matchedJob.interviewRounds.length,
      interviewerName: 'Panel Lead (${matchedJob.company})',
      interviewerRole: 'Senior Technical Lead',
      scheduledAt: scheduledAt,
      status: InterviewStatus.scheduled,
      reschedulesLeft: 2,
    );

    _interviews.insert(0, newBooking);
    return newBooking;
  }

  @override
  Future<InterviewBooking> rescheduleInterview({
    required String interviewId,
    required DateTime newDateTime,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _interviews.indexWhere((i) => i.id == interviewId);
    if (index == -1) {
      throw const ValidationException(message: 'Interview booking record not found.');
    }

    final existing = _interviews[index];
    if (existing.reschedulesLeft <= 0) {
      throw const ValidationException(
        message: 'Maximum reschedule limit reached (2 attempts per round per PRD SCH-05). Please contact Talent HR.',
      );
    }

    final updated = existing.copyWith(
      scheduledAt: newDateTime,
      status: InterviewStatus.rescheduled,
      reschedulesLeft: existing.reschedulesLeft - 1,
    );

    _interviews[index] = updated;
    return updated;
  }

  @override
  Future<List<ExpertBooking>> getExpertBookings() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_expertBookings);
  }

  @override
  Future<Map<String, dynamic>> checkExpertConflict({
    required String expertId,
    required String targetCompany,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final mentors = await getMentors();
    final expert = mentors.firstWhere(
      (m) => m.id == expertId,
      orElse: () => mentors.first,
    );

    final normalizedTarget = targetCompany.toLowerCase().trim();
    final normalizedExpertCompany = expert.company.toLowerCase().trim();

    if (normalizedTarget.isNotEmpty &&
        (normalizedExpertCompany.contains(normalizedTarget) ||
            normalizedTarget.contains(normalizedExpertCompany))) {
      return {
        'hasConflict': true,
        'conflictReason':
            'Active Conflict of Interest (BR-07 / EXP-07): ${expert.name} is currently an active, verified employee at ${expert.company}. Under platform fair-hiring rules, experts cannot provide paid coaching for hiring loops at their active employer.',
      };
    }

    return {'hasConflict': false, 'conflictReason': null};
  }

  @override
  Future<ExpertBooking> bookExpertSession({
    required String expertId,
    required DateTime scheduledAt,
    required int durationMinutes,
    required String topic,
    bool consentForRecording = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final mentors = await getMentors();
    final expert = mentors.firstWhere(
      (m) => m.id == expertId,
      orElse: () => mentors.first,
    );

    // Compute escrow & RBI compliance commission split
    final baseRate = expert.hourlyRateInr;
    final commission = (baseRate * 0.20).round(); // 20% baseline platform commission (BR-05 / BRD §7)
    final payout = baseRate - commission; // 80% expert payout

    final booking = ExpertBooking(
      id: 'exp_book_${DateTime.now().millisecondsSinceEpoch}',
      expertId: expert.id,
      expertName: expert.name,
      expertRole: expert.role,
      expertCompany: expert.company,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      sessionRateInr: baseRate,
      platformCommissionInr: commission,
      expertPayoutInr: payout,
      status: ExpertBookingStatus.confirmed,
      sessionTopic: topic,
      hasDualConsentForRecording: consentForRecording,
    );

    _expertBookings.insert(0, booking);
    return booking;
  }

  @override
  Future<List<String>> generateMockInterviewQuestions({
    required String role,
    required List<String> focusSkills,
    required String stage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      'In a high-throughput mobile application, how do you handle state re-computation and cache invalidation across distributed async providers?',
      'Describe how you would design an offline-first sync mechanism that guarantees zero data loss during network disruptions and avoids duplicate writes.',
      'How does certificate pinning protect against Man-in-the-Middle (MitM) attacks, and what zero-downtime rotation strategy would you deploy when certificates approach expiry (RFC 7469)?',
      'Explain how you profile and eliminate frame drops (jank) in Flutter widget render pipelines with complex nested lists and animations.',
      'Walk through how you would architect an idempotent interview slot reservation flow using distributed Redis locks to prevent double-booking race conditions.',
    ];
  }

  @override
  Future<Map<String, dynamic>> evaluateMockAnswer({
    required String question,
    required String candidateAnswer,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final trimmed = candidateAnswer.trim();
    if (trimmed.length < 20) {
      return {
        'score': 5.0,
        'rating': 'Needs Elaboration',
        'critique':
            'The answer is too brief. Try using the STAR methodology (Situation, Task, Action, Result) with concrete architectural trade-offs.',
        'keyStrengths': ['Direct answer to prompt'],
        'recommendedAdditions': [
          'Mention edge cases and failure modes',
          'Discuss performance implications and telemetry',
        ],
      };
    }

    return {
      'score': 8.5,
      'rating': 'Strong Technical Depth',
      'critique':
          'Clear conceptual structure and good engineering trade-off rationale. Highlighted resilience, decoupled state handling, and production failure recovery.',
      'keyStrengths': [
        'Demonstrates clean separation of concerns',
        'Accounts for async race conditions and idempotency',
      ],
      'recommendedAdditions': [
        'Mention automated widget/integration regression testing strategies',
        'Discuss telemetry metrics (P99 latency, crash-free rates)',
      ],
    };
  }
}
