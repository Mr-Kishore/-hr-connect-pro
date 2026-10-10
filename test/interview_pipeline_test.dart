import 'package:flutter_test/flutter_test.dart';
import 'package:hr_connect_pro/core/errors/app_exception.dart';
import 'package:hr_connect_pro/features/candidate_flow/data/candidate_repository.dart';
import 'package:hr_connect_pro/features/candidate_flow/domain/models/interview_booking.dart';

void main() {
  group('CandidateRepository - Self-Booking & Pipeline Tests', () {
    late CandidateRepository repository;

    setUp(() {
      repository = MockCandidateRepository();
    });

    test('getInterviews returns initial active and completed interviews', () async {
      final interviews = await repository.getInterviews();
      expect(interviews, isNotEmpty);
      expect(interviews.any((i) => i.status == InterviewStatus.scheduled), isTrue);
      expect(interviews.any((i) => i.status == InterviewStatus.completed), isTrue);
    });

    test('bookInterviewSlot successfully creates booking and prevents slot conflict', () async {
      final slotTime = DateTime.now().add(const Duration(days: 5, hours: 14));

      // First booking succeeds
      final booking = await repository.bookInterviewSlot(
        jobId: 'job_01',
        slotId: 'slot_fin_01',
        scheduledAt: slotTime,
      );

      expect(booking.id, startsWith('int_'));
      expect(booking.jobId, equals('job_01'));
      expect(booking.company, isNotEmpty);
      expect(booking.stage, isNotEmpty);
      expect(booking.status, equals(InterviewStatus.scheduled));
      expect(booking.reschedulesLeft, equals(2));

      // Attempting to book a conflicting slot at the same hour should throw SlotConflictException
      expect(
        () => repository.bookInterviewSlot(
          jobId: 'job_02',
          slotId: 'slot_health_01',
          scheduledAt: slotTime,
        ),
        throwsA(isA<SlotConflictException>()),
      );
    });

    test('rescheduleInterview enforces PRD SCH-05 max 2 reschedules rule', () async {
      final interviews = await repository.getInterviews();
      final target = interviews.firstWhere((i) => i.status == InterviewStatus.scheduled);
      expect(target.reschedulesLeft, equals(2));

      final newTime1 = DateTime.now().add(const Duration(days: 3));
      final updated1 = await repository.rescheduleInterview(
        interviewId: target.id,
        newDateTime: newTime1,
        reason: 'Client conflict',
      );
      expect(updated1.reschedulesLeft, equals(1));
      expect(updated1.status, equals(InterviewStatus.rescheduled));

      final newTime2 = DateTime.now().add(const Duration(days: 4));
      final updated2 = await repository.rescheduleInterview(
        interviewId: target.id,
        newDateTime: newTime2,
        reason: 'Personal emergency',
      );
      expect(updated2.reschedulesLeft, equals(0));

      // Third reschedule must be blocked per PRD SCH-05
      final newTime3 = DateTime.now().add(const Duration(days: 5));
      expect(
        () => repository.rescheduleInterview(
          interviewId: target.id,
          newDateTime: newTime3,
          reason: 'Another change',
        ),
        throwsA(
          predicate((e) =>
              e is ValidationException &&
              e.message.contains('Maximum reschedule limit reached')),
        ),
      );
    });

    test('Scorecard verification contains granular competency breakdown', () async {
      final interviews = await repository.getInterviews();
      final completed = interviews.firstWhere((i) => i.scorecard != null);

      expect(completed.scorecard, isNotNull);
      final scorecard = completed.scorecard!;
      expect(scorecard.overallRating, inInclusiveRange(1, 5));
      expect(scorecard.competencyScores, isNotEmpty);
      expect(scorecard.recommendation, isNotEmpty);
      expect(scorecard.strengths, isNotEmpty);
      expect(scorecard.areasToImprove, isNotEmpty);
    });
  });
}
