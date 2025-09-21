import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/controller/teachers/teacher_vadtest_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/common/poeple_model.dart';
import 'package:Vadai/model/teachers/teacher_schoolexam_marksentry_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TeacherExamMarksEntryScreen extends StatefulWidget {
  final String examId;
  final String examName;
  final String subjectId;
  final String subjectName;
  final String classId;
  final String sectionId;
  final int totalMarks;

  const TeacherExamMarksEntryScreen({
    Key? key,
    required this.examId,
    required this.examName,
    required this.subjectId,
    required this.subjectName,
    required this.classId,
    required this.sectionId,
    required this.totalMarks,
  }) : super(key: key);

  @override
  State<TeacherExamMarksEntryScreen> createState() =>
      _TeacherExamMarksEntryScreenState();
}

class _TeacherExamMarksEntryScreenState
    extends State<TeacherExamMarksEntryScreen> {
  final TeacherVadTestController vadTestController = Get.find();

  final RxBool isLoading = true.obs;
  final RxList<PeopleModel> studentsList = <PeopleModel>[].obs;

  // Map to store student marks (studentId -> mark entry)
  final RxMap<String, TeacherSchoolExamMarkEntryModel> studentMarks =
      <String, TeacherSchoolExamMarkEntryModel>{}.obs;

  // Map to track which students have marks being edited
  final RxMap<String, bool> editingMarks = <String, bool>{}.obs;

  // Track text controllers for each student
  final Map<String, TextEditingController> markControllers = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    // Dispose all text controllers
    markControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      // Load students list
      final peopleData = await vadTestController.getPeopleList(
        classId: widget.classId,
        sectionId: widget.sectionId,
        subjectId: widget.subjectId,
      );

      if (peopleData != null && peopleData[ApiParameter.students] != null) {
        studentsList.value = peopleData[ApiParameter.students];

        // Initialize controllers for each student
        for (var student in studentsList) {
          if (student.sId != null) {
            markControllers[student.sId!] = TextEditingController();
          }
        }

        // Load marks for all students
        await loadAllStudentMarks();
      } else {
        commonSnackBar(message: "Failed to load students list");
      }
    } catch (e) {
      log("Error loading data: $e");
      commonSnackBar(message: "An error occurred while loading students");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAllStudentMarks() async {
    try {
      for (var student in studentsList) {
        if (student.sId != null) {
          await loadStudentMark(student.sId!);
        }
      }
    } catch (e) {
      log("Error loading all student marks: $e");
    }
  }

  Future<void> loadStudentMark(String studentId) async {
    try {
      final mark = await vadTestController.getStudentExamMark(
        examId: widget.examId,
        studentId: studentId,
        subjectId: widget.subjectId,
      );

      if (mark != null) {
        // Student already has a mark
        studentMarks[studentId] = mark;

        // Update the text controller
        if (markControllers.containsKey(studentId)) {
          markControllers[studentId]!.text = mark.markScored?.toString() ?? '';
        }
      }
    } catch (e) {
      log("Error loading mark for student $studentId: $e");
    }
  }

  Future<void> submitMark(String studentId) async {
    // Check if we have a text controller for this student
    if (!markControllers.containsKey(studentId)) return;

    // Get the mark from the text controller
    final markText = markControllers[studentId]!.text.trim();
    if (markText.isEmpty) {
      commonSnackBar(message: "Please enter a mark");
      return;
    }

    // Parse the mark
    int mark;
    try {
      mark = int.parse(markText);
    } catch (e) {
      commonSnackBar(message: "Please enter a valid number");
      return;
    }

    // Validate the mark
    if (mark < 0) {
      commonSnackBar(message: "Mark cannot be negative");
      return;
    }

    if (mark > widget.totalMarks) {
      commonSnackBar(message: "Mark cannot exceed ${widget.totalMarks}");
      return;
    }

    // Show loading
    isLoading.value = true;

    try {
      // Submit the mark
      final success = await vadTestController.submitStudentExamMark(
        examId: widget.examId,
        studentId: studentId,
        subjectId: widget.subjectId,
        markScored: mark,
      );

      if (success) {
        // Reload the mark to get the updated data
        await loadStudentMark(studentId);

        // Exit editing mode
        editingMarks[studentId] = false;
      }
    } catch (e) {
      log("Error submitting mark: $e");
      commonSnackBar(message: "Failed to submit mark");
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
        title: "${widget.subjectName} Marks Entry",
        isBack: true,
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(child: commonLoader());
        }

        if (studentsList.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            // Header info card
            _buildHeaderInfo(),

            // Students list with marks entry
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(16),
                  vertical: getHeight(16),
                ),
                itemCount: studentsList.length,
                itemBuilder: (context, index) {
                  final student = studentsList[index];
                  return _buildStudentMarkItem(student, index + 1);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(getWidth(16)),
      margin: EdgeInsets.all(getWidth(16)),
      decoration: BoxDecoration(
        color: AppColors.blueColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(getWidth(12)),
        border: Border.all(color: AppColors.blueColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.examName,
            style: TextStyle(
              fontSize: getWidth(18),
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.book_rounded,
                          color: AppColors.blueColor,
                          size: getWidth(16),
                        ),
                        SizedBox(width: getWidth(4)),
                        Expanded(
                          child: Text(
                            "Subject: ${widget.subjectName}",
                            style: TextStyle(
                              fontSize: getWidth(14),
                              color: AppColors.textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: getHeight(4)),
                    Row(
                      children: [
                        Icon(
                          Icons.people_alt_rounded,
                          color: AppColors.blueColor,
                          size: getWidth(16),
                        ),
                        SizedBox(width: getWidth(4)),
                        Text(
                          "Students: ${studentsList.length}",
                          style: TextStyle(
                            fontSize: getWidth(14),
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(12),
                  vertical: getHeight(6),
                ),
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(getWidth(8)),
                ),
                child: Text(
                  "Total: ${widget.totalMarks} marks",
                  style: TextStyle(
                    fontSize: getWidth(14),
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: getHeight(8)),
          Text(
            "Enter marks for each student below:",
            style: TextStyle(
              fontSize: getWidth(13),
              fontStyle: FontStyle.italic,
              color: AppColors.textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentMarkItem(PeopleModel student, int serialNumber) {
    if (student.sId == null) return SizedBox.shrink();

    // Check if student has mark entry
    final hasMarkEntry = studentMarks.containsKey(student.sId!);

    return Obx(() {
      final isEditing = editingMarks[student.sId!] ?? false;
      final markEntry = hasMarkEntry ? studentMarks[student.sId!] : null;
      final markController = markControllers[student.sId!];
      return Container(
        margin: EdgeInsets.only(bottom: getHeight(12)),
        padding: EdgeInsets.all(getWidth(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(getWidth(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Serial number
            Container(
              width: getWidth(28),
              height: getWidth(28),
              decoration: BoxDecoration(
                color: AppColors.blueColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  serialNumber.toString(),
                  style: TextStyle(
                    fontSize: getWidth(14),
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: getWidth(12)),

            // Student profile image
            Container(
              width: getWidth(40),
              height: getWidth(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey.withOpacity(0.1),
                border: Border.all(
                  color: AppColors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child:
                  student.profileImage != null &&
                          student.profileImage!.isNotEmpty
                      ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: student.profileImage!,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: AppColors.grey.withOpacity(0.3),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: AppColors.blueColor,
                                  size: getWidth(32),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: AppColors.blueColor.withOpacity(0.15),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: AppColors.blueColor,
                                  size: getWidth(32),
                                ),
                              ),
                        ),
                      )
                      : Icon(
                        Icons.person,
                        color: AppColors.grey,
                        size: getWidth(24),
                      ),
            ),
            SizedBox(width: getWidth(12)),

            // Student name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name ?? 'Unknown Student',
                    style: TextStyle(
                      fontSize: getWidth(15),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                  if (student.email != null && student.email!.isNotEmpty) ...[
                    SizedBox(height: getHeight(2)),
                    Text(
                      student.email!,
                      style: TextStyle(
                        fontSize: getWidth(12),
                        color: AppColors.textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Mark display or entry
            if (isEditing && markController != null) ...[
              // Edit mode - Allow marking
              Container(
                width: getWidth(60),
                height: getHeight(40),
                child: commonTextFiled(
                  controller: markController,
                  keyBoardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  borderRadius: getWidth(6),
                ),
              ),
              SizedBox(width: getWidth(8)),
              // Save button
              IconButton(
                onPressed: () => submitMark(student.sId!),
                icon: Icon(Icons.check_circle, color: Colors.green),
                tooltip: 'Save',
              ),
              // Cancel button
              IconButton(
                onPressed: () {
                  // Reset to original value
                  if (markEntry != null && markEntry.markScored != null) {
                    markController!.text = markEntry.markScored.toString();
                  } else {
                    markController!.clear();
                  }
                  // Exit edit mode
                  editingMarks[student.sId!] = false;
                },
                icon: Icon(Icons.cancel, color: Colors.red),
                tooltip: 'Cancel',
              ),
            ] else if (hasMarkEntry) ...[
              // Display mode - Show existing mark
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(12),
                  vertical: getHeight(6),
                ),
                decoration: BoxDecoration(
                  color: _getMarkColor(markEntry!),
                  borderRadius: BorderRadius.circular(getWidth(8)),
                ),
                child: Text(
                  "${markEntry.markScored ?? 0}/${markEntry.totalMark ?? widget.totalMarks}",
                  style: TextStyle(
                    fontSize: getWidth(14),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: getWidth(8)),
              // Edit button
              IconButton(
                onPressed: () {
                  editingMarks[student.sId!] = true;
                },
                icon: Icon(Icons.edit, color: AppColors.blueColor),
                tooltip: 'Edit',
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: () {
                  editingMarks[student.sId!] = true;
                  editingMarks.refresh();
                },
                icon: Icon(Icons.add, size: getWidth(16)),
                label: Text("Add"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: getWidth(12),
                    vertical: getHeight(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Color _getMarkColor(TeacherSchoolExamMarkEntryModel markEntry) {
    final percentage = markEntry.getPercentage();

    if (percentage >= 75) {
      return Colors.green; // Excellent
    } else if (percentage >= 60) {
      return Colors.blue; // Good
    } else if (percentage >= 40) {
      return Colors.orange; // Pass
    } else {
      return Colors.red; // Fail
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_alt_outlined,
            size: getWidth(64),
            color: AppColors.grey.withOpacity(0.5),
          ),
          SizedBox(height: getHeight(16)),
          Text(
            "No Students Found",
            style: TextStyle(
              fontSize: getWidth(18),
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(8)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: getWidth(32)),
            child: Text(
              "There are no students assigned to this class yet.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: getWidth(14),
                color: AppColors.textColor.withOpacity(0.7),
              ),
            ),
          ),
          SizedBox(height: getHeight(24)),
          materialButtonOnlyText(text: "Refresh", onTap: loadData),
        ],
      ),
    );
  }
}
