import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:Vadai/common/common_widgets.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/common/poeple_model.dart';
import 'package:Vadai/model/students/announcements_model.dart';
import 'package:Vadai/model/students/assignements_model.dart';
import 'package:Vadai/model/students/attendance_data_model.dart';
import 'package:Vadai/model/common/chapter_model.dart';
import 'package:Vadai/model/common/comment_reply_model.dart';
import 'package:Vadai/model/common/comments_model.dart';
import 'package:Vadai/model/common/module_model.dart';
import 'package:Vadai/model/students/remarks_model.dart';
import 'package:Vadai/model/students/subject_model.dart';
import 'package:Vadai/model/students/test_model.dart';
import 'package:Vadai/routes.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;

class ClassRoomController extends GetxController {
  ApiHelper api = ApiHelper();
  final RxList<SubjectModel?> subjectsList = <SubjectModel?>[].obs;
  RxInt submittedAssignmentsCount = 0.obs;
  RxBool isLoading = false.obs;
  RxInt myClassroomAnnouncementCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getMyClassroomBadgeCount();
  }

  Future<void> getMyClassroomBadgeCount() async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        "${ApiNames.baseUrl}/api/v1/announcement/student/classroom/get-badge-count",
      );

      if (response != null && response.statusCode == 200) {
        final int badgeCount = response.data['data']['badgeCount'] ?? 0;
        myClassroomAnnouncementCount.value = badgeCount;
        log('Classroom badge count fetched successfully: $badgeCount');
      } else {
        log(
          'Error fetching badge count: ${response?.statusMessage ?? "Unknown error"}',
        );
      }
    } catch (e) {
      log('Error in getMyClassroomBadgeCount: $e');
    }
  }

  Future<void> getSubjectList() async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        ApiNames.getAllSubjects,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          subjectsList.clear();
          for (var subject in response.data['data']['subjects']) {
            subjectsList.add(SubjectModel.fromJson(subject));
          }
          submittedAssignmentsCount.value =
              int.tryParse(
                response.data['data']['submittedAssignmentsCount'].toString(),
              ) ??
              0;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getSubjectList, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getSubjectList: $e',
      );
    }
  }

  Future<List<ChapterModel>?> getMyClassroomResourceChapterList() async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        ApiNames.getResourceAllChapter,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<ChapterModel> chaptersList = [];
          for (var chapter
              in response.data[ApiParameter.data][ApiParameter.chapters]) {
            chaptersList.add(ChapterModel.fromJson(chapter));
          }
          return chaptersList;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getChaptersList, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getChaptersList: $e',
      );
    }
    return null;
  }

  Future<List<ChapterModel>?> getResourceChapterList({
    required String subjectId,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getResourceAllChapter}/$subjectId',
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<ChapterModel> chaptersList = [];
          for (var chapter
              in response.data[ApiParameter.data][ApiParameter.chapters]) {
            chaptersList.add(ChapterModel.fromJson(chapter));
          }
          return chaptersList;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getChaptersList, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getChaptersList: $e',
      );
    }
    return null;
  }

  Future<List<ModuleModel>?> getResourseModuleList({
    required String chapterId,
    String searchTag = '',
    CancelToken? cancelToken,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getResourceAllModule}/$chapterId?searchTag=$searchTag',
        cancelToken: cancelToken,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<ModuleModel> ls = [];
          for (var chapter
              in response.data[ApiParameter.data][ApiParameter.modules]) {
            ls.add(ModuleModel.fromJson(chapter));
          }
          return ls;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getModuleList, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getModuleList: $e',
      );
    }
    return null;
  }

  Future<List<ModuleModel>?> getCurriculumModuleList({
    required String chapterId,
    String searchTag = '',
    CancelToken? cancelToken,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getCurriculumAllModule}/$chapterId?searchTag=$searchTag',
        cancelToken: cancelToken,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<ModuleModel> ls = [];
          for (var chapter
              in response.data[ApiParameter.data][ApiParameter.modules]) {
            ls.add(ModuleModel.fromJson(chapter));
          }
          return ls;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getModuleList, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getModuleList: $e',
      );
    }
    return null;
  }

  Future<List<ChapterModel>?> getCurriculumChapterList({
    required String subjectId,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getCurriculumAllChapter}/$subjectId',
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<ChapterModel> chaptersList = [];
          for (var chapter
              in response.data[ApiParameter.data][ApiParameter.chapters]) {
            chaptersList.add(ChapterModel.fromJson(chapter));
          }
          return chaptersList;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getChaptersList, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getChaptersList: $e',
      );
    }
    return null;
  }

  Future<AttendanceDataModel?> getAttendance({
    required int month,
    required int year,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getAttendanceList}?month=$month&year=$year',
      );
      if (response != null) {
        if (response.statusCode == 200) {
          AttendanceDataModel attendanceData = AttendanceDataModel.fromJson(
            response.data[ApiParameter.data],
          );
          return attendanceData;
        } else {
          log(
            '------------------------------->>>>>>>>>>>>>> Error in getAttendance, status code: ${response.statusCode}',
          );
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getAttendance, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getAttendance: $e',
      );
    }
    return null;
  }

  Future<TestModel?> getTest({required String chapterId}) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getCurriculumChapterTest}/$chapterId',
      );
      if (response != null) {
        if (response.statusCode == 200) {
          return TestModel.fromJson(
            response.data[ApiParameter.data][ApiParameter.test],
          );
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getTest, response is null',
        );
      }
    } catch (e) {
      log('------------------------------->>>>>>>>>>>>>> Error in getTest: $e');
    }
    return null;
  }

  Future<void> submitTest({
    required String chapterId,
    required List<Map<String, dynamic>> answers,
  }) async {
    Map<String, dynamic> body = {ApiParameter.mCQAnswers: answers};
    try {
      dio.Response? response = await api.postMethodWithDio(
        '${ApiNames.getCurriculumTestSubmit}/$chapterId',
        body,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          commonSnackBar(message: 'Test submitted successfully');
          return Get.offAllNamed(RouteNames.userDashboard);
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in submitTest, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in submitTest: $e',
      );
    }
  }

  Future<Map<String, dynamic>?> getClassroomAnnouncementsList({
    int pageNumber = 1,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getClassroomAnnouncementsList}?pageNumber=$pageNumber',
      );
      log('----------->>>>>>>>>>>>>>> response: $response');
      if (response != null) {
        if (response.statusCode == 200) {
          List<AnnouncementsModel> ls = [];
          for (var i
              in response.data[ApiParameter.data][ApiParameter.announcements]) {
            ls.add(AnnouncementsModel.fromJson(i));
          }
          final bool? hasNext =
              response.data[ApiParameter.data][ApiParameter.hasNext];
          return {
            ApiParameter.announcements: ls,
            ApiParameter.hasNext: hasNext,
          };
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getClassroomAnnouncementsList, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getClassroomAnnouncementsList: $e',
      );
    }
    return null;
  }

  Future<Map<String, dynamic>?> getClassroomRemarks({
    int pageNumber = 1,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getClassroomRemarks}?pageNumber=$pageNumber',
      );

      if (response != null) {
        if (response.statusCode == 200) {
          List<RemarksModel> remarks = [];
          for (var remarkData in response.data[ApiParameter.data]['remarks']) {
            remarks.add(RemarksModel.fromJson(remarkData));
          }

          final bool? hasNext =
              response.data[ApiParameter.data][ApiParameter.hasNext];

          return {'remarks': remarks, ApiParameter.hasNext: hasNext};
        } else {
          log('Error in getClassroomRemarks: ${response.statusMessage}');
        }
      } else {
        log('Error in getClassroomRemarks: response is null');
      }
    } catch (e) {
      log('Error in getClassroomRemarks: $e');
    }

    return null;
  }

  Future<Map<String, dynamic>?> getSubjectAnnouncementsList({
    required String subjectId,
    int pageNumber = 1,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getAnnouncementsList}?pageNumber=$pageNumber&subjectId=$subjectId',
      );
      log('----------->>>>>>>>>>>>>>> response: $response');
      if (response != null) {
        if (response.statusCode == 200) {
          List<AnnouncementsModel> ls = [];
          for (var i
              in response.data[ApiParameter.data][ApiParameter.announcements]) {
            ls.add(AnnouncementsModel.fromJson(i));
          }
          final bool? hasNext =
              response.data[ApiParameter.data][ApiParameter.hasNext];
          return {
            ApiParameter.announcements: ls,
            ApiParameter.hasNext: hasNext,
          };
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getSubjectAnnouncementsList, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getSubjectAnnouncementsList: $e',
      );
    }
    return null;
  }

  Future<Map<String, dynamic>?> getSubjectPeopleList({
    required String subjectId,
    int pageNumber = 1,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getSubjectPeopleList}?pageNumber=$pageNumber&subject=$subjectId',
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<PeopleModel> ls = [];
          TeacherModel? teacher;
          for (var i
              in response.data[ApiParameter.data][ApiParameter.students]) {
            ls.add(PeopleModel.fromJson(i));
          }
          teacher = TeacherModel.fromJson(
            response.data[ApiParameter.data][ApiParameter.teacherProfile],
          );
          final bool? hasNext =
              response.data[ApiParameter.data][ApiParameter.hasNext];
          return {
            ApiParameter.students: ls,
            ApiParameter.teacherProfile: teacher,
            ApiParameter.hasNext: hasNext,
          };
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getSubjectPeopleList, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getSubjectPeopleList: $e',
      );
    }
    return null;
  }

  Future<Map<String, dynamic>?> getAssignments({
    required String subjectId,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getAssignments}/$subjectId',
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<AssignmentsModel> completed = [];
          List<AssignmentsModel> notCompleted = [];
          for (var i
              in response.data[ApiParameter.data][ApiParameter.assignments]) {
            AssignmentsModel assignment = AssignmentsModel.fromJson(i);
            if (assignment.isCompleted == true) {
              completed.add(assignment);
            } else {
              notCompleted.add(assignment);
            }
          }
          return {
            ApiParameter.isCompleted: completed,
            ApiParameter.isNotCompleted: notCompleted,
          };
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getAssignments, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getAssignments: $e',
      );
    }
    return null;
  }

  Future<bool> submitAssignment({
    required String assignmentId,
    List<File>? files,
    List<Map<String, dynamic>>? mcqAnswers,
  }) async {
    try {
      dio.FormData formData = dio.FormData();

      // Add MCQ answers if present
      if (mcqAnswers != null && mcqAnswers.isNotEmpty) {
        formData.fields.add(MapEntry('MCQAnswers', jsonEncode(mcqAnswers)));
      }

      // Add files if present
      if (files != null && files.isNotEmpty) {
        for (var file in files) {
          final fileName = file.path.split('/').last;
          formData.files.add(
            MapEntry(
              'files',
              await dio.MultipartFile.fromFile(file.path, filename: fileName),
            ),
          );
        }
      }

      // Submit the assignment
      dio.Response? response = await api.postMethodWithDio(
        '${ApiNames.submitAssignment}/$assignmentId',
        formData,
      );

      if (response != null && response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      log('Error submitting assignment: $e');
      throw e;
    }
    return false;
  }

  Future<String?> generateAssignmentPrompt({
    required String assignmentId,
  }) async {
    try {
      Map<String, dynamic> body = {"assignmentId": assignmentId};
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.createAssignmentPrompt,
        body,
        snakeBar: false,
      );
      if (response != null && response.statusCode == 200) {
        final prompt = response.data['data']['prompt'];
        return prompt;
      } else {
        log(
          'Failed to generate assignment prompt: ${response?.statusMessage ?? "Unknown error"}',
        );
        return null;
      }
    } catch (e) {
      log('Error generating assignment prompt: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getComments({
    required String parentId,
    int pageNumber = 1,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getComments}/$parentId?pageNumber=$pageNumber',
      );

      if (response != null) {
        if (response.statusCode == 200) {
          List<CommentsModel> comments = <CommentsModel>[];
          List<dynamic> commentsData =
              response.data[ApiParameter.data][ApiParameter.comments];

          for (var comment in commentsData) {
            CommentsModel commentModel = CommentsModel.fromJson(comment);
            comments.add(commentModel);
          }

          final bool? hasNext =
              response.data[ApiParameter.data][ApiParameter.hasNext];

          return {
            ApiParameter.comments: comments,
            ApiParameter.hasNext: hasNext,
          };
        } else {
          log('Error in getComments: ${response.statusMessage}');
        }
      } else {
        log('Error in getComments: response is null');
      }
    } catch (e) {
      log('Error in getComments: $e');
    }

    return null;
  }

  Future<bool> addComment({
    required String parentId,
    required String comment,
  }) async {
    try {
      Map<String, dynamic> body = {'parentId': parentId, 'comment': comment};

      dio.Response? response = await api.postMethodWithDio(
        ApiNames.addComment,
        body,
        snakeBar: false,
      );

      if (response != null && response.statusCode == 200) {
        return true;
      } else {
        log(
          'Error in addComment: ${response?.statusMessage ?? "Unknown error"}',
        );
      }
    } catch (e) {
      log('Error in addComment: $e');
    }

    return false;
  }

  Future<List<CommentsReplyModel>?> getCommentReplies({
    required String commentId,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.listRepliesUser}/$commentId',
      );

      if (response != null) {
        if (response.statusCode == 200) {
          List<CommentsReplyModel> replies = <CommentsReplyModel>[];
          List<dynamic> repliesData =
              response.data[ApiParameter.data]["replies"];

          for (var reply in repliesData) {
            CommentsReplyModel replyModel = CommentsReplyModel.fromJson(reply);
            replies.add(replyModel);
          }

          return replies;
        } else {
          log('Error in getCommentReplies: ${response.statusMessage}');
        }
      } else {
        log('Error in getCommentReplies: response is null');
      }
    } catch (e) {
      log('Error in getCommentReplies: $e');
    }
    return null;
  }

  Future<bool> addReply({
    required String commentId,
    required String reply,
  }) async {
    try {
      Map<String, dynamic> body = {'commentId': commentId, 'reply': reply};

      dio.Response? response = await api.postMethodWithDio(
        ApiNames.addReply,
        body,
        snakeBar: false,
      );

      if (response != null && response.statusCode == 200) {
        return true;
      } else {
        log('Error in addReply: ${response?.statusMessage ?? "Unknown error"}');
      }
    } catch (e) {
      log('Error in addReply: $e');
    }

    return false;
  }
}
