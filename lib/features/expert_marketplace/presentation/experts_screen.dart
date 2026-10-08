import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class ExpertsScreen extends StatelessWidget {
  const ExpertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Advisory Experts'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildExpertCard(
            name: 'Priya Sundaram',
            title: 'Lead Architect @ Global Cloud',
            experienceYears: 12,
            domains: ['Flutter', 'Microservices', 'System Design'],
            ratePerHour: 2499,
            rating: 4.9,
          ),
          const SizedBox(height: 12),
          _buildExpertCard(
            name: 'Rahul Verma',
            title: 'Engineering Director @ SaaS Unicorn',
            experienceYears: 15,
            domains: ['Tech Leadership', 'Mock Interviews', 'Negotiation'],
            ratePerHour: 3499,
            rating: 5.0,
          ),
        ],
      ),
    );
  }

  Widget _buildExpertCard({
    required String name,
    required String title,
    required int experienceYears,
    required List<String> domains,
    required int ratePerHour,
    required double rating,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(name[0], style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(title, style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.warning, size: 16),
                    const SizedBox(width: 4),
                    Text('$rating', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: domains.map((d) => Chip(
                label: Text(d),
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₹$ratePerHour / session', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Book 1:1 Consultation'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
