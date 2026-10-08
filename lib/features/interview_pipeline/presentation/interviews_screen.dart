import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class InterviewsScreen extends StatelessWidget {
  const InterviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Scheduled Interviews'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
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
                        'Fintech Innovations',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Round: L1 Technical',
                          style: TextStyle(color: AppColors.info, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Scheduled: Oct 12, 2026 at 10:00 AM IST'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Reschedule (1 of 2 left)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Join Room'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
