import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/app_colors.dart';
import '../../components/ui_components.dart';

class LearnerSettingsScreen extends StatelessWidget {
  const LearnerSettingsScreen({super.key});

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
            _buildNotificationSection(),
            const SizedBox(height: 24),
            _buildLearningSection(),
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
            'Profile',
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
            'Update your personal information',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.photo_camera,
            'Change Avatar',
            'Update your profile picture',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.security,
            'Change Password',
            'Update your account password',
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
            Icons.assignment,
            'Assignment Reminders',
            'Get reminded about due assignments',
            true,
          ),
          _buildSwitchTile(
            Icons.grade,
            'Grade Notifications',
            'Get notified when grades are posted',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildLearningSection() {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Preferences',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            Icons.language,
            'Language',
            'English',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.palette,
            'Theme',
            'Light Mode',
            onTap: () {},
          ),
          _buildSwitchTile(
            Icons.download,
            'Auto Download',
            'Download course materials automatically',
            false,
          ),
          _buildSwitchTile(
            Icons.wifi_off,
            'Offline Mode',
            'Enable offline access to downloaded content',
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
            'Make your profile visible to other students',
            true,
          ),
          _buildSwitchTile(
            Icons.analytics,
            'Learning Analytics',
            'Share learning data for improvement',
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
            'Support',
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
            'Get help and find answers',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.contact_support,
            'Contact Support',
            'Reach out to our support team',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.bug_report,
            'Report Bug',
            'Report issues or bugs',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.star_rate,
            'Rate App',
            'Rate Brain Nest on app store',
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
            'Account',
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
            'Backup your learning progress',
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.download,
            'Export Data',
            'Download your personal data',
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
            'Permanently delete your account',
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
