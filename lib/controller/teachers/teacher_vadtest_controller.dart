import 'dart:developer';

import 'package:Vadai/common/common_widgets.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/common/poeple_model.dart';
import 'package:Vadai/model/teachers/teacher_schoolexam_marksentry_model.dart';
import 'package:Vadai/model/teachers/teacher_schoolexam_model.dart';
import 'package:Vadai/model/teachers/teacher_schoolexam_subject_details_model.dart';
import 'package:Vadai/model/teachers/teacher_vadtest_details_model.dart';
import 'package:Vadai/model/teachers/teacher_vadtest_subject_model.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class TeacherVadTestController extends GetxController {
  ApiHelper api = ApiHelper();
  RxBool isLoading = false.obs;
  RxList<TeacherVadTestSubjectModel> vadTestSubjectList =
      <TeacherVadTestSubjectModel>[].obs;

  Future<void> getVadTestSubjects() async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        ApiNames.getVadTestSubjects,
      );

      if (response != null && response.statusCode == 200) {
        vadTestSubjectList.clear();
        List<TeacherVadTestSubjectModel> subjects = [];
        if (response.data['data'] != null &&
            response.data['data']['vadTests'] != null) {
          List<dynamic> vadTests = response.data['data']['vadTests'];

          for (var classData in vadTests) {
            TeacherVadTestSubjectModel subject =
                TeacherVadTestSubjectModel.fromJson(classData);
            subjects.add(subject);
          }
        }

        vadTestSubjectList.addAll(subjects);
      } else {
        log(
          'Failed to load VAD test subjects: ${response?.statusMessage ?? "Unknown error"}',
        );
      }
    } catch (e) {
      log('Error loading VAD test subjects: $e');
    }
  }

  Future<TeacherVadTestDetailsModel?> getVadTestDetails(
    String vadTestId,
  ) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        "${ApiNames.getVadTestDetails}/$vadTestId",
      );

      if (response != null && response.statusCode == 200) {
        if (response.data['data'] != null &&
            response.data['data']['vadTest'] != null) {
          log('VAD test details fetched successfully');
          return TeacherVadTestDetailsModel.fromJson(
            response.data['data']['vadTest'],
          );
        } else {
          log('Invalid response format for VAD test details');
        }
      } else {
        log(
          'Failed to get VAD test details: ${response?.statusMessage ?? "Unknown error"}',
        );
      }

      return null;
    } catch (e) {
      log('Error getting VAD test details: $e');
      return null;
    }
  }

  Future<List<TeacherSchoolExamModel>?> getSchoolExams({
    required String? classId,
    required String? sectionId,
    required String? subjectId,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getTeacherSchoolExams}?classId=$classId&sectionId=$sectionId&subjectId=$subjectId',
      );

      if (response != null && response.statusCode == 200) {
        List<TeacherSchoolExamModel> exams = [];

        if (response.data['data'] != null &&
            response.data['data']['schoolExamsWithSubject'] != null) {
          List<dynamic> examsList =
              response.data['data']['schoolExamsWithSubject'];

          for (var exam in examsList) {
            TeacherSchoolExamModel schoolExam = TeacherSchoolExamModel.fromJson(
              exam,
            );
            exams.add(schoolExam);
          }
          return exams;
        } else {
          log('Invalid response format for school exams');
        }
      } else {
        log(
          'Failed to load school exams: ${response?.statusMessage ?? "Unknown error"}',
        );
      }
      return null;
    } catch (e) {
      log('Error loading school exams: $e');
      return null;
    }
  }

  Future<TeacherSchoolExamSubjectDetailsModel?> getSchoolExamSubjectDetails({
    required String examId,
    required String? classId,
    required String? sectionId,
    required String? subjectId,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        "${ApiNames.getSchoolExamSubjectDetails}/$examId?classId=$classId&sectionId=$sectionId&subjectId=$subjectId",
      );

      if (response != null && response.statusCode == 200) {
        if (response.data['data'] != null &&
            response.data['data']['schoolExamWithSubject'] != null) {
          return TeacherSchoolExamSubjectDetailsModel.fromJson(
            response.data['data']['schoolExamWithSubject'],
          );
        } else {
          log('Invalid response format for school exam subject details');
        }
      } else {
        log(
          'Failed to get school exam subject details: ${response?.statusMessage ?? "Unknown error"}',
        );
      }

      return null;
    } catch (e) {
      log('Error getting school exam subject details: $e');
      return null;
    }
  }

  Future<bool> submitStudentExamMark({
    required String examId,
    required String studentId,
    required String subjectId,
    required int markScored,
  }) async {
    try {
      // Prepare request body
      Map<String, dynamic> requestBody = {
        "examId": examId,
        "studentId": studentId,
        "subjectId": subjectId,
        "markScored": markScored,
      };

      // Make API call
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.submitExamMark,
        requestBody,
      );

      // Handle response
      if (response != null && response.statusCode == 200) {
        log('Mark submitted successfully: ${response.data}');

        // Show success message to user
        commonSnackBar(message: "Student mark submitted successfully");

        return true;
      } else {
        log(
          'Failed to submit student mark: ${response?.statusMessage ?? "Unknown error"}',
        );
        log('Response status code: ${response?.statusCode}');
        log('Response data: ${response?.data}');

        commonSnackBar(
          message: response?.data?['message'] ?? "Failed to submit mark",
        );

        return false;
      }
    } catch (e) {
      log('Error submitting student mark: $e');

      return false;
    }
  }

  Future<TeacherSchoolExamMarkEntryModel?> getStudentExamMark({
    required String examId,
    required String studentId,
    required String subjectId,
  }) async {
    try {
      final queryParams =
          'examId=$examId&studentId=$studentId&subjectId=$subjectId';

      // Make API call
      dio.Response? response = await api.getMethodWithDio(
        "${ApiNames.getStudentExamMark}?$queryParams",
      );

      if (response != null && response.statusCode == 200) {
        log('Mark retrieved successfully: ${response.data}');

        // Parse the response
        if (response.data['data'] != null &&
            response.data['data']['markEntry'] != null) {
          // Convert to model
          return TeacherSchoolExamMarkEntryModel.fromJson(
            response.data['data']['markEntry'],
          );
        } else {
          log('Mark entry not found in response');
          return null;
        }
      } else {
        // Log error details
        log(
          'Failed to get student mark: ${response?.statusMessage ?? "Unknown error"}',
        );
        log('Response status code: ${response?.statusCode}');

        return null;
      }
    } catch (e) {
      log('Error getting student mark: $e');
      return null;
    }
  }

  //* People API
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
}
