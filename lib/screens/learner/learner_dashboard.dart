import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/app_colors.dart';
import '../../components/ui_components.dart';
import '../../controllers/learner/learner_home_controller.dart';

class LearnerDashboard extends StatelessWidget {
  const LearnerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LearnerHomeController());
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.accent.withOpacity(0.03),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refreshData,
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(context, controller),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeSection(controller),
                          const SizedBox(height: 24),
                          _buildQuickStats(controller),
                          const SizedBox(height: 24),
                          _buildActiveCoursesSection(controller),
                          const SizedBox(height: 24),
                          _buildLearningProgress(controller),
                          const SizedBox(height: 24),
                          _buildRecentActivities(controller),
                          const SizedBox(height: 24),
                          _buildUpcomingEvents(controller),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.viewAllCourses(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.explore, color: Colors.white),
        label: Text(
          'Explore',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, LearnerHomeController controller) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: FlexibleSpaceBar(
          title: Text(
            'Brain Nest',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
          titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => controller.viewProfile(),
          icon: const Icon(Icons.account_circle, color: Colors.white),
        ),
        IconButton(
          onPressed: () => controller.viewSettings(),
          icon: const Icon(Icons.settings, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(LearnerHomeController controller) {
    final profile = controller.learnerProfile.value;
    
    return GradientCard(
      colors: [
        AppColors.accent.withOpacity(0.1),
        AppColors.primary.withOpacity(0.05),
      ],
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            child: Text(
              (profile['name'] ?? 'L').toString().substring(0, 1).toUpperCase(),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${profile['name'] ?? 'Learner'}!',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ready to continue your learning journey?',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.psychology,
              color: AppColors.accent,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(LearnerHomeController controller) {
    final stats = controller.learningStats.value;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Progress',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            StatisticCard(
              title: 'Courses Completed',
              value: '${stats['coursesCompleted'] ?? 0}',
              icon: Icons.school,
              iconColor: AppColors.primary,
              trend: '+2',
              isPositiveTrend: true,
            ),
            StatisticCard(
              title: 'Learning Hours',
              value: '${stats['totalHours'] ?? 0}h',
              icon: Icons.access_time,
              iconColor: AppColors.accent,
              trend: '+5h',
              isPositiveTrend: true,
            ),
            StatisticCard(
              title: 'Achievements',
              value: '${stats['achievements'] ?? 0}',
              icon: Icons.emoji_events,
              iconColor: Colors.orange,
              trend: '+1',
              isPositiveTrend: true,
            ),
            StatisticCard(
              title: 'Streak Days',
              value: '${stats['streakDays'] ?? 0}',
              icon: Icons.local_fire_department,
              iconColor: Colors.red,
              trend: '+3',
              isPositiveTrend: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveCoursesSection(LearnerHomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Courses',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: controller.viewAllCourses,
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.activeCourses.length,
            itemBuilder: (context, index) {
              final course = controller.activeCourses[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: ProgressIndicatorCard(
                  title: course['title'] ?? '',
                  subtitle: '${course['lessonsCompleted']}/${course['totalLessons']} lessons',
                  progress: (course['progress'] ?? 0.0) / 100.0,
                  icon: Icons.book,
                  progressColor: AppColors.accent,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLearningProgress(LearnerHomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Progress',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GradientCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Goal',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '12 hours completed of 15 hours',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '80%',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(AppColors.accent),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities(LearnerHomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...controller.recentActivities.take(3).map((activity) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GradientCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getActivityIcon(activity['type']),
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          activity['time'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildUpcomingEvents(LearnerHomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Events',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...controller.upcomingEvents.take(2).map((event) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GradientCard(
              colors: [
                AppColors.accent.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.event,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['title'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${event['date']} at ${event['time']}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.accent,
                    size: 16,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'lesson_completed':
        return Icons.check_circle;
      case 'quiz_completed':
        return Icons.quiz;
      case 'assignment_submitted':
        return Icons.assignment_turned_in;
      case 'achievement_unlocked':
        return Icons.emoji_events;
      default:
        return Icons.notifications;
    }
  }
}
