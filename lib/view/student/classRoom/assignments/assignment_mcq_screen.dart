import 'package:Vadai/common_imports.dart';
import 'package:Vadai/model/students/assignements_model.dart';
import 'package:flutter/services.dart';

class AssignmentMCQScreen extends StatefulWidget {
  final List<MCQs> mcqs;
  final RxMap<String, int>? initialAnswers;
  final bool isReviewMode;

  const AssignmentMCQScreen({
    Key? key,
    required this.mcqs,
    this.initialAnswers,
    this.isReviewMode = false,
  }) : super(key: key);

  @override
  State<AssignmentMCQScreen> createState() => _AssignmentMCQScreenState();
}

class _AssignmentMCQScreenState extends State<AssignmentMCQScreen> {
  RxInt currentQuestionIndex = 0.obs;
  RxMap<String, int> userAnswers = <String, int>{}.obs;

  @override
  void initState() {
    super.initState();
    userAnswers =
        widget.initialAnswers != null
            ? RxMap<String, int>.from(widget.initialAnswers!)
            : <String, int>{}.obs;
  }

  void selectAnswer(String mcqId, int answerIndex) {
    if (mcqId.isNotEmpty) {
      userAnswers[mcqId] = answerIndex;
    } else {
      log('Warning: empty mcqId provided');
    }
  }

  void navigateToPreviousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void navigateToNextQuestion() {
    if (currentQuestionIndex.value < widget.mcqs.length - 1) {
      currentQuestionIndex.value++;
    }
  }

  bool allQuestionsAnswered() {
    return widget.mcqs.every((mcq) => userAnswers.containsKey(mcq.sId));
  }

  void submitAnswers() {
    if (!allQuestionsAnswered()) {
      commonSnackBar(message: "Please answer all questions before submitting");
      return;
    }

    // Validate that all mcqIds are not empty
    bool allIdsValid = widget.mcqs.every(
      (mcq) => mcq.sId != null && mcq.sId!.isNotEmpty,
    );
    if (!allIdsValid) {
      commonSnackBar(
        message: "Some questions have invalid IDs. Please contact support.",
      );
      return;
    }

    Get.back(result: userAnswers);
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: widget.isReviewMode ? "Review Your Answers" : "Assignment Quiz",
      ),
      body: Obx(() {
        final currentMCQ = widget.mcqs[currentQuestionIndex.value];
        final options = currentMCQ.answerOptions ?? [];
        final userSelectedAnswer =
            currentMCQ.sId != null ? userAnswers[currentMCQ.sId] : null;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(getWidth(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isReviewMode)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: getHeight(16)),
                    padding: EdgeInsets.symmetric(
                      vertical: getHeight(10),
                      horizontal: getWidth(16),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.green,
                          size: getWidth(20),
                        ),
                        SizedBox(width: getWidth(8)),
                        Expanded(
                          child: Text(
                            "You're reviewing your answers. You can still make changes if needed.",
                            style: TextStyle(
                              fontSize: getWidth(14),
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Progress indicator
                QuizProgressIndicator(
                  totalQuestions: widget.mcqs.length,
                  answeredQuestions: userAnswers.length,
                  isReviewMode: widget.isReviewMode,
                ),

                SizedBox(height: getHeight(16)),

                // Question counter
                QuestionCounter(
                  currentIndex: currentQuestionIndex.value,
                  totalQuestions: widget.mcqs.length,
                  isReviewMode: widget.isReviewMode,
                ),

                // Question text
                QuestionDisplay(question: currentMCQ.question ?? ""),

                // Answer options
                AnswerOptionsList(
                  options: options,
                  selectedAnswerIndex: userSelectedAnswer,
                  onOptionSelected:
                      (index) => selectAnswer(currentMCQ.sId ?? "", index),
                  isReviewMode: widget.isReviewMode,
                ),

                // Navigation and submit buttons
                NavigationButtons(
                  currentIndex: currentQuestionIndex.value,
                  totalQuestions: widget.mcqs.length,
                  onPrevious: navigateToPreviousQuestion,
                  onNext: navigateToNextQuestion,
                  onSubmit: submitAnswers,
                  allAnswered: allQuestionsAnswered(),
                  submitButtonText:
                      widget.isReviewMode ? "Save Changes" : "Submit Answers",
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// Reuse the same UI components from ChapterQuizScreen with minor modifications
class QuizProgressIndicator extends StatelessWidget {
  final int totalQuestions;
  final int answeredQuestions;
  final bool isReviewMode;

  const QuizProgressIndicator({
    Key? key,
    required this.totalQuestions,
    required this.answeredQuestions,
    this.isReviewMode = false,
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
              isReviewMode ? "Review Progress" : "Progress",
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
  final bool isReviewMode;

  const QuestionCounter({
    Key? key,
    required this.currentIndex,
    required this.totalQuestions,
    this.isReviewMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: getHeight(8),
        horizontal: getWidth(12),
      ),
      decoration: BoxDecoration(
        color:
            isReviewMode
                ? AppColors.green.withOpacity(0.1)
                : AppColors.blueColor.withOpacity(0.1),
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
  final Function(int) onOptionSelected;

  final bool isReviewMode;

  const AnswerOptionsList({
    Key? key,
    required this.options,
    this.selectedAnswerIndex,
    required this.onOptionSelected,
    this.isReviewMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isReviewMode ? "Your selected answer:" : "Select an answer:",
          style: TextStyle(fontSize: getWidth(16), fontWeight: FontWeight.bold),
        ),
        SizedBox(height: getHeight(12)),
        ...List.generate(
          options.length,
          (index) => AnswerOption(
            option: options[index] ?? "",
            optionLetter: String.fromCharCode(65 + index),
            isSelected: selectedAnswerIndex == index,
            onTap: () => onOptionSelected(index),
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
  final VoidCallback onTap;
  final bool isReviewMode;

  const AnswerOption({
    Key? key,
    required this.option,
    required this.optionLetter,
    required this.isSelected,
    required this.onTap,
    this.isReviewMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isSelected ? AppColors.blueColor.withOpacity(0.1) : Colors.white;
    final borderColor =
        isSelected ? AppColors.blueColor : AppColors.lightBorder;

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
            if (isReviewMode && isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.green,
                size: getWidth(20),
              ),
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
  final VoidCallback onSubmit;
  final bool allAnswered;
  final bool isReviewMode;
  final String submitButtonText;

  const NavigationButtons({
    Key? key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
    required this.allAnswered,
    this.isReviewMode = false,
    this.submitButtonText = "Submit Answers",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLastQuestion = currentIndex == totalQuestions - 1;
    final Color accentColor =
        isReviewMode ? AppColors.green : AppColors.blueColor;

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
                color: currentIndex > 0 ? accentColor : AppColors.grey,
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
                        ? accentColor
                        : AppColors.grey,
                borderRadius: getWidth(8),
              ),
            ],
          ),
        ),

        // Submit button
        materialButtonWithChild(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isReviewMode ? Icons.save : Icons.check_circle,
                color: AppColors.white,
                size: getWidth(18),
              ),
              SizedBox(width: getWidth(8)),
              Text(
                submitButtonText,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          onPressed: allAnswered ? onSubmit : null,
          color: allAnswered ? AppColors.green : AppColors.grey,
          borderRadius: getWidth(8),
        ),
      ],
    );
  }
}
