import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/app_colors.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1e3a8a),
              Color(0xFFf8fafc),
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllNotifications(),
                      _buildAnnouncements(),
                      _buildReminders(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '12 new notifications',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Announcements'),
          Tab(text: 'Reminders'),
        ],
      ),
    );
  }

  Widget _buildAllNotifications() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 15,
      itemBuilder: (context, index) {
        return _buildNotificationCard(
          index: index,
          isRead: index > 2,
        );
      },
    );
  }

  Widget _buildAnnouncements() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 8,
      itemBuilder: (context, index) {
        return _buildAnnouncementCard(index);
      },
    );
  }

  Widget _buildReminders() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildReminderCard(index);
      },
    );
  }

  Widget _buildNotificationCard({required int index, required bool isRead}) {
    final notificationTypes = [
      {
        'type': 'course',
        'icon': Icons.school,
        'color': AppColors.primary,
        'title': 'New course available',
        'subtitle':
            'Machine Learning Fundamentals is now available for enrollment',
        'time': '2 hours ago',
      },
      {
        'type': 'assignment',
        'icon': Icons.assignment,
        'color': AppColors.warning,
        'title': 'Assignment due soon',
        'subtitle': 'Neural Networks assignment is due in 2 days',
        'time': '4 hours ago',
      },
      {
        'type': 'achievement',
        'icon': Icons.emoji_events,
        'color': AppColors.success,
        'title': 'Achievement unlocked',
        'subtitle': 'You\'ve completed 10 courses! Keep up the great work',
        'time': '1 day ago',
      },
      {
        'type': 'update',
        'icon': Icons.update,
        'color': AppColors.info,
        'title': 'App update available',
        'subtitle': 'New features and improvements are available',
        'time': '2 days ago',
      },
      {
        'type': 'message',
        'icon': Icons.message,
        'color': AppColors.accent,
        'title': 'New message from instructor',
        'subtitle': 'Dr. Smith has responded to your question',
        'time': '3 days ago',
      },
    ];

    final notification = notificationTypes[index % notificationTypes.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isRead ? Colors.transparent : AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (notification['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    notification['icon'] as IconData,
                    color: notification['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['subtitle'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification['time'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(int index) {
    final announcements = [
      {
        'title': 'Platform Maintenance Scheduled',
        'content':
            'The platform will undergo maintenance on Sunday, 2 AM - 4 AM EST. Some services may be temporarily unavailable.',
        'priority': 'high',
        'date': '2025-01-15',
      },
      {
        'title': 'New AI Course Series Launch',
        'content':
            'We\'re excited to announce our new AI course series covering GPT, Computer Vision, and Neural Networks.',
        'priority': 'medium',
        'date': '2025-01-14',
      },
      {
        'title': 'Winter Break Schedule',
        'content':
            'Please note the modified support hours during winter break. Emergency support remains available 24/7.',
        'priority': 'low',
        'date': '2025-01-12',
      },
    ];

    final announcement = announcements[index % announcements.length];
    final priorityColor = announcement['priority'] == 'high'
        ? AppColors.error
        : announcement['priority'] == 'medium'
            ? AppColors.warning
            : AppColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: priorityColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (announcement['priority'] as String).toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: priorityColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                announcement['date'] as String,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            announcement['title'] as String,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            announcement['content'] as String,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(int index) {
    final reminders = [
      {
        'title': 'Complete Neural Networks Assignment',
        'dueDate': 'Due in 2 days',
        'course': 'Machine Learning Fundamentals',
        'type': 'assignment',
      },
      {
        'title': 'Attend Live Session: Deep Learning',
        'dueDate': 'Tomorrow at 3:00 PM',
        'course': 'Advanced AI Course',
        'type': 'session',
      },
      {
        'title': 'Submit Project Proposal',
        'dueDate': 'Due next week',
        'course': 'Data Science Capstone',
        'type': 'project',
      },
    ];

    final reminder = reminders[index % reminders.length];
    IconData iconData;
    Color iconColor;

    switch (reminder['type']) {
      case 'assignment':
        iconData = Icons.assignment;
        iconColor = AppColors.warning;
        break;
      case 'session':
        iconData = Icons.video_call;
        iconColor = AppColors.primary;
        break;
      case 'project':
        iconData = Icons.folder;
        iconColor = AppColors.accent;
        break;
      default:
        iconData = Icons.schedule;
        iconColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder['title'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reminder['course'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reminder['dueDate'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: iconColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
