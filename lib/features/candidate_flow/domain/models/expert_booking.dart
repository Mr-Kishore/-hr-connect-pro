enum ExpertBookingStatus { confirmed, completed, cancelled }

class ExpertBooking {
  final String id;
  final String expertId;
  final String expertName;
  final String expertRole;
  final String expertCompany;
  final DateTime scheduledAt;
  final int durationMinutes;
  final int sessionRateInr;
  final int platformCommissionInr; // 20%
  final int expertPayoutInr; // 80%
  final ExpertBookingStatus status;
  final String sessionTopic;
  final bool hasDualConsentForRecording;

  const ExpertBooking({
    required this.id,
    required this.expertId,
    required this.expertName,
    required this.expertRole,
    required this.expertCompany,
    required this.scheduledAt,
    this.durationMinutes = 45,
    required this.sessionRateInr,
    required this.platformCommissionInr,
    required this.expertPayoutInr,
    this.status = ExpertBookingStatus.confirmed,
    this.sessionTopic = '1:1 Architecture & Technical Mock Prep',
    this.hasDualConsentForRecording = false,
  });

  ExpertBooking copyWith({
    String? id,
    String? expertId,
    String? expertName,
    String? expertRole,
    String? expertCompany,
    DateTime? scheduledAt,
    int? durationMinutes,
    int? sessionRateInr,
    int? platformCommissionInr,
    int? expertPayoutInr,
    ExpertBookingStatus? status,
    String? sessionTopic,
    bool? hasDualConsentForRecording,
  }) {
    return ExpertBooking(
      id: id ?? this.id,
      expertId: expertId ?? this.expertId,
      expertName: expertName ?? this.expertName,
      expertRole: expertRole ?? this.expertRole,
      expertCompany: expertCompany ?? this.expertCompany,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      sessionRateInr: sessionRateInr ?? this.sessionRateInr,
      platformCommissionInr:
          platformCommissionInr ?? this.platformCommissionInr,
      expertPayoutInr: expertPayoutInr ?? this.expertPayoutInr,
      status: status ?? this.status,
      sessionTopic: sessionTopic ?? this.sessionTopic,
      hasDualConsentForRecording:
          hasDualConsentForRecording ?? this.hasDualConsentForRecording,
    );
  }
}
