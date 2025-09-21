import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/helper/attachment_picker_helper.dart';
import 'package:Vadai/view/teachers/classroom/assignments/question_count_dialog.dart';
import 'package:Vadai/view/teachers/classroom/assignments/teacher_mcq_editor_screen.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TeacherCreateAssignment extends StatefulWidget {
  const TeacherCreateAssignment({Key? key}) : super(key: key);

  @override
  State<TeacherCreateAssignment> createState() =>
      _TeacherCreateAssignmentState();
}

class _TeacherCreateAssignmentState extends State<TeacherCreateAssignment> {
  final TeacherClassroomController _controller =
      Get.find<TeacherClassroomController>();
  final AttachmentPickerHelper _attachmentHelper = AttachmentPickerHelper();
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController _lessonController = TextEditingController();
  final TextEditingController _contentsController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _additionalInfoController =
      TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _submissionFormatController =
      TextEditingController();

  // State variables
  String subjectId = '';
  String subjectName = '';
  RxBool isLoading = false.obs;
  RxBool isSubmitting = false.obs;
  RxBool isGeneratingQuiz = false.obs;

  // Topics list
  RxList<String> topics = <String>[].obs;

  // Due date
  Rx<DateTime?> dueDate = Rx<DateTime?>(null);

  // Documents
  RxList<Map<String, dynamic>> documents = <Map<String, dynamic>>[].obs;

  // MCQ related
  RxBool includeMCQ = false.obs;
  RxInt numberOfQuestions = 1.obs;
  RxList<MCQQuestionItem> mcqQuestions = <MCQQuestionItem>[].obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
    });
  }

  @override
  void dispose() {
    _lessonController.dispose();
    _contentsController.dispose();
    _topicController.dispose();
    _additionalInfoController.dispose();
    _instructionsController.dispose();
    _submissionFormatController.dispose();
    for (var item in mcqQuestions) {
      item.questionController.dispose();
      for (var controller in item.optionControllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void initData() {
    if (Get.arguments != null) {
      subjectId = Get.arguments['subjectId'] ?? '';
      subjectName = Get.arguments['subjectName'] ?? '';
    }

    // Set default due date to 1 week from now
    dueDate.value = DateTime.now().add(Duration(days: 7));

    // Add a default MCQ question
    _addDefaultMCQ();
  }

  void _addDefaultMCQ() {
    mcqQuestions.add(
      MCQQuestionItem(
        questionController: TextEditingController(),
        optionControllers: List.generate(4, (index) => TextEditingController()),
        correctOptionIndex: 0,
      ),
    );
  }

  void _addTopic() {
    final topic = _topicController.text.trim();
    if (topic.isNotEmpty && !topics.contains(topic)) {
      topics.add(topic);
      _topicController.clear();
    } else if (topics.contains(topic)) {
      commonSnackBar(message: "Topic already added");
    }
  }

  void _removeTopic(int index) {
    topics.removeAt(index);
  }

  Future<void> _selectDueDate() async {
    // First select the date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: dueDate.value ?? DateTime.now().add(Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.blueColor,
              onPrimary: AppColors.white,
            ),
            dialogBackgroundColor: AppColors.white,
          ),
          child: child!,
        );
      },
    );

    // If date was selected, now select the time
    if (pickedDate != null) {
      // Default time to current time or noon if none selected previously
      final TimeOfDay initialTime =
          dueDate.value != null
              ? TimeOfDay.fromDateTime(dueDate.value!)
              : TimeOfDay(hour: 23, minute: 59);

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.blueColor,
                onPrimary: AppColors.white,
              ),
              dialogBackgroundColor: AppColors.white,
            ),
            child: child!,
          );
        },
      );

      // If time was also selected, combine date and time
      if (pickedTime != null) {
        final DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        dueDate.value = combinedDateTime;
      } else {
        // Only date was selected, set time to 11:59 PM
        dueDate.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          23, // 11 PM
          59, // 59 minutes
        );
      }
    }
  }

  Future<void> _uploadDocument() async {
    try {
      isLoading.value = true;

      final result = await _attachmentHelper.pickAndUploadFile();

      if (result != null) {
        documents.add({
          'type': result['type'],
          'link': result['url'],
          'name': result['name'],
        });
      }
    } catch (e) {
      log('Error uploading document: $e');
      commonSnackBar(
        message: "Failed to upload document. Please try again.",
        color: AppColors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _removeDocument(int index) {
    documents.removeAt(index);
  }

  void _showDocumentPreview(Map<String, dynamic> document) {
    final link = document['link'] as String;
    launchUrl(link);
  }

  Future<void> _showMCQOptionsDialog() async {
    int? selectedQuestionsCount = 3;
    bool generateWithAI = false;

    await Get.dialog(
      AlertDialog(
        title: Text('Add Multiple-Choice Questions'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How many questions would you like to add?'),
                SizedBox(height: getHeight(16)),
                DropdownButtonFormField<int>(
                  value: selectedQuestionsCount,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: getWidth(12),
                      vertical: getHeight(12),
                    ),
                  ),
                  items:
                      List.generate(10, (index) => index + 1)
                          .map(
                            (count) => DropdownMenuItem<int>(
                              value: count,
                              child: Text(
                                '$count ${count == 1 ? 'question' : 'questions'}',
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedQuestionsCount = value;
                    });
                  },
                ),
                SizedBox(height: getHeight(24)),
                Row(
                  children: [
                    Checkbox(
                      value: generateWithAI,
                      activeColor: AppColors.blueColor,
                      onChanged: (value) {
                        setState(() {
                          generateWithAI = value ?? false;
                        });
                      },
                    ),
                    SizedBox(width: getWidth(8)),
                    Expanded(
                      child: Text(
                        'Generate questions using AI based on content',
                        style: TextStyle(fontSize: getWidth(14)),
                      ),
                    ),
                  ],
                ),
                if (generateWithAI)
                  Padding(
                    padding: EdgeInsets.only(
                      left: getWidth(32),
                      top: getHeight(8),
                    ),
                    child: Text(
                      'AI will generate questions based on the content you\'ve provided.',
                      style: TextStyle(
                        fontSize: getWidth(12),
                        color: AppColors.textColor.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back(
                result: {
                  'count': selectedQuestionsCount,
                  'generateWithAI': generateWithAI,
                },
              );
            },
            child: Text('Add'),
            style: TextButton.styleFrom(foregroundColor: AppColors.blueColor),
          ),
        ],
      ),
    ).then((result) async {
      if (result != null) {
        final count = result['count'] as int;
        final generateWithAI = result['generateWithAI'] as bool;

        if (generateWithAI && _contentsController.text.isNotEmpty) {
          await _generateQuizWithAI(count);
          _openMCQEditor(); // Open the editor after generating questions
        } else {
          _setManualQuestions(count);
          _openMCQEditor(); // Open the editor with empty questions
        }

        includeMCQ.value = true;
      }
    });
  }

  Future<void> _openMCQEditor() async {
    final result = await Get.to(
      () => TeacherMCQEditorScreen(initialQuestions: mcqQuestions.toList()),
    );

    if (result != null && result is List<MCQQuestionItem>) {
      // Dispose old controllers
      for (var item in mcqQuestions) {
        item.questionController.dispose();
        for (var controller in item.optionControllers) {
          controller.dispose();
        }
      }

      mcqQuestions.clear();
      mcqQuestions.addAll(result);
      numberOfQuestions.value = mcqQuestions.length;
    }
  }

  Future<void> _generateQuizWithAI(int count) async {
    try {
      isGeneratingQuiz.value = true;

      final quizQuestions = await _controller.generateAssignmentQuiz(
        numberOfQuestions: count,
        content: _contentsController.text,
      );

      if (quizQuestions != null && quizQuestions.isNotEmpty) {
        // Clear existing questions
        for (var item in mcqQuestions) {
          item.questionController.dispose();
          for (var controller in item.optionControllers) {
            controller.dispose();
          }
        }
        mcqQuestions.clear();

        // Add generated questions
        for (var question in quizQuestions) {
          final optionControllers = List.generate(
            question.answerOptions?.length ?? 4,
            (index) => TextEditingController(
              text: question.answerOptions?[index] ?? '',
            ),
          );

          mcqQuestions.add(
            MCQQuestionItem(
              questionController: TextEditingController(
                text: question.question,
              ),
              optionControllers: optionControllers,
              correctOptionIndex: question.correctOptionIndex ?? 0,
            ),
          );
        }

        numberOfQuestions.value = mcqQuestions.length;
        commonSnackBar(
          message: "${mcqQuestions.length} questions generated successfully!",
          color: AppColors.green,
        );
      } else {
        commonSnackBar(
          message:
              "Failed to generate questions. Please try manually or with different content.",
          color: AppColors.red,
        );
        _setManualQuestions(count);
      }
    } catch (e) {
      log('Error generating quiz: $e');
      commonSnackBar(
        message: "Error generating questions. Please try manually.",
        color: AppColors.red,
      );
      _setManualQuestions(count);
    } finally {
      isGeneratingQuiz.value = false;
    }
  }

  void _setManualQuestions(int count) {
    // Clear existing questions
    for (var item in mcqQuestions) {
      item.questionController.dispose();
      for (var controller in item.optionControllers) {
        controller.dispose();
      }
    }
    mcqQuestions.clear();

    // Add new empty questions
    for (int i = 0; i < count; i++) {
      mcqQuestions.add(
        MCQQuestionItem(
          questionController: TextEditingController(),
          optionControllers: List.generate(
            4,
            (index) => TextEditingController(),
          ),
          correctOptionIndex: 0,
        ),
      );
    }

    numberOfQuestions.value = count;
  }

  void _addMCQ() {
    mcqQuestions.add(
      MCQQuestionItem(
        questionController: TextEditingController(),
        optionControllers: List.generate(4, (index) => TextEditingController()),
        correctOptionIndex: 0,
      ),
    );
    numberOfQuestions.value = mcqQuestions.length;
  }

  void _removeMCQ(int index) {
    if (mcqQuestions.length > 1) {
      final item = mcqQuestions[index];
      item.questionController.dispose();
      for (var controller in item.optionControllers) {
        controller.dispose();
      }

      mcqQuestions.removeAt(index);
      numberOfQuestions.value = mcqQuestions.length;
    } else {
      commonSnackBar(
        message: "You must have at least one question.",
        color: AppColors.red,
      );
    }
  }

  bool _validateForm() {
    if (_lessonController.text.isEmpty) {
      commonSnackBar(message: "Please enter a lesson name.");
      return false;
    }

    if (_contentsController.text.isEmpty) {
      commonSnackBar(message: "Please enter content for the assignment.");
      return false;
    }

    if (topics.isEmpty) {
      commonSnackBar(message: "Please add at least one topic.");
      return false;
    }

    if (dueDate.value == null) {
      commonSnackBar(message: "Please select a due date.");
      return false;
    }

    if (_instructionsController.text.isEmpty) {
      commonSnackBar(message: "Please provide instructions for students.");
      return false;
    }

    if (_submissionFormatController.text.isEmpty) {
      commonSnackBar(message: "Please specify the submission format.");
      return false;
    }

    if (includeMCQ.value) {
      for (int i = 0; i < mcqQuestions.length; i++) {
        if (mcqQuestions[i].questionController.text.isEmpty) {
          commonSnackBar(message: "Question ${i + 1} is empty.");
          return false;
        }

        for (int j = 0; j < mcqQuestions[i].optionControllers.length; j++) {
          if (mcqQuestions[i].optionControllers[j].text.isEmpty) {
            commonSnackBar(
              message: "Option ${j + 1} for Question ${i + 1} is empty.",
            );
            return false;
          }
        }
      }
    }

    return true;
  }

  Future<void> _submitAssignment() async {
    if (!_validateForm()) return;
    DateTime? dateTime = dueDate.value?.toUtc();
    if (dateTime == null) {
      commonSnackBar(message: "Please select a due date.");
      return;
    }

    try {
      isSubmitting.value = true;

      // Prepare MCQs if included
      List<Map<String, dynamic>> mcqs = [];
      if (includeMCQ.value) {
        for (var mcq in mcqQuestions) {
          mcqs.add({
            "question": mcq.questionController.text,
            "answerOptions": mcq.optionControllers.map((c) => c.text).toList(),
            "correctOptionIndex": mcq.correctOptionIndex,
          });
        }
      }

      final result = await _controller.createAssignment(
        lesson: _lessonController.text.trim(),
        topics: topics.toList(),
        additionalInfo: _additionalInfoController.text.trim(),
        dueDate: dateTime,
        instructions: _instructionsController.text.trim(),
        submissionFormat: _submissionFormatController.text.trim(),
        isMCQ: includeMCQ.value,
        numberOfQuestions: includeMCQ.value ? numberOfQuestions.value : 0,
        mcqs: includeMCQ.value ? mcqs : null,
        subjectId: subjectId,
        contents: _contentsController.text.trim(),
        documents: documents,
      );

      if (result) {
        Get.back(result: true);
      } else {
        commonSnackBar(
          message: "Failed to create assignment. Please try again.",
          color: AppColors.red,
        );
      }
    } catch (e) {
      log('Error creating assignment: $e');
      commonSnackBar(
        message: "An error occurred while creating the assignment.",
        color: AppColors.red,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => commonScaffold(
        context: context,
        appBar: commonAppBar(
          context: context,
          isBack: true,
          title: subjectName,
        ),
        body:
            isLoading.value || isGeneratingQuiz.value
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.blueColor),
                      SizedBox(height: getHeight(16)),
                      Text(
                        isGeneratingQuiz.value
                            ? "Generating questions..."
                            : "Loading...",
                        style: TextStyle(
                          fontSize: getWidth(16),
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                )
                : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(getWidth(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lesson Name
                        _buildSectionTitle("Lesson Name"),
                        SizedBox(height: getHeight(8)),
                        commonTextFiled(
                          controller: _lessonController,
                          hintText: "Enter lesson name",
                          borderRadius: 8,
                        ),
                        SizedBox(height: getHeight(24)),

                        // Content
                        _buildSectionTitle("Content"),
                        SizedBox(height: getHeight(8)),
                        commonTextFiled(
                          controller: _contentsController,
                          hintText: "Enter the assignment content",
                          borderRadius: 8,
                          maxLines: 6,
                          keyBoardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                        ),
                        SizedBox(height: getHeight(24)),

                        // Topics
                        _buildSectionTitle("Topics"),
                        SizedBox(height: getHeight(8)),
                        Row(
                          children: [
                            Expanded(
                              child: commonTextFiled(
                                controller: _topicController,
                                hintText: "Add a topic",
                                borderRadius: 8,
                                onEditingComplete: _addTopic,
                              ),
                            ),
                            SizedBox(width: getWidth(8)),
                            ElevatedButton(
                              onPressed: _addTopic,
                              child: Icon(Icons.add, color: AppColors.white),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blueColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    getWidth(8),
                                  ),
                                ),
                                padding: EdgeInsets.all(getWidth(12)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: getHeight(12)),
                        Wrap(
                          spacing: getWidth(8),
                          runSpacing: getHeight(8),
                          children: List.generate(
                            topics.length,
                            (index) => Chip(
                              label: Text(topics[index]),
                              backgroundColor: AppColors.blueColor.withOpacity(
                                0.1,
                              ),
                              labelStyle: TextStyle(
                                color: AppColors.blueColor,
                                fontSize: getWidth(14),
                              ),
                              deleteIcon: Icon(
                                Icons.close,
                                size: getWidth(16),
                                color: AppColors.blueColor,
                              ),
                              onDeleted: () => _removeTopic(index),
                            ),
                          ),
                        ),
                        SizedBox(height: getHeight(24)),

                        // Additional Info
                        _buildSectionTitle("Additional Information"),
                        SizedBox(height: getHeight(8)),
                        commonTextFiled(
                          controller: _additionalInfoController,
                          hintText: "Enter additional information (optional)",
                          borderRadius: 8,
                          maxLines: 3,
                          keyBoardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                        ),
                        SizedBox(height: getHeight(24)),

                        // Due Date
                        _buildSectionTitle("Due Date"),
                        SizedBox(height: getHeight(8)),
                        InkWell(
                          onTap: _selectDueDate,
                          child: Container(
                            padding: EdgeInsets.all(getWidth(12)),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.lightBorder),
                              borderRadius: BorderRadius.circular(getWidth(8)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    dueDate.value != null
                                        ? DateFormat(
                                          'MMMM dd, yyyy - hh:mm a',
                                        ).format(dueDate.value!)
                                        : "Select a due date and time",
                                    style: TextStyle(
                                      fontSize: getWidth(14),
                                      color:
                                          dueDate.value != null
                                              ? AppColors.textColor
                                              : AppColors.textColor.withOpacity(
                                                0.5,
                                              ),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  color: AppColors.blueColor,
                                  size: getWidth(20),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: getHeight(24)),

                        // Instructions
                        _buildSectionTitle("Instructions"),
                        SizedBox(height: getHeight(8)),
                        commonTextFiled(
                          controller: _instructionsController,
                          hintText: "Enter instructions for students",
                          borderRadius: 8,
                          maxLines: 5,
                          keyBoardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                        ),
                        SizedBox(height: getHeight(24)),

                        // Submission Format
                        _buildSectionTitle("Submission Format"),
                        SizedBox(height: getHeight(8)),
                        commonTextFiled(
                          controller: _submissionFormatController,
                          hintText: "E.g., PDF, Word document, etc.",
                          borderRadius: 8,
                        ),
                        SizedBox(height: getHeight(24)),

                        // Documents
                        _buildSectionTitle("Documents"),
                        SizedBox(height: getHeight(8)),
                        ElevatedButton.icon(
                          onPressed: _uploadDocument,
                          icon: const Icon(
                            Icons.upload_file,
                            color: AppColors.white,
                          ),
                          label: const Text(
                            "Upload Document",
                            style: TextStyle(color: AppColors.white),
                          ),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blueColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidth(16),
                              vertical: getHeight(12),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(getWidth(8)),
                            ),
                            textStyle: TextStyle(
                              fontSize: getWidth(14),
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: getHeight(12)),
                        documents.isEmpty
                            ? Center(
                              child: Text(
                                "No documents uploaded yet",
                                style: TextStyle(
                                  fontSize: getWidth(14),
                                  color: AppColors.textColor.withOpacity(0.5),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                            : Column(
                              children: List.generate(
                                documents.length,
                                (index) =>
                                    _buildDocumentItem(documents[index], index),
                              ),
                            ),
                        SizedBox(height: getHeight(24)), // MCQ Section
                        Row(
                          children: [
                            _buildSectionTitle("Multiple-Choice Questions"),
                            Spacer(),
                            Switch(
                              value: includeMCQ.value,
                              onChanged: (value) {
                                includeMCQ.value = value;
                                if (value && mcqQuestions.isEmpty) {
                                  _addDefaultMCQ();
                                }
                              },
                              activeColor: AppColors.blueColor,
                              inactiveThumbColor: AppColors.black,
                              inactiveTrackColor: AppColors.grey,
                            ),
                          ],
                        ),
                        SizedBox(height: getHeight(8)),
                        includeMCQ.value
                            ? Column(
                              children: [
                                // MCQ Summary and Edit Button
                                Container(
                                  padding: EdgeInsets.all(getWidth(16)),
                                  decoration: BoxDecoration(
                                    color: AppColors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      getWidth(8),
                                    ),
                                    border: Border.all(
                                      color: AppColors.grey.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${mcqQuestions.length} Question${mcqQuestions.length == 1 ? '' : 's'}",
                                            style: TextStyle(
                                              fontSize: getWidth(16),
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.blueColor,
                                            ),
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: _configureQuestions,
                                            icon: Icon(
                                              Icons.edit,
                                              color: AppColors.white,
                                              size: getWidth(16),
                                            ),
                                            label: Text("Edit Questions"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.blueColor,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: getWidth(16),
                                                vertical: getHeight(8),
                                              ),
                                              textStyle: TextStyle(
                                                fontSize: getWidth(14),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      getWidth(8),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: getHeight(8)),
                                      // Display sample of questions
                                      if (mcqQuestions.isNotEmpty) ...[
                                        _buildQuestionPreview(
                                          0,
                                        ), // First question preview
                                        if (mcqQuestions.length > 1) ...[
                                          SizedBox(height: getHeight(8)),
                                          Text(
                                            "... ${mcqQuestions.length - 1} more question${mcqQuestions.length > 2 ? 's' : ''}",
                                            style: TextStyle(
                                              fontSize: getWidth(14),
                                              color: AppColors.textColor
                                                  .withOpacity(0.6),
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                      SizedBox(height: getHeight(16)),
                                      Divider(
                                        color: AppColors.grey.withOpacity(0.3),
                                      ),
                                      SizedBox(height: getHeight(8)),
                                      // AI generation or manual addition options
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed:
                                                  () =>
                                                      _showQuestionCountDialog(),
                                              icon: Icon(
                                                Icons.auto_awesome,
                                                size: getWidth(16),
                                              ),
                                              label: Text("Generate with AI"),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    AppColors.blueColor,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: getWidth(16)),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed:
                                                  () =>
                                                      _manuallyConfigureQuestions(
                                                        3,
                                                      ),
                                              icon: Icon(
                                                Icons.add,
                                                size: getWidth(16),
                                              ),
                                              label: Text("Add Questions"),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    AppColors.blueColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                            : Center(
                              child: Text(
                                "Enable to add multiple-choice questions",
                                style: TextStyle(
                                  fontSize: getWidth(14),
                                  color: AppColors.textColor.withOpacity(0.5),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        SizedBox(height: getHeight(32)),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                isSubmitting.value ? null : _submitAssignment,
                            child:
                                isSubmitting.value
                                    ? SizedBox(
                                      height: getHeight(20),
                                      width: getHeight(20),
                                      child: CircularProgressIndicator(
                                        color: AppColors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Text("Create Assignment"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blueColor,
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: getHeight(16),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  getWidth(8),
                                ),
                              ),
                              textStyle: TextStyle(
                                fontSize: getWidth(16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: getHeight(32)),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: getWidth(16),
        fontWeight: FontWeight.bold,
        color: AppColors.textColor,
      ),
    );
  }

  Widget _buildDocumentItem(Map<String, dynamic> document, int index) {
    String name = document['name'] ?? 'Document';
    String type = document['type'] ?? '';

    IconData iconData;
    Color iconColor;

    if (type.contains('pdf')) {
      iconData = Icons.picture_as_pdf;
      iconColor = AppColors.red;
    } else if (type.contains('doc')) {
      iconData = Icons.description;
      iconColor = AppColors.blueColor;
    } else if (type.contains('image')) {
      iconData = Icons.image;
      iconColor = AppColors.green;
    } else if (type.contains('text')) {
      iconData = Icons.text_snippet;
      iconColor = AppColors.textColor;
    } else if (type.contains('link')) {
      iconData = Icons.link;
      iconColor = AppColors.blueColor;
    } else {
      iconData = Icons.insert_drive_file;
      iconColor = AppColors.textColor;
    }

    return Container(
      margin: EdgeInsets.only(bottom: getHeight(8)),
      padding: EdgeInsets.all(getWidth(12)),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(getWidth(8)),
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(iconData, color: iconColor, size: getWidth(24)),
          SizedBox(width: getWidth(12)),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: getWidth(14),
                color: AppColors.textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => _showDocumentPreview(document),
            icon: Icon(
              Icons.visibility,
              color: AppColors.blueColor,
              size: getWidth(20),
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          SizedBox(width: getWidth(12)),
          IconButton(
            onPressed: () => _removeDocument(index),
            icon: Icon(
              Icons.delete_outline,
              color: AppColors.red,
              size: getWidth(20),
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMCQQuestion(int questionIndex) {
    final question = mcqQuestions[questionIndex];

    return Container(
      margin: EdgeInsets.only(bottom: getHeight(24)),
      padding: EdgeInsets.all(getWidth(16)),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(getWidth(8)),
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Question ${questionIndex + 1}",
                style: TextStyle(
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueColor,
                ),
              ),
              IconButton(
                onPressed: () => _removeMCQ(questionIndex),
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.red,
                  size: getWidth(20),
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: getHeight(12)),
          commonTextFiled(
            controller: question.questionController,
            hintText: "Enter question",
            borderRadius: 8,
          ),
          SizedBox(height: getHeight(16)),
          Text(
            "Options (select the correct answer)",
            style: TextStyle(
              fontSize: getWidth(14),
              fontWeight: FontWeight.w500,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(8)),
          ...List.generate(
            question.optionControllers.length,
            (optionIndex) => Padding(
              padding: EdgeInsets.only(bottom: getHeight(8)),
              child: Row(
                children: [
                  Radio<int>(
                    value: optionIndex,
                    groupValue: question.correctOptionIndex,
                    onChanged: (value) {
                      setState(() {
                        question.correctOptionIndex = value ?? 0;
                      });
                    },
                    activeColor: AppColors.blueColor,
                  ),
                  SizedBox(width: getWidth(8)),
                  Expanded(
                    child: commonTextFiled(
                      controller: question.optionControllers[optionIndex],
                      hintText: "Option ${optionIndex + 1}",
                      borderRadius: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Preview a single MCQ question
  Widget _buildQuestionPreview(int index) {
    final question = mcqQuestions[index];
    final questionText =
        question.questionController.text.isEmpty
            ? "Question ${index + 1}"
            : question.questionController.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question text with number
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(getWidth(6)),
              decoration: BoxDecoration(
                color: AppColors.blueColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: getWidth(10),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: getWidth(8)),
            Expanded(
              child: Text(
                questionText,
                style: TextStyle(
                  fontSize: getWidth(14),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // Correct answer if available
        if (question.questionController.text.isNotEmpty &&
            question.optionControllers.isNotEmpty &&
            question
                .optionControllers[question.correctOptionIndex]
                .text
                .isNotEmpty) ...[
          SizedBox(height: getHeight(4)),
          Padding(
            padding: EdgeInsets.only(left: getWidth(24)),
            child: Text(
              "Correct answer: ${question.optionControllers[question.correctOptionIndex].text}",
              style: TextStyle(
                fontSize: getWidth(12),
                color: AppColors.green,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  // Configure questions (open the full editor)
  void _configureQuestions() async {
    // Navigate to the MCQ editor screen and await result
    final result = await Get.to(
      () => TeacherMCQEditorScreen(initialQuestions: mcqQuestions.toList()),
    );

    if (result != null && result is List<MCQQuestionItem>) {
      // Clear old questions
      _clearMCQQuestions();

      // Add new questions from editor
      mcqQuestions.addAll(result);
      numberOfQuestions.value = mcqQuestions.length;
    }
  }

  void _showQuestionCountDialog() {
    if (_contentsController.text.isEmpty) {
      commonSnackBar(
        message: "Please add content to generate questions from",
        color: AppColors.red,
      );
      return;
    }

    // Show the separate dialog widget
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => QuestionCountDialog(
            onGenerate: (selectedCount) {
              // This will be called with valid count
              _generateQuestionsWithAI(selectedCount);
            },
          ),
    );
  }

  // Generate questions using AI with specified count
  void _generateQuestionsWithAI(int selectedCount) async {
    try {
      isGeneratingQuiz.value = true;

      final quizQuestions = await _controller.generateAssignmentQuiz(
        numberOfQuestions: selectedCount,
        content: _contentsController.text,
      );

      if (quizQuestions != null && quizQuestions.isNotEmpty) {
        // Clear existing questions
        _clearMCQQuestions();

        // Add generated questions
        for (var question in quizQuestions) {
          final optionControllers = List.generate(
            question.answerOptions?.length ?? 4,
            (index) => TextEditingController(
              text: question.answerOptions?[index] ?? '',
            ),
          );

          mcqQuestions.add(
            MCQQuestionItem(
              questionController: TextEditingController(
                text: question.question,
              ),
              optionControllers: optionControllers,
              correctOptionIndex: question.correctOptionIndex ?? 0,
            ),
          );
        }

        numberOfQuestions.value = mcqQuestions.length;

        // Open the MCQ editor to review the generated questions
        _configureQuestions();

        commonSnackBar(
          message: "${mcqQuestions.length} questions generated successfully!",
          color: AppColors.green,
        );
      } else {
        commonSnackBar(
          message: "Failed to generate questions. Please try manually.",
          color: AppColors.red,
        );
      }
    } catch (e) {
      log('Error generating quiz: $e');
      commonSnackBar(
        message: "Error generating questions. Please try manually.",
        color: AppColors.red,
      );
    } finally {
      isGeneratingQuiz.value = false;
    }
  }

  // Manually configure questions
  void _manuallyConfigureQuestions(int count) {
    // Set up empty questions
    _clearMCQQuestions();

    // Add new empty questions
    for (int i = 0; i < count; i++) {
      mcqQuestions.add(
        MCQQuestionItem(
          questionController: TextEditingController(),
          optionControllers: List.generate(
            4,
            (index) => TextEditingController(),
          ),
          correctOptionIndex: 0,
        ),
      );
    }

    numberOfQuestions.value = count;

    // Open the MCQ editor
    _configureQuestions();
  }

  // Clear MCQ questions and dispose controllers
  void _clearMCQQuestions() {
    for (var item in mcqQuestions) {
      item.questionController.dispose();
      for (var controller in item.optionControllers) {
        controller.dispose();
      }
    }
    mcqQuestions.clear();
  }
}
