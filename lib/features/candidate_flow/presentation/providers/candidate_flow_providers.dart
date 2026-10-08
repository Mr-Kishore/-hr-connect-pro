import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/candidate_repository.dart';
import '../../domain/models/candidate_profile.dart';
import '../../domain/models/job_opportunity.dart';
import '../../domain/models/recommended_course.dart';
import '../../domain/models/mentor_profile.dart';
import '../../domain/models/chat_message.dart';

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

final candidateProfileProvider = NotifierProvider<CandidateProfileNotifier, CandidateProfile?>(() {
  return CandidateProfileNotifier();
});

final matchedJobsProvider = FutureProvider<List<JobOpportunity>>((ref) async {
  final repo = ref.read(candidateRepositoryProvider);
  return await repo.getMatchedJobs();
});

final recommendedCoursesProvider = FutureProvider<List<RecommendedCourse>>((ref) async {
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
      'men_01': repo.getChatHistory('men_01'),
    };
  }

  Future<void> sendMessage(String mentorId, String text) async {
    if (text.trim().isEmpty) return;
    final repo = ref.read(candidateRepositoryProvider);
    final newMsg = await repo.sendChatMessage(mentorId: mentorId, text: text.trim());
    final current = state[mentorId] ?? repo.getChatHistory(mentorId);
    state = {
      ...state,
      mentorId: [...current, newMsg],
    };
  }
}

final chatStateProvider = NotifierProvider<ChatStateNotifier, Map<String, List<ChatMessage>>>(() {
  return ChatStateNotifier();
});
