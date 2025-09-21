import 'package:Vadai/app_selection_screen.dart';
import 'package:Vadai/common/webview.dart';
import 'package:Vadai/view/student/auth/fillDetails/profile_review_screen.dart';
import 'package:Vadai/view/student/auth/login_screen.dart';
import 'package:Vadai/view/student/auth/otp_screen.dart';
import 'package:Vadai/view/student/auth/fillDetails/upload_profile.dart';
import 'package:Vadai/view/student/auth/fillDetails/upload_school_details.dart';
import 'package:Vadai/view/student/auth/fillDetails/upload_subject.dart';
import 'package:Vadai/view/student/auth/fillDetails/welcome_aboard.dart';
import 'package:Vadai/view/student/classRoom/comments/comment_replies_screen.dart';
import 'package:Vadai/view/student/classRoom/comments/comments_screen.dart';
import 'package:Vadai/view/student/classRoom/myClassroom/attendance_screen.dart';
import 'package:Vadai/view/student/classRoom/myClassroom/classroom_announcements.dart';
import 'package:Vadai/view/student/classRoom/myClassroom/classroom_remarks.dart';
import 'package:Vadai/view/student/classRoom/myClassroom/classroom_resources.dart';
import 'package:Vadai/view/student/classRoom/myClassroom/my_classroom.dart';
import 'package:Vadai/view/student/profile/screens/plans_screen.dart';
import 'package:Vadai/view/student/profile/screens/accounts.dart';
import 'package:Vadai/view/splash_screen.dart';
import 'package:Vadai/view/student/vad_test/screens/vad_test_documents_screen.dart';
import 'package:Vadai/view/student/vad_test/screens/vad_test_list_screen.dart';
import 'package:Vadai/view/teachers/accounts/teacher_account_screen.dart';
import 'package:Vadai/view/teachers/accounts/teacher_notification_screen.dart';
import 'package:Vadai/view/teachers/auth/screens/profile_setup/TeacherWelcomeAboard.dart';
import 'package:Vadai/view/teachers/auth/screens/profile_setup/teacher_profile_review.dart';
import 'package:Vadai/view/teachers/auth/screens/profile_setup/teacher_upload_profile.dart';
import 'package:Vadai/view/teachers/auth/screens/profile_setup/teacher_upload_school_details.dart';
import 'package:Vadai/view/teachers/auth/screens/profile_setup/teacher_upload_subject.dart';
import 'package:Vadai/view/teachers/auth/screens/teachers_login.dart';
import 'package:Vadai/view/teachers/auth/screens/teachers_otp.dart';
import 'package:Vadai/view/teachers/classroom/assignments/teacher_assignments_list.dart';
import 'package:Vadai/view/teachers/classroom/assignments/teacher_create_assignment.dart';
import 'package:Vadai/view/teachers/classroom/assignments/teacher_submission_details.dart';
import 'package:Vadai/view/teachers/classroom/assignments/teacher_submission_list.dart';
import 'package:Vadai/view/teachers/classroom/assignments/teacher_update_assignment.dart';
import 'package:Vadai/view/teachers/classroom/class_teacher/class_teacher_screen.dart';
import 'package:Vadai/view/teachers/classroom/class_teacher/teacher_attendance_screen.dart';
import 'package:Vadai/view/teachers/classroom/class_teacher/teacher_classroom_announcements.dart';
import 'package:Vadai/view/teachers/classroom/class_teacher/teacher_classroom_resources.dart';
import 'package:Vadai/view/teachers/classroom/class_teacher/teacher_remarks_screen.dart';
import 'package:Vadai/view/teachers/classroom/class_teacher/teacher_student_remarks_screen.dart';
import 'package:Vadai/view/teachers/classroom/comments/teacher_comment_replies_screen.dart';
import 'package:Vadai/view/teachers/classroom/comments/teacher_comments_screen.dart';
import 'package:Vadai/view/teachers/classroom/performance/teacher_performance_screen.dart';
import 'package:Vadai/view/teachers/classroom/performance/teacher_student_performance_screen.dart';
import 'package:Vadai/view/teachers/classroom/resources/teacher_module_details_screen.dart';
import 'package:Vadai/view/teachers/classroom/resources/teacher_modules_screen.dart';
import 'package:Vadai/view/teachers/classroom/resources/teacher_resources_screen.dart';
import 'package:Vadai/view/teachers/classroom/screens/teacher_peoples_screen.dart';
import 'package:Vadai/view/teachers/classroom/subject_announcement/create_teacher_announcement.dart';
import 'package:Vadai/view/teachers/classroom/subject_announcement/edit_teacher_announcement.dart';
import 'package:Vadai/view/teachers/classroom/subject_announcement/teacher_announcements.dart';
import 'package:Vadai/view/teachers/classroom/screens/teacher_subject_details.dart';
import 'package:Vadai/view/teachers/teachers_dashboard.dart';
import 'package:Vadai/view/teachers/timeline/screens/exam_progress_details_screen.dart';
import 'package:Vadai/view/teachers/timeline/screens/subtopics_screen.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:Vadai/view/student/career_games/career_dashboard.dart';
import 'package:Vadai/view/student/career_games/saved_job_roles.dart';
import 'package:Vadai/view/student/classRoom/announcements.dart';
import 'package:Vadai/view/student/classRoom/assignments/assignments.dart';
import 'package:Vadai/view/student/classRoom/curriculum.dart';
import 'package:Vadai/view/common/ethical_learning/screens/my_compendia.dart';
import 'package:Vadai/view/common/ethical_learning/upload_compendia/screens/upload_compendia.dart';
import 'package:Vadai/view/common/ethical_learning/view_compendia/screens/view_compendia.dart';
import 'package:Vadai/view/student/profile/screens/notifications.dart';
import 'package:Vadai/view/student/tabs/class_room.dart';
import 'package:Vadai/view/student/classRoom/chapter_details.dart';
import 'package:Vadai/view/student/classRoom/chapters.dart';
import 'package:Vadai/view/student/classRoom/peoples.dart';
import 'package:Vadai/view/student/classRoom/subject_details.dart';
import 'package:Vadai/view/student/user_dashboard.dart';

class RouteNames {
  // static const initial = accountScreen;
  static const initial = root;

  // Base routes

  static const String root = "/";
  static const String appSelection = "/appSelection";
  static const String notificationScreen = "/notificationScreen";
  static const String home = "/home";
  static const String loginScreen = "/loginScreen";
  static const String otpScreen = "/otpScreen";
  static const String welcomeAboard = "/welcomeAboard";
  static const String uploadProfile = "/uploadProfile";
  static const String uploadSchoolDetails = "/uploadSchoolDetails";
  static const String uploadSubject = "/uploadSubject";
  static const String userDashboard = "/userDashboard";
  static const String chaptersScreen = "/chaptersScreen";
  static const String subjectDetail = "/subjectDetails";
  static const String curriculum = "/curriculumScreen";
  static const String peoplesScreen = "/peoplesScreen";
  static const String chapterDetailsScreen = "/chapterDetailsScreen";
  static const String announcements = "/announcements";
  static const String assignments = "/assignments";
  static const String uploadCompendia = "/uploadCompendia";
  static const String myCompendia = "/myCompendia";
  static const String viewCompendia = "/viewCompendia";
  static const String savedJobRoles = "/savedJobRoles";
  static const String careerDashboard = "/careerDashboard";
  static const String plansScreen = "/plansScreen";
  static const String accountScreen = "/accountScreen";
  static const String aiScreen = "/aiScreen";
  static const String vadTestList = '/vadtest-list';
  static const String vadTestDocuments = '/vadtest-documents';
  static const String profileReview = '/profile-review';
  static const String comments = '/comments';
  static const String myClassroom = '/myClassroom';
  static const String classroomRemarks = '/classroomRemarks';
  static const String classroomAnnouncements = '/classroomAnnouncements';
  static const String commentReplies = '/comment-replies';
  static const String classroomResources = '/classroomResources';
  static const String attendanceScreen = "/attendanceScreen";

  //! Teacher routes
  static const String teachersLoginScreen = "/teachersLoginScreen";
  static const String teachersOtpScreen = "/teachersOtpScreen";
  static const String teacherUploadProfile = "/teacherUploadProfile";
  static const String teacherUploadSchoolDetails =
      "/teacherUploadSchoolDetails";
  static const String teacherUploadSubject = "/TeacherUploadSubject";
  static const String teacherProfileReview = "/teacherProfileReview";
  static const String teacherWelcomeAboard = "/teacherWelcomeAboard";
  static const String teachersDashboard = "/teachersDashboard";
  static const String teacherNotificationScreen = "/teacherNotificationScreen";
  static const String teacherAccountScreen = "/teacherAccountScreen";
  static const String teacherSubjectDetails = '/teacher-subject-details';
  static const String teacherAnnouncements = '/teacher-subject-announcements';
  static const String createAnnouncement = '/createAnnouncement';
  static const String teacherComments = '/teacher-comments';
  static const String teacherCommentReplies = '/teacher-comment-replies';
  static const String editAnnouncement = '/edit-teacher-announcement';
  static const String teacherResources = '/teacher-resources';
  static const String teacherResourceModules = '/teacher-resource-modules';
  static const String teacherModuleDetails = '/teacher-module-details';
  static const String teacherPeoples = '/teacher-peoples';
  static const String teacherAssignments = '/teacher/assignments';
  static const String teacherSubmissions = '/teacher/submissions';
  static const String teacherSubmissionDetails = '/teacher/submission-details';
  static const String createAssignment = '/teacher/create-assignment';
  static const String classTeacherScreen = '/teacher/classTeacherScreen';
  static const String teacherClassroomAnnouncements =
      '/teacher-classroom-announcements';
  static const String teacherClassroomResources =
      '/teacher-classroom-resources';
  static const String teacherAttendance = '/teacher/attendance';
  static const teacherRemarks = "/teacher-remarks";
  static const teacherStudentRemarks = "/teacher-student-remarks";
  static const String teacherExamProgress = '/teacher/exam-progress';
  static const String teacherSubtopicsProgress = '/teacher/subtopics-progress';
  static const String updateAssignment = '/update-assignment';
  static const String teacherPerformance = '/teacher/performance';
  static const String teacherStudentPerformance =
      '/teacher/student/performance';
}

class RoutesStudents {
  static final routes = [
    GetPage(name: RouteNames.root, page: () => const SplashScreen()),
    GetPage(
      name: RouteNames.appSelection,
      page: () => const AppSelectionScreen(),
    ),
    GetPage(name: RouteNames.loginScreen, page: () => const LoginScreen()),
    GetPage(
      name: RouteNames.otpScreen,
      page: () => const OTPVerificationScreen(),
    ),
    GetPage(name: RouteNames.welcomeAboard, page: () => const WelcomeAboard()),
    GetPage(name: RouteNames.uploadProfile, page: () => const UploadProfile()),
    GetPage(
      name: RouteNames.uploadSchoolDetails,
      page: () => const UploadSchoolDetails(),
    ),
    GetPage(name: RouteNames.uploadSubject, page: () => const UploadSubject()),
    GetPage(
      name: RouteNames.profileReview,
      page: () => const ProfileReviewScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(name: RouteNames.userDashboard, page: () => const UserDashboard()),
    GetPage(
      name: RouteNames.notificationScreen,
      page: () => const NotificationScreen(),
    ),
    GetPage(name: RouteNames.home, page: () => const ClassRoom()),
    GetPage(
      name: RouteNames.subjectDetail,
      page: () => const SubjectDetailsScreen(),
    ),
    GetPage(name: RouteNames.curriculum, page: () => const CurriculumScreen()),
    GetPage(
      name: RouteNames.chaptersScreen,
      page: () => const ChaptersScreen(),
    ),
    GetPage(
      name: RouteNames.classroomResources,
      page: () => const ClassroomResources(),
    ),
    GetPage(
      name: RouteNames.chapterDetailsScreen,
      page: () => const ChapterDetailsScreen(),
    ),
    GetPage(name: RouteNames.peoplesScreen, page: () => const PeoplesScreen()),
    GetPage(name: RouteNames.announcements, page: () => const Announcements()),
    GetPage(name: RouteNames.assignments, page: () => const Assignments()),
    GetPage(name: RouteNames.comments, page: () => const CommentsScreen()),
    GetPage(
      name: RouteNames.commentReplies,
      page: () => const CommentRepliesScreen(),
    ),
    GetPage(
      name: RouteNames.uploadCompendia,
      page: () => const UploadCompendia(),
    ),
    GetPage(name: RouteNames.myCompendia, page: () => const MyCompendia()),
    GetPage(name: RouteNames.viewCompendia, page: () => const ViewCompendia()),
    GetPage(name: RouteNames.savedJobRoles, page: () => const SavedJobRoles()),
    GetPage(
      name: RouteNames.careerDashboard,
      page: () => const CareerDashboard(),
    ),
    GetPage(name: RouteNames.plansScreen, page: () => const PlansScreen()),
    GetPage(name: RouteNames.accountScreen, page: () => const AccountScreen()),
    GetPage(name: RouteNames.aiScreen, page: () => const Webview()),
    GetPage(name: RouteNames.myClassroom, page: () => const MyClassroom()),
    GetPage(
      name: RouteNames.classroomAnnouncements,
      page: () => const ClassroomAnnouncements(),
    ),
    GetPage(
      name: RouteNames.classroomRemarks,
      page: () => const ClassroomRemarks(),
    ),
    GetPage(
      name: RouteNames.vadTestList,
      page:
          () => VadTestListScreen(
            subjectId: Get.arguments['subjectId'] ?? '',
            subjectName: Get.arguments['subjectName'] ?? '',
            subjectIcon: Get.arguments['subjectIcon'],
          ),
    ),
    GetPage(
      name: RouteNames.vadTestDocuments,
      page:
          () => VadTestDocumentsScreen(
            testName: Get.arguments['testName'] ?? '',
            documents: Get.arguments['documents'],
          ),
    ),
    GetPage(
      name: RouteNames.attendanceScreen,
      page: () => const AttendanceScreen(),
    ),

    //! teachers routes
    GetPage(name: RouteNames.root, page: () => const SplashScreen()),
    GetPage(
      name: RouteNames.teachersLoginScreen,
      page: () => const TeacherLoginScreen(),
    ),
    GetPage(
      name: RouteNames.teachersOtpScreen,
      page: () => const TeacherOTPVerificationScreen(),
    ),
    GetPage(
      name: RouteNames.teacherUploadProfile,
      page: () => const TeacherUploadProfile(),
    ),
    GetPage(
      name: RouteNames.teacherUploadSchoolDetails,
      page: () => const TeacherUploadSchoolDetails(),
    ),
    GetPage(
      name: RouteNames.teacherUploadSubject,
      page: () => const TeacherUploadSubject(),
    ),
    GetPage(
      name: RouteNames.teacherProfileReview,
      page: () => const TeacherProfileReview(),
    ),
    GetPage(
      name: RouteNames.teacherWelcomeAboard,
      page: () => const TeacherWelcomeAboard(),
    ),
    GetPage(
      name: RouteNames.teachersDashboard,
      page: () => const TeachersDashboard(),
    ),
    GetPage(
      name: RouteNames.teacherNotificationScreen,
      page: () => const TeacherNotificationScreen(),
    ),
    GetPage(
      name: RouteNames.teacherAccountScreen,
      page: () => const TeacherAccountScreen(),
    ),
    GetPage(
      name: RouteNames.teacherSubjectDetails,
      page: () => const TeacherSubjectDetails(),
    ),
    GetPage(
      name: RouteNames.teacherAnnouncements,
      page: () => const TeacherAnnouncements(),
    ),
    GetPage(
      name: RouteNames.createAnnouncement,
      page: () => const CreateTeacherAnnouncement(),
    ),
    GetPage(
      name: RouteNames.teacherComments,
      page: () => const TeacherCommentsScreen(),
    ),
    GetPage(
      name: RouteNames.teacherCommentReplies,
      page: () => const TeacherCommentRepliesScreen(),
    ),
    GetPage(
      name: RouteNames.editAnnouncement,
      page: () => const EditTeacherAnnouncement(),
    ),
    GetPage(
      name: RouteNames.teacherResources,
      page: () => const TeacherResourcesScreen(),
    ),
    GetPage(
      name: RouteNames.teacherResourceModules,
      page: () => const TeacherModulesScreen(),
    ),
    GetPage(
      name: RouteNames.teacherModuleDetails,
      page: () => const TeacherModuleDetailsScreen(),
    ),
    GetPage(
      name: RouteNames.teacherPeoples,
      page: () => const TeacherPeoplesScreen(),
    ),
    GetPage(
      name: RouteNames.teacherAssignments,
      page: () => const TeacherAssignmentsList(),
    ),
    GetPage(
      name: RouteNames.updateAssignment,
      page: () => const TeacherUpdateAssignment(),
    ),
    GetPage(
      name: RouteNames.teacherSubmissions,
      page: () => const TeacherSubmissionsList(),
    ),
    GetPage(
      name: RouteNames.teacherSubmissionDetails,
      page: () => const TeacherSubmissionDetails(),
    ),
    GetPage(
      name: RouteNames.createAssignment,
      page: () => const TeacherCreateAssignment(),
    ),
    GetPage(
      name: RouteNames.classTeacherScreen,
      page: () => const ClassTeacherScreen(),
    ),
    GetPage(
      name: RouteNames.teacherClassroomAnnouncements,
      page: () => const TeacherClassroomAnnouncements(),
    ),
    GetPage(
      name: RouteNames.teacherClassroomResources,
      page: () => const TeacherClassroomResources(),
    ),
    GetPage(
      name: RouteNames.teacherAttendance,
      page: () => const TeacherAttendanceScreen(),
    ),
    GetPage(
      name: RouteNames.teacherRemarks,
      page: () => const TeacherRemarksScreen(),
    ),
    GetPage(
      name: RouteNames.teacherStudentRemarks,
      page: () => const TeacherStudentRemarksScreen(),
    ),
    GetPage(
      name: RouteNames.teacherExamProgress,
      page: () => ExamProgressDetailsScreen(),
    ),
    GetPage(
      name: RouteNames.teacherSubtopicsProgress,
      page: () => const SubtopicsScreen(),
    ),
    GetPage(
      name: RouteNames.teacherPerformance,
      page: () => TeacherPerformanceScreen(),
    ),
    GetPage(
      name: RouteNames.teacherStudentPerformance,
      page: () => TeacherStudentPerformanceScreen(),
    ),
  ];
}
