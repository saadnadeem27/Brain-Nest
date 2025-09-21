import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/app_colors.dart';
import '../../components/ui_components.dart';

class EducatorSettingsScreen extends StatelessWidget {
  const EducatorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildProfileSection(),
            const SizedBox(height: 24),
            _buildTeachingSection(),
            const SizedBox(height: 24),
            _buildNotificationSection(),
            const SizedBox(height: 24),
            _buildPrivacySection(),
            const SizedBox(height: 24),
            _buildSupportSection(),
            const SizedBox(height: 24),
            _buildAccountSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile & Account',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            Icons.person,
            'Edit Profile',
            'Update your professional information',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.photo_camera,
            'Change Photo',
            'Update your profile picture',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.security,
            'Change Password',
            'Update your account password',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.schedule,
            'Office Hours',
            'Set your availability and office hours',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTeachingSection() {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Teaching Preferences',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            Icons.auto_graph,
            'Auto-Grade Quizzes',
            'Automatically grade multiple choice quizzes',
            true,
          ),
          _buildSwitchTile(
            Icons.notifications_active,
            'Assignment Reminders',
            'Send automatic reminders to students',
            true,
          ),
          _buildSwitchTile(
            Icons.grade,
            'Grade Notifications',
            'Notify students when grades are posted',
            false,
          ),
          _buildSettingTile(
            Icons.backup,
            'Gradebook Backup',
            'Configure automatic gradebook backups',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.import_export,
            'Import/Export',
            'Manage course content import and export',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            Icons.notifications,
            'Push Notifications',
            'Receive notifications on your device',
            true,
          ),
          _buildSwitchTile(
            Icons.email,
            'Email Notifications',
            'Receive updates via email',
            true,
          ),
          _buildSwitchTile(
            Icons.assignment_turned_in,
            'Submission Alerts',
            'Get notified of new student submissions',
            true,
          ),
          _buildSwitchTile(
            Icons.question_answer,
            'Q&A Notifications',
            'Get notified of student questions',
            false,
          ),
          _buildSwitchTile(
            Icons.schedule,
            'Class Reminders',
            'Receive reminders before classes',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy & Security',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            Icons.visibility,
            'Profile Visibility',
            'Make your profile visible to students',
            true,
          ),
          _buildSwitchTile(
            Icons.analytics,
            'Teaching Analytics',
            'Share teaching data for platform improvement',
            false,
          ),
          _buildSwitchTile(
            Icons.security,
            'Two-Factor Authentication',
            'Add extra security to your account',
            false,
          ),
          _buildSettingTile(
            Icons.shield,
            'Privacy Policy',
            'Read our privacy policy',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.description,
            'Terms of Service',
            'Read terms and conditions',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support & Resources',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            Icons.help,
            'Help Center',
            'Find answers and tutorials',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.contact_support,
            'Contact Support',
            'Reach out to our support team',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.school,
            'Teaching Resources',
            'Access teaching materials and best practices',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.bug_report,
            'Report Issue',
            'Report bugs or technical issues',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.star_rate,
            'Rate Platform',
            'Rate your experience with Brain Nest',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Management',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            Icons.backup,
            'Backup Data',
            'Backup your courses and gradebooks',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.download,
            'Export Data',
            'Download your teaching data',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.sync,
            'Sync Settings',
            'Synchronize settings across devices',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.logout,
            'Sign Out',
            'Sign out of your account',
            onTap: () {},
            textColor: Colors.red,
          ),
          _buildSettingTile(
            Icons.delete_forever,
            'Delete Account',
            'Permanently delete your educator account',
            onTap: () {},
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? AppColors.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: (newValue) {},
        activeColor: AppColors.primary,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
