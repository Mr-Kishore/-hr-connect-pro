class CandidateProfile {
  final String id;
  final String phone;
  final String name;
  final String? currentRole;
  final String? targetRole;
  final List<String> extractedSkills;
  final int readinessScore;
  final String? resumeFileName;
  final bool onboardingCompleted;

  const CandidateProfile({
    required this.id,
    required this.phone,
    required this.name,
    this.currentRole,
    this.targetRole,
    this.extractedSkills = const [],
    this.readinessScore = 0,
    this.resumeFileName,
    this.onboardingCompleted = false,
  });

  CandidateProfile copyWith({
    String? id,
    String? phone,
    String? name,
    String? currentRole,
    String? targetRole,
    List<String>? extractedSkills,
    int? readinessScore,
    String? resumeFileName,
    bool? onboardingCompleted,
  }) {
    return CandidateProfile(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      currentRole: currentRole ?? this.currentRole,
      targetRole: targetRole ?? this.targetRole,
      extractedSkills: extractedSkills ?? this.extractedSkills,
      readinessScore: readinessScore ?? this.readinessScore,
      resumeFileName: resumeFileName ?? this.resumeFileName,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
