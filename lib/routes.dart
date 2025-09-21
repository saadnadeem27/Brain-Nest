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
import 'screens/learner/learner_courses_screen.dart';
import 'screens/learner/learner_assignments_screen.dart';
import 'screens/learner/learner_profile_screen.dart';
import 'screens/learner/learner_settings_screen.dart';
import 'screens/educator/educator_dashboard.dart';
import 'screens/educator/educator_course_management_screen.dart';
import 'screens/educator/educator_gradebook_screen.dart';
import 'screens/educator/educator_profile_screen.dart';
import 'screens/educator/educator_settings_screen.dart';
import 'screens/educator/create_assignment_screen.dart';

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

  // Learner routes
  static const String learnerCourses = '/learner-courses';
  static const String learnerAssignments = '/learner-assignments';
  static const String learnerProfile = '/learner-profile';
  static const String learnerSettings = '/learner-settings';

  // Educator routes
  static const String educatorCourseManagement = '/educator-course-management';
  static const String educatorGradebook = '/educator-gradebook';
  static const String educatorProfile = '/educator-profile';
  static const String educatorSettings = '/educator-settings';
  static const String createAssignment = '/create-assignment';

  static List<GetPage> routes = [
    GetPage(
      name: initial,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
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

    // Learner screens
    GetPage(
      name: learnerCourses,
      page: () => const LearnerCoursesScreen(),
    ),
    GetPage(
      name: learnerAssignments,
      page: () => const LearnerAssignmentsScreen(),
    ),
    GetPage(
      name: learnerProfile,
      page: () => const LearnerProfileScreen(),
    ),
    GetPage(
      name: learnerSettings,
      page: () => const LearnerSettingsScreen(),
    ),

    // Educator screens
    GetPage(
      name: educatorCourseManagement,
      page: () => const EducatorCourseManagementScreen(),
    ),
    GetPage(
      name: educatorGradebook,
      page: () => const EducatorGradebookScreen(),
    ),
    GetPage(
      name: educatorProfile,
      page: () => const EducatorProfileScreen(),
    ),
    GetPage(
      name: educatorSettings,
      page: () => const EducatorSettingsScreen(),
    ),
    GetPage(
      name: createAssignment,
      page: () => const CreateAssignmentScreen(),
    ),
  ];
}
