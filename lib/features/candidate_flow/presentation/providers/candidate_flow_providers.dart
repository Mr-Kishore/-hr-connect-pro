import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/candidate_repository.dart';
import '../../domain/models/candidate_profile.dart';
import '../../domain/models/job_opportunity.dart';
import '../../domain/models/recommended_course.dart';
import '../../domain/models/mentor_profile.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/interview_booking.dart';
import '../../domain/models/expert_booking.dart';

final candidateRepositoryProvider = Provider<CandidateRepository>((ref) {
  return MockCandidateRepository();
});

class CandidateProfileNotifier extends Notifier<CandidateProfile?> {
  @override
  CandidateProfile? build() {
    return null;
  }

  Future<bool> checkUserExists(String phone) async {
    final repo = ref.read(candidateRepositoryProvider);
    return await repo.checkUserExists(phone);
  }

  Future<CandidateProfile> loginOrRegister(String phone, String otp) async {
    final repo = ref.read(candidateRepositoryProvider);
    final profile = await repo.loginOrRegister(phone, otp);
    state = profile;
    return profile;
  }

  Future<void> parseResume({required String fileName}) async {
    final repo = ref.read(candidateRepositoryProvider);
    final updated = await repo.parseResume(fileName: fileName);
    state = updated;
  }

  Future<void> updateRoleIntent({
    required String currentRole,
    required String targetRole,
  }) async {
    final repo = ref.read(candidateRepositoryProvider);
    final updated = await repo.updateRoleIntent(
      currentRole: currentRole,
      targetRole: targetRole,
    );
    state = updated;
  }
}

final candidateProfileProvider =
    NotifierProvider<CandidateProfileNotifier, CandidateProfile?>(() {
      return CandidateProfileNotifier();
    });

final matchedJobsProvider = FutureProvider<List<JobOpportunity>>((ref) async {
  final repo = ref.read(candidateRepositoryProvider);
  return await repo.getMatchedJobs();
});

final recommendedCoursesProvider = FutureProvider<List<RecommendedCourse>>((
  ref,
) async {
  final repo = ref.read(candidateRepositoryProvider);
  return await repo.getRecommendedCourses();
});

final mentorsProvider = FutureProvider<List<MentorProfile>>((ref) async {
  final repo = ref.read(candidateRepositoryProvider);
  return await repo.getMentors();
});

class ChatStateNotifier extends Notifier<Map<String, List<ChatMessage>>> {
  @override
  Map<String, List<ChatMessage>> build() {
    final repo = ref.read(candidateRepositoryProvider);
    return {
      'men_01': List<ChatMessage>.unmodifiable(repo.getChatHistory('men_01')),
    };
  }

  Future<void> sendMessage(String mentorId, String text) async {
    if (text.trim().isEmpty) return;
    final repo = ref.read(candidateRepositoryProvider);
    await repo.sendChatMessage(mentorId: mentorId, text: text.trim());
    state = {
      ...state,
      mentorId: List<ChatMessage>.unmodifiable(repo.getChatHistory(mentorId)),
    };
  }
}

final chatStateProvider =
    NotifierProvider<ChatStateNotifier, Map<String, List<ChatMessage>>>(() {
      return ChatStateNotifier();
    });

// Interviews Pipeline Provider
class InterviewsNotifier extends AsyncNotifier<List<InterviewBooking>> {
  @override
  Future<List<InterviewBooking>> build() async {
    final repo = ref.read(candidateRepositoryProvider);
    return await repo.getInterviews();
  }

  Future<InterviewBooking> bookSlot({
    required String jobId,
    required String slotId,
    required DateTime scheduledAt,
  }) async {
    final repo = ref.read(candidateRepositoryProvider);
    final booking = await repo.bookInterviewSlot(
      jobId: jobId,
      slotId: slotId,
      scheduledAt: scheduledAt,
    );
    state = AsyncData(await repo.getInterviews());
    return booking;
  }

  Future<InterviewBooking> reschedule({
    required String interviewId,
    required DateTime newDateTime,
    required String reason,
  }) async {
    final repo = ref.read(candidateRepositoryProvider);
    final updated = await repo.rescheduleInterview(
      interviewId: interviewId,
      newDateTime: newDateTime,
      reason: reason,
    );
    state = AsyncData(await repo.getInterviews());
    return updated;
  }
}

final interviewsProvider =
    AsyncNotifierProvider<InterviewsNotifier, List<InterviewBooking>>(() {
      return InterviewsNotifier();
    });

// Expert Marketplace Bookings Provider
class ExpertBookingsNotifier extends AsyncNotifier<List<ExpertBooking>> {
  @override
  Future<List<ExpertBooking>> build() async {
    final repo = ref.read(candidateRepositoryProvider);
    return await repo.getExpertBookings();
  }

  Future<ExpertBooking> bookSession({
    required String expertId,
    required DateTime scheduledAt,
    required int durationMinutes,
    required String topic,
    bool consentForRecording = false,
  }) async {
    final repo = ref.read(candidateRepositoryProvider);
    final booking = await repo.bookExpertSession(
      expertId: expertId,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      topic: topic,
      consentForRecording: consentForRecording,
    );
    state = AsyncData(await repo.getExpertBookings());
    return booking;
  }
}

final expertBookingsProvider =
    AsyncNotifierProvider<ExpertBookingsNotifier, List<ExpertBooking>>(() {
      return ExpertBookingsNotifier();
    });

// Bookmarked / Saved Jobs State
class BookmarkedJobsNotifier extends Notifier<Set<String>> {
  static const String _storageKey = 'bookmarked_job_ids';

  @override
  Set<String> build() {
    loadFromStorage();
    return const {};
  }

  Future<Set<String>> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_storageKey);
      if (list != null && list.isNotEmpty) {
        state = list.toSet();
      }
    } catch (_) {}
    return state;
  }

  Future<void> toggleBookmark(String jobId) async {
    final next = Set<String>.from(state);
    if (next.contains(jobId)) {
      next.remove(jobId);
    } else {
      next.add(jobId);
    }
    state = Set.unmodifiable(next);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, next.toList());
    } catch (_) {}
  }

  bool isBookmarked(String jobId) => state.contains(jobId);
}

final bookmarkedJobsProvider =
    NotifierProvider<BookmarkedJobsNotifier, Set<String>>(() {
      return BookmarkedJobsNotifier();
    });

// Jobs Search & Filter State
class JobFilterState {
  final String searchQuery;
  final bool onlyInstantInterview;
  final bool onlyHighMatch;
  final bool onlyBookmarked;

  const JobFilterState({
    this.searchQuery = '',
    this.onlyInstantInterview = false,
    this.onlyHighMatch = false,
    this.onlyBookmarked = false,
  });

  JobFilterState copyWith({
    String? searchQuery,
    bool? onlyInstantInterview,
    bool? onlyHighMatch,
    bool? onlyBookmarked,
  }) {
    return JobFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      onlyInstantInterview: onlyInstantInterview ?? this.onlyInstantInterview,
      onlyHighMatch: onlyHighMatch ?? this.onlyHighMatch,
      onlyBookmarked: onlyBookmarked ?? this.onlyBookmarked,
    );
  }
}

class JobFilterNotifier extends Notifier<JobFilterState> {
  @override
  JobFilterState build() => const JobFilterState();

  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);
  void toggleInstantInterview() =>
      state = state.copyWith(onlyInstantInterview: !state.onlyInstantInterview);
  void toggleHighMatch() =>
      state = state.copyWith(onlyHighMatch: !state.onlyHighMatch);
  void toggleBookmarked() =>
      state = state.copyWith(onlyBookmarked: !state.onlyBookmarked);
  void reset() => state = const JobFilterState();
}

final jobFilterProvider = NotifierProvider<JobFilterNotifier, JobFilterState>(
  () => JobFilterNotifier(),
);

final filteredJobsProvider = Provider<AsyncValue<List<JobOpportunity>>>((ref) {
  final jobsAsync = ref.watch(matchedJobsProvider);
  final filter = ref.watch(jobFilterProvider);
  final bookmarkedIds = ref.watch(bookmarkedJobsProvider);

  return jobsAsync.whenData((jobs) {
    return jobs.where((job) {
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase();
        final match =
            job.title.toLowerCase().contains(query) ||
            job.company.toLowerCase().contains(query) ||
            job.matchedSkills.any((s) => s.toLowerCase().contains(query));
        if (!match) return false;
      }
      if (filter.onlyInstantInterview && !job.hasInstantInterview) {
        return false;
      }
      if (filter.onlyHighMatch && job.fitScore < 80) {
        return false;
      }
      if (filter.onlyBookmarked && !bookmarkedIds.contains(job.id)) {
        return false;
      }
      return true;
    }).toList();
  });
});

// DPDP Act 2023 Consent Management State
class DpdpConsentState {
  final bool aiResumeProcessing;
  final bool recruiterDiscovery;
  final bool sessionDualRecording;
  final bool autoSkillBenchmarking;

  const DpdpConsentState({
    this.aiResumeProcessing = true,
    this.recruiterDiscovery = true,
    this.sessionDualRecording = false,
    this.autoSkillBenchmarking = true,
  });

  DpdpConsentState copyWith({
    bool? aiResumeProcessing,
    bool? recruiterDiscovery,
    bool? sessionDualRecording,
    bool? autoSkillBenchmarking,
  }) {
    return DpdpConsentState(
      aiResumeProcessing: aiResumeProcessing ?? this.aiResumeProcessing,
      recruiterDiscovery: recruiterDiscovery ?? this.recruiterDiscovery,
      sessionDualRecording: sessionDualRecording ?? this.sessionDualRecording,
      autoSkillBenchmarking:
          autoSkillBenchmarking ?? this.autoSkillBenchmarking,
    );
  }
}

class DpdpConsentNotifier extends Notifier<DpdpConsentState> {
  @override
  DpdpConsentState build() => const DpdpConsentState();

  void toggleAiResume() =>
      state = state.copyWith(aiResumeProcessing: !state.aiResumeProcessing);
  void toggleRecruiterDiscovery() =>
      state = state.copyWith(recruiterDiscovery: !state.recruiterDiscovery);
  void toggleSessionRecording() =>
      state = state.copyWith(sessionDualRecording: !state.sessionDualRecording);
  void toggleSkillBenchmarking() => state = state.copyWith(
    autoSkillBenchmarking: !state.autoSkillBenchmarking,
  );
}

final dpdpConsentProvider =
    NotifierProvider<DpdpConsentNotifier, DpdpConsentState>(
      () => DpdpConsentNotifier(),
    );
