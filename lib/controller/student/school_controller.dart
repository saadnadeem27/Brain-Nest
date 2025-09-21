import 'dart:developer';

import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/helper/local_storage_helper.dart';
import 'package:Vadai/model/students/school_details_model.dart';
import 'package:Vadai/model/students/subject_model.dart';
import 'package:Vadai/routes.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class SchoolController extends GetxController {
  ApiHelper api = ApiHelper();

  Future<List<SchoolDetailModel>?> getSchoolList() async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        ApiNames.getSchoolDetails,
      );
      List<SchoolDetailModel> schoolList = [];
      if (response != null) {
        if (response.statusCode == 200) {
          List studentData = response.data['data']["schools"];
          for (var i = 0; i < studentData.length; i++) {
            SchoolDetailModel school = SchoolDetailModel.fromJson(
              studentData[i],
            );
            schoolList.add(school);
          }
          return schoolList;
        } else {
          log(
            '------------------------------->>>>>>>>>>>>>> Error in getStudentProfile, response status not 200: ${response.data}',
          );
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getStudentProfile, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getStudentProfile: $e',
      );
    }
    return null;
  }

  Future<List<SubjectModel?>?> getSubjectList({
    required String schoolId,
    required String classId,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getSchoolSubjects}?schoolId=$schoolId&classId=$classId',
      );
      List<SubjectModel?> subjectList = [];
      if (response != null) {
        if (response.statusCode == 200) {
          List ls = response.data['data']["subjects"];
          for (var i = 0; i < ls.length; i++) {
            SubjectModel school = SubjectModel.fromJson(ls[i]);
            subjectList.add(school);
          }
          return subjectList;
        } else {
          log(
            '------------------------------->>>>>>>>>>>>>> Error in getSubjectList, response status not 200: ${response.data}',
          );
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
    return null;
  }

  Future<bool> completeProfile({
    required String schoolId,
    required String classId,
    required String sectionId,
    required String name,
    required List<String> subjects,
    String? rollNumber,
    String? phoneNumber,
    String? parentWhatsapp,
    String? studentWhatsapp,
    String? profileImageUrl,
  }) async {
    try {
      Map<String, dynamic> body = {
        ApiParameter.name: name,
        ApiParameter.schoolId: schoolId,
        ApiParameter.classId: classId,
        ApiParameter.sectionId: sectionId,
        ApiParameter.subjects: subjects,
      };

      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        body['profileImage'] = profileImageUrl;
      }

      if (rollNumber != null && rollNumber.isNotEmpty) {
        body['rollNumber'] = int.tryParse(rollNumber) ?? rollNumber;
      }

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        body['phoneNumber'] = phoneNumber;
      }

      if (parentWhatsapp != null && parentWhatsapp.isNotEmpty) {
        body['parentWhatsappNumber'] = parentWhatsapp;
      }

      if (studentWhatsapp != null && studentWhatsapp.isNotEmpty) {
        body['studentWhatsappNumber'] = studentWhatsapp;
      }

      log('Complete profile request: $body');

      dio.Response? response = await api.postMethodWithDio(
        ApiNames.completeProfile,
        body,
        snakeBar: false,
      );

      if (response != null) {
        if (response.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      log('Exception in completeProfile: $e');
    }
    return false;
  }
}
