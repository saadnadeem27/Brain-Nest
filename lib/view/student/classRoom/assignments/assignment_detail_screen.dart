import 'dart:io';
import 'dart:ui';
import 'package:Vadai/common/widgets/prompt_copied_dialog.dart';
import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/classroom_controller.dart';
import 'package:Vadai/model/students/assignements_model.dart';
import 'package:Vadai/view/student/classRoom/assignments/assignment_mcq_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class AssignmentDetailScreen extends StatefulWidget {
  const AssignmentDetailScreen({super.key});

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  final ClassRoomController classRoomCtr = Get.find();
  late AssignmentsModel assignment;
  RxBool isLoading = false.obs;
  RxBool isSubmitting = false.obs;
  RxBool isGeneratingPrompt = false.obs;
  RxList<File> selectedFiles = <File>[].obs;
  RxList<String> selectedFileNames = <String>[].obs;
  RxMap<String, int> mcqAnswers = <String, int>{}.obs;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      assignment = Get.arguments['assignment'];
    }
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'jpeg'],
      );

      if (result != null) {
        // Add each selected file to our lists
        for (var file in result.files) {
          if (file.path != null) {
            selectedFiles.add(File(file.path!));
            selectedFileNames.add(file.name);
          }
        }
      }
    } catch (e) {
      log('Error picking files: $e');
      commonSnackBar(
        message: "Error selecting files. Please try again.",
        color: AppColors.errorColor,
      );
    }
  }

  void navigateToMCQScreen() async {
    if (assignment.mCQs == null || assignment.mCQs!.isEmpty) {
      commonSnackBar(message: "No MCQs available for this assignment");
      return;
    }
    bool isReviewing = mcqAnswers.isNotEmpty;
    final result = await Get.to(
      () => AssignmentMCQScreen(
        mcqs: assignment.mCQs!,
        initialAnswers: mcqAnswers,
        isReviewMode: isReviewing,
      ),
    );
    if (result != null) {
      mcqAnswers.value = Map<String, int>.from(result);
    }
  }

  Future<void> handleAiMagicPress() async {
    if (assignment.sId == null) {
      commonSnackBar(
        message: "Assignment ID is missing. Cannot generate prompt.",
        color: AppColors.red,
      );
      return;
    }

    isGeneratingPrompt.value = true;

    try {
      final prompt = await classRoomCtr.generateAssignmentPrompt(
        assignmentId: assignment.sId!,
      );

      if (prompt != null) {
        await Clipboard.setData(ClipboardData(text: prompt));
        showPromptCopiedDialog(context, () {
          Get.back();
          Get.toNamed(RouteNames.aiScreen);
        });
      } else {
        commonSnackBar(
          message: "Failed to generate prompt. Please try again.",
          color: AppColors.red,
        );
      }
    } catch (e) {
      log('Error generating prompt: $e');
      commonSnackBar(
        message: "An error occurred. Please try again.",
        color: AppColors.red,
      );
    } finally {
      isGeneratingPrompt.value = false;
    }
  }

  Future<void> submitAssignment() async {
    // Validate if assignment requires MCQ responses
    if (assignment.isMCQ == true &&
        assignment.mCQs != null &&
        assignment.mCQs!.isNotEmpty &&
        mcqAnswers.isEmpty) {
      commonSnackBar(
        message: "Please complete the MCQ questions before submitting",
        color: AppColors.red,
      );
      return;
    }

    // Validate if assignment requires file upload
    if (assignment.submissionFormat?.toLowerCase().contains('file') == true &&
        selectedFiles.isEmpty) {
      commonSnackBar(
        message: "Please upload at least one file before submitting",
        color: AppColors.red,
      );
      return;
    }

    isSubmitting.value = true;

    try {
      // Format MCQ answers for API
      final List<Map<String, dynamic>> answers = [];
      mcqAnswers.forEach((mcqId, answerIndex) {
        answers.add({
          'questionId': mcqId, // Use 'questionId' instead of 'mcqId'
          'selectedOptionIndex': answerIndex,
        });
      });

      // Submit assignment with multiple files
      await classRoomCtr.submitAssignment(
        assignmentId: assignment.sId ?? '',
        files: selectedFiles.toList(),
        mcqAnswers: answers,
      );

      isSubmitting.value = false;
      Get.back(result: true);
      commonSnackBar(
        message: "Assignment submitted successfully",
        color: AppColors.blueColor,
      );
    } catch (e) {
      isSubmitting.value = false;
      log('Error submitting assignment: $e');
      commonSnackBar(
        message: "Failed to submit assignment. Please try again.",
        color: AppColors.errorColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: "Assignment Details",
      ),
      body: Obx(
        () =>
            isLoading.value
                ? Center(child: commonLoader())
                : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(getWidth(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAssignmentHeader(),
                        SizedBox(height: getHeight(16)),
                        _buildAssignmentDetails(),
                        SizedBox(height: getHeight(24)),
                        if (assignment.isMCQ == true &&
                            assignment.mCQs != null &&
                            assignment.mCQs!.isNotEmpty)
                          _buildMCQSection(),
                        SizedBox(height: getHeight(24)),
                        _buildFileUploadSection(),
                        SizedBox(height: getHeight(20)),
                        _buildAiButton(),
                        SizedBox(height: getHeight(16)),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildAssignmentHeader() {
    return Container(
      padding: EdgeInsets.all(getWidth(16)),
      decoration: BoxDecoration(
        color: AppColors.colorC56469,
        borderRadius: BorderRadius.circular(getWidth(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            assignment.lesson ?? "Assignment",
            style: TextStyle(
              fontSize: getWidth(20),
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: getHeight(8)),
          Text(
            assignment.topics
                    ?.map(
                      (topic) => topic[0].toUpperCase() + topic.substring(1),
                    )
                    .join(', ') ??
                "",
            style: TextStyle(
              fontSize: getWidth(14),
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: getHeight(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoBadge(
                label: "Due Date",
                value: formatDate(assignment.dueDate ?? ""),
                icon: Icons.calendar_today,
              ),
              if (assignment.isMCQ == true)
                _buildInfoBadge(
                  label: "Quiz",
                  value: "${assignment.mCQs?.length ?? 0} questions",
                  icon: Icons.quiz,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(12),
        vertical: getHeight(6),
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(getWidth(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.white, size: getWidth(16)),
          SizedBox(width: getWidth(6)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: getWidth(10),
                  color: AppColors.white.withOpacity(0.8),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: getWidth(12),
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentDetails() {
    return Container(
      padding: EdgeInsets.all(getWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getWidth(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.blueColor,
                size: getWidth(20),
              ),
              SizedBox(width: getWidth(8)),
              Text(
                "Assignment Details",
                style: TextStyle(
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: getHeight(12)),
          if (assignment.additionalInfo != null &&
              assignment.additionalInfo!.isNotEmpty)
            _buildDetailItem(
              title: "Description",
              content: assignment.additionalInfo!,
            ),
          if (assignment.instructions != null &&
              assignment.instructions!.isNotEmpty)
            _buildDetailItem(
              title: "Instructions",
              content: assignment.instructions!,
            ),
          if (assignment.submissionFormat != null &&
              assignment.submissionFormat!.isNotEmpty)
            _buildDetailItem(
              title: "Submission Format",
              content: assignment.submissionFormat!,
            ),
          if (assignment.contents != null && assignment.contents!.isNotEmpty)
            _buildDetailItem(title: "Contents", content: assignment.contents!),
        ],
      ),
    );
  }

  Widget _buildDetailItem({required String title, required String content}) {
    return Container(
      margin: EdgeInsets.only(bottom: getHeight(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: getWidth(14),
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(4)),
          Text(
            content,
            style: TextStyle(
              fontSize: getWidth(14),
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMCQSection() {
    return Container(
      padding: EdgeInsets.all(getWidth(16)),
      decoration: BoxDecoration(
        color: AppColors.blueColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(getWidth(10)),
        border: Border.all(
          color: AppColors.blueColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.quiz,
                    color: AppColors.blueColor,
                    size: getWidth(20),
                  ),
                  SizedBox(width: getWidth(8)),
                  Text(
                    "Quiz Questions",
                    style: TextStyle(
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        mcqAnswers.isEmpty
                            ? AppColors.grey.withOpacity(0.3)
                            : AppColors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          mcqAnswers.isEmpty ? AppColors.grey : AppColors.green,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    mcqAnswers.isEmpty ? "Not Started" : "Completed",
                    style: TextStyle(
                      fontSize: getWidth(12),
                      color:
                          mcqAnswers.isEmpty
                              ? AppColors.textColor
                              : AppColors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: getHeight(12)),
          Text(
            "Complete the ${assignment.mCQs?.length ?? 0} multiple choice questions for this assignment.",
            style: TextStyle(
              fontSize: getWidth(14),
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(16)),
          materialButtonWithChild(
            width: double.infinity,
            borderRadius: getWidth(8),
            color: AppColors.blueColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.question_answer,
                  color: AppColors.white,
                  size: getWidth(18),
                ),
                SizedBox(width: getWidth(8)),
                Text(
                  mcqAnswers.isEmpty
                      ? "Answer Questions"
                      : "Edit/Review Answers",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: getWidth(14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            onPressed: navigateToMCQScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Container(
      padding: EdgeInsets.all(getWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getWidth(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.upload_file,
                    color: AppColors.blueColor,
                    size: getWidth(20),
                  ),
                  SizedBox(width: getWidth(8)),
                  Text(
                    "Upload Assignment Files",
                    style: TextStyle(
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
              Obx(
                () => Text(
                  "${selectedFiles.length} files selected",
                  style: TextStyle(
                    fontSize: getWidth(12),
                    color: AppColors.textColor.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: getHeight(12)),
          Text(
            "Upload your assignment files (PDF, DOC, DOCX, JPG, JPEG, PNG)",
            style: TextStyle(
              fontSize: getWidth(14),
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(16)),
          Obx(
            () =>
                selectedFiles.isEmpty
                    ? GestureDetector(
                      onTap: pickFile,
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: Radius.circular(getWidth(10)),
                        color: AppColors.grey,
                        strokeWidth: 1.5,
                        dashPattern: [6, 3],
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(getWidth(20)),
                          decoration: BoxDecoration(
                            color: AppColors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(getWidth(10)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file,
                                size: getWidth(32),
                                color: AppColors.grey,
                              ),
                              SizedBox(height: getHeight(8)),
                              Text(
                                "Click to select files",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: getWidth(14),
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    : Column(
                      children: [
                        ...List.generate(
                          selectedFiles.length,
                          (index) => _buildSelectedFile(index),
                        ),
                        SizedBox(height: getHeight(12)),
                        materialButtonWithChild(
                          width: double.infinity,
                          color: AppColors.blueColor.withOpacity(0.1),
                          borderRadius: getWidth(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: AppColors.blueColor,
                                size: getWidth(16),
                              ),
                              SizedBox(width: getWidth(4)),
                              Text(
                                "Add More Files",
                                style: TextStyle(
                                  color: AppColors.blueColor,
                                  fontSize: getWidth(14),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          onPressed: pickFile,
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFile(int index) {
    String fileExtension =
        selectedFileNames[index].split('.').last.toLowerCase();
    IconData fileIcon;

    switch (fileExtension) {
      case 'pdf':
        fileIcon = Icons.picture_as_pdf;
        break;
      case 'doc':
      case 'docx':
        fileIcon = Icons.description;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        fileIcon = Icons.image;
        break;
      default:
        fileIcon = Icons.insert_drive_file;
    }

    return Container(
      margin: EdgeInsets.only(bottom: getHeight(8)),
      padding: EdgeInsets.all(getWidth(12)),
      decoration: BoxDecoration(
        color: AppColors.blueColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(getWidth(8)),
        border: Border.all(
          color: AppColors.blueColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(getWidth(8)),
            decoration: BoxDecoration(
              color: AppColors.blueColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              fileIcon,
              color: AppColors.blueColor,
              size: getWidth(20),
            ),
          ),
          SizedBox(width: getWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedFileNames[index],
                  style: TextStyle(
                    fontSize: getWidth(14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: getHeight(2)),
                Text(
                  '${(selectedFiles[index].lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                  style: TextStyle(
                    fontSize: getWidth(12),
                    color: AppColors.textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: AppColors.red,
              size: getWidth(20),
            ),
            onPressed: () {
              selectedFiles.removeAt(index);
              selectedFileNames.removeAt(index);
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildAiButton() {
    return Center(
      child: Obx(
        () => materialButtonWithChild(
          width: double.infinity,
          borderRadius: getWidth(8),
          color: AppColors.blueColor,
          child:
              isGeneratingPrompt.value
                  ? SizedBox(
                    height: getHeight(20),
                    width: getWidth(20),
                    child: commonLoader(
                      customHeight: getHeight(20),
                      customWidth: getWidth(20),
                    ),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppColors.white,
                        size: getWidth(18),
                      ),
                      SizedBox(width: getWidth(8)),
                      Text(
                        "AI Magic",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: getWidth(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          onPressed: isGeneratingPrompt.value ? null : handleAiMagicPress,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => materialButtonWithChild(
        width: double.infinity,
        borderRadius: getWidth(8),
        color: AppColors.green,
        child:
            isSubmitting.value
                ? SizedBox(
                  height: getHeight(20),
                  width: getWidth(20),
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.white,
                      size: getWidth(18),
                    ),
                    SizedBox(width: getWidth(8)),
                    Text(
                      "Submit Assignment",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: getWidth(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        onPressed: isSubmitting.value ? null : submitAssignment,
      ),
    );
  }
}

class DottedBorder extends StatelessWidget {
  final Widget child;
  final BorderType borderType;
  final Radius radius;
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;

  const DottedBorder({
    Key? key,
    required this.child,
    required this.borderType,
    required this.radius,
    required this.color,
    required this.strokeWidth,
    required this.dashPattern,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DottedBorderPainter(
        borderType: borderType,
        radius: radius,
        color: color,
        strokeWidth: strokeWidth,
        dashPattern: dashPattern,
      ),
      child: child,
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  final BorderType borderType;
  final Radius radius;
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;

  DottedBorderPainter({
    required this.borderType,
    required this.radius,
    required this.color,
    required this.strokeWidth,
    required this.dashPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final Path path = Path();

    switch (borderType) {
      case BorderType.RRect:
        path.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            radius,
          ),
        );
        break;
      case BorderType.Rect:
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
        break;
      case BorderType.Oval:
        path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
        break;
    }

    Path dashPath = Path();
    double dashLength = dashPattern[0];
    double dashSpace = dashPattern[1];

    for (PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum BorderType { RRect, Rect, Oval }
