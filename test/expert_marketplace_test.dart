import 'package:flutter_test/flutter_test.dart';
import 'package:hr_connect_pro/features/candidate_flow/data/candidate_repository.dart';
import 'package:hr_connect_pro/features/candidate_flow/domain/models/expert_booking.dart';

void main() {
  group('Expert Marketplace & Escrow Policy Tests', () {
    late CandidateRepository repository;

    setUp(() {
      repository = MockCandidateRepository();
    });

    test('getExpertBookings returns initial confirmed booking', () async {
      final bookings = await repository.getExpertBookings();
      expect(bookings, isNotEmpty);
      expect(bookings.first.status, equals(ExpertBookingStatus.confirmed));
    });

    test('checkExpertConflict flags conflict when candidate has target interview at same company (EXP-07)', () async {
      final conflictCheck = await repository.checkExpertConflict(
        expertId: 'men_01', // Kavita Menon at Google
        targetCompany: 'Google India',
      );
      expect(conflictCheck['hasConflict'], isTrue);
      expect(conflictCheck['conflictReason'], isNotNull);
      expect(conflictCheck['conflictReason'], contains('Conflict of Interest'));

      final safeCheck = await repository.checkExpertConflict(
        expertId: 'men_01',
        targetCompany: 'Razorpay Software',
      );
      expect(safeCheck['hasConflict'], isFalse);
      expect(safeCheck['conflictReason'], isNull);
    });

    test(
      'Expert booking enforces 20% platform fee and 80% payout split',
      () async {
        final scheduledTime = DateTime.now().add(
          const Duration(days: 3, hours: 10),
        );

        final booking = await repository.bookExpertSession(
          expertId: 'men_01', // 1500 INR/hr
          scheduledAt: scheduledTime,
          durationMinutes: 45,
          topic: 'System Architecture & Concurrency',
          consentForRecording: true,
        );

        expect(booking.sessionRateInr, equals(1500));
        expect(booking.platformCommissionInr, equals(300)); // 20% of 1500
        expect(booking.expertPayoutInr, equals(1200)); // 80% of 1500
        expect(booking.status, equals(ExpertBookingStatus.confirmed));
        expect(booking.hasDualConsentForRecording, isTrue);
      },
    );
  });
}
