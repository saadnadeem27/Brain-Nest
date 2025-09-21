import 'package:get/get.dart';
import 'app_selection_screen.dart';
import 'view/splash_screen.dart';
import 'view/course_detail_screen.dart';
import 'view/profile_screen.dart';
import 'view/notification_center_screen.dart';
import 'view/assignment_management_screen.dart';
import 'view/student_analytics_screen.dart';
import 'view/library_resource_screen.dart';
import 'screens/learner/learner_dashboard.dart';
import 'screens/educator/educator_dashboard.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String appSelection = '/app-selection';
  static const String learnerDashboard = '/learner-dashboard';
  static const String educatorDashboard = '/educator-dashboard';
  static const String courseDetail = '/course-detail';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String assignmentManagement = '/assignment-management';
  static const String studentAnalytics = '/student-analytics';
  static const String libraryResources = '/library-resources';

  static List<GetPage> routes = [
    GetPage(
      name: initial,
      page: () => SplashScreen(),
    ),
    GetPage(
      name: splash,
      page: () => SplashScreen(),
    ),
    GetPage(
      name: appSelection,
      page: () => const AppSelectionScreen(),
    ),
    GetPage(
      name: learnerDashboard,
      page: () => const LearnerDashboard(),
    ),
    GetPage(
      name: educatorDashboard,
      page: () => const EducatorDashboard(),
    ),
    GetPage(
      name: courseDetail,
      page: () => CourseDetailScreen(
        courseId: Get.parameters['courseId'] ?? '',
        courseTitle: Get.parameters['courseTitle'] ?? 'Course',
      ),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationCenterScreen(),
    ),
    GetPage(
      name: assignmentManagement,
      page: () => const AssignmentManagementScreen(),
    ),
    GetPage(
      name: studentAnalytics,
      page: () => const StudentAnalyticsScreen(),
    ),
    GetPage(
      name: libraryResources,
      page: () => const LibraryResourceScreen(),
    ),
  ];
}
