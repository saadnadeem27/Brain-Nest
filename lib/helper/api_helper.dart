import 'dart:developer';
import 'dart:io';

import 'package:Vadai/common/App_strings.dart';
import 'package:Vadai/common/common_widgets.dart';
import 'package:Vadai/helper/local_storage_helper.dart';
import 'package:Vadai/helper/network_helper.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class ApiParameter {
  static const String title = "title";
  static const String content = "content";
  static const String list = "list";
  static const String message = "message";
  static const String user = "user";
  static const String system = "system";
  static const String email = "email";
  static const String data = "data";
  static const String otp = "otp";
  static const String password = "password";
  static const String confirmPassword = "confirmPassword";
  static const String profileImage = "profileImage";
  static const String school = "school";
  static const String students = "students";
  static const String teacherProfile = "teacherProfile";
  static const String schoolId = "schoolId";
  static const String classId = "classId";
  static const String sectionId = "sectionId";
  static const String isCompleted = "isCompleted";
  static const String isNotCompleted = "isNotCompleted";
  static const String name = "name";
  static const String subjects = "subjects";
  static const String chapters = "chapters";
  static const String modules = "modules";
  static const String test = "test";
  static const String mCQAnswers = "MCQAnswers";
  static const String announcements = "announcements";
  static const String assignments = "assignments";
  static const String comments = "comments";
  static const String hasNext = "hasNext";

  //Compendia
  static const String questionId = "questionId";
  static const String question = "question";
  static const String selectedOptionIndex = "selectedOptionIndex";
  static const String MCQAnswers = "MCQAnswers";
  static const String category = "category";
  static const String query = "query";
  static const String subcategory = "subcategory";
  static const String suggestions = "suggestions";
  static const String contents = "contents";
  static const String websiteLinks = "websiteLinks";
  static const String coverImage = "coverImage";
  static const String images = "images";
  static const String numberOfQuestions = "numberOfQuestions";
  static const String MCQs = "MCQs";
  static const String continuedFrom = "continuedFrom";
  static const String compendiaId = "compendiaId";
  static const String compendiumId = "compendiumId";

  //Webinars
  static const String webinars = "webinars";
  static const String suggestion = "suggestion";
  static const String webinarId = "webinarId";
  static const String jobRoles = "jobRoles";
  static const String jobRole = "jobRole";
  static const String savedJobRoles = "savedJobRoles";
  static const String categories = "categories";
  static const String career = "career";
  static const String goal = "goal";
  static const String strength = "strength";
  static const String weakness = "weakness";
  static const String plans = "plans";
  static const String partToReview = "partToReview";
}

class ApiNames {
  // static const String baseFirebaseURL =
  //     "https://lavado-9b98a-default-rtdb.firebaseio.com/baseURL.json";

  static String baseUrl = "http://43.205.60.33";
  static String aiUrl = "https://api.groq.com/openai/v1/chat/completions";
  static String sendOtp = "$baseUrl/api/v1/students/auth/email/send-otp";
  static String verifyOtp = "$baseUrl/api/v1/students/auth/email/verify-otp";
  static String changeAccessLevel =
      "$baseUrl/api/v1/students/auth/send-change-access-level-request";
  static String uploadProfileImage =
      "$baseUrl/api/v1/students/auth/save-profile-image";
  static String getStudentProfile = "$baseUrl/api/v1/student/get-profile";
  static String getNotification =
      "$baseUrl/api/v1/notification/student/get-notifications";
  static String getNotificationCount =
      "$baseUrl/api/v1/notification/student/get-notification-count";
  static String getRuleBook = "$baseUrl/api/v1/rulebook/student/get-rulebooks";
  static String getVadSquadReview =
      "$baseUrl/api/v1/vad-review/student/get-vad-sqad-reviews";
  static String sendFeedback = "$baseUrl/api/v1/student/send-feedback";
  static String getSchoolDetails =
      "$baseUrl/api/v1/school/student/get-all-schools";
  static String getSchoolSubjects = "$baseUrl/api/v1/subjects/list-subjects";
  static String completeProfile =
      "$baseUrl/api/v1/students/auth/complete-profile";
  static String getAllSubjects =
      "$baseUrl/api/v1/subjects/student/all-subjects";
  static String getResourceAllChapter =
      "$baseUrl/api/v1/chapters/student/all-chapters";
  static String getMyClassroomResourceChapter =
      "$baseUrl/api/v1/chapters/student/classroom-chapters";
  static String getResourceAllModule =
      "$baseUrl/api/v1/modules/student/all-modules";
  static String getCurriculumAllModule =
      "$baseUrl/api/v1/curriculum-modules/student/all-curriculum-modules";
  static String getCurriculumAllChapter =
      "$baseUrl/api/v1/curriculum-modules/student/all-curriculum-chapters";
  static String getAttendanceList =
      "$baseUrl/api/v1/student/classroom/attendance";
  static String getCurriculumChapterTest =
      "$baseUrl/api/v1/curriculum-test/student/test";
  static String getCurriculumTestSubmit =
      "$baseUrl/api/v1/curriculum-test/student/submit-test";
  static String getClassroomAnnouncementsList =
      "$baseUrl/api/v1/announcement/student/classroom/list-all";
  static String getClassroomRemarks = "$baseUrl/api/v1/remark/list-all-remarks";
  static String addClassroomRemarks =
      "$baseUrl/api/v1/remark/classroom/add-remark";
  static String getAnnouncementsList =
      "$baseUrl/api/v1/announcement/student/list-all";
  static String getSubjectPeopleList =
      "$baseUrl/api/v1/student/get-all-students";
  static String getAssignments =
      "$baseUrl/api/v1/assignments/student/all-assignments";
  static String submitAssignment = "$baseUrl/api/v1/assignments/student/submit";
  static String createAssignmentPrompt =
      "${ApiNames.baseUrl}/api/v1/chat/student/assignment/create-assignment-prompt";
  static String getComments = "${ApiNames.baseUrl}/api/v1/comment/viewComments";
  static String addComment = "${ApiNames.baseUrl}/api/v1/comment/addComment";
  static String listRepliesUser =
      "${ApiNames.baseUrl}/api/v1/comment/reply/listRepliesUser";
  static String addReply = "${ApiNames.baseUrl}/api/v1/comment/reply/addReply";

  //* Ethical Learning
  static String getEthicalLearningCategories =
      "$baseUrl/api/v1/compendia/category/get-all-categories";
  static String getEthicalLearningSubCategories =
      "$baseUrl/api/v1/compendia/sub-category/get-all-sub-categories";
  static String getEthicalLearningAllCompendia =
      "$baseUrl/api/v1/compendia/student/get-all-compendia";
  static String getEthicalLearningCompendia =
      "$baseUrl/api/v1/compendia/student/get-compendium";
  static String getEthicalLearningMyCompendia =
      "$baseUrl/api/v1/compendia/student/my-compendia";
  static String getCompendium =
      "$baseUrl/api/v1/compendia/student/get-compendium";
  static String pinCompendia =
      "$baseUrl/api/v1/compendia/student/pin-compendium";
  static String removePinCompendia =
      "$baseUrl/api/v1/compendia/student/remove-pinned-compendium";
  static String addCompendia =
      "$baseUrl/api/v1/compendia/student/add-compendium";
  static String addCompendiaSuggestion =
      "$baseUrl/api/v1/compendia/student/add-suggestion";
  static String generateQuiz = "$baseUrl/api/v1/chat/student/generate-quiz";
  static String generateCompendiaPrompt =
      "$baseUrl/api/v1/chat/student/compendia/create-compendium-prompt";
  static String submitCompendiaQuiz =
      "$baseUrl/api/v1/compendia/student/submit-quiz";
  static String getSignedUrl = "$baseUrl/api/v1/signed-url/get-signed-url";
  static String submitCompendiaForReview =
      "$baseUrl/api/v1/compendia/student/submit-for-review/";

  //*Webinars
  static String getAllWebinars =
      "$baseUrl/api/v1/webinar/student/list-all-webinar";
  static String registerWebinars = "$baseUrl/api/v1/webinar/student/register";
  static String webinarsSuggestion =
      "$baseUrl/api/v1/webinar/student/add-suggestions";
  static String getJobRoles = "$baseUrl/api/v1/job-role/list-job-roles";
  static String jobRolesDetails = "$baseUrl/api/v1/job-role/get-job-role";
  static String jobRoleSaved = "$baseUrl/api/v1/job-role/save-job-roles";
  static String getSavedJobRoles =
      "$baseUrl/api/v1/job-role//list-saved-job-roles";
  static String getJobRolesCategories =
      "$baseUrl/api/v1/job-role-category/list-categories";
  static String jobRoleSuggestion =
      "$baseUrl/api/v1/job-role-category/add-suggestion";
  static String careerDetails =
      "$baseUrl/api/v1/career/student/get-career-dashboard";
  static String careerSubmit =
      "$baseUrl/api/v1/career/student/save-career-dashboard";
  static String submitVADSquadReviews =
      "$baseUrl/api/v1/career/student/submit-for-review";
  static String unsaveJobRole = "$baseUrl/api/v1/job-role/unsave-job-roles";
  static String generateJobRolePrompt =
      "$baseUrl/api/v1/chat/student/job-role/create-job-role-description-prompt";
  static String generateCareerDashboardPrompt =
      "$baseUrl/api/v1/chat/student/career/create-career-dashboard-prompt";

  // * Vad Test
  static String getSubjectList = "$baseUrl/api/v1/vad-test/student/subjects";
  static String getVadTest = "$baseUrl/api/v1/vad-test/student/tests";
  static String getSchoolExams =
      "${ApiNames.baseUrl}/api/v1/vad-test/student/exams";
  static String getExamSubjectsWithMarks =
      "$baseUrl/api/v1/vad-test/student/exam/subjects-and-marks";
  static String getExamScoreReport =
      "$baseUrl/api/v1/vad-test/student/exam/score-report";

  //! Teacher APIs
  static String teacherSendOtp =
      "$baseUrl/api/v1/teachers/account/email/send-otp";
  static String teacherVerifyOtp =
      "$baseUrl/api/v1/teachers/account/email/verify-otp";
  static String teacherCompleteProfile =
      "$baseUrl/api/v1/teachers/account/complete-profile";
  static String teacherGetSignedUrl =
      "$baseUrl/api/v1/signed-url/get-signed-url";
  static String teacherGetNotificationCount =
      "$baseUrl/api/v1/notification/teacher/get-notification-count";
  static String teacherGetNotifications =
      "$baseUrl/api/v1/notification/teacher/get-notifications";
  static String updateTeachersProfile =
      "$baseUrl/api/v1/teachers/account/update-profile";
  static String getSubjectsTaking =
      "$baseUrl/api/v1/teachers/classroom/get-subjects-taking";
  static String getTeachersAnnouncementsList =
      "$baseUrl/api/v1/announcement/teachers/list-all";
  static String createTeacherAnnouncement =
      "$baseUrl/api/v1/announcement/teachers/create";
  static String updateTeacherAnnouncement =
      "$baseUrl/api/v1/announcement/teachers/update";
  static String deleteTeacherAnnouncement =
      "$baseUrl/api/v1/announcement/teachers/delete";
  static String getTeachersComments =
      "${ApiNames.baseUrl}/api/v1/comment/viewComments";
  static String addTeachersComment =
      "${ApiNames.baseUrl}/api/v1/comment/teachers/addComment";
  static String listTeachersRepliesUser =
      "${ApiNames.baseUrl}/api/v1/comment/reply/listRepliesUser";
  static String addTeachersReply =
      "${ApiNames.baseUrl}/api/v1/comment/reply/addReply";
  //*Resources
  static String getTeacherResourceAllChapter =
      "$baseUrl/api/v1/chapters/teachers/all-chapters";
  static String getClassTeacherResourceAllChapter =
      "$baseUrl/api/v1/chapters/teachers/get-classroom-chapters";
  static String addTeacherChapter =
      "$baseUrl/api/v1/chapters/teachers/add-chapter";
  static String deleteTeacherChapter =
      "$baseUrl/api/v1/chapters/teachers/remove-chapter";
  static String getTeachersResourceModuleList =
      "$baseUrl/api/v1/modules/teachers/all-modules";
  static String addTeacherResourceModule =
      "$baseUrl/api/v1/chapters/teachers/add-module";
  static String addTeacherResourceModuleDocument =
      "$baseUrl/api/v1/chapters/teachers/add-document";
  static String deleteTeacherResourceModuleDocument =
      "$baseUrl/api/v1/chapters/teachers/remove-document";
  static String getTeachersStudents =
      "$baseUrl/api/v1/teachers/classroom/get-all-students";
  static String getTeachersAssignments =
      "$baseUrl/api/v1/assignments/teachers/all-assignments";
  static String getStudentsSubmittedAssignmentsList =
      "$baseUrl/api/v1/assignments/teachers/all-submissions";
  static String getStudentsSubmittedAssignmentsDetail =
      "$baseUrl/api/v1/assignments/teachers/submission";
  static String getAssignmentReport =
      "$baseUrl/api/v1/assignments/teachers/assigment-report";
  static String getStudentReport =
      "$baseUrl/api/v1/assignments/teachers/student-report";
  static String createTeacherAssignment =
      "$baseUrl/api/v1/assignments/teachers/add-assignment";
  static String updateTeacherAssignment =
      "$baseUrl/api/v1/assignments/teachers/update-assignment";
  static String deleteTeacherAssignment =
      "$baseUrl/api/v1/assignments/teachers/delete-assignment";
  static String approveSubmission =
      "$baseUrl/api/v1/assignments/teachers/approve-submission";
  static String rejectSubmission =
      "$baseUrl/api/v1/assignments/teachers/reject-submission";
  static String generateAssignmentQuiz =
      "$baseUrl/api/v1/chat/teachers/assignment/generate-quiz";
  static String getAttendanceDetails =
      "$baseUrl/api/v1/teachers/classroom/get-attendance-details";
  static String submitAttendance =
      "$baseUrl/api/v1/teachers/classroom/submit-attendance";

  //! Progress Tracking
  static String getVadTestProgress =
      "$baseUrl/api/v1/vad-test/teachers/progress-track";
  static String getSchoolExamProgress =
      "$baseUrl/api/v1/vad-test/teachers/exam/progress-track";
  //! Teachers Vad Test
  static String getVadTestSubjects =
      "$baseUrl/api/v1/vad-test/teachers/get-vad-test-subjects";
  static String getVadTestDetails = "$baseUrl/api/v1/vad-test/details";
  static String getTeacherSchoolExams =
      "$baseUrl/api/v1/vad-test/teachers/exams";
  static String getSchoolExamSubjectDetails =
      "$baseUrl/api/v1/vad-test/teachers/exam";
  static String submitExamMark =
      '$baseUrl/api/v1/vad-test/teachers/exams/submit-mark';
  static String getStudentExamMark =
      '$baseUrl/api/v1/vad-test/teachers/exams/get-mark';

  static String getStudentVadTestExamReport =
      '$baseUrl/api/v1/vad-test/student-score-report';
  static String getStudentSchoolExamReport =
      '$baseUrl/api/v1/vad-test/teachers/exams/student-report';
}

class ApiHelper {
  dio.Dio dioInstance = dio.Dio();

  Future<dio.Response?> patchMethodWithDio(
    String url,
    body, {
    Map<String, String>? header,
    bool snakeBar = true,
  }) async {
    dioInstance.options.headers =
        header ??
        {
          "Authorization":
              'Bearer ${LocalStorage.read(key: LocalStorageKeys.token)}',
        };

    log(
      "-----------------------Patch With Dio----------------------------------\n---------------------------API--------------------------------\n--------------------------------------------------------------",
    );
    log("url: $url");
    log("Headers: ${dioInstance.options.headers}");
    log("Request: $body");

    if (await NetworkManager().isConnected()) {
      try {
        dio.Response? response = await dioInstance.patch(
          url,
          data: body,
          options: dio.Options(validateStatus: (status) => true),
        );

        log("Response: statusCode ==>> ${response.statusCode}");
        log("Response: ${response.data}");
        log(
          "-------------------------------------------------------------------------------\n-------------------------------------------------------------------------------",
        );
        if (snakeBar) {
          commonSnackBar(message: response.data[ApiParameter.message]);
        }
        if (response.statusCode == 401) {
          //snackBar(title: response.data[APIParameters.message]);
          //commonLogoutMethod();
          return null;
        }
        if (response.statusCode == 403) {
          commonSnackBar(message: response.data[ApiParameter.message]);
          LocalStorage.deleteAll();
          //! Navigate to screen after logout
          return null;
        }

        if (response.statusCode == 404) {
          commonSnackBar(message: response.data[ApiParameter.message]);
          return null;
        }

        return response;
      } catch (exception) {
        log(exception.toString());
        return null;
      }
    } else {
      commonSnackBar(message: AppStrings.pleaseConnectInternet);
      return null;
    }
  }

  Future<dio.Response?> postMethodWithDio(
    String url,
    body, {
    Map<String, String>? header,
    bool snakeBar = true,
  }) async {
    (dioInstance.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
        () =>
            HttpClient()
              ..badCertificateCallback =
                  (X509Certificate cert, String host, int port) => true;
    dioInstance.options.headers =
        header ??
        {
          "Authorization":
              LocalStorage.read(key: LocalStorageKeys.token) != null
                  ? 'Bearer ${LocalStorage.read(key: LocalStorageKeys.token)}'
                  : LocalStorage.read(key: LocalStorageKeys.preAuthToken) !=
                      null
                  ? 'Bearer ${LocalStorage.read(key: LocalStorageKeys.preAuthToken)}'
                  : '',
        };
    log(
      "-----------------------Post With Dio----------------------------------\n---------------------------API--------------------------------\n--------------------------------------------------------------",
    );
    log("url: $url");
    log("Headers: ${dioInstance.options.headers}");
    log("Request: $body");
    if (await NetworkManager().isConnected()) {
      try {
        dio.Response? response = await dioInstance.post(
          url,
          data: body,
          options: dio.Options(validateStatus: (status) => true),
        );
        log("Response: statusCode ==>> ${response.statusCode}");
        log("Response: ${response.data}");
        log(
          "-------------------------------------------------------------------------------\n-------------------------------------------------------------------------------",
        );

        if (snakeBar) {
          commonSnackBar(message: response.data[ApiParameter.message]);
        }
        if (response.statusCode == 401) {
          commonSnackBar(message: response.data[ApiParameter.message]);
          return null;
        }
        if (response.statusCode == 403) {
          commonSnackBar(message: response.data[ApiParameter.message]);
          LocalStorage.deleteAll();
          return null;
        }

        if (response.statusCode == 404) {
          commonSnackBar(message: response.data[ApiParameter.message]);
          return null;
        }
        return response;
      } catch (exception) {
        log(exception.toString());
        return null;
      }
    } else {
      commonSnackBar(message: AppStrings.pleaseConnectInternet);
      return null;
    }
  }

  Future<dio.Response?> putMethodWithDio(
    String url,
    body, {
    Map<String, String>? header,
    bool snakeBar = true,
  }) async {
    (dioInstance.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
        () =>
            HttpClient()
              ..badCertificateCallback =
                  (X509Certificate cert, String host, int port) => true;
    dioInstance.options.headers =
        header ??
        {
          "Authorization":
              'Bearer ${LocalStorage.read(key: LocalStorageKeys.token)}',
        };
    log(
      "-----------------------Post With Dio----------------------------------\n---------------------------API--------------------------------\n--------------------------------------------------------------",
    );
    log("url: $url");
    log("Headers: ${dioInstance.options.headers}");
    log("Request: $body");
    if (await NetworkManager().isConnected()) {
      try {
        dio.Response? response = await dioInstance.put(
          url,
          data: body,
          options: dio.Options(validateStatus: (status) => true),
        );
        log("Response: statusCode ==>> ${response.statusCode}");
        log("Response: ${response.data}");
        log(
          "-------------------------------------------------------------------------------\n-------------------------------------------------------------------------------",
        );
        if (snakeBar) {
          commonSnackBar(message: response.data[ApiParameter.message]);
        }
        if (response.statusCode == 401) {
          //snackBar(title: response.data[APIParameters.message]);
          //commonLogoutMethod();
          commonSnackBar(message: response.data[ApiParameter.message]);
          return null;
        }
        if (response.statusCode == 403) {
          commonSnackBar(message: response.data[ApiParameter.message]);
          LocalStorage.deleteAll();
          //! Navigate to screen after logout
          return null;
        }

        if (response.statusCode == 404) {
          commonSnackBar(message: response.data[ApiParameter.message]);
          return null;
        }

        return response;
      } catch (exception) {
        log(exception.toString());
        return null;
      }
    } else {
      commonSnackBar(message: AppStrings.pleaseConnectInternet);
      return null;
    }
  }

  getMethodWithDio(
    String url, {
    Map<String, String>? header,
    Map<String, dynamic>? body,
    CancelToken? cancelToken,
    Function()? onCancelled,
  }) async {
    (dioInstance.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
        () =>
            HttpClient()
              ..badCertificateCallback =
                  (X509Certificate cert, String host, int port) => true;
    dioInstance.options.headers =
        header ??
        {
          "Authorization":
              LocalStorage.read(key: LocalStorageKeys.token) != null
                  ? 'Bearer ${LocalStorage.read(key: LocalStorageKeys.token)}'
                  : LocalStorage.read(key: LocalStorageKeys.preAuthToken) !=
                      null
                  ? 'Bearer ${LocalStorage.read(key: LocalStorageKeys.preAuthToken)}'
                  : '',
        };
    log(
      "-----------------------Get----------------------------------\n---------------------------API--------------------------------\n--------------------------------------------------------------",
    );
    log("url: $url");
    log("Headers: ${dioInstance.options.headers}");
    if (await NetworkManager().isConnected()) {
      try {
        dio.Response? response = await dioInstance.get(
          url,
          data: body,
          options: dio.Options(validateStatus: (val) => true),
          cancelToken: cancelToken,
        );
        log("Response: statusCode ==>> ${response.statusCode}");
        log("Response: ${response.data}");
        log(
          "-------------------------------------------------------------------------------\n-------------------------------------------------------------------------------",
        );

        if (response.statusCode == 401) {
          commonSnackBar(message: response.data[ApiParameter.message]);
          return null;
        }
        if (response.statusCode == 403) {
          commonSnackBar(message: response.data[ApiParameter.message]);
          LocalStorage.deleteAll();
          //! Navigate to screen after logout
          return null;
        }

        if (response.statusCode == 404) {
          commonSnackBar(message: response.data[ApiParameter.message]);
          return null;
        }

        return response;
      } on DioException catch (exception) {
        if (CancelToken.isCancel(exception)) {
          onCancelled?.call();
        }
        log("Exception ==>> $exception");
        return null;
      }
    } else {
      commonSnackBar(message: AppStrings.pleaseConnectInternet);
      return null;
    }
  }

  deleteMethodWithDio(
    String url, {
    Map<String, String>? header,
    Map<String, dynamic>? body,
    CancelToken? cancelToken,
    Function()? onCancelled,
    bool snakeBar = true,
  }) async {
    (dioInstance.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
        () =>
            HttpClient()
              ..badCertificateCallback =
                  (X509Certificate cert, String host, int port) => true;
    dioInstance.options.headers =
        header ??
        {
          "Authorization":
              'Bearer ${LocalStorage.read(key: LocalStorageKeys.token)}',
        };
    log(
      "-----------------------Get----------------------------------\n---------------------------API--------------------------------\n--------------------------------------------------------------",
    );
    log("url: $url");
    log("Headers: ${dioInstance.options.headers}");
    log("Request body: $body");
    if (await NetworkManager().isConnected()) {
      try {
        dio.Response? response = await dioInstance.delete(
          url,
          options: dio.Options(validateStatus: (val) => true),
          cancelToken: cancelToken,
          data: body,
        );
        log("Response: statusCode ==>> ${response.statusCode}");
        log("Response: ${response.data}");
        log(
          "-------------------------------------------------------------------------------\n-------------------------------------------------------------------------------",
        );
        if (snakeBar) {
          commonSnackBar(message: response.data[ApiParameter.message]);
        }
        if (response.statusCode == 401) {
          commonSnackBar(message: response.data[ApiParameter.message]);
          LocalStorage.deleteAll();
          //! Navigate to screen after logout
          return null;
        }
        if (response.statusCode == 403) {
          commonSnackBar(message: response.data[ApiParameter.message]);
          LocalStorage.deleteAll();
          //! Navigate to screen after logout
          return null;
        }

        if (response.statusCode == 404) {
          commonSnackBar(message: response.data[ApiParameter.message]);
          return null;
        }

        return response;
      } on DioException catch (exception) {
        if (CancelToken.isCancel(exception)) {
          onCancelled?.call();
        }
        log("Exception ==>> $exception");
        return null;
      }
    } else {
      commonSnackBar(message: AppStrings.pleaseConnectInternet);
      return null;
    }
  }
}
