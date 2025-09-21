import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/model/teachers/teacher_submitted_assignments_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherSubmissionDetails extends StatefulWidget {
  const TeacherSubmissionDetails({Key? key}) : super(key: key);

  @override
  State<TeacherSubmissionDetails> createState() =>
      _TeacherSubmissionDetailsState();
}

class _TeacherSubmissionDetailsState extends State<TeacherSubmissionDetails> {
  final TeacherClassroomController _controller =
      Get.find<TeacherClassroomController>();
  final TextEditingController _rejectionReasonController =
      TextEditingController();

  String submissionId = '';
  String studentName = '';
  String lesson = '';

  RxBool isLoading = false.obs;
  Rx<TeacherSubmittedAssignment?> submission = Rx<TeacherSubmittedAssignment?>(
    null,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
    });
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  initData() async {
    isLoading.value = true;
    try {
      if (Get.arguments != null) {
        // Extract arguments
        submissionId = Get.arguments['submissionId'] ?? '';
        studentName = Get.arguments['studentName'] ?? '';
        lesson = Get.arguments['lesson'] ?? '';

        // Load submission details
        await loadSubmissionDetails();
      }
    } catch (e) {
      log('Error in initData of teacher submission details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSubmissionDetails() async {
    try {
      final result = await _controller.getStudentsSubmittedAssignmentsDetail(
        submissionId: submissionId,
      );
      if (result != null) {
        submission.value = result;
      }
    } catch (e) {
      log('Error loading submission details: $e');
    }
  }

  Future<void> approveSubmission() async {
    try {
      final result = await _controller.approveSubmission(
        submissionId: submissionId,
      );
      if (result) {
        await loadSubmissionDetails();
        Get.back(result: true);
      }
    } catch (e) {
      log('Error approving submission: $e');
    }
  }

  Future<void> showRejectDialog() async {
    _rejectionReasonController.clear();

    await Get.dialog(
      AlertDialog(
        title: Text('Reject Submission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide a reason for rejection:'),
            SizedBox(height: getHeight(16)),
            TextField(
              controller: _rejectionReasonController,
              decoration: InputDecoration(
                hintText: 'Enter reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              final reason = _rejectionReasonController.text.trim();
              if (reason.isEmpty) {
                commonSnackBar(
                  message: "Please provide a reason for rejection",
                  color: AppColors.red,
                );
                return;
              }

              Get.back();
              await rejectSubmission(reason);
            },
            child: Text('Reject'),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
          ),
        ],
      ),
    );
  }

  Future<void> rejectSubmission(String reason) async {
    try {
      final result = await _controller.rejectSubmission(
        submissionId: submissionId,
        reason: reason,
      );
      if (result) {
        await loadSubmissionDetails();
        Get.back(result: true);
      }
    } catch (e) {
      log('Error rejecting submission: $e');
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
          title: '$lesson by $studentName',
        ),
        body:
            isLoading.value
                ? Center(child: commonLoader())
                : submission.value == null
                ? Center(
                  child: Text(
                    'No submission details found',
                    style: TextStyle(
                      fontSize: getWidth(16),
                      color: AppColors.textColor.withOpacity(0.7),
                    ),
                  ),
                )
                : SingleChildScrollView(
                  padding: EdgeInsets.all(getWidth(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Submission status banner
                      _buildStatusBanner(submission.value!),
                      SizedBox(height: getHeight(24)),

                      // Student info
                      _buildStudentInfo(submission.value!),
                      SizedBox(height: getHeight(24)),

                      // MCQ answers
                      if (submission.value!.mcqAnswers.isNotEmpty) ...[
                        _buildMCQAnswers(submission.value!),
                        SizedBox(height: getHeight(24)),
                      ],

                      // Attached files
                      if (submission.value!.filesAttached.isNotEmpty) ...[
                        _buildAttachedFiles(submission.value!),
                        SizedBox(height: getHeight(24)),
                      ],

                      // Approve/Reject buttons
                      if (submission.value!.filesAttached.isNotEmpty) ...[
                        _buildAttachedFiles(submission.value!),
                        SizedBox(height: getHeight(24)),
                      ],

                      _buildActionButtons(),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildStatusBanner(TeacherSubmittedAssignment submission) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (submission.approvalStatus.toLowerCase()) {
      case 'approved':
        statusColor = AppColors.green;
        statusText = 'Approved';
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = AppColors.red;
        statusText = 'Rejected';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.colorC56469;
        statusText = 'Pending Review';
        statusIcon = Icons.pending_actions;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(getWidth(16)),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(getWidth(12)),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: getWidth(24)),
          SizedBox(width: getWidth(12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusText,
                style: TextStyle(
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
              SizedBox(height: getHeight(4)),
              Text(
                "Submitted on: ${DateFormat('MMM dd, yyyy - hh:mm a').format(submission.submittedOn)}",
                style: TextStyle(
                  fontSize: getWidth(12),
                  color: AppColors.textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfo(TeacherSubmittedAssignment submission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Student Information',
          style: TextStyle(
            fontSize: getWidth(18),
            fontWeight: FontWeight.w600,
            color: AppColors.blueColor,
          ),
        ),
        SizedBox(height: getHeight(16)),
        Container(
          padding: EdgeInsets.all(getWidth(16)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(getWidth(12)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Profile image
              ClipRRect(
                borderRadius: BorderRadius.circular(getWidth(30)),
                child:
                    (submission.submittedBy.profileImage.isEmpty ||
                            submission.submittedBy.profileImage == 'null')
                        ? Container(
                          width: getWidth(60),
                          height: getWidth(60),
                          color: AppColors.grey.withOpacity(0.3),
                          child: Icon(
                            Icons.person,
                            color: AppColors.grey,
                            size: getWidth(36),
                          ),
                        )
                        : CachedNetworkImage(
                          imageUrl: submission.submittedBy.profileImage,
                          width: getWidth(60),
                          height: getWidth(60),
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: AppColors.grey.withOpacity(0.3),
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.grey,
                                  size: getWidth(36),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: AppColors.grey.withOpacity(0.3),
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.grey,
                                  size: getWidth(36),
                                ),
                              ),
                        ),
              ),
              SizedBox(width: getWidth(16)),

              // Student details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.submittedBy.name,
                      style: TextStyle(
                        fontSize: getWidth(18),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: getHeight(8)),
                    _infoRow(
                      Icons.school,
                      "Class ${submission.submittedBy.className} - Section ${submission.submittedBy.section}",
                    ),
                    SizedBox(height: getHeight(4)),
                    _infoRow(
                      Icons.assignment,
                      "Submission ID: ${submission.submissionId}",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: getWidth(14),
          color: AppColors.blueColor.withOpacity(0.7),
        ),
        SizedBox(width: getWidth(4)),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: getWidth(12),
              color: AppColors.textColor.withOpacity(0.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMCQAnswers(TeacherSubmittedAssignment submission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MCQ Answers',
          style: TextStyle(
            fontSize: getWidth(18),
            fontWeight: FontWeight.w600,
            color: AppColors.blueColor,
          ),
        ),
        SizedBox(height: getHeight(16)),
        Container(
          padding: EdgeInsets.all(getWidth(16)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(getWidth(12)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate(submission.mcqAnswers.length, (index) {
              final answer = submission.mcqAnswers[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom:
                      index < submission.mcqAnswers.length - 1
                          ? getHeight(16)
                          : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: getWidth(24),
                      height: getWidth(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.blueColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: getWidth(12),
                          fontWeight: FontWeight.w600,
                          color: AppColors.blueColor,
                        ),
                      ),
                    ),
                    SizedBox(width: getWidth(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ID: ${answer.questionId}',
                            style: TextStyle(
                              fontSize: getWidth(12),
                              color: AppColors.textColor.withOpacity(0.6),
                            ),
                          ),
                          SizedBox(height: getHeight(4)),
                          Text(
                            'Selected Option: ${answer.selectedOptionIndex + 1}',
                            style: TextStyle(
                              fontSize: getWidth(14),
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachedFiles(TeacherSubmittedAssignment submission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attached Files',
          style: TextStyle(
            fontSize: getWidth(18),
            fontWeight: FontWeight.w600,
            color: AppColors.blueColor,
          ),
        ),
        SizedBox(height: getHeight(16)),
        Container(
          padding: EdgeInsets.all(getWidth(16)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(getWidth(12)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate(submission.filesAttached.length, (index) {
              final fileUrl = submission.filesAttached[index];
              final fileName = fileUrl.split('/').last;
              final fileExtension = fileName.split('.').last.toLowerCase();

              IconData fileIcon;
              Color iconColor;

              switch (fileExtension) {
                case 'pdf':
                  fileIcon = Icons.picture_as_pdf;
                  iconColor = AppColors.red;
                  break;
                case 'doc':
                case 'docx':
                  fileIcon = Icons.description;
                  iconColor = AppColors.blueColor;
                  break;
                case 'jpg':
                case 'jpeg':
                case 'png':
                  fileIcon = Icons.image;
                  iconColor = AppColors.green;
                  break;
                default:
                  fileIcon = Icons.insert_drive_file;
                  iconColor = AppColors.grey;
              }

              return GestureDetector(
                onTap: () {
                  launch(fileUrl);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: getHeight(12),
                    horizontal: getWidth(16),
                  ),
                  margin: EdgeInsets.only(
                    bottom:
                        index < submission.filesAttached.length - 1
                            ? getHeight(8)
                            : 0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(getWidth(8)),
                  ),
                  child: Row(
                    children: [
                      Icon(fileIcon, color: iconColor, size: getWidth(24)),
                      SizedBox(width: getWidth(12)),
                      Expanded(
                        child: Text(
                          fileName,
                          style: TextStyle(
                            fontSize: getWidth(14),
                            color: AppColors.textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        color: AppColors.blueColor,
                        size: getWidth(16),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    // Get current status
    String currentStatus = submission.value!.approvalStatus.toLowerCase();

    // Different UI based on current status
    switch (currentStatus) {
      case 'approved':
        // For approved assignments, show only reject option
        return ElevatedButton.icon(
          onPressed: () => showRejectDialog(),

          icon: const Icon(
            Icons.close,
            color: AppColors.white,
          ).paddingOnly(left: getWidth(8)),
          label: Text('Reject Assignment').paddingOnly(right: getWidth(8)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.red,
            foregroundColor: AppColors.white,
            padding: EdgeInsets.symmetric(vertical: getHeight(14)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(getWidth(8)),
            ),
          ),
        );

      case 'rejected':
        // For rejected assignments, show only approve option
        return ElevatedButton.icon(
          onPressed: () => approveSubmission(),
          icon: const Icon(
            Icons.check,
            color: AppColors.white,
          ).paddingOnly(left: getWidth(8)),
          label: Text('Approve Assignment').paddingOnly(right: getWidth(8)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: AppColors.white,
            padding: EdgeInsets.symmetric(vertical: getHeight(14)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(getWidth(8)),
            ),
          ),
        );

      case 'pending':
      default:
        // For pending assignments, show both options
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => showRejectDialog(),
                icon: const Icon(
                  Icons.close,
                  color: AppColors.white,
                ).paddingOnly(left: getWidth(8)),
                label: Text('Reject').paddingOnly(right: getWidth(8)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: getHeight(14)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(getWidth(8)),
                  ),
                ),
              ),
            ),
            SizedBox(width: getWidth(16)),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => approveSubmission(),
                icon: Icon(Icons.check, color: AppColors.white),
                label: Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: getHeight(14)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(getWidth(8)),
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }
}
