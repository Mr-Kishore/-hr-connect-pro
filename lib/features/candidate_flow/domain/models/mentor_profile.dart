class MentorProfile {
  final String id;
  final String name;
  final String role;
  final String company;
  final int experienceYears;
  final double rating;
  final int totalMentees;
  final int hourlyRateInr;
  final List<String> expertise;
  final bool isAvailableNow;

  const MentorProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.company,
    required this.experienceYears,
    required this.rating,
    required this.totalMentees,
    required this.hourlyRateInr,
    required this.expertise,
    this.isAvailableNow = true,
  });
}
