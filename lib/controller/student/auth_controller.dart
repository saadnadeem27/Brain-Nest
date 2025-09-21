import 'dart:io';

import 'package:Vadai/common_imports.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/helper/local_storage_helper.dart';
import 'package:dio/dio.dart' as dio;

class AuthController extends GetxController {
  ApiHelper api = ApiHelper();

  Future<bool> sendOtp({required String email}) async {
    Map<String, dynamic> body = {ApiParameter.email: email.toLowerCase()};
    try {
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.sendOtp,
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
      log('Error in sending OTP: $e');
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
        ApiNames.verifyOtp,
        body,
        snakeBar: false,
      );

      if (response != null) {
        if (response.statusCode == 200) {
          if (response.data != null &&
              response.data['data']['student']['schoolId'] != null &&
              response.data['data']['student']['schoolId'] != "") {
            final String token =
                response.data['data']['tokens']['access']['token'];
            LocalStorage.write(key: LocalStorageKeys.token, data: token);
            LocalStorage.write(key: LocalStorageKeys.userRole, data: "student");
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
      log('Error in verifying OTP: $e');
      return {
        'success': false,
        'message': 'An error occurred during verification',
      };
    }
    return {'success': false, 'message': 'Could not connect to server'};
  }

  Future<Map<String, dynamic>> requestAccessLevelChange({
    required bool fullPotentialAccess,
  }) async {
    try {
      Map<String, dynamic> body = {"fullPotentialAccess": fullPotentialAccess};

      log(
        'Requesting access level change to ${fullPotentialAccess ? "Premium" : "Basic"}',
      );

      dio.Response? response = await api.postMethodWithDio(
        ApiNames.changeAccessLevel,
        body,
        snakeBar: true,
      );

      if (response != null) {
        if (response.statusCode == 200) {
          return {
            'success': true,
            'message':
                response.data['message'] ?? 'Request submitted successfully',
          };
        } else {
          return {
            'success': false,
            'message': response.data['message'] ?? 'Failed to submit request',
          };
        }
      }
    } catch (e) {
      log('Error requesting access level change: $e');
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
        ApiNames.getSignedUrl,
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
      log("Error in getSignedUrl: $e");
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
        log("File upload successful");
        return true;
      } else {
        log("File upload failed - Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      log("Error uploading file: $e");
      return false;
    }
  }
}
