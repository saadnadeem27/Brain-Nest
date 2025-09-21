import 'package:Vadai/common_imports.dart';

class TeacherMCQEditorScreen extends StatefulWidget {
  final List<MCQQuestionItem> initialQuestions;

  const TeacherMCQEditorScreen({Key? key, required this.initialQuestions})
    : super(key: key);

  @override
  State<TeacherMCQEditorScreen> createState() => _TeacherMCQEditorScreenState();
}

class _TeacherMCQEditorScreenState extends State<TeacherMCQEditorScreen> {
  late List<MCQQuestionItem> mcqQuestions;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    mcqQuestions =
        widget.initialQuestions.isNotEmpty
            ? widget.initialQuestions.map((q) => q.copy()).toList()
            : [MCQQuestionItem.empty()];
  }

  void addQuestion() {
    setState(() {
      mcqQuestions.add(MCQQuestionItem.empty());
      currentIndex = mcqQuestions.length - 1;
    });
  }

  void removeCurrentQuestion() {
    if (mcqQuestions.length > 1) {
      setState(() {
        mcqQuestions.removeAt(currentIndex);
        if (currentIndex > 0) currentIndex--;
      });
    } else {
      commonSnackBar(message: "At least one question is required.");
    }
  }

  void saveAndReturn() {
    // Validate all questions
    for (int i = 0; i < mcqQuestions.length; i++) {
      final q = mcqQuestions[i];
      q.questionController.text = q.questionController.text.trim();
      for (int j = 0; j < q.optionControllers.length; j++) {
        q.optionControllers[j].text = q.optionControllers[j].text.trim();
      }
      if (q.questionController.text.trim().isEmpty) {
        commonSnackBar(message: "Question ${i + 1} is empty.");
        return;
      }
      for (int j = 0; j < q.optionControllers.length; j++) {
        if (q.optionControllers[j].text.trim().isEmpty) {
          commonSnackBar(
            message: "Option ${j + 1} for Question ${i + 1} is empty.",
          );
          return;
        }
      }
    }
    Get.back(result: mcqQuestions);
  }

  @override
  Widget build(BuildContext context) {
    final q = mcqQuestions[currentIndex];
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: "Edit MCQ Questions",
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(getWidth(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed:
                        currentIndex > 0
                            ? () => setState(() => currentIndex--)
                            : null,
                  ),
                  Text(
                    "Question ${currentIndex + 1} of ${mcqQuestions.length}",
                    style: TextStyle(
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    onPressed:
                        currentIndex < mcqQuestions.length - 1
                            ? () => setState(() => currentIndex++)
                            : null,
                  ),
                ],
              ),
              SizedBox(height: getHeight(16)),
              // Question text
              Text("Question", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: getHeight(8)),
              commonTextFiled(
                controller: q.questionController,
                hintText: "Enter question text",
                borderRadius: 8,
                maxLineNull: true,
                keyBoardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
              SizedBox(height: getHeight(16)),
              Text(
                "Options (select the correct answer)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: getHeight(8)),
              ...List.generate(
                4,
                (i) => Row(
                  children: [
                    Radio<int>(
                      value: i,
                      groupValue: q.correctOptionIndex,
                      onChanged: (val) {
                        setState(() {
                          q.correctOptionIndex = val ?? 0;
                        });
                      },
                      activeColor: AppColors.blueColor,
                    ),
                    SizedBox(width: getWidth(8)),
                    Expanded(
                      child: commonTextFiled(
                        controller: q.optionControllers[i],
                        hintText: "Option ${i + 1}",
                        borderRadius: 8,
                        maxLineNull: true,
                      ),
                    ),
                  ],
                ).paddingOnly(bottom: getHeight(8)),
              ),
              SizedBox(height: getHeight(24)),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: addQuestion,
                      icon: Icon(Icons.add),
                      label: Text("Add Question"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueColor,
                      ),
                    ),
                  ),
                  SizedBox(height: getHeight(12)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: removeCurrentQuestion,
                      icon: Icon(Icons.delete),
                      label: Text("Remove"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                      ),
                    ),
                  ),
                  SizedBox(height: getHeight(12)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: saveAndReturn,
                      icon: Icon(Icons.save),
                      label: Text("Save & Return"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MCQQuestionItem {
  final TextEditingController questionController;
  final List<TextEditingController> optionControllers;
  int correctOptionIndex;

  MCQQuestionItem({
    required this.questionController,
    required this.optionControllers,
    required this.correctOptionIndex,
  });

  MCQQuestionItem.empty()
    : questionController = TextEditingController(),
      optionControllers = List.generate(4, (_) => TextEditingController()),
      correctOptionIndex = 0;

  MCQQuestionItem copy() {
    return MCQQuestionItem(
      questionController: TextEditingController(text: questionController.text),
      optionControllers:
          optionControllers
              .map((c) => TextEditingController(text: c.text))
              .toList(),
      correctOptionIndex: correctOptionIndex,
    );
  }
}
