import 'dart:developer';

import 'package:Vadai/common_imports.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/school_all_exams_reports.dart';
import 'package:Vadai/model/students/school_exam_marks.dart';
import 'package:Vadai/model/students/school_exam_model.dart';
import 'package:Vadai/model/students/vad_test_model.dart';
import 'package:Vadai/model/students/vad_test_subjects_model.dart';
import 'package:dio/dio.dart' as dio;

class VadTestController extends GetxController {
  ApiHelper api = ApiHelper();
  List<VadTestSubjectsModel> vadTestSubjects = <VadTestSubjectsModel>[].obs;
  RxBool isLoading = false.obs;

  Future<void> getSubjectList() async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        ApiNames.getSubjectList,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          vadTestSubjects.clear();
          List<VadTestSubjectsModel> ls = <VadTestSubjectsModel>[];
          for (var vadTests in response.data['data']['vadTests']) {
            ls.add(VadTestSubjectsModel.fromJson(vadTests));
          }
          for (var vadTest in response.data['data']['vadTests']) {
            VadTestSubjectsModel vadTestSubjectsModel =
                VadTestSubjectsModel.fromJson(vadTest);
            ls.add(vadTestSubjectsModel);
          }
          vadTestSubjects.addAll(ls);
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

  Future<Map<String, List<VadTestModel>>?> getVadTest({
    required String subjectId,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        "${ApiNames.getVadTest}?subjectId=$subjectId",
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<VadTestModel> upcoming = <VadTestModel>[];
          List<VadTestModel> live = <VadTestModel>[];
          List<VadTestModel> past = <VadTestModel>[];
          for (var vadTests in response.data['data']['vadTests']['upcoming']) {
            VadTestModel vadTestModel = VadTestModel.fromJson(vadTests);
            upcoming.add(vadTestModel);
          }
          for (var vadTests in response.data['data']['vadTests']['live']) {
            VadTestModel vadTestModel = VadTestModel.fromJson(vadTests);
            live.add(vadTestModel);
          }
          for (var vadTests in response.data['data']['vadTests']['past']) {
            VadTestModel vadTestModel = VadTestModel.fromJson(vadTests);
            past.add(vadTestModel);
          }
          return {'upcoming': upcoming, 'live': live, 'past': past};
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getVadTest, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getVadTest: $e',
      );
    }
    return null;
  }

  Future<List<SchoolExamModel>?> getSchoolExams() async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        ApiNames.getSchoolExams,
      );

      if (response != null) {
        if (response.statusCode == 200) {
          List<SchoolExamModel> exams = <SchoolExamModel>[];
          List<dynamic> examsList =
              response.data['data']['schoolExamsWithSubjects'];
          for (var exam in examsList) {
            SchoolExamModel schoolExam = SchoolExamModel.fromJson(exam);
            exams.add(schoolExam);
          }

          return exams;
        } else {
          log('Error in getSchoolExams: ${response.statusMessage}');
        }
      } else {
        log('Error in getSchoolExams: response is null');
      }
    } catch (e) {
      log('Error in getSchoolExams: $e');
    }

    return null;
  }

  Future<List<SchoolExamMarks>?> getExamSubjectsWithMarks(String examId) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        "${ApiNames.getExamSubjectsWithMarks}/$examId",
      );

      if (response != null) {
        if (response.statusCode == 200) {
          List<SchoolExamMarks> subjectsWithMarks = <SchoolExamMarks>[];
          List<dynamic> subjectsData =
              response.data['data']['subjectsWithMarks'];

          for (var subject in subjectsData) {
            SchoolExamMarks examMark = SchoolExamMarks.fromJson(subject);
            subjectsWithMarks.add(examMark);
          }

          return subjectsWithMarks;
        } else {
          log('Error in getExamSubjectsWithMarks: ${response.statusMessage}');
        }
      } else {
        log('Error in getExamSubjectsWithMarks: response is null');
      }
    } catch (e) {
      log('Error in getExamSubjectsWithMarks: $e');
    }
    return null;
  }

  Future<ExamScoreReportResponse?> getExamScoreReportWithInfo() async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        ApiNames.getExamScoreReport,
      );

      if (response != null) {
        if (response.statusCode == 200) {
          ExamScoreReportResponse reportResponse =
              ExamScoreReportResponse.fromJson(response.data['data']);
          return reportResponse;
        } else {
          log('Error in getExamScoreReportWithInfo: ${response.statusMessage}');
        }
      } else {
        log('Error in getExamScoreReportWithInfo: response is null');
      }
    } catch (e) {
      log('Error in getExamScoreReportWithInfo: $e');
    }

    return null;
  }
}
