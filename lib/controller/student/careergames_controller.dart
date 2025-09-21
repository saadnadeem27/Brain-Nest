import 'dart:developer';
import 'package:Vadai/common/common_widgets.dart';
import 'package:Vadai/common_imports.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/careerdashboard_model.dart';
import 'package:Vadai/model/students/job_role_model.dart';
import 'package:Vadai/model/students/webinars_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;

class CareerGamesController extends GetxController {
  ApiHelper api = ApiHelper();
  RxBool isLoading = false.obs;
  RxBool hasNextJobRolePage = false.obs;
  RxList<WebinarsModel?> webinarsList = <WebinarsModel?>[].obs;
  RxList<JobRoleModel?> jobRoleList = <JobRoleModel?>[].obs;
  RxList<JobRoleCategory?> jobRoleCategoryList =
      <JobRoleCategory?>[].obs; // for job role categories

  //! 1: Get webinars, pagination
  Future<Map<String, dynamic>?> getWebinars({int? pageNumber = 1}) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getAllWebinars}?pageNumber=$pageNumber',
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<WebinarsModel> ls = [];
          if (pageNumber == 1) {
            webinarsList.clear();
          }
          for (var i
              in response.data[ApiParameter.data][ApiParameter.webinars]) {
            ls.add(WebinarsModel.fromJson(i));
          }
          final bool? hasNext =
              response.data[ApiParameter.data][ApiParameter.hasNext];
          webinarsList.addAll(ls);
          for (var webinar in ls) {
            if (webinar.coverImage != null && webinar.coverImage!.isNotEmpty) {
              precacheImage(
                CachedNetworkImageProvider(webinar.coverImage!),
                Get.context!,
              ).catchError((_) {
                // Silently handle any errors during precaching
              });
            }
          }
          return {ApiParameter.webinars: ls, ApiParameter.hasNext: hasNext};
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getWebinars, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getWebinars: $e',
      );
    }
    return null;
  }

  //! 2: Register webinars
  Future<void> registerWebinars({
    required String question,
    required String webinarId,
  }) async {
    Map<String, dynamic> body = {
      ApiParameter.webinarId: webinarId,
      ApiParameter.question: question,
    };
    try {
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.registerWebinars,
        body,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          return;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in registerWebinars, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in registerWebinars: $e',
      );
    }
  }

  //! 3: Webinar suggestions
  Future<void> webinarsSuggestion({required String suggestion}) async {
    Map<String, dynamic> body = {ApiParameter.suggestion: suggestion};
    try {
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.webinarsSuggestion,
        body,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          return;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in webinarsSuggestion, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in webinarsSuggestion: $e',
      );
    }
  }

  //! 4: Get job roles, pagination and for National / Global
  Future<Map<String, dynamic>?> getJobRole({
    int? pageNumber = 1,
    String range = 'National',
    String category = '',
    String searchTag = '',
    CancelToken? cancelToken,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getJobRoles}?pageNumber=$pageNumber&range=$range&category=$category&searchTag=$searchTag',
        cancelToken: cancelToken,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<JobRoleModel> ls = [];
          if (pageNumber == 1) {
            jobRoleList.clear();
          }
          for (var i
              in response.data[ApiParameter.data][ApiParameter.jobRoles]) {
            ls.add(JobRoleModel.fromJson(i));
          }
          hasNextJobRolePage.value =
              response.data[ApiParameter.data][ApiParameter.hasNext];
          jobRoleList.addAll(ls);
          return {ApiParameter.jobRoles: ls};
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getJobRole, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getJobRole: $e',
      );
    }
    return null;
  }

  //! 5: Get job role details
  Future<JobRoleModel?> getJobRoleDetails({required String id}) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.jobRolesDetails}/$id',
      );
      if (response != null) {
        if (response.statusCode == 200) {
          JobRoleModel? temp;
          temp = JobRoleModel.fromJson(
            response.data[ApiParameter.data][ApiParameter.jobRole],
          );
          return temp;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getJobRoleDetails, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getJobRoleDetails: $e',
      );
    }
    return null;
  }

  //! 6: Save any job role
  Future<void> jobRoleSaved({required String id}) async {
    try {
      dio.Response? response = await api.postMethodWithDio(
        '${ApiNames.jobRoleSaved}/$id',
        {},
        snakeBar: false,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          return;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in jobRoleSaved, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in jobRoleSaved: $e',
      );
    }
  }

  //! 7: get saved job roles
  Future<Map<String, dynamic>?> getSavedJobRole({int? pageNumber = 1}) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getSavedJobRoles}?pageNumber=$pageNumber',
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<JobRoleModel> ls = [];
          for (var item
              in response.data[ApiParameter.data][ApiParameter.savedJobRoles]) {
            ls.add(JobRoleModel.fromJson(item[ApiParameter.jobRole]));
          }
          final bool? hasNext =
              response.data[ApiParameter.data][ApiParameter.hasNext];
          return {ApiParameter.jobRoles: ls, ApiParameter.hasNext: hasNext};
        }
      } else {}
    } catch (e) {}
    return null;
  }

  //! 8: Job role categories
  Future<void> getJobRoleCategories() async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        ApiNames.getJobRolesCategories,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<JobRoleCategory?> ls = [];
          for (var i
              in response.data[ApiParameter.data][ApiParameter.categories]) {
            ls.add(JobRoleCategory.fromJson(i));
          }
          jobRoleCategoryList.addAll(ls);
          return;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getJobRoleDetails, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getJobRoleDetails: $e',
      );
    }
    return;
  }

  //! 9: Job role suggestions
  Future<void> jobRoleSuggestion({required String suggestion}) async {
    Map<String, dynamic> body = {ApiParameter.suggestion: suggestion};
    try {
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.jobRoleSuggestion,
        body,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          return;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in jobRoleSuggestion, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in jobRoleSuggestion: $e',
      );
    }
  }

  //! 10: Get career details
  Future<CareerDashboardModel?> getCareerDetails() async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        ApiNames.careerDetails,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          CareerDashboardModel? temp;
          temp = CareerDashboardModel.fromJson(
            response.data[ApiParameter.data][ApiParameter.career],
          );
          return temp;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getCareerDetails, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getCareerDetails: $e',
      );
    }
    return null;
  }

  //! 11: Save career details
  Future<bool?> saveCareerDetails({
    String? goal,
    String? strength,
    String? weakness,
    List<Plans>? plans,
  }) async {
    Map<String, dynamic> body = {};
    if (goal != null) body[ApiParameter.goal] = goal;
    if (strength != null) body[ApiParameter.strength] = strength;
    if (weakness != null) body[ApiParameter.weakness] = weakness;
    if (plans != null && plans.isNotEmpty) {
      body[ApiParameter.plans] = plans.map((plan) => plan.toJson()).toList();
    }
    try {
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.careerSubmit,
        body,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          return true;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in saveCareerDetails, response is null',
        );
        return false;
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in saveCareerDetails: $e',
      );
    }
    return false;
  }

  //! 12: Submit VAD Squad reviews
  Future<void> submitVADSquadReviews({required String partToReview}) async {
    Map<String, dynamic> body = {ApiParameter.partToReview: partToReview};
    try {
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.submitVADSquadReviews,
        body,
      );
      if (response != null) {
        return;
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in submitVADSquadReviews, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in submitVADSquadReviews: $e',
      );
    }
  }

  Future<bool> unsaveJobRole({required String jobRoleId}) async {
    try {
      dio.Response? response = await api.postMethodWithDio(
        '${ApiNames.unsaveJobRole}/$jobRoleId',
        {},
      );

      if (response != null) {
        return true;
      }
    } catch (e) {
      log('Error in unsaveJobRole: $e');
    }
    return false;
  }

  Future<String?> generateJobRolePrompt({required String jobRoleId}) async {
    Map<String, dynamic> body = {"jobRoleId": jobRoleId};
    try {
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.generateJobRolePrompt,
        body,
      );

      if (response != null && response.data[ApiParameter.data] != null) {
        return response.data[ApiParameter.data]["prompt"];
      }
    } catch (e) {
      log('Error in generateJobRolePrompt: $e');
    }
    return null;
  }

  Future<String?> generateCareerDashboardPrompt({
    required String section,
    String? planId,
    required String selectedOption,
  }) async {
    Map<String, dynamic> body = {
      "section": section,
      "selectedOption": selectedOption,
    };

    if (planId != null) {
      body["planId"] = planId;
    }

    try {
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.generateCareerDashboardPrompt,
        body,
      );

      if (response != null && response.data[ApiParameter.data] != null) {
        return response.data[ApiParameter.data]["prompt"];
      }
    } catch (e) {
      log('Error in generateCareerDashboardPrompt: $e');
      commonSnackBar(
        message: "Failed to generate prompt. Please try again.",
        color: Colors.red,
      );
    }
    return null;
  }
}
