import 'dart:async';

import '../domain/models/candidate_profile.dart';
import '../domain/models/job_opportunity.dart';
import '../domain/models/recommended_course.dart';
import '../domain/models/mentor_profile.dart';
import '../domain/models/chat_message.dart';

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

  MockCandidateRepository() {
    _initializeDefaultChats();
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
    return const [
      JobOpportunity(
        id: 'job_01',
        title: 'Senior Flutter Engineer',
        company: 'Razorpay',
        location: 'Bengaluru (Hybrid)',
        salaryRange: '₹22 - 30 LPA',
        fitScore: 84,
        matchedSkills: [
          'Flutter',
          'Dart',
          'State Management',
          'Clean Architecture',
        ],
        missingSkills: ['GraphQL', 'CI/CD Pipelines'],
        description: 'Lead mobile development for high-throughput payment SDKs and checkout flows.',
        portalUrl: 'https://razorpay.com/careers/mobile-lead',
        isDirectApply: true,
        postedAgo: 'Just now',
      ),
      JobOpportunity(
        id: 'job_02',
        title: 'Lead Mobile Developer',
        company: 'Flipkart',
        location: 'Bengaluru (On-site)',
        salaryRange: '₹28 - 38 LPA',
        fitScore: 79,
        matchedSkills: ['Flutter', 'RESTful APIs', 'Git', 'Clean Architecture'],
        missingSkills: [
          'Automated Testing (Widget/Integration)',
          'Kotlin Native Interop',
        ],
        description: 'Architect customer-facing catalog experiences with fluid 60fps micro-animations.',
        portalUrl: 'https://flipkartcareers.com/job/lead-mobile',
        isDirectApply: false,
        postedAgo: '1 day ago',
      ),
      JobOpportunity(
        id: 'job_03',
        title: 'Mobile SDE-2',
        company: 'Zomato',
        location: 'Gurugram / Remote',
        salaryRange: '₹18 - 25 LPA',
        fitScore: 92,
        matchedSkills: ['Flutter', 'Dart', 'Riverpod', 'RESTful APIs', 'Git'],
        missingSkills: ['WebSocket Streaming'],
        description: 'Build real-time tracking interfaces and quick commerce dispatch workflows.',
        portalUrl: 'https://zomato.com/careers/sde2-flutter',
        isDirectApply: true,
        postedAgo: '3 days ago',
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
}
