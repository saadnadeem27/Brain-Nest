import 'dart:convert';
import 'dart:developer';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/ai_message_model.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class AIController extends GetxController {
  final String apiKey =
      "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";
  ApiHelper api = ApiHelper();
  RxList<ChatMessage> chatHistory = <ChatMessage>[].obs;

  Future<void> fetchGroqResponse({required String prompt}) async {
    var headers = {'Authorization': 'Bearer $apiKey'};

    var messages = chatHistory.map((msg) => msg.toJson()).toList();

    var body = jsonEncode({
      "model": "llama-3.3-70b-versatile",
      "messages": messages,
    });

    try {
      var response = await api.postMethodWithDio(
        ApiNames.aiUrl,
        body,
        header: headers,
        snakeBar: false,
      );
      log('-------------------> response is ${json.encode(response?.data)}');

      if (response != null && response.data != null) {
        var responseData = response.data;
        var message = responseData['choices'][0]['message']['content'];
        chatHistory.add(ChatMessage(role: "system", content: message));
      } else {
        log('Response or response data is null');
      }
    } catch (e) {
      log('Failed to connect to API: $e');
    }
  }
}
