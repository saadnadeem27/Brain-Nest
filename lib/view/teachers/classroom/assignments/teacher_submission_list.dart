import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/model/teachers/teacher_assignment_model.dart';
import 'package:Vadai/model/teachers/teacher_submitted_assignments_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class TeacherSubmissionsList extends StatefulWidget {
  const TeacherSubmissionsList({Key? key}) : super(key: key);

  @override
  State<TeacherSubmissionsList> createState() => _TeacherSubmissionsListState();
}

class _TeacherSubmissionsListState extends State<TeacherSubmissionsList> {
  final TeacherClassroomController _controller =
      Get.find<TeacherClassroomController>();

  TeacherAssignmentModel? assignment = null;
  String subjectName = '';

  RxBool isLoading = false.obs;
  RxList<TeacherSubmittedAssignment> submissions =
      <TeacherSubmittedAssignment>[].obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
    });
  }

  initData() async {
    isLoading.value = true;
    try {
      if (Get.arguments != null) {
        // Extract arguments
        assignment = Get.arguments['assignment'];
        subjectName = Get.arguments['subjectName'] ?? '';

        // Load submissions
        await loadSubmissions();
      }
    } catch (e) {
      log('Error in initData of teacher submissions list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSubmissions() async {
    try {
      final result = await _controller.getStudentsSubmittedAssignmentsList(
        assignmentId: assignment?.sId ?? '',
      );
      if (result != null) {
        submissions.value = result;
      }
    } catch (e) {
      log('Error loading submissions: $e');
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
          title: assignment?.lesson ?? '',
        ),
        body:
            isLoading.value
                ? Center(child: commonLoader())
                : RefreshIndicator(
                  onRefresh: loadSubmissions,
                  child:
                      assignment?.sId == null || submissions.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_turned_in_outlined,
                                  size: getWidth(80),
                                  color: AppColors.grey.withOpacity(0.5),
                                ),
                                SizedBox(height: getHeight(16)),
                                Text(
                                  'No submissions yet',
                                  style: TextStyle(
                                    fontSize: getWidth(16),
                                    color: AppColors.textColor.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            itemCount: submissions.length,
                            padding: EdgeInsets.all(getWidth(16)),
                            itemBuilder: (context, index) {
                              final submission = submissions[index];
                              return _buildSubmissionCard(submission);
                            },
                          ),
                ),
      ),
    );
  }

  Widget _buildSubmissionCard(TeacherSubmittedAssignment submission) {
    Color statusColor;
    String statusText;

    switch (submission.approvalStatus.toLowerCase()) {
      case 'approved':
        statusColor = AppColors.green;
        statusText = 'Approved';
        break;
      case 'rejected':
        statusColor = AppColors.red;
        statusText = 'Rejected';
        break;
      default:
        statusColor = AppColors.colorC56469;
        statusText = 'Pending';
    }

    final formattedDate = DateFormat(
      'MMM dd, yyyy - hh:mm a',
    ).format(submission.submittedOn);

    return GestureDetector(
      onTap: () {
        // Navigate to submission details
        Get.toNamed(
          RouteNames.teacherSubmissionDetails,
          arguments: {
            'submissionId': submission.id,
            'studentName': submission.submittedBy.name,
            'lesson': assignment?.lesson,
          },
        )?.then((result) async {
          if (result == true) {
            await loadSubmissions();
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: getHeight(16)),
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
          border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(16),
                vertical: getHeight(8),
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(getWidth(12)),
                  topRight: Radius.circular(getWidth(12)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Submitted on: $formattedDate",
                    style: TextStyle(
                      fontSize: getWidth(12),
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getWidth(8),
                      vertical: getHeight(4),
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(getWidth(12)),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: getWidth(10),
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Student info
            Padding(
              padding: EdgeInsets.all(getWidth(16)),
              child: Row(
                children: [
                  // Profile image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(getWidth(20)),
                    child:
                        (submission.submittedBy.profileImage.isEmpty ||
                                submission.submittedBy.profileImage == 'null')
                            ? Container(
                              width: getWidth(40),
                              height: getWidth(40),
                              color: AppColors.grey.withOpacity(0.3),
                              child: Icon(
                                Icons.person,
                                color: AppColors.grey,
                                size: getWidth(24),
                              ),
                            )
                            : CachedNetworkImage(
                              imageUrl: submission.submittedBy.profileImage,
                              width: getWidth(40),
                              height: getWidth(40),
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    color: AppColors.grey.withOpacity(0.3),
                                    child: Icon(
                                      Icons.person,
                                      color: AppColors.grey,
                                      size: getWidth(24),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: AppColors.grey.withOpacity(0.3),
                                    child: Icon(
                                      Icons.person,
                                      color: AppColors.grey,
                                      size: getWidth(24),
                                    ),
                                  ),
                            ),
                  ),
                  SizedBox(width: getWidth(12)),

                  // Student details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          submission.submittedBy.name,
                          style: TextStyle(
                            fontSize: getWidth(16),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(height: getHeight(4)),
                        Text(
                          "Class ${submission.submittedBy.className} - Section ${submission.submittedBy.section}",
                          style: TextStyle(
                            fontSize: getWidth(12),
                            color: AppColors.textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: getWidth(16),
                    color: statusColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
