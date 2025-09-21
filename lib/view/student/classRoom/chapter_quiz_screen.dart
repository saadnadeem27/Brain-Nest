import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/classroom_controller.dart';
import 'package:Vadai/model/students/test_model.dart';
import 'package:flutter/services.dart';

class ChapterQuizScreen extends StatefulWidget {
  const ChapterQuizScreen({super.key});

  @override
  State<ChapterQuizScreen> createState() => _ChapterQuizScreenState();
}

class _ChapterQuizScreenState extends State<ChapterQuizScreen> {
  final ClassRoomController classRoomCtr = Get.find();
  String? chapterId;
  String? chapterName;
  String? comingFrom;
  RxBool isLoading = true.obs;
  RxBool isSubmitted = false.obs;
  TestModel? testModel;
  RxInt currentQuestionIndex = 0.obs;
  RxMap<int, int?> userAnswers =
      <int, int?>{}.obs; // questionIndex to answerIndex

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    isLoading.value = true;
    if (Get.arguments != null) {
      chapterId = Get.arguments[AppStrings.chapterId];
      chapterName = Get.arguments['chapterName'];
      comingFrom = Get.arguments[AppStrings.comingFrom];
    }

    try {
      if (chapterId != null) {
        testModel = await classRoomCtr.getTest(chapterId: chapterId!);
      }
    } catch (e) {
      log('Error loading test: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectAnswer(int questionIndex, int answerIndex) {
    userAnswers[questionIndex] = answerIndex;
  }

  void navigateToPreviousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void navigateToNextQuestion() {
    if (currentQuestionIndex.value < (testModel?.questions?.length ?? 0) - 1) {
      currentQuestionIndex.value++;
    }
  }

  bool allQuestionsAnswered() {
    if (testModel?.questions == null) return false;

    return testModel!.questions!.asMap().keys.every(
      (index) => userAnswers.containsKey(index),
    );
  }

  void submitQuiz() async {
    if (!allQuestionsAnswered()) {
      commonSnackBar(message: "");
      return;
    }

    isLoading.value = true;

    try {
      // Prepare answers in required format for API
      final List<Map<String, dynamic>> answers = [];
      userAnswers.forEach((questionIndex, answerIndex) {
        if (testModel?.questions != null &&
            questionIndex < testModel!.questions!.length &&
            answerIndex != null) {
          answers.add({
            'questionId': testModel!.questions![questionIndex].questionId,
            'selectedOptionIndex': answerIndex,
          });
        }
      });

      // Submit test
      classRoomCtr.submitTest(chapterId: chapterId!, answers: answers);

      isSubmitted.value = true;

      // Calculate score for displaying results
      int correctAnswers = 0;
      userAnswers.forEach((questionIndex, answerIndex) {
        if (testModel?.questions != null &&
            questionIndex < testModel!.questions!.length &&
            answerIndex ==
                testModel!.questions![questionIndex].correctOptionIndex) {
          correctAnswers++;
        }
      });

      // Show results dialog
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Quiz Results",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: getWidth(18),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You scored $correctAnswers out of ${testModel?.questions?.length}",
                style: TextStyle(
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: getHeight(12)),
              Text(
                "Percentage: ${(correctAnswers / (testModel?.questions?.length ?? 1) * 100).toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close dialog
              },
              child: Text("Review Answers"),
            ),
            TextButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Return to previous screen
              },
              child: Text("Finish"),
            ),
          ],
        ),
      );
    } catch (e) {
      log('Error submitting test: $e');
      commonSnackBar(message: "Failed to submit test. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: chapterName != null ? "Quiz: $chapterName" : "Chapter Quiz",
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(child: commonLoader());
        }

        if (testModel == null ||
            testModel?.questions == null ||
            testModel!.questions!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: getWidth(48),
                  color: AppColors.grey,
                ),
                SizedBox(height: getHeight(16)),
                Text(
                  "No quiz questions available for this chapter",
                  style: TextStyle(fontSize: getWidth(16)),
                ),
                SizedBox(height: getHeight(16)),
                materialButtonWithChild(
                  child: Text(
                    "Go Back",
                    style: TextStyle(color: AppColors.white),
                  ),
                  onPressed: () => Get.back(),
                  color: AppColors.blueColor,
                  borderRadius: getWidth(8),
                ),
              ],
            ),
          );
        }

        final questions = testModel!.questions!;
        final currentQuestion = questions[currentQuestionIndex.value];
        final options = currentQuestion.answerOptions ?? [];
        final userSelectedAnswer = userAnswers[currentQuestionIndex.value];

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(getWidth(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                QuizProgressIndicator(
                  totalQuestions: questions.length,
                  answeredQuestions: userAnswers.length,
                ),

                SizedBox(height: getHeight(16)),

                // Question counter
                QuestionCounter(
                  currentIndex: currentQuestionIndex.value,
                  totalQuestions: questions.length,
                ),

                // Question text
                QuestionDisplay(question: currentQuestion.question ?? ""),

                // Answer options
                AnswerOptionsList(
                  options: options,
                  selectedAnswerIndex: userSelectedAnswer,
                  correctAnswerIndex:
                      isSubmitted.value
                          ? currentQuestion.correctOptionIndex
                          : null,
                  onOptionSelected:
                      isSubmitted.value
                          ? null
                          : (index) =>
                              selectAnswer(currentQuestionIndex.value, index),
                ),

                // Navigation and submit buttons
                NavigationButtons(
                  currentIndex: currentQuestionIndex.value,
                  totalQuestions: questions.length,
                  onPrevious: navigateToPreviousQuestion,
                  onNext: navigateToNextQuestion,
                  onSubmit: isSubmitted.value ? null : submitQuiz,
                  allAnswered: allQuestionsAnswered(),
                ),

                // Results section (when submitted)
                if (isSubmitted.value)
                  ResultsSection(
                    questions: questions,
                    userAnswers: userAnswers,
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// Reusable widgets for the quiz UI
class QuizProgressIndicator extends StatelessWidget {
  final int totalQuestions;
  final int answeredQuestions;

  const QuizProgressIndicator({
    Key? key,
    required this.totalQuestions,
    required this.answeredQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progress =
        totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Progress",
              style: TextStyle(
                fontSize: getWidth(14),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "$answeredQuestions of $totalQuestions answered",
              style: TextStyle(
                fontSize: getWidth(14),
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
        SizedBox(height: getHeight(8)),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.grey.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueColor),
          minHeight: getHeight(8),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class QuestionCounter extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;

  const QuestionCounter({
    Key? key,
    required this.currentIndex,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: getHeight(8),
        horizontal: getWidth(12),
      ),
      decoration: BoxDecoration(
        color: AppColors.blueColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "Question ${currentIndex + 1} of $totalQuestions",
        style: TextStyle(
          fontSize: getWidth(16),
          fontWeight: FontWeight.bold,
          color: AppColors.blueColor,
        ),
      ),
    );
  }
}

class QuestionDisplay extends StatelessWidget {
  final String question;

  const QuestionDisplay({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: getHeight(16)),
      padding: EdgeInsets.all(getWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        question,
        style: TextStyle(fontSize: getWidth(18), fontWeight: FontWeight.w500),
      ),
    );
  }
}

class AnswerOptionsList extends StatelessWidget {
  final List<String?> options;
  final int? selectedAnswerIndex;
  final int? correctAnswerIndex;
  final Function(int)? onOptionSelected;

  const AnswerOptionsList({
    Key? key,
    required this.options,
    this.selectedAnswerIndex,
    this.correctAnswerIndex,
    this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select an answer:",
          style: TextStyle(fontSize: getWidth(16), fontWeight: FontWeight.bold),
        ),
        SizedBox(height: getHeight(12)),
        ...List.generate(
          options.length,
          (index) => AnswerOption(
            option: options[index] ?? "",
            optionLetter: String.fromCharCode(65 + index),
            isSelected: selectedAnswerIndex == index,
            isCorrect: correctAnswerIndex == index,
            isSubmitted: correctAnswerIndex != null,
            onTap:
                onOptionSelected != null
                    ? () => onOptionSelected!(index)
                    : null,
          ),
        ),
      ],
    );
  }
}

class AnswerOption extends StatelessWidget {
  final String option;
  final String optionLetter;
  final bool isSelected;
  final bool isCorrect;
  final bool isSubmitted;
  final VoidCallback? onTap;

  const AnswerOption({
    Key? key,
    required this.option,
    required this.optionLetter,
    required this.isSelected,
    required this.isCorrect,
    required this.isSubmitted,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;

    if (isSubmitted) {
      if (isSelected && isCorrect) {
        backgroundColor = AppColors.green.withOpacity(0.1);
        borderColor = AppColors.green;
      } else if (isSelected && !isCorrect) {
        backgroundColor = AppColors.red.withOpacity(0.1);
        borderColor = AppColors.red;
      } else if (isCorrect) {
        backgroundColor = AppColors.green.withOpacity(0.1);
        borderColor = AppColors.green;
      } else {
        backgroundColor = Colors.white;
        borderColor = AppColors.lightBorder;
      }
    } else {
      backgroundColor =
          isSelected ? AppColors.blueColor.withOpacity(0.1) : Colors.white;
      borderColor = isSelected ? AppColors.blueColor : AppColors.lightBorder;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: getHeight(12)),
        padding: EdgeInsets.symmetric(
          vertical: getHeight(12),
          horizontal: getWidth(16),
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: getWidth(30),
              height: getWidth(30),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? borderColor : Colors.grey.withOpacity(0.2),
              ),
              child: Text(
                optionLetter,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: getWidth(12)),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: getWidth(16),
                  color: AppColors.textColor,
                ),
              ),
            ),
            if (isSubmitted && isCorrect)
              Icon(
                Icons.check_circle,
                color: AppColors.green,
                size: getWidth(24),
              ),
            if (isSubmitted && isSelected && !isCorrect)
              Icon(Icons.cancel, color: AppColors.red, size: getWidth(24)),
          ],
        ),
      ),
    );
  }
}

class NavigationButtons extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onSubmit;
  final bool allAnswered;

  const NavigationButtons({
    Key? key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.onPrevious,
    required this.onNext,
    this.onSubmit,
    required this.allAnswered,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLastQuestion = currentIndex == totalQuestions - 1;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: getHeight(24)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous button
              materialButtonWithChild(
                width: getWidth(120),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.white,
                      size: getWidth(14),
                    ),
                    SizedBox(width: getWidth(4)),
                    Text(
                      "Previous",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: getWidth(14),
                      ),
                    ),
                  ],
                ),
                onPressed: currentIndex > 0 ? onPrevious : null,
                color: currentIndex > 0 ? AppColors.blueColor : AppColors.grey,
                borderRadius: getWidth(8),
              ),

              // Next button
              materialButtonWithChild(
                width: getWidth(120),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Next",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: getWidth(14),
                      ),
                    ),
                    SizedBox(width: getWidth(4)),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.white,
                      size: getWidth(14),
                    ),
                  ],
                ),
                onPressed: currentIndex < totalQuestions - 1 ? onNext : null,
                color:
                    currentIndex < totalQuestions - 1
                        ? AppColors.blueColor
                        : AppColors.grey,
                borderRadius: getWidth(8),
              ),
            ],
          ),
        ),

        // Submit button
        if (isLastQuestion || allAnswered)
          materialButtonWithChild(
            width: double.infinity,
            child: Text(
              "Submit Quiz",
              style: TextStyle(
                color: AppColors.white,
                fontSize: getWidth(16),
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: onSubmit,
            color:
                onSubmit != null && allAnswered
                    ? AppColors.green
                    : AppColors.grey,
            borderRadius: getWidth(8),
          ),
      ],
    );
  }
}

class ResultsSection extends StatelessWidget {
  final List<Questions> questions;
  final Map<int, int?> userAnswers;

  const ResultsSection({
    Key? key,
    required this.questions,
    required this.userAnswers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate score
    int correctAnswers = 0;
    userAnswers.forEach((questionIndex, answerIndex) {
      if (answerIndex == questions[questionIndex].correctOptionIndex) {
        correctAnswers++;
      }
    });

    final percentage = (correctAnswers / questions.length * 100);

    return Container(
      margin: EdgeInsets.only(top: getHeight(24)),
      padding: EdgeInsets.all(getWidth(16)),
      decoration: BoxDecoration(
        color: AppColors.blueColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blueColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quiz Results",
            style: TextStyle(
              fontSize: getWidth(20),
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ResultItem(
                label: "Score",
                value: "$correctAnswers/${questions.length}",
              ),
              ResultItem(
                label: "Percentage",
                value: "${percentage.toStringAsFixed(1)}%",
              ),
              ResultItem(
                label: "Status",
                value: percentage >= 70 ? "Passed" : "Failed",
                valueColor: percentage >= 70 ? AppColors.green : AppColors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ResultItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const ResultItem({
    Key? key,
    required this.label,
    required this.value,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: getWidth(14),
            fontWeight: FontWeight.w500,
            color: AppColors.textColor,
          ),
        ),
        SizedBox(height: getHeight(4)),
        Text(
          value,
          style: TextStyle(
            fontSize: getWidth(18),
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textColor,
          ),
        ),
      ],
    );
  }
}
