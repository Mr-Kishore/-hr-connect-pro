import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matched Jobs'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildJobCard(
            title: 'Senior Flutter Developer',
            company: 'Fintech Innovations',
            location: 'Bangalore / Hybrid',
            matchScore: 92,
            matchedSkills: ['Flutter', 'Dart', 'REST APIs'],
            missingSkills: ['GraphQL'],
            slotsAvailable: 8,
          ),
          const SizedBox(height: 12),
          _buildJobCard(
            title: 'Mobile Architecture Specialist',
            company: 'HealthCloud Systems',
            location: 'Remote',
            matchScore: 88,
            matchedSkills: ['Clean Architecture', 'Dart', 'CI/CD'],
            missingSkills: ['Kotlin Native'],
            slotsAvailable: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard({
    required String title,
    required String company,
    required String location,
    required int matchScore,
    required List<String> matchedSkills,
    required List<String> missingSkills,
    required int slotsAvailable,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$matchScore% Match',
                    style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('$company • $location', style: const TextStyle(color: AppColors.textSecondaryLight)),
            const SizedBox(height: 12),
            const Text('Matched Skills:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: matchedSkills.map((s) => Chip(
                avatar: const Icon(Icons.check, size: 14, color: AppColors.accent),
                label: Text(s),
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
            const SizedBox(height: 6),
            const Text('Identified Skill Gaps:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: missingSkills.map((s) => Chip(
                avatar: const Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                label: Text(s),
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              child: Text('Book Interview ($slotsAvailable Slots Open)'),
            ),
          ],
        ),
      ),
    );
  }
}
