import 'package:flutter_test/flutter_test.dart';
import 'package:hr_connect_pro/features/candidate_flow/data/candidate_repository.dart';

void main() {
  group('Flow 1: Candidate Flow & Security Unit Tests', () {
    late MockCandidateRepository repository;

    setUp(() {
      repository = MockCandidateRepository();
    });

    test('CF-1: Deduplication detects existing candidate vs new registration', () async {
      final exists = await repository.checkUserExists('+919876543210');
      expect(exists, isTrue, reason: 'Registered user must be identified to prevent duplicates');

      final isNew = await repository.checkUserExists('+919111122223');
      expect(isNew, isFalse, reason: 'Unregistered user must be flagged as new registration');
    });

    test('CF-2: Resume parser applies Endowed Progress jump and extracts competencies', () async {
      final profile = await repository.parseResume(fileName: 'Aditya_Resume.pdf');

      expect(profile.extractedSkills, isNotEmpty);
      expect(profile.extractedSkills.contains('Flutter'), isTrue);
      expect(profile.extractedSkills.contains('Dart'), isTrue);
      expect(profile.readinessScore, equals(45), reason: 'Endowed progress leaps to 45% on resume upload');
    });

    test('CF-3: Role intent updates trajectory and elevates readiness score', () async {
      final updated = await repository.updateRoleIntent(
        currentRole: 'Junior Mobile Developer',
        targetRole: 'Senior Flutter Engineer',
      );

      expect(updated.currentRole, 'Junior Mobile Developer');
      expect(updated.targetRole, 'Senior Flutter Engineer');
      expect(updated.readinessScore, equals(78));
      expect(updated.onboardingCompleted, isTrue);
    });

    test('CF-4: Disintermediation defense automatically redacts phone numbers in chat', () async {
      const leakAttempt = 'Connect with me directly at +91 9876543210 to book off-platform';
      final message = await repository.sendChatMessage(
        mentorId: 'men_01',
        text: leakAttempt,
      );

      expect(message.isRedacted, isTrue);
      expect(message.text.contains('9876543210'), isFalse);
      expect(message.text.contains('[Phone Number Redacted]'), isTrue);
      expect(message.safetyNotice, isNotNull);
    });

    test('CF-5: Disintermediation defense automatically redacts emails and links in chat', () async {
      const emailAttempt = 'Send payment receipt to mentor.kavita@google.com or check linkedin.com/in/kavita';
      final message = await repository.sendChatMessage(
        mentorId: 'men_01',
        text: emailAttempt,
      );

      expect(message.isRedacted, isTrue);
      expect(message.text.contains('mentor.kavita@google.com'), isFalse);
      expect(message.text.contains('[Email Redacted]'), isTrue);
      expect(message.text.contains('[External Link Redacted]'), isTrue);
    });

    test('CF-6: Normal compliant technical chat passes through without redaction', () async {
      const compliantMsg = 'What design pattern do you recommend for offline data sync in Riverpod?';
      final message = await repository.sendChatMessage(
        mentorId: 'men_01',
        text: compliantMsg,
      );

      expect(message.isRedacted, isFalse);
      expect(message.text, equals(compliantMsg));
      expect(message.safetyNotice, isNull);
    });

    test('CF-7: Matched jobs deliver explainable skills breakdown', () async {
      final jobs = await repository.getMatchedJobs();

      expect(jobs, isNotEmpty);
      for (final job in jobs) {
        expect(job.matchedSkills, isNotEmpty);
        expect(job.missingSkills, isNotEmpty);
        expect(job.fitScore, greaterThan(70));
      }
    });
  });
}
