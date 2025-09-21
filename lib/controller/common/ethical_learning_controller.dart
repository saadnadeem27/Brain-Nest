import 'dart:developer';
import 'dart:io';

import 'package:Vadai/common_imports.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/compendia_model.dart';
import 'package:Vadai/model/students/quiz_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;

class EthicalLearningController extends GetxController {
  ApiHelper api = ApiHelper();
  RxBool isLoading = false.obs;
  RxBool hasNext = false.obs;
  RxList<CompendiaCategoryModel?> categories = <CompendiaCategoryModel?>[].obs;
  RxList<CompendiaSubCategoryModel?> subCategories =
      <CompendiaSubCategoryModel?>[].obs;
  RxList<CompendiaOverviewModel?> compendia = <CompendiaOverviewModel?>[].obs;

  Future<void> getCategories() async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        ApiNames.getEthicalLearningCategories,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<CompendiaCategoryModel?> ls = [];
          for (var item in response.data['data']['categories']) {
            ls.add(CompendiaCategoryModel.fromJson(item));
          }
          categories.value = ls;
          update();
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getCategories, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getCategories: $e',
      );
    }
  }

  Future<void> getSubCategories({required String categoryId}) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getEthicalLearningSubCategories}/$categoryId',
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<CompendiaSubCategoryModel?> ls = [];
          for (var item in response.data['data']['subcategories']) {
            ls.add(CompendiaSubCategoryModel.fromJson(item));
          }
          subCategories.value = ls;
          update();
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getSubCategories, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getSubCategories: $e',
      );
    }
  }

  Future<void> getAllCompendia({
    int pageNumber = 1,
    String searchTag = '',
    required String category,
    required String subCategory,
    CancelToken? cancelToken,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getEthicalLearningAllCompendia}?pageNumber=$pageNumber&searchTag=$searchTag&category=$category&subcategory=$subCategory',
        cancelToken: cancelToken,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<CompendiaOverviewModel?> ls = [];
          for (var item in response.data['data']['compendia']) {
            ls.add(CompendiaOverviewModel.fromJson(item));
          }
          if (pageNumber == 1) {
            compendia.value = ls;
          } else {
            compendia.addAll(ls);
          }
          hasNext.value =
              response.data[ApiParameter.data][ApiParameter.hasNext];
          update();
          for (var compendium in ls) {
            if (compendium?.coverImage != null &&
                compendium!.coverImage!.isNotEmpty) {
              precacheImage(
                CachedNetworkImageProvider(compendium.coverImage!),
                Get.context!,
              ).catchError((e) {
                // Silently handle any errors during precaching
                log('Error precaching compendium image: $e');
              });
            }
          }
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getAllCompendia, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getAllCompendia: $e',
      );
    }
  }

  Future<Map<String, dynamic>?> getMyCompendia({int pageNumber = 1}) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getEthicalLearningMyCompendia}?pageNumber=$pageNumber',
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<CompendiaOverviewModel?> ls = [];
          for (var item in response.data['data']['compendia']) {
            ls.add(CompendiaOverviewModel.fromJson(item));
          }
          hasNext.value =
              response.data[ApiParameter.data][ApiParameter.hasNext];
          for (var compendium in ls) {
            if (compendium?.coverImage != null &&
                compendium!.coverImage!.isNotEmpty) {
              precacheImage(
                CachedNetworkImageProvider(compendium.coverImage!),
                Get.context!,
              ).catchError((e) {
                // Silently handle any errors during precaching
                log('Error precaching my compendia image: $e');
              });
            }
          }
          return {ApiParameter.list: ls, ApiParameter.hasNext: hasNext.value};
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getMyCompendia, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getMyCompendia: $e',
      );
    }
  }

  Future<CompendiaDetailModel?> getCompendia({
    required String compendiaId,
  }) async {
    try {
      dio.Response? response = await api.getMethodWithDio(
        '${ApiNames.getEthicalLearningCompendia}/$compendiaId',
      );
      if (response != null) {
        if (response.statusCode == 200) {
          CompendiaDetailModel? temp = CompendiaDetailModel.fromJson(
            response.data['data'],
          );
          return temp;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in getCompendia, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in getCompendia: $e',
      );
    }
    return null;
  }

  Future<bool?> pinCompendia({required String compendiaId}) async {
    try {
      dio.Response? response = await api.postMethodWithDio(
        '${ApiNames.pinCompendia}/$compendiaId',
        {},
        snakeBar: false,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          return true;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in pinCompendia, response is null',
        );
        return false;
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in pinCompendia: $e',
      );
    }
    return false;
  }

  Future<bool?> removePinCompendia({required String compendiaId}) async {
    try {
      dio.Response? response = await api.postMethodWithDio(
        '${ApiNames.removePinCompendia}/$compendiaId',
        {},
        snakeBar: false,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          return true;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in removePinCompendia, response is null',
        );
        return false;
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in removePinCompendia: $e',
      );
    }
    return false;
  }

  Future<bool?> addCompendia({
    required String title,
    required String contents,
    required List<String> websiteLinks,
    required String coverImage,
    required List<String> images,
    required String category,
    required String subcategory,
    required int numberOfQuestions,
    required List<dynamic> MCQs,
    required String continuedFrom,
  }) async {
    Map<String, dynamic> data = {
      ApiParameter.title: title,
      ApiParameter.contents: contents,
      ApiParameter.websiteLinks: websiteLinks,
      ApiParameter.coverImage: coverImage,
      ApiParameter.images: images,
      ApiParameter.category: category,
      ApiParameter.subcategory: subcategory,
      ApiParameter.numberOfQuestions: numberOfQuestions,
      ApiParameter.MCQs: MCQs,
      ApiParameter.continuedFrom: continuedFrom,
    };
    try {
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.addCompendia,
        data,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          return true;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in addCompendia, response is null',
        );
        return false;
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in addCompendia: $e',
      );
    }
    return false;
  }

  Future<bool?> addCompendiaSuggestion({
    required String category,
    required String subcategory,
    required String suggestions,
  }) async {
    Map<String, dynamic> data = {
      ApiParameter.category: category,
      ApiParameter.subcategory: subcategory,
      ApiParameter.suggestions: suggestions,
    };
    try {
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.addCompendiaSuggestion,
        data,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          return true;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in addCompendiaSuggestion, response is null',
        );
        return false;
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in addCompendiaSuggestion: $e',
      );
    }
    return false;
  }

  Future<List<QuizModel>?> generateQuiz({
    required String query,
    required String numberOfQuestions,
  }) async {
    Map<String, dynamic> data = {
      ApiParameter.query: query,
      ApiParameter.numberOfQuestions: numberOfQuestions,
    };
    try {
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.generateQuiz,
        data,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          List<QuizModel> ls = [];
          for (var item in response.data['data']['response']) {
            ls.add(QuizModel.fromJson(item));
          }
          return ls;
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in generateQuiz, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in generateQuiz: $e',
      );
    }
    return null;
  }

  Future<String?> generateCompendiaPrompt({required String compendiaId}) async {
    Map<String, dynamic> data = {ApiParameter.compendiumId: compendiaId};
    try {
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.generateCompendiaPrompt,
        data,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          String? prompt = response.data['data']['prompt'];
          return prompt;
        } else {
          log(
            '------------------------------->>>>>>>>>>>>>> Error in generateCompendiaPrompt, status code: ${response.statusCode}',
          );
        }
      } else {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in generateCompendiaPrompt, response is null',
        );
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in generateCompendiaPrompt: $e',
      );
    }
    return null;
  }

  Future<bool> submitCompendiaQuiz({
    required String compendiaId,
    required List<Map<String, dynamic>> answers,
  }) async {
    Map<String, dynamic> body = {ApiParameter.MCQAnswers: answers};
    try {
      dio.Response? response = await api.postMethodWithDio(
        ApiNames.submitCompendiaQuiz,
        body,
      );

      if (response != null && response.statusCode == 200) {
        commonSnackBar(message: 'Quiz submitted successfully');
        return true;
      }
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in submitCompendiaQuiz: $e',
      );
    }
    return false;
  }

  Future<bool> submitCompendiaForReview({
    required String compendiaId,
    required String partToReview,
  }) async {
    Map<String, dynamic> data = {"partToReview": partToReview};

    try {
      dio.Response? response = await api.postMethodWithDio(
        "${ApiNames.submitCompendiaForReview}$compendiaId",
        data,
      );

      if (response != null && response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      log('Error in submitCompendiaForReview: $e');
    }
    return false;
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
