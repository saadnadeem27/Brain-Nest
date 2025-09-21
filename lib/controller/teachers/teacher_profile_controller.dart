import 'dart:developer';
import 'dart:io';

import 'package:Vadai/helper/api_helper.dart';
import '../../model/common/notification_model.dart';
import 'package:Vadai/model/teachers/teacher_profile_model.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class TeacherProfileController extends GetxController {
  ApiHelper api = ApiHelper();
  RxBool isLoading = false.obs;
  RxBool unReadNotification = false.obs;
  final Rx<TeachersProfileModel?> teacherProfile = Rx<TeachersProfileModel?>(
    null,
  );

  @override
  void onInit() {
    super.onInit();
    getTeacherProfile();
  }

  Future<TeachersProfileModel?> getTeacherProfile() async {
    isLoading.value = true;
    try {
      dio.Response? response = await api.getMethodWithDio(
        "${ApiNames.baseUrl}/api/v1/teachers/account/get-profile",
      );

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> teacherData = response.data['data']['teacher'];
        TeachersProfileModel teacher = TeachersProfileModel.fromJson(
          teacherData,
        );
        teacherProfile(teacher);
        log('Teacher profile fetched successfully');
        return teacher;
      } else {
        log(
          'Error fetching teacher profile: ${response?.statusMessage ?? "Unknown error"}',
        );
      }
    } catch (e) {
      log('Exception in getTeacherProfile: $e');
    } finally {
      isLoading.value = false;
    }
    return null;
  }

  Future<bool?> updateTeacherProfileImage({String? profileImg}) async {
    Map<String, dynamic> body = {"profileImage": profileImg};
    try {
      dio.Response? response = await api.putMethodWithDio(
        ApiNames.updateTeachersProfile,
        body,
        snakeBar: false,
      );
      if (response != null && response.statusCode == 200) {
        log('Teacher profile image updated successfully');
        return true;
      } else {
        log(
          'Error updating teacher profile image: ${response?.statusMessage ?? "Unknown error"}',
        );
      }
    } catch (e) {
      log('Error in updateTeacherProfileImage: $e');
    }
    return false;
  }

  Future<void> getNotificationCount() async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        ApiNames.teacherGetNotificationCount,
      );

      if (response != null && response.statusCode == 200) {
        unReadNotification.value = response.data['data']['badgeCount'] > 0;
      }
    } catch (e) {
      log('Error in getNotificationCount: $e');
    }
  }

  Future<Map<String, dynamic>?> getNotifications({int pageKey = 1}) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        "${ApiNames.teacherGetNotifications}?pageNumber=$pageKey",
      );

      if (response != null && response.statusCode == 200) {
        List<NotificationModel> notificationList = [];
        for (var item in response.data['data']['notifications']) {
          notificationList.add(NotificationModel.fromJson(item));
        }

        return {
          ApiParameter.list: notificationList,
          ApiParameter.hasNext: response.data['data']['hasNext'],
        };
      }
    } catch (e) {
      log('Error in getNotifications: $e');
    }
    return null;
  }

  /// Submits teacher feedback
  Future<void> submitFeedback({
    required String title,
    required String content,
  }) async {
    Map<String, dynamic> body = {
      ApiParameter.title: title,
      ApiParameter.content: content,
    };

    try {
      await api.postMethodWithDio(
        "${ApiNames.baseUrl}/api/v1/teachers/send-feedback",
        body,
      );
    } catch (e) {
      log('Error in submitFeedback: $e');
    }
  }

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
