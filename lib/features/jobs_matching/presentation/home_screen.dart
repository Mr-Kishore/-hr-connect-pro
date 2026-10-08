import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/route_constants.dart';
import '../../../app/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HR Connect Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology_outlined),
            tooltip: 'AI Career Coach',
            onPressed: () => context.push(RouteConstants.aiCareerCoach),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Status Card
            Card(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Target Roles & Status',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ready for Interviews',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Profile Complete: 85%',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Self-Booking Active',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recommended Job Matches',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.go(RouteConstants.jobs),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Preview Job Match Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Senior Flutter Developer',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '92% Match',
                            style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Fintech Innovations • Bangalore / Hybrid', style: TextStyle(color: AppColors.textSecondaryLight)),
                    const SizedBox(height: 12),
                    const Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Chip(label: Text('Flutter'), visualDensity: VisualDensity.compact),
                        Chip(label: Text('Dart'), visualDensity: VisualDensity.compact),
                        Chip(label: Text('Clean Architecture'), visualDensity: VisualDensity.compact),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.go(RouteConstants.jobs),
                      child: const Text('Schedule Interview (8 Slots Available)'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
