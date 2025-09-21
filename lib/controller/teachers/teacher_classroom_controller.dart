import 'dart:io';

import 'package:Vadai/common_imports.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/common/chapter_model.dart';
import 'package:Vadai/model/common/comment_reply_model.dart';
import 'package:Vadai/model/common/comments_model.dart';
import 'package:Vadai/model/common/module_model.dart';
import 'package:Vadai/model/common/poeple_model.dart';
import 'package:Vadai/model/teachers/teacher_announcement_model.dart';
import 'package:Vadai/model/teachers/teacher_assignment_model.dart';
import 'package:Vadai/model/teachers/teacher_assignment_report_model.dart';
import 'package:Vadai/model/teachers/teacher_classes_data.dart';
import 'package:Vadai/model/teachers/teacher_remark_model.dart';
import 'package:Vadai/model/teachers/teacher_student_performance_model.dart';
import 'package:Vadai/model/teachers/teacher_student_report_model.dart';
import 'package:Vadai/model/teachers/teacher_students_attendance_model.dart';
import 'package:Vadai/model/teachers/teacher_submitted_assignments_model.dart';
import 'package:dio/dio.dart' as dio;

class TeacherClassroomController extends GetxController {
  ApiHelper api = ApiHelper();
  RxBool isLoading = false.obs;
  Rx<TeacherClassesData?> teacherClassesData = Rx<TeacherClassesData?>(null);

  Future<void> getTeachingSubjects() async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        ApiNames.getSubjectsTaking,
      );

      if (response != null && response.statusCode == 200) {
        TeacherClassesData? tmp = TeacherClassesData.fromJson(
          response.data['data'],
        );

        teacherClassesData = tmp.obs;

        log('Teacher classes and subjects loaded successfully');
      } else {
        log(
          'Failed to load teacher classes: ${response?.statusMessage ?? "Unknown error"}',
        );
        commonSnackBar(
          message: "Failed to load your classes. Please try again.",
          color: Colors.red,
        );
      }
    } catch (e) {
      log('Error loading teacher classes: $e');
    }
  }

  Future<Map<String, dynamic>?> getClassroomAnnouncementsList({
    int pageNumber = 1,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getTeachersAnnouncementsList}?pageNumber=$pageNumber',
      );
      log('----------->>>>>>>>>>>>>>> response: $response');
      if (response != null) {
        if (response.statusCode == 200) {
          List<TeacherAnnouncementModel> ls = [];
          for (var i
              in response.data[ApiParameter.data][ApiParameter.announcements]) {
            ls.add(TeacherAnnouncementModel.fromJson(i));
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

  Future<Map<String, dynamic>?> getAnnouncementsList({
    required String subjectId,
    required String classId,
    required String sectionId,
    int pageNumber = 1,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getTeachersAnnouncementsList}?pageNumber=$pageNumber&subjectId=$subjectId&classId=$classId&sectionId=$sectionId',
      );
      log('----------->>>>>>>>>>>>>>> response: $response');
      if (response != null) {
        if (response.statusCode == 200) {
          List<TeacherAnnouncementModel> ls = [];
          for (var i
              in response.data[ApiParameter.data][ApiParameter.announcements]) {
            ls.add(TeacherAnnouncementModel.fromJson(i));
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

  Future<bool> createAnnouncement({
    required String title,
    required String description,
    String? classId,
    String? sectionId,
    String? subjectId,
  }) async {
    try {
      Map<String, dynamic> body = {
        "title": title,
        "description": description,
        "sendToParentWhatsapp": false,
      };
      if (classId != null && classId.isNotEmpty) {
        body["classId"] = classId;
      }
      if (sectionId != null && sectionId.isNotEmpty) {
        body["sectionId"] = sectionId;
      }
      if (subjectId != null && subjectId.isNotEmpty) {
        body["subjectId"] = subjectId;
      }
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.createTeacherAnnouncement,
        body,
      );

      if (response != null && response.statusCode == 200) {
        log('Announcement created successfully');
        commonSnackBar(
          message: "Announcement created successfully!",
          color: AppColors.green,
        );
        return true;
      } else {
        log(
          'Failed to create announcement: ${response?.statusMessage ?? "Unknown error"}',
        );
        return false;
      }
    } catch (e) {
      log('Error creating announcement: $e');
      return false;
    }
  }

  Future<bool> updateAnnouncement({
    required String announcementId,
    required String title,
    required String description,
    String? classId,
    String? sectionId,
    String? subjectId,
  }) async {
    try {
      Map<String, dynamic> body = {
        "title": title,
        "description": description,
        "sendToParentWhatsapp": false,
      };
      if (classId != null && classId.isNotEmpty) {
        body["classId"] = classId;
      }
      if (sectionId != null && sectionId.isNotEmpty) {
        body["sectionId"] = sectionId;
      }
      if (subjectId != null && subjectId.isNotEmpty) {
        body["subjectId"] = subjectId;
      }
      dio.Response? response = await api.putMethodWithDio(
        '${ApiNames.updateTeacherAnnouncement}/$announcementId',
        body,
        snakeBar: false,
      );

      if (response != null && response.statusCode == 200) {
        log('Announcement updated successfully');
        commonSnackBar(
          message: "Announcement updated successfully!",
          color: AppColors.green,
        );
        return true;
      } else {
        log(
          'Failed to updateAnnouncement announcement: ${response?.statusMessage ?? "Unknown error"}',
        );
        return false;
      }
    } catch (e) {
      log('Error updateAnnouncement announcement: $e');
      return false;
    }
  }

  Future<bool> deleteAnnouncement({required String announcementId}) async {
    try {
      dio.Response? response = await api.deleteMethodWithDio(
        '${ApiNames.deleteTeacherAnnouncement}/$announcementId',
        snakeBar: false,
      );

      if (response != null && response.statusCode == 200) {
        log('Announcement deleted successfully');
        commonSnackBar(
          message: "Announcement deleted successfully!",
          color: AppColors.green,
        );
        return true;
      } else {
        log(
          'Failed to delete announceme nt: ${response?.statusMessage ?? "Unknown error"}',
        );
        return false;
      }
    } catch (e) {
      log('Error deleting announcement: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getComments({
    required String parentId,
    int pageNumber = 1,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getTeachersComments}/$parentId?pageNumber=$pageNumber',
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
        ApiNames.addTeachersComment,
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
        '${ApiNames.listTeachersRepliesUser}/$commentId',
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
        ApiNames.addTeachersReply,
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

  //* Resources
  Future<List<ChapterModel>?> getMyClassroomResourceChapterList() async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        ApiNames.getClassTeacherResourceAllChapter,
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
        '${ApiNames.getTeacherResourceAllChapter}/$subjectId',
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

  Future<bool> addChapter({
    required String chapterName,
    String? classId,
    String? sectionId,
    String? subjectId,
  }) async {
    try {
      // for classroom only chapterName is required
      Map<String, dynamic> body = {"chapterName": chapterName};

      if (subjectId != null && subjectId.isNotEmpty) {
        body["subjectId"] = subjectId;
      }
      if (classId != null && classId.isNotEmpty) {
        body["classId"] = classId;
      }

      if (sectionId != null && sectionId.isNotEmpty) {
        body["sectionId"] = sectionId;
      }

      dio.Response? response = await api.postMethodWithDio(
        ApiNames.addTeacherChapter,
        body,
        snakeBar: false,
      );

      // Process response
      if (response != null && response.statusCode == 200) {
        log('Chapter added successfully');
        commonSnackBar(
          message: "Chapter added successfully!",
          color: AppColors.green,
        );
        return true;
      } else {
        log(
          'Failed to add chapter: ${response?.statusMessage ?? "Unknown error"}',
        );
        return false;
      }
    } catch (e) {
      log('Error adding chapter: $e');
      return false;
    }
  }

  Future<bool> deleteChapter({required String chapterId}) async {
    try {
      dio.Response? response = await api.deleteMethodWithDio(
        '${ApiNames.deleteTeacherChapter}/$chapterId',
        snakeBar: false,
      );

      if (response != null && response.statusCode == 200) {
        log('Chapter deleted successfully');
        commonSnackBar(
          message: "Chapter deleted successfully!",
          color: AppColors.green,
        );
        return true;
      } else {
        log(
          'Failed to delete Chapter: ${response?.statusMessage ?? "Unknown error"}',
        );
        return false;
      }
    } catch (e) {
      log('Error deleting Chapter: $e');
      return false;
    }
  }

  Future<List<ModuleModel>?> getTeachersResourceModuleList({
    required String chapterId,
    String searchTag = '',
    dio.CancelToken? cancelToken,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getTeachersResourceModuleList}/$chapterId?searchTag=$searchTag',
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

  Future<bool> addModule({
    required String moduleName,
    required String chapterId,
    required List<Map<String, String>> documents,
  }) async {
    try {
      Map<String, dynamic> body = {
        "moduleName": moduleName,
        "chapterId": chapterId,
        "documents": documents,
      };
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.addTeacherResourceModule,
        body,
        snakeBar: false,
      );
      if (response != null && response.statusCode == 200) {
        log('Module added successfully');
        commonSnackBar(
          message: "Module added successfully!",
          color: AppColors.green,
        );
        return true;
      } else {
        log(
          'Failed to add module: ${response?.statusMessage ?? "Unknown error"}',
        );
        return false;
      }
    } catch (e) {
      log('Error adding module: $e');
      return false;
    }
  }

  Future<bool> addDocument({
    required String moduleId,
    required List<Map<String, String>> documents,
  }) async {
    try {
      Map<String, dynamic> body = {"documents": documents};

      dio.Response? response = await api.postMethodWithDio(
        '${ApiNames.addTeacherResourceModuleDocument}/$moduleId',
        body,
        snakeBar: false,
      );

      if (response != null && response.statusCode == 200) {
        log('Documents added successfully');
        commonSnackBar(
          message: "Documents added successfully!",
          color: AppColors.green,
        );
        return true;
      } else {
        log(
          'Failed to add documents: ${response?.statusMessage ?? "Unknown error"}',
        );
        return false;
      }
    } catch (e) {
      log('Error adding documents: $e');
      return false;
    }
  }

  Future<bool> deleteDocument({
    required String moduleId,
    required String documentId,
  }) async {
    try {
      dio.Response? response = await api.deleteMethodWithDio(
        '${ApiNames.deleteTeacherResourceModuleDocument}/$moduleId/$documentId',
        snakeBar: false,
      );

      if (response != null && response.statusCode == 200) {
        log('Document deleted successfully');
        commonSnackBar(
          message: "Document deleted successfully!",
          color: AppColors.green,
        );
        return true;
      } else {
        log(
          'Failed to delete document: ${response?.statusMessage ?? "Unknown error"}',
        );
        return false;
      }
    } catch (e) {
      log('Error deleting document: $e');
      return false;
    }
  }

  Future<bool> deleteModule({required String moduleId}) async {
    try {
      dio.Response? response = await api.deleteMethodWithDio(
        '${ApiNames.baseUrl}/api/v1/chapters/teachers/remove-module/$moduleId',
        snakeBar: false,
      );

      if (response != null && response.statusCode == 200) {
        log('Module deleted successfully');
        commonSnackBar(
          message: "Module deleted successfully!",
          color: AppColors.green,
        );
        return true;
      } else {
        log(
          'Failed to delete module: ${response?.statusMessage ?? "Unknown error"}',
        );
        return false;
      }
    } catch (e) {
      log('Error deleting module: $e');
      return false;
    }
  }

  //* Peoples API
  Future<Map<String, dynamic>?> getPeopleList({
    String? classId,
    String? sectionId,
    String? subjectId,
    int pageNumber = 1,
  }) async {
    try {
      //! for classroom don't provide any
      final queryParams = <String, String>{'pageNumber': pageNumber.toString()};

      if (subjectId != null && subjectId.isNotEmpty) {
        queryParams['subjectId'] = subjectId;
      }

      if (classId != null && classId.isNotEmpty) {
        queryParams['classId'] = classId;
      }

      if (sectionId != null && sectionId.isNotEmpty) {
        queryParams['sectionId'] = sectionId;
      }
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getTeachersStudents}?$queryString',
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

  //* Assignment API
  Future<List<TeacherAssignmentModel>?> getAssignmentsList({
    required String subjectId,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getTeachersAssignments}/$subjectId',
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<TeacherAssignmentModel> ls = [];
          for (var item in response.data[ApiParameter.data]['assignments']) {
            ls.add(TeacherAssignmentModel.fromJson(item));
          }
          return ls;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getAssignmentsList, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getAssignmentsList: $e',
      );
    }
    return null;
  }

  Future<bool> createAssignment({
    required String lesson,
    required List<String> topics,
    required String additionalInfo,
    required DateTime dueDate,
    required String instructions,
    required String submissionFormat,
    required bool isMCQ,
    required int numberOfQuestions,
    required List<Map<String, dynamic>>? mcqs,
    required String subjectId,
    required String contents,
    required List<Map<String, dynamic>> documents,
  }) async {
    try {
      // Format the due date to YYYY-MM-DD format
      String formattedDueDate =
          "${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}";

      Map<String, dynamic> body = {
        "lesson": lesson,
        "topics": topics,
        "additionalInfo": additionalInfo,
        "dueDate": formattedDueDate,
        "instructions": instructions,
        "submissionFormat": submissionFormat,
        "isMCQ": isMCQ,
        "numberOfQuestions": numberOfQuestions,
        "MCQs": mcqs,
        "subjectId": subjectId,
        "contents": contents,
        "documents": documents,
      };

      dio.Response? response = await api.postMethodWithDio(
        ApiNames.createTeacherAssignment,
        body,
        snakeBar: false,
      );

      if (response != null && response.statusCode == 200) {
        log('Assignment created successfully');
        commonSnackBar(
          message: "Assignment created successfully!",
          color: AppColors.green,
        );
        return true;
      } else {
        log(
          'Failed to create assignment: ${response?.statusMessage ?? "Unknown error"}',
        );
        return false;
      }
    } catch (e) {
      log('Error creating assignment: $e');
      return false;
    }
  }

  Future<bool> updateAssignment({
    required String assignmentId,
    required String lesson,
    required List<String> topics,
    required String additionalInfo,
    required DateTime dueDate,
    required String instructions,
    required String submissionFormat,
    required bool isMCQ,
    required int numberOfQuestions,
    required List<Map<String, dynamic>>? mcqs,
    required String subjectId,
    required String contents,
    required List<Map<String, dynamic>> documents,
  }) async {
    try {
      String formattedDueDate =
          "${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}";

      Map<String, dynamic> body = {
        "lesson": lesson,
        "topics": topics,
        "additionalInfo": additionalInfo,
        "dueDate": formattedDueDate,
        "instructions": instructions,
        "submissionFormat": submissionFormat,
        "isMCQ": isMCQ,
        "numberOfQuestions": numberOfQuestions,
        "MCQs": mcqs,
        "subjectId": subjectId,
        "contents": contents,
        "documents": documents,
      };

      dio.Response? response = await api.putMethodWithDio(
        "${ApiNames.updateTeacherAssignment}/$assignmentId",
        body,
        snakeBar: false,
      );

      if (response != null && response.statusCode == 200) {
        log('Assignment updated successfully');
        commonSnackBar(
          message: "Assignment updated successfully!",
          color: AppColors.green,
        );
        return true;
      } else {
        log(
          'Failed to update assignment: ${response?.statusMessage ?? "Unknown error"}',
        );
        return false;
      }
    } catch (e) {
      log('Error updating assignment: $e');
      return false;
    }
  }

  Future<bool> deleteAssignment({required String assignmentId}) async {
    try {
      var response = await api.deleteMethodWithDio(
        '${ApiNames.deleteTeacherAssignment}/$assignmentId',
      );
      if (response.statusCode == 200) {
        log('Assignment deleted successfully');
        commonSnackBar(
          message: "Assignment deleted successfully!",
          color: AppColors.green,
        );
        return true;
      } else {
        log(
          'Failed to delete assignment: ${response.statusMessage ?? "Unknown error"}',
        );
        return false;
      }
    } catch (e) {
      log('Error deleting assignment: $e');
      return false;
    }
  }

  Future<List<MCQQuestion>?> generateAssignmentQuiz({
    required int numberOfQuestions,
    required String content,
  }) async {
    try {
      Map<String, dynamic> body = {
        "numberOfQuestions": numberOfQuestions,
        "query": content,
      };

      dio.Response? response = await api.postMethodWithDio(
        ApiNames.generateAssignmentQuiz,
        body,
        snakeBar: false,
      );

      if (response != null && response.statusCode == 200) {
        log('Quiz generated successfully');

        // Extract questions from response
        List<dynamic> questionsData = response.data['data']['prompt'];
        List<MCQQuestion> questions = [];

        for (var questionData in questionsData) {
          MCQQuestion question = MCQQuestion(
            question: questionData['question'],
            answerOptions: List<String>.from(questionData['answerOptions']),
            correctOptionIndex: questionData['correctOptionIndex'],
          );
          questions.add(question);
        }

        return questions;
      } else {
        log(
          'Failed to generate quiz: ${response?.statusMessage ?? "Unknown error"}',
        );
        return null;
      }
    } catch (e) {
      log('Error generating quiz: $e');
      return null;
    }
  }

  //submitted by students
  Future<List<TeacherSubmittedAssignment>?>
  getStudentsSubmittedAssignmentsList({required String assignmentId}) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getStudentsSubmittedAssignmentsList}/$assignmentId',
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<TeacherSubmittedAssignment> ls = [];
          for (var item in response.data[ApiParameter.data]['submissions']) {
            ls.add(TeacherSubmittedAssignment.fromJson(item));
          }
          return ls;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getAssignmentsList, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getAssignmentsList: $e',
      );
    }
    return null;
  }

  Future<TeacherSubmittedAssignment?> getStudentsSubmittedAssignmentsDetail({
    required String submissionId,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getStudentsSubmittedAssignmentsDetail}/$submissionId',
      );
      if (response != null) {
        if (response.statusCode == 200) {
          return TeacherSubmittedAssignment.fromJson(
            response.data[ApiParameter.data]['submission'],
          );
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getStudentsSubmittedAssignmentsDetail, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getStudentsSubmittedAssignmentsDetail: $e',
      );
    }
    return null;
  }

  Future<bool> approveSubmission({required String submissionId}) async {
    try {
      dio.Response? response = await api.postMethodWithDio(
        '${ApiNames.approveSubmission}/$submissionId',
        {},
        snakeBar: false,
      );

      if (response != null && response.statusCode == 200) {
        log('Submission approved successfully');
        commonSnackBar(
          message: "Submission approved successfully!",
          color: AppColors.green,
        );
        return true;
      } else {
        log(
          'Failed to approve submission: ${response?.statusMessage ?? "Unknown error"}',
        );
        return false;
      }
    } catch (e) {
      log('Error approving submission: $e');
      return false;
    }
  }

  Future<bool> rejectSubmission({
    required String submissionId,
    required String reason,
  }) async {
    try {
      Map<String, dynamic> body = {"reason": reason};

      dio.Response? response = await api.postMethodWithDio(
        '${ApiNames.rejectSubmission}/$submissionId',
        body,
        snakeBar: false,
      );

      if (response != null && response.statusCode == 200) {
        log('Submission rejected successfully');
        commonSnackBar(
          message: "Submission rejected successfully!",
          color: AppColors.green,
        );
        return true;
      } else {
        log(
          'Failed to reject submission: ${response?.statusMessage ?? "Unknown error"}',
        );
        return false;
      }
    } catch (e) {
      log('Error rejecting submission: $e');
      return false;
    }
  }

  Future<TeacherAssignmentReport?> getAssignmentReport({
    required String subjectId,
    required String classId,
    required String sectionId,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getAssignmentReport}?subjectId=$subjectId&classId=$classId&sectionId=$sectionId',
      );

      if (response != null) {
        if (response.statusCode == 200) {
          return TeacherAssignmentReport.fromJson(
            response.data[ApiParameter.data],
          );
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getAssignmentReport, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getAssignmentReport: $e',
      );
    }
    return null;
  }

  Future<TeacherStudentReport?> getStudentReport({
    required String subjectId,
    required String classId,
    required String sectionId,
    required String studentId,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getStudentReport}?subjectId=$subjectId&classId=$classId&sectionId=$sectionId&studentId=$studentId',
      );

      if (response != null) {
        if (response.statusCode == 200) {
          return TeacherStudentReport.fromJson(
            response.data[ApiParameter.data],
          );
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getStudentReport, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getStudentReport: $e',
      );
    }
    return null;
  }

  //*Attendance API
  Future<List<StudentAttendanceModel>?> getAttendanceDetails({
    required String date,
    // Format: YYYY-MM-DD
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getAttendanceDetails}?date=$date',
      );

      if (response != null && response.statusCode == 200) {
        List<StudentAttendanceModel> attendanceList = [];

        // Parse the response data
        List<dynamic> studentsData =
            response.data[ApiParameter.data]['studentsWithAttendance'];

        // Convert each item to StudentAttendanceModel
        for (var studentData in studentsData) {
          StudentAttendanceModel student = StudentAttendanceModel.fromJson(
            studentData,
          );
          attendanceList.add(student);
        }

        log(
          'Successfully fetched attendance details for ${attendanceList.length} students',
        );
        return attendanceList;
      } else {
        log(
          'Failed to fetch attendance details: ${response?.statusMessage ?? "Unknown error"}',
        );
        return null;
      }
    } catch (e) {
      log('Error fetching attendance details: $e');
      return null;
    }
  }

  Future<bool> submitAttendance({
    required String date,
    required List<Map<String, String>> attendanceData,
  }) async {
    try {
      Map<String, dynamic> body = {
        "date": date,
        "attendanceData": attendanceData,
      };
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.submitAttendance,
        body,
        snakeBar: false,
      );

      if (response != null && response.statusCode == 200) {
        log('Attendance submitted successfully');
        commonSnackBar(
          message: "Attendance submitted successfully!",
          color: AppColors.green,
        );
        return true;
      } else {
        log(
          'Failed to submit attendance: ${response?.statusMessage ?? "Unknown error"}',
        );
        return false;
      }
    } catch (e) {
      log('Error submitting attendance: $e');
      commonSnackBar(
        message: "Error submitting attendance. Please try again.",
        color: Colors.red,
      );
      return false;
    }
  }

  //* Remarks API
  Future<Map<String, dynamic>?> getStudentRemarks({
    required String studentId,
    int pageNumber = 1,
  }) async {
    try {
      // Build query parameters string
      String queryParams = "studentId=$studentId";
      queryParams += "&pageNumber=$pageNumber";

      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getClassroomRemarks}?$queryParams',
      );

      if (response != null && response.statusCode == 200) {
        List<TeacherRemarkModel> remarksList = [];
        List<dynamic> remarksData = response.data[ApiParameter.data]['remarks'];
        for (var remarkData in remarksData) {
          TeacherRemarkModel remark = TeacherRemarkModel.fromJson(remarkData);
          remarksList.add(remark);
        }
        final bool hasNext =
            response.data[ApiParameter.data]['hasNext'] ?? false;
        log('Successfully fetched ${remarksList.length} remarks for student');
        return {'remarks': remarksList, 'hasNext': hasNext};
      } else {
        log(
          'Failed to fetch student remarks: ${response?.statusMessage ?? "Unknown error"}',
        );
        return null;
      }
    } catch (e) {
      log('Error fetching student remarks: $e');
      return null;
    }
  }

  Future<bool> addRemark({
    required String remarks,
    required String receiverId,
  }) async {
    try {
      Map<String, dynamic> body = {
        "remarks": remarks,
        "receiver": receiverId,
        "sendToWhatsapp": false,
        "sendToParentWhatsapp": false,
      };

      dio.Response? response = await api.postMethodWithDio(
        ApiNames.addClassroomRemarks,
        body,
        snakeBar: false,
      );

      if (response != null && response.statusCode == 200) {
        log('Remark added successfully');
        commonSnackBar(
          message: "Remark added successfully!",
          color: AppColors.green,
        );
        return true;
      } else {
        log(
          'Failed to add remark: ${response?.statusMessage ?? "Unknown error"}',
        );
        return false;
      }
    } catch (e) {
      log('Error adding remark: $e');
      return false;
    }
  }

  // Student Report API
  // Student Exam Report API
  Future<TeacherStudentPerformanceModel?> getStudentVadTestExamReport({
    required String studentId,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getStudentVadTestExamReport}/$studentId',
      );

      if (response != null && response.statusCode == 200) {
        log('Successfully fetched exam report for student: $studentId');
        return TeacherStudentPerformanceModel.fromJson(response.data);
      } else {
        log(
          'Failed to fetch student exam report: ${response?.statusMessage ?? "Unknown error"}',
        );
        return null;
      }
    } catch (e) {
      log('Error fetching student exam report: $e');
      return null;
    }
  }

  Future<TeacherStudentPerformanceModel?> getStudentSchoolExamReport({
    required String studentId,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getStudentSchoolExamReport}/$studentId',
      );

      if (response != null && response.statusCode == 200) {
        log('Successfully fetched school exam report for student: $studentId');
        return TeacherStudentPerformanceModel.fromJson(response.data);
      } else {
        log(
          'Failed to fetch student school exam report: ${response?.statusMessage ?? "Unknown error"}',
        );
        return null;
      }
    } catch (e) {
      log('Error fetching student school exam report: $e');
      return null;
    }
  }

  //* File Upload API
  Future<String?> getSignedUrl({
    required String fileName,
    required String fieldName,
  }) async {
    try {
      // Prepare request data
      final data = {"fileName": fileName, "fieldName": fieldName};

      // Make the API call
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.teacherGetSignedUrl,
        data,
        snakeBar: false,
      );
      if (response != null && response.statusCode == 200) {
        final signedUrl = response.data['data']['signedUrl'] as String?;
        log("Signed URL obtained: ${signedUrl?.substring(0, 50)}...");
        return signedUrl;
      } else {
        log("Failed to get signed URL - Status code: ${response?.statusCode}");
        return null;
      }
    } catch (e) {
      log("Error in teacher getSignedUrl: $e");
      return null;
    }
  }

  Future<bool> uploadFileWithSignedUrl({
    required File file,
    required String signedUrl,
  }) async {
    try {
      final uploadDio = dio.Dio();
      final headers = {'Content-Type': 'application/octet-stream'};
      final response = await uploadDio.put(
        signedUrl,
        data: file.readAsBytesSync(),
        options: dio.Options(
          headers: headers,
          validateStatus: (status) => true,
        ),
      );
      if (response.statusCode == 200) {
        log("Teacher file upload successful");
        return true;
      } else {
        log("Teacher file upload failed - Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      log("Error uploading teacher file: $e");
      return false;
    }
  }
}
