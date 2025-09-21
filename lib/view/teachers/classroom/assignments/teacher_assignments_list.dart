import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/model/teachers/teacher_assignment_model.dart';
import 'package:Vadai/view/teachers/classroom/assignments/teacher_update_assignment.dart';
import 'package:intl/intl.dart';

class TeacherAssignmentsList extends StatefulWidget {
  const TeacherAssignmentsList({Key? key}) : super(key: key);

  @override
  State<TeacherAssignmentsList> createState() => _TeacherAssignmentsListState();
}

class _TeacherAssignmentsListState extends State<TeacherAssignmentsList> {
  final TeacherClassroomController _controller =
      Get.find<TeacherClassroomController>();

  String className = '';
  String sectionName = '';
  String subjectName = '';
  String classId = '';
  String sectionId = '';
  String subjectId = '';

  RxBool isLoading = false.obs;
  RxList<TeacherAssignmentModel> assignments = <TeacherAssignmentModel>[].obs;

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
        className = Get.arguments['className'] ?? '';
        sectionName = Get.arguments['sectionName'] ?? '';
        subjectName = Get.arguments['subjectName'] ?? '';
        classId = Get.arguments['classId'] ?? '';
        sectionId = Get.arguments['sectionId'] ?? '';
        subjectId = Get.arguments['subjectId'] ?? '';

        // Load assignments
        await loadAssignments();
      }
    } catch (e) {
      log('Error in initData of teacher assignments list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAssignments() async {
    try {
      final result = await _controller.getAssignmentsList(subjectId: subjectId);
      if (result != null) {
        assignments.value = result;
      }
    } catch (e) {
      log('Error loading assignments: $e');
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
          title: 'Assignments',
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.toNamed(
              RouteNames.createAssignment,
              arguments: {'subjectId': subjectId, 'subjectName': subjectName},
            )?.then((result) {
              if (result == true) {
                loadAssignments();
              }
            });
          },
          backgroundColor: AppColors.blueColor,
          child: const Icon(Icons.add, color: AppColors.white),
        ),
        body:
            isLoading.value
                ? Center(child: commonLoader())
                : RefreshIndicator(
                  onRefresh: loadAssignments,
                  child:
                      assignments.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: getWidth(80),
                                  color: AppColors.grey.withOpacity(0.5),
                                ),
                                SizedBox(height: getHeight(16)),
                                Text(
                                  'No assignments yet',
                                  style: TextStyle(
                                    fontSize: getWidth(16),
                                    color: AppColors.textColor.withOpacity(0.7),
                                  ),
                                ),
                                SizedBox(height: getHeight(8)),
                                Text(
                                  'Create your first assignment by clicking the + button',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: getWidth(14),
                                    color: AppColors.textColor.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            itemCount: assignments.length,
                            padding: EdgeInsets.all(getWidth(16)),
                            itemBuilder: (context, index) {
                              final assignment = assignments[index];
                              bool isOverdue = assignment.isDueOver();
                              return _buildAssignmentCard(
                                assignment,
                                isOverdue,
                              );
                            },
                          ),
                ),
      ),
    );
  }

  Widget _buildAssignmentCard(
    TeacherAssignmentModel assignment,
    bool isOverdue,
  ) {
    final dueDate = assignment.getDueDateDateTime();
    final formattedDate =
        dueDate != null
            ? DateFormat('MMM dd, yyyy').format(dueDate)
            : 'No due date';

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          RouteNames.teacherSubmissions,
          arguments: {'assignment': assignment, 'subjectName': subjectName},
        );
      },
      onLongPress: () {
        _showAssignmentOptions(assignment);
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
          border: Border.all(
            color:
                isOverdue
                    ? AppColors.red.withOpacity(0.3)
                    : AppColors.blueColor.withOpacity(0.3),
            width: 1,
          ),
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
                color:
                    isOverdue
                        ? AppColors.red.withOpacity(0.1)
                        : AppColors.blueColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(getWidth(12)),
                  topRight: Radius.circular(getWidth(12)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Due: $formattedDate",
                    style: TextStyle(
                      fontSize: getWidth(12),
                      fontWeight: FontWeight.w500,
                      color: isOverdue ? AppColors.red : AppColors.blueColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getWidth(8),
                      vertical: getHeight(4),
                    ),
                    decoration: BoxDecoration(
                      color:
                          isOverdue
                              ? AppColors.red.withOpacity(0.2)
                              : AppColors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(getWidth(12)),
                    ),
                    child: Text(
                      isOverdue ? "Overdue" : "Active",
                      style: TextStyle(
                        fontSize: getWidth(10),
                        fontWeight: FontWeight.w600,
                        color: isOverdue ? AppColors.red : AppColors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Assignment content
            Padding(
              padding: EdgeInsets.all(getWidth(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.lesson ?? 'Untitled Assignment',
                    style: TextStyle(
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: getHeight(8)),

                  // Topics
                  if (assignment.topics != null &&
                      assignment.topics!.isNotEmpty)
                    Wrap(
                      spacing: getWidth(8),
                      runSpacing: getHeight(8),
                      children:
                          assignment.topics!.map((topic) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: getWidth(8),
                                vertical: getHeight(4),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blueColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  getWidth(12),
                                ),
                              ),
                              child: Text(
                                topic,
                                style: TextStyle(
                                  fontSize: getWidth(10),
                                  color: AppColors.blueColor,
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                  SizedBox(height: getHeight(16)),

                  // Submission info
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: getWidth(14),
                        color: AppColors.textColor.withOpacity(0.6),
                      ),
                      SizedBox(width: getWidth(4)),
                      Text(
                        "${assignment.submittedCount ?? 0} submissions",
                        style: TextStyle(
                          fontSize: getWidth(12),
                          color: AppColors.textColor.withOpacity(0.6),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          // Edit button
                          InkWell(
                            onTap: () => _editAssignment(assignment),
                            borderRadius: BorderRadius.circular(getWidth(16)),
                            child: Padding(
                              padding: EdgeInsets.all(getWidth(8)),
                              child: Icon(
                                Icons.edit_outlined,
                                size: getWidth(21),
                                color: AppColors.blueColor,
                              ),
                            ),
                          ),

                          // Delete button
                          InkWell(
                            onTap: () => _confirmDeleteAssignment(assignment),
                            borderRadius: BorderRadius.circular(getWidth(16)),
                            child: Padding(
                              padding: EdgeInsets.all(getWidth(8)),
                              child: Icon(
                                Icons.delete_outline,
                                size: getWidth(21),
                                color: AppColors.red,
                              ),
                            ),
                          ),

                          SizedBox(width: getWidth(4)),

                          // View submissions arrow
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: getWidth(21),
                            color: AppColors.blueColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignmentOptions(TeacherAssignmentModel assignment) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(getWidth(16))),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: getHeight(20),
            horizontal: getWidth(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Assignment Options",
                style: TextStyle(
                  fontSize: getWidth(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: getHeight(20)),
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.blueColor),
                title: Text("Edit Assignment"),
                onTap: () {
                  Navigator.pop(context);
                  _editAssignment(assignment);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.red),
                title: Text("Delete Assignment"),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteAssignment(assignment);
                },
              ),
              ListTile(
                leading: Icon(Icons.visibility, color: AppColors.green),
                title: Text("View Submissions"),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed(
                    RouteNames.teacherSubmissions,
                    arguments: {
                      'assignment': assignment,
                      'subjectName': subjectName,
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editAssignment(TeacherAssignmentModel assignment) {
    Get.to(
      () => TeacherUpdateAssignment(),
      arguments: {'assignment': assignment, 'subjectName': subjectName},
    )?.then((result) {
      if (result == true || result == 'deleted') {
        // Refresh the assignments list
        loadAssignments();
      }
    });
  }

  void _confirmDeleteAssignment(TeacherAssignmentModel assignment) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Assignment?'),
        content: Text(
          'Are you sure you want to delete this assignment? This action cannot be undone and all student submissions will be deleted.',
          style: TextStyle(fontSize: getWidth(14)),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              _deleteAssignment(assignment);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAssignment(TeacherAssignmentModel assignment) async {
    try {
      final result = await _controller.deleteAssignment(
        assignmentId: assignment.sId ?? '',
      );

      if (result) {
        commonSnackBar(
          message: "Assignment deleted successfully",
          color: AppColors.green,
        );
        loadAssignments();
      } else {
        commonSnackBar(
          message: "Failed to delete assignment",
          color: AppColors.red,
        );
      }
    } catch (e) {
      log('Error deleting assignment: $e');
      commonSnackBar(
        message: "An error occurred while deleting the assignment",
        color: AppColors.red,
      );
    }
  }
}
