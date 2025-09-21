import 'dart:io';

import 'package:Vadai/common_imports.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/teachers/teacher_classes_data.dart';
import 'package:Vadai/model/teachers/teacher_schoolexam_progress_model.dart';
import 'package:Vadai/model/teachers/teacher_vadtest_progress_model.dart';
import 'package:dio/dio.dart' as dio;

class TeacherProgressTrackingController extends GetxController {
  ApiHelper api = ApiHelper();
  RxBool isLoading = false.obs;
  RxBool hasDataChanged = false.obs;
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

  Future<List<TeacherVadTestProgressModel>?> getVadTestProgress({
    required String classId,
    required String sectionId,
    required String subjectId,
  }) async {
    try {
      final url =
          '${ApiNames.getVadTestProgress}?classId=$classId&sectionId=$sectionId&subjectId=$subjectId';
      log('Calling VAD test progress API: $url');
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getVadTestProgress}?classId=$classId&sectionId=$sectionId&subjectId=$subjectId',
      );

      if (response != null && response.statusCode == 200) {
        List<TeacherVadTestProgressModel> ls = [];
        List<dynamic> items =
            response.data[ApiParameter.data]["librariesWithProgress"];
        for (var item in items) {
          TeacherVadTestProgressModel tmp =
              TeacherVadTestProgressModel.fromJson(item);
          ls.add(tmp);
        }
        return ls;
      } else {
        log(
          'Failed to load VAD Test progress: ${response?.statusMessage ?? "Unknown error"}',
        );
        return null;
      }
    } catch (e) {
      log('Error loading VAD Test progress: $e');
      commonSnackBar(
        message: "An error occurred while loading test progress.",
        color: Colors.red,
      );
      return null;
    }
  }

  Future<List<TeacherSchoolExamProgressModel>?> getSchoolExamProgress({
    required String classId,
    required String sectionId,
    required String subjectId,
  }) async {
    try {
      final url =
          '${ApiNames.getSchoolExamProgress}?classId=$classId&sectionId=$sectionId&subjectId=$subjectId';
      log('Calling school exam progress API: $url');
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getSchoolExamProgress}?classId=$classId&sectionId=$sectionId&subjectId=$subjectId',
      );

      if (response != null && response.statusCode == 200) {
        List<TeacherSchoolExamProgressModel> ls = [];
        List<dynamic> items =
            response.data[ApiParameter.data]["examWithProgress"];
        for (var item in items) {
          TeacherSchoolExamProgressModel tmp =
              TeacherSchoolExamProgressModel.fromJson(item);
          ls.add(tmp);
        }
        return ls;
      } else {
        log(
          'Failed to load school exam progress: ${response?.statusMessage ?? "Unknown error"}',
        );
        return null;
      }
    } catch (e) {
      log('Error loading school exam progress: $e');
      return null;
    }
  }

  Future<bool> markProgress({
    required String topicId,
    required String classId,
    required String sectionId,
  }) async {
    try {
      Map<String, dynamic> body = {"classId": classId, "sectionId": sectionId};

      dio.Response? response = await api.postMethodWithDio(
        '${ApiNames.baseUrl}/api/v1/vad-test/teachers/mark-progress/$topicId',
        body,
        snakeBar: true,
      );

      if (response != null && response.statusCode == 200) {
        log('Progress marked successfully');
        return true;
      } else {
        log(
          'Failed to mark progress: ${response?.statusMessage ?? "Unknown error"}',
        );
        commonSnackBar(
          message: "Failed to mark progress. Please try again.",
          color: Colors.red,
        );
        return false;
      }
    } catch (e) {
      log('Error marking progress: $e');
      commonSnackBar(
        message: "An error occurred while marking progress.",
        color: Colors.red,
      );
      return false;
    }
  }
}
