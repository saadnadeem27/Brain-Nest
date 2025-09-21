import 'dart:developer';

import 'package:Vadai/helper/api_helper.dart';
import '../../model/common/notification_model.dart';
import 'package:Vadai/model/students/rule_book_model.dart';
import 'package:Vadai/model/students/student_profile_model.dart';
import 'package:Vadai/model/students/vad_squad_review_model.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class StudentProfileController extends GetxController {
  ApiHelper api = ApiHelper();
  RxBool isLoading = false.obs;
  RxBool unReadNotification = false.obs;
  final Rx<StudentProfileModel?> studentProfile = Rx<StudentProfileModel?>(
    null,
  );

  @override
  void onInit() {
    super.onInit();
    getStudentProfile();
  }

  Future<StudentProfileModel?> getStudentProfile() async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        ApiNames.getStudentProfile,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          Map<String, dynamic> studentData = response.data['data']['student'];
          StudentProfileModel student = StudentProfileModel.fromJson(
            studentData,
          );
          studentProfile(StudentProfileModel.fromJson(studentData));
          return student;
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

  Future<int?> updateUserInfo({String? profileImg}) async {
    dio.MultipartFile? profileImgMultipart;
    if (profileImg != null) {
      profileImgMultipart = await dio.MultipartFile.fromFile(
        profileImg,
        filename: profileImg.split("/").last,
        contentType: dio.DioMediaType('image', profileImg.split(".").last),
      );
    }
    Map<String, dynamic> body = {
      if (profileImgMultipart != null)
        ApiParameter.profileImage: profileImgMultipart,
    };
    try {
      dio.FormData fromData = dio.FormData.fromMap(body);
      final response = await api.postMethodWithDio(
        ApiNames.uploadProfileImage,
        fromData,
        snakeBar: false,
      );
      if (response != null) {
        return response.statusCode;
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in updateUserInfo: $e',
      );
    }
    return null;
  }

  Future<Map<String, dynamic>?> getNotification({int pageKey = 1}) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        "${ApiNames.getNotification}?pageNumber=$pageKey",
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<NotificationModel> notificationList = [];
          for (var item in response.data['data']['notifications']) {
            notificationList.add(NotificationModel.fromJson(item));
          }
          Map<String, dynamic> data = {
            ApiParameter.list: notificationList,
            ApiParameter.hasNext: response.data['data']['hasNext'],
          };
          return data;
        }
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getNotification: $e',
      );
    }
    return null;
  }

  Future<void> getNotificationCount() async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        ApiNames.getNotificationCount,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          unReadNotification.value = response.data['data']['badgeCount'] > 0;
        }
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getNotificationCount: $e',
      );
    }
  }

  Future<List<RuleBookModel>?> getRuleBookList() async {
    try {
      dio.Response? response = await api.getMethodWithDio(ApiNames.getRuleBook);
      if (response != null) {
        List<RuleBookModel> ruleBookList = [];
        if (response.statusCode == 200) {
          for (var item in response.data['data']['rulebooks']) {
            ruleBookList.add(RuleBookModel.fromJson(item));
          }
        }
        return ruleBookList;
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getNotificationCount: $e',
      );
    }
    return null;
  }

  Future<Map<String, dynamic>?> getVadSquadReviewList({int pageKey = 1}) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getVadSquadReview}?pageNumber=$pageKey',
      );
      if (response != null) {
        List<VADSquadReviewModel> ls = [];
        if (response.statusCode == 200) {
          for (var item in response.data['data']['reviews']) {
            ls.add(VADSquadReviewModel.fromJson(item));
          }
        }
        return {
          ApiParameter.list: ls,
          ApiParameter.hasNext: response.data['data']['hasNext'],
        };
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getVadSquadReviewList: $e',
      );
    }
    return null;
  }

  Future<void> submitFeedback({
    required String title,
    required String content,
  }) async {
    Map<String, dynamic> body = {
      ApiParameter.title: title,
      ApiParameter.content: content,
    };
    try {
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.sendFeedback,
        body,
      );
      if (response != null) {
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in submitFeedback, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in submitFeedback: $e',
      );
    }
  }
}
