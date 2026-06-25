import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/glass_card.dart';
import 'training_detail_screen.dart';

class AgentTrainingTab extends StatelessWidget {
  const AgentTrainingTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;

    final courses = [
      _CourseItem(
        title: 'Platform Onboarding 101',
        category: 'Getting Started',
        duration: '12 mins',
        progress: 1.0,
        icon: Icons.play_circle_fill,
      ),
      _CourseItem(
        title: 'Mastering IT & BPO Referrals',
        category: 'Advanced Sales',
        duration: '45 mins',
        progress: 0.45,
        icon: Icons.video_library,
      ),
      _CourseItem(
        title: 'KYC & Banking Compliance Policies',
        category: 'Legal',
        duration: '18 mins',
        progress: 0.9,
        icon: Icons.policy,
      ),
      _CourseItem(
        title: 'Growing Your Level-2 Indirect Network',
        category: 'Referral Marketing',
        duration: '30 mins',
        progress: 0.0,
        icon: Icons.group_work,
      ),
    ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, idx) {
        final course = courses[idx];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TrainingDetailScreen(
                  title: course.title,
                  category: course.category,
                  duration: course.duration,
                  progress: course.progress,
                  icon: course.icon,
                ),
              ),
            );
          },
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A3B6E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(course.icon, color: const Color(0xFFFFC107), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFC107),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        course.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Duration: ${course.duration}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: course.progress,
                                minHeight: 4,
                                backgroundColor: Colors.grey.withOpacity(0.15),
                                color: const Color(0xFFFFC107),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${(course.progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFFFC107)),
              ],
            ),
          ),
        ).marginOnly(bottom: 12);
      },
    );
  }
}

class _CourseItem {
  final String title;
  final String category;
  final String duration;
  final double progress;
  final IconData icon;

  _CourseItem({
    required this.title,
    required this.category,
    required this.duration,
    required this.progress,
    required this.icon,
  });
}
