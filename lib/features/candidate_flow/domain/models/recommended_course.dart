class RecommendedCourse {
  final String id;
  final String title;
  final String provider; // e.g. 'Coursera', 'Udemy', 'edX'
  final String duration;
  final double rating;
  final String skillTarget;
  final String externalUrl;
  final String level; // 'Intermediate', 'Advanced', etc.

  const RecommendedCourse({
    required this.id,
    required this.title,
    required this.provider,
    required this.duration,
    required this.rating,
    required this.skillTarget,
    required this.externalUrl,
    required this.level,
  });
}
