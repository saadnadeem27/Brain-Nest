import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/common/ethical_learning_controller.dart';
import 'package:Vadai/model/students/quiz_model.dart';
import 'package:Vadai/view/common/ethical_learning/upload_compendia/screens/edit_quiz.dart';
import 'package:flutter/services.dart';

class WebsiteLinkSection extends StatefulWidget {
  final TextEditingController controller;
  final RxList<String> websiteLinks;
  final VoidCallback onAddLink;

  const WebsiteLinkSection({
    Key? key,
    required this.controller,
    required this.websiteLinks,
    required this.onAddLink,
  }) : super(key: key);

  @override
  State<WebsiteLinkSection> createState() => WebsiteLinkSectionState();
}

class WebsiteLinkSectionState extends State<WebsiteLinkSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.websiteLink,
          style: TextStyle(fontSize: getWidth(18), fontWeight: FontWeight.bold),
        ).paddingOnly(top: getHeight(16)),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.grey,
                spreadRadius: getWidth(4),
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: commonTextFiled(
                  controller: widget.controller,
                  hintText: "Enter website link and tap icon",
                  borderRadius: getWidth(10),
                  onEditingComplete: widget.onAddLink,
                  suffixWidget: InkWell(
                    onTap: widget.onAddLink,
                    child: Icon(
                      Icons.send_and_archive_outlined,
                      color: AppColors.blueColor,
                      size: getWidth(24),
                    ).paddingOnly(right: getWidth(16)),
                  ),
                ),
              ),
            ],
          ),
        ).paddingOnly(top: getHeight(8), bottom: getHeight(8)),

        Obx(
          () =>
              widget.websiteLinks.isNotEmpty
                  ? Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getWidth(8),
                      vertical: getHeight(4),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          widget.websiteLinks.asMap().entries.map((entry) {
                            int index = entry.key;
                            String link = entry.value;
                            return Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      await launchUrl(link);
                                    },
                                    child: Text(
                                      link,
                                      style: TextStyle(
                                        fontSize: getWidth(14),
                                        color: AppColors.blueColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: AppColors.red,
                                    size: getWidth(20),
                                  ),
                                  onPressed:
                                      () => widget.websiteLinks.removeAt(index),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ).paddingOnly(left: getWidth(8)),
                              ],
                            );
                          }).toList(),
                    ),
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class NoteSection extends StatelessWidget {
  const NoteSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'Note: ',
        style: TextStyle(
          fontSize: getWidth(12),
          fontWeight: FontWeight.bold,
          color: AppColors.textColor,
        ),
        children: <TextSpan>[
          TextSpan(
            text:
                'The Textual content you provide for the compendium is more than enough. Only add website links and images to this compendium if you truly believe that they would help students understand your compendium.',
            style: TextStyle(
              fontSize: getWidth(12),
              fontWeight: FontWeight.normal,
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final Function(List<QuizModel>?) onQuizCreate;
  final VoidCallback onSubmit;
  final TextEditingController contentController;
  final EthicalLearningController ethicalCtr;
  final RxList<QuizModel> generatedQuizzes;

  const ActionButtons({
    Key? key,
    required this.onQuizCreate,
    required this.onSubmit,
    required this.contentController,
    required this.ethicalCtr,
    required this.generatedQuizzes,
  }) : super(key: key);

  void _showQuestionCountDialog(BuildContext context) {
    final content = contentController.text.trim();
    if (content.isEmpty) {
      commonSnackBar(message: "Please enter content before generating a quiz");
      return;
    }
    TextEditingController questionCountController = TextEditingController(
      text: "5",
    );
    RxBool generateWithAI = true.obs;

    Get.dialog(
      AlertDialog(
        title: Text(
          "Create Quiz Questions",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: getWidth(18)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "How many questions would you like to create?",
                style: TextStyle(fontSize: getWidth(14)),
              ),
              SizedBox(height: getHeight(16)),

              commonTextFiled(
                controller: questionCountController,
                hintText: "Select number of questions",
                borderRadius: getWidth(8),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: getWidth(16),
                  vertical: getHeight(12),
                ),
              ),

              SizedBox(height: getHeight(24)),
              Text(
                "Generation Method:",
                style: TextStyle(
                  fontSize: getWidth(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: getHeight(8)),

              // AI Generation option
              Obx(
                () => ListTile(
                  title: Text("AI-Generated Questions"),
                  subtitle: Text(
                    "Let AI create questions based on your content",
                    style: TextStyle(fontSize: getWidth(12)),
                  ),
                  leading: Radio<bool>(
                    value: true,
                    groupValue: generateWithAI.value,
                    activeColor: AppColors.blueColor,
                    onChanged: (val) {
                      if (val != null) generateWithAI.value = val;
                    },
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              Obx(
                () => ListTile(
                  title: Text("Create Manually"),
                  subtitle: Text(
                    "Create your own questions from scratch",
                    style: TextStyle(fontSize: getWidth(12)),
                  ),
                  leading: Radio<bool>(
                    value: false,
                    groupValue: generateWithAI.value,
                    activeColor: AppColors.blueColor,
                    onChanged: (val) {
                      if (val != null) generateWithAI.value = val;
                    },
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),

              Obx(
                () =>
                    generateWithAI.value
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: getHeight(8)),
                            Container(
                              padding: EdgeInsets.all(getWidth(12)),
                              decoration: BoxDecoration(
                                color: AppColors.blueColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  getWidth(8),
                                ),
                                border: Border.all(
                                  color: AppColors.blueColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.blueColor,
                                    size: getWidth(20),
                                  ),
                                  SizedBox(width: getWidth(8)),
                                  Expanded(
                                    child: Text(
                                      "AI will analyze your content and generate relevant questions. You can edit them afterward.",
                                      style: TextStyle(
                                        fontSize: getWidth(12),
                                        color: AppColors.blueColor.withOpacity(
                                          0.8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: TextStyle(color: AppColors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              int count =
                  int.tryParse(
                    questionCountController.text.isEmpty
                        ? "5"
                        : questionCountController.text,
                  ) ??
                  5;

              if (count <= 0 || count > 25) {
                commonSnackBar(message: "Please select between 1-25 questions");
                return;
              }

              Get.back(
                result: {
                  'count': count,
                  'generateWithAI': generateWithAI.value,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(getWidth(8)),
              ),
            ),
            child: Text("Create", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).then((result) async {
      if (result != null) {
        final count = result['count'] as int;
        final generateWithAI = result['generateWithAI'] as bool;

        if (generateWithAI && contentController.text.isNotEmpty) {
          await _generateQuiz(context, count.toString());
        } else {
          _navigateToEditQuiz(context);
        }
      }
    });
  }

  Future<void> _generateQuiz(BuildContext context, String questionCount) async {
    final content = contentController.text.trim();
    if (content.isEmpty) {
      commonSnackBar(message: "Please enter content before generating a quiz");
      return;
    }

    Get.dialog(
      Dialog(
        child: Container(
          padding: EdgeInsets.all(getWidth(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.blueColor),
              SizedBox(height: getHeight(20)),
              Text(
                "Generating Questions...",
                style: TextStyle(
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: getHeight(10)),
              Text(
                "Analyzing your content to create meaningful quiz questions.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: getWidth(14),
                  color: AppColors.textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final quizzes = await ethicalCtr.generateQuiz(
        query: content,
        numberOfQuestions: questionCount,
      );

      Get.back(); // Close loading dialog

      if (quizzes == null || quizzes.isEmpty) {
        commonSnackBar(message: "Failed to generate quiz questions");
      } else {
        onQuizCreate(quizzes);
        _navigateToEditQuiz(context);

        // Show success message
        Get.snackbar(
          "Success",
          "${quizzes.length} questions generated!",
          backgroundColor: AppColors.green.withOpacity(0.9),
          colorText: Colors.white,
          margin: EdgeInsets.all(getWidth(10)),
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      commonSnackBar(message: "Error generating quiz: ${e.toString()}");
      log("Quiz generation error: $e");
    }
  }

  void _navigateToEditQuiz(BuildContext context) async {
    final result = await Get.to(
      () => const UploadCompendiaEditQize(),
      arguments: {'quizzes': generatedQuizzes},
    );

    if (result != null && result is List<QuizModel>) {
      onQuizCreate(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: materialButtonWithChild(
            child: Text(
              AppStrings.createQuiz,
              style: TextStyle(color: AppColors.white, fontSize: getWidth(24)),
            ).paddingOnly(
              left: getWidth(16),
              right: getWidth(16),
              top: getHeight(8),
              bottom: getHeight(8),
            ),
            onPressed: () => _showQuestionCountDialog(context),
            color: AppColors.blueColor,
            borderRadius: getWidth(5),
          ),
        ),
        if (generatedQuizzes.isNotEmpty)
          Align(
            alignment: Alignment.center,
            child: materialButtonWithChild(
              width: double.infinity,
              child: Text(
                "Edit Quiz",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: getWidth(16),
                ),
              ),
              onPressed: () => _navigateToEditQuiz(context),
              color: AppColors.green,
              borderRadius: getWidth(5),
            ),
          ).paddingOnly(top: getHeight(16), bottom: getHeight(8)),
        commonDivider(
          height: getHeight(1),
        ).paddingOnly(top: getHeight(8), bottom: getHeight(8)),
        Align(
          alignment: Alignment.center,
          child: materialButtonWithChild(
            width: double.infinity,
            child: Text(
              AppStrings.submit,
              style: TextStyle(color: AppColors.white, fontSize: getWidth(24)),
            ).paddingOnly(
              left: getWidth(16),
              right: getWidth(16),
              top: getHeight(8),
              bottom: getHeight(8),
            ),
            onPressed: onSubmit,
            color: AppColors.blueColor,
            borderRadius: getWidth(5),
          ),
        ).paddingOnly(top: getHeight(8)),
      ],
    );
  }
}
