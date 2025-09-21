import 'package:get/get.dart';
import '../../services/static_data_service.dart';

class LearnerHomeController extends GetxController {
  final StaticDataService _dataService = StaticDataService();
  
  var isLoading = false.obs;
  var learnerProfile = {}.obs;
  var activeCourses = <Map<String, dynamic>>[].obs;
  var recentActivities = <Map<String, dynamic>>[].obs;
  var learningStats = {}.obs;
  var upcomingEvents = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading(true);
    try {
      // Load learner profile
      learnerProfile.value = _dataService.getLearnerProfile();
      
      // Load active courses
      activeCourses.value = _dataService.getActiveCourses();
      
      // Load recent activities
      recentActivities.value = _dataService.getRecentLearningActivities();
      
      // Load learning statistics
      learningStats.value = _dataService.getLearningStatistics();
      
      // Load upcoming events
      upcomingEvents.value = _dataService.getUpcomingEvents();
      
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

  void navigateToCourse(String courseId) {
    Get.toNamed('/course-detail', arguments: courseId);
  }

  void markNotificationAsRead(String notificationId) {
    // Mark notification as read in static data
    recentActivities.refresh();
  }

  void viewAllCourses() {
    Get.toNamed('/courses');
  }

  void viewProfile() {
    Get.toNamed('/learner-profile');
  }

  void viewSettings() {
    Get.toNamed('/learner-settings');
  }
}
