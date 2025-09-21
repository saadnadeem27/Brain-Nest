import 'package:get/get.dart';
import '../../services/static_data_service.dart';

class EducatorHomeController extends GetxController {
  final StaticDataService _dataService = StaticDataService();

  var isLoading = false.obs;
  var educatorProfile = {}.obs;
  var activeCourses = <Map<String, dynamic>>[].obs;
  var studentMetrics = {}.obs;
  var recentSubmissions = <Map<String, dynamic>>[].obs;
  var upcomingClasses = <Map<String, dynamic>>[].obs;
  var performanceData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading(true);
    try {
      // Load educator profile
      educatorProfile.value = _dataService.getEducatorProfile();

      // Load active courses
      activeCourses.value = _dataService.getEducatorCourses();

      // Load student metrics
      studentMetrics.value = _dataService.getStudentMetrics();

      // Load recent submissions
      recentSubmissions.value = _dataService.getRecentSubmissions();

      // Load upcoming classes
      upcomingClasses.value = _dataService.getUpcomingClasses();

      // Load performance data
      performanceData.value = _dataService.getClassPerformanceData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard data');
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshData() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));

    // Reload dashboard data
    loadDashboardData();
  }

  void navigateToCourseManagement(String courseId) {
    Get.toNamed('/educator-course-management', arguments: courseId);
  }

  void navigateToStudentAnalytics() {
    Get.toNamed('/student-analytics');
  }

  void navigateToGradebook() {
    Get.toNamed('/educator-gradebook');
  }

  void viewProfile() {
    Get.toNamed('/educator-profile');
  }

  void viewSettings() {
    Get.toNamed('/educator-settings');
  }

  void createNewAssignment() {
    Get.toNamed('/create-assignment');
  }

  void manageClass(String classId) {
    Get.toNamed('/class-management', arguments: classId);
  }

  void reviewSubmission(String submissionId) {
    Get.toNamed('/review-submission', arguments: submissionId);
  }
}
