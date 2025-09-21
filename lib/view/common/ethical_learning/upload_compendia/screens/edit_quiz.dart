import 'package:Vadai/common_imports.dart';
import 'package:Vadai/model/students/quiz_model.dart';
import 'package:flutter/services.dart';

class UploadCompendiaEditQize extends StatefulWidget {
  const UploadCompendiaEditQize({super.key});

  @override
  State<UploadCompendiaEditQize> createState() =>
      _UploadCompendiaEditQizeState();
}

class _UploadCompendiaEditQizeState extends State<UploadCompendiaEditQize> {
  RxList<QuizModel> quizzes = <QuizModel>[].obs;
  RxInt currentQuestionIndex = 0.obs;
  final TextEditingController questionController = TextEditingController();
  List<TextEditingController> optionControllers = [];
  RxInt selectedCorrectOption = 0.obs;
  RxBool isLoading = false.obs;
  RxBool hasUnsavedChanges = false.obs;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() {
    if (Get.arguments != null && Get.arguments['quizzes'] != null) {
      quizzes.value = List<QuizModel>.from(Get.arguments['quizzes']);
      if (quizzes.isNotEmpty) {
        loadQuestionDetails(0);
      } else {
        // Add a default empty question if none exist
        _addEmptyQuestion();
      }
    } else {
      // Add a default empty question if none exist
      _addEmptyQuestion();
    }
  }

  void _addEmptyQuestion() {
    quizzes.add(
      QuizModel(
        question: '',
        answerOptions: ['', '', '', ''],
        correctOptionIndex: 0,
      ),
    );
    loadQuestionDetails(0);
  }

  void loadQuestionDetails(int index) {
    if (index < 0 || index >= quizzes.length) return;

    // Clear previous controllers
    for (var controller in optionControllers) {
      controller.dispose();
    }
    optionControllers.clear();

    // Set up question controller
    QuizModel currentQuiz = quizzes[index];
    questionController.text = currentQuiz.question ?? '';

    // Set up option controllers
    if (currentQuiz.answerOptions != null) {
      for (var option in currentQuiz.answerOptions!) {
        TextEditingController optionController = TextEditingController(
          text: option,
        );
        optionControllers.add(optionController);
      }
    }

    // Set correct option
    selectedCorrectOption.value = currentQuiz.correctOptionIndex ?? 0;

    // Reset the unsaved changes flag
    hasUnsavedChanges.value = false;
  }

  void saveCurrentQuestion() {
    if (currentQuestionIndex.value < 0 ||
        currentQuestionIndex.value >= quizzes.length)
      return;

    QuizModel updatedQuiz = QuizModel(
      question: questionController.text,
      answerOptions:
          optionControllers.map((controller) => controller.text).toList(),
      correctOptionIndex: selectedCorrectOption.value,
    );

    quizzes[currentQuestionIndex.value] = updatedQuiz;
    hasUnsavedChanges.value = false;
  }

  void navigateToPreviousQuestion() {
    if (currentQuestionIndex.value <= 0) return;
    saveCurrentQuestion();
    currentQuestionIndex.value--;
    loadQuestionDetails(currentQuestionIndex.value);
  }

  void navigateToNextQuestion() {
    if (currentQuestionIndex.value >= quizzes.length - 1) return;
    saveCurrentQuestion();
    currentQuestionIndex.value++;
    loadQuestionDetails(currentQuestionIndex.value);
  }

  void addNewQuestion() {
    saveCurrentQuestion();

    quizzes.add(
      QuizModel(
        question: '',
        answerOptions: ['', '', '', ''],
        correctOptionIndex: 0,
      ),
    );

    currentQuestionIndex.value = quizzes.length - 1;
    loadQuestionDetails(currentQuestionIndex.value);
  }

  void deleteCurrentQuestion() {
    if (quizzes.length <= 1) {
      commonSnackBar(message: "You need at least one question");
      return;
    }

    final indexToDelete = currentQuestionIndex.value;

    // If we're deleting the last question, move to the previous one first
    if (indexToDelete == quizzes.length - 1 && indexToDelete > 0) {
      currentQuestionIndex.value--;
    }

    quizzes.removeAt(indexToDelete);
    loadQuestionDetails(currentQuestionIndex.value);
  }

  void saveAndExit() {
    // Save the current question first
    saveCurrentQuestion();

    // Validate all questions
    List<String> errorMessages = [];

    for (int i = 0; i < quizzes.length; i++) {
      final quiz = quizzes[i];

      if (quiz.question?.isEmpty ?? true) {
        errorMessages.add("Question ${i + 1} has no text");
      }

      if (quiz.answerOptions != null) {
        for (int j = 0; j < quiz.answerOptions!.length; j++) {
          if (quiz.answerOptions![j].isEmpty) {
            errorMessages.add("Question ${i + 1}, Option ${j + 1} is empty");
          }
        }
      }
    }

    if (errorMessages.isNotEmpty) {
      // Show first error only to avoid overwhelming the user
      commonSnackBar(message: errorMessages.first);
      return;
    }

    Get.back(result: quizzes);
  }

  void _markAsChanged() {
    hasUnsavedChanges.value = true;
  }

  Widget buildOptionField(int index) {
    final optionLabels = ['A', 'B', 'C', 'D'];
    final optionLabel =
        index < optionLabels.length
            ? optionLabels[index]
            : (index + 1).toString();

    return Container(
      margin: EdgeInsets.only(bottom: getHeight(12)),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              selectedCorrectOption.value == index
                  ? AppColors.blueColor
                  : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(8),
        color:
            selectedCorrectOption.value == index
                ? AppColors.blueColor.withOpacity(0.05)
                : Colors.white,
      ),
      child: Row(
        children: [
          // Option label (A, B, C, D)
          Container(
            width: getWidth(40),
            height: getHeight(60),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  selectedCorrectOption.value == index
                      ? AppColors.blueColor
                      : AppColors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Text(
              optionLabel,
              style: TextStyle(
                fontSize: getWidth(18),
                fontWeight: FontWeight.bold,
                color:
                    selectedCorrectOption.value == index
                        ? Colors.white
                        : AppColors.textColor,
              ),
            ),
          ),

          // Option text field
          Expanded(
            child: TextFormField(
              controller: optionControllers[index],
              decoration: InputDecoration(
                hintText: 'Enter option $optionLabel',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: getWidth(16),
                  vertical: getHeight(8),
                ),
                suffixIcon:
                    selectedCorrectOption.value == index
                        ? Icon(
                          Icons.check_circle,
                          color: AppColors.blueColor,
                          size: getWidth(20),
                        )
                        : null,
              ),
              maxLines: 2,
              minLines: 1,
              onChanged: (_) => _markAsChanged(),
            ),
          ),

          // Correct answer checkbox
          Obx(
            () => Radio<int>(
              value: index,
              groupValue: selectedCorrectOption.value,
              onChanged: (int? value) {
                if (value != null) {
                  selectedCorrectOption.value = value;
                  _markAsChanged();
                }
              },
              activeColor: AppColors.blueColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    questionController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (hasUnsavedChanges.value) {
          // Ask the user to save changes
          bool shouldSave =
              await showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Save Changes?'),
                      content: Text(
                        'You have unsaved changes. Do you want to save them before leaving?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'Discard',
                            style: TextStyle(color: AppColors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(
                            'Save',
                            style: TextStyle(color: AppColors.blueColor),
                          ),
                        ),
                      ],
                    ),
              ) ??
              false;

          if (shouldSave) {
            saveCurrentQuestion();
          }
        }
        return true;
      },
      child: commonScaffold(
        context: context,
        appBar: commonAppBar(
          context: context,
          isBack: true,
          title: "Edit Quiz Questions",
          actions: [
            // Save button in app bar
            TextButton.icon(
              onPressed: saveAndExit,
              icon: Icon(
                Icons.check,
                color: AppColors.blueColor,
                size: getWidth(20),
              ),
              label: Text(
                "Save",
                style: TextStyle(
                  color: AppColors.blueColor,
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: Obx(() {
          if (isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (quizzes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "No quiz questions yet",
                    style: TextStyle(fontSize: getWidth(16)),
                  ),
                  SizedBox(height: getHeight(20)),
                  ElevatedButton.icon(
                    onPressed: _addEmptyQuestion,
                    icon: Icon(Icons.add),
                    label: Text("Add a Question"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: getWidth(20),
                        vertical: getHeight(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Question counter and navigation
              Container(
                padding: EdgeInsets.all(getWidth(12)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous button
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color:
                            currentQuestionIndex.value > 0
                                ? AppColors.blueColor
                                : AppColors.grey,
                        size: getWidth(20),
                      ),
                      onPressed:
                          currentQuestionIndex.value > 0
                              ? navigateToPreviousQuestion
                              : null,
                    ),

                    // Question counter
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: getWidth(12),
                        vertical: getHeight(6),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blueColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(getWidth(20)),
                      ),
                      child: Text(
                        "Question ${currentQuestionIndex.value + 1} of ${quizzes.length}",
                        style: TextStyle(
                          fontSize: getWidth(14),
                          fontWeight: FontWeight.w600,
                          color: AppColors.blueColor,
                        ),
                      ),
                    ),

                    // Next button
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color:
                            currentQuestionIndex.value < quizzes.length - 1
                                ? AppColors.blueColor
                                : AppColors.grey,
                        size: getWidth(20),
                      ),
                      onPressed:
                          currentQuestionIndex.value < quizzes.length - 1
                              ? navigateToNextQuestion
                              : null,
                    ),
                  ],
                ),
              ),

              // Question editor
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(getWidth(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question text
                      Text(
                        "Question Text",
                        style: TextStyle(
                          fontSize: getWidth(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: getHeight(8)),

                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.lightBorder),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: TextFormField(
                          controller: questionController,
                          decoration: InputDecoration(
                            hintText: "Enter your question here",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(getWidth(16)),
                          ),
                          maxLines: 5,
                          minLines: 3,
                          onChanged: (_) => _markAsChanged(),
                        ),
                      ),

                      SizedBox(height: getHeight(24)),

                      // Options section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Answer Options",
                            style: TextStyle(
                              fontSize: getWidth(16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Select Correct",
                            style: TextStyle(
                              fontSize: getWidth(14),
                              color: AppColors.blueColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: getHeight(12)),

                      ...List.generate(
                        optionControllers.length,
                        (index) => buildOptionField(index),
                      ),

                      SizedBox(height: getHeight(40)),

                      // Action buttons
                      Row(
                        children: [
                          // Delete button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: deleteCurrentQuestion,
                              icon: Icon(Icons.delete, color: Colors.white),
                              label: Text(
                                "Delete",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.red,
                                padding: EdgeInsets.symmetric(
                                  vertical: getHeight(12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: getWidth(16)),

                          // Add button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: addNewQuestion,
                              icon: Icon(Icons.add, color: Colors.white),
                              label: Text(
                                "Add New",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blueColor,
                                padding: EdgeInsets.symmetric(
                                  vertical: getHeight(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: getHeight(16)),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: saveAndExit,
                          icon: Icon(Icons.check, color: Colors.white),
                          label: Text(
                            "Save All Questions",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: getWidth(16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            padding: EdgeInsets.symmetric(
                              vertical: getHeight(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
