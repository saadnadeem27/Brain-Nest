import 'dart:io';

import 'package:Vadai/common_imports.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/helper/local_storage_helper.dart';
import 'package:dio/dio.dart' as dio;

class TeacherAuthController extends GetxController {
  ApiHelper api = ApiHelper();

  Future<bool> sendOtp({required String email}) async {
    Map<String, dynamic> body = {ApiParameter.email: email.toLowerCase()};
    try {
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.teacherSendOtp,
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
      log('Error in sending teacher OTP: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    Map<String, dynamic> body = {
      ApiParameter.email: email.toLowerCase(),
      ApiParameter.otp: otp,
    };
    try {
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.teacherVerifyOtp,
        body,
        snakeBar: false,
      );

      if (response != null) {
        if (response.statusCode == 200) {
          if (response.data != null &&
              response.data['data']['teacher']['classesAndSubjects'] != null &&
              (response.data['data']['teacher']['classesAndSubjects'] ?? [])
                  .isNotEmpty) {
            final String token =
                response.data['data']['tokens']['access']['token'];
            LocalStorage.write(key: LocalStorageKeys.token, data: token);
            LocalStorage.write(key: LocalStorageKeys.userRole, data: "teacher");
            return {'success': true, 'isRegistered': true, 'token': token};
          }
          final String preAuthToken =
              response.data['data']['tokens']['access']['token'];
          LocalStorage.write(
            key: LocalStorageKeys.preAuthToken,
            data: preAuthToken,
          );
          return {'success': true, 'isRegistered': false};
        } else {
          // OTP verification failed
          return {
            'success': false,
            'message': response.data?['message'] ?? 'OTP verification failed',
          };
        }
      }
    } catch (e) {
      log('Error in verifying teacher OTP: $e');
      return {
        'success': false,
        'message': 'An error occurred during verification',
      };
    }
    return {'success': false, 'message': 'Could not connect to server'};
  }

  Future<Map<String, dynamic>> completeTeacherProfile({
    required String name,
    required String schoolId,
    required String classId,
    required String sectionId,
    required List<Map<String, String>> classesAndSubjects,
    String? profileImageUrl,
    String? teachersWhatsappNumber,
  }) async {
    try {
      Map<String, dynamic> body = {
        ApiParameter.name: name,
        ApiParameter.schoolId: schoolId,
        "classId": classId,
        "sectionId": sectionId,
        "classesAndSubjects": classesAndSubjects,
      };

      // Add optional fields if they are provided
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        body['profileImage'] = profileImageUrl;
      }

      if (teachersWhatsappNumber != null && teachersWhatsappNumber.isNotEmpty) {
        body['teachersWhatsappNumber'] = teachersWhatsappNumber;
      }

      log('Complete teacher profile request: $body');

      dio.Response? response = await api.postMethodWithDio(
        ApiNames.teacherCompleteProfile,
        body,
        snakeBar: false,
      );

      if (response != null) {
        if (response.statusCode == 200) {
          // Store the token if it's returned in the response
          if (response.data != null &&
              response.data['data'] != null &&
              response.data['data']['tokens'] != null &&
              response.data['data']['tokens']['access'] != null &&
              response.data['data']['tokens']['access']['token'] != null) {
            final String token =
                response.data['data']['tokens']['access']['token'];
            await LocalStorage.write(key: LocalStorageKeys.token, data: token);
          }

          return {'success': true, 'message': 'Profile completed successfully'};
        } else {
          log('Error in completeTeacherProfile: ${response.statusMessage}');
          return {
            'success': false,
            'message': response.data?['message'] ?? 'Profile creation failed',
          };
        }
      }
    } catch (e) {
      log('Exception in completeTeacherProfile: $e');
      return {
        'success': false,
        'message': 'An error occurred while completing profile',
      };
    }
    return {'success': false, 'message': 'Could not connect to server'};
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
