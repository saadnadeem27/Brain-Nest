import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/model/teachers/teacher_students_attendance_model.dart';
import 'package:intl/intl.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  final TeacherClassroomController controller =
      Get.find<TeacherClassroomController>();

  // Date selection and data loading state
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isEditing = false.obs;

  // Attendance data
  final RxList<StudentAttendanceModel> students =
      <StudentAttendanceModel>[].obs;
  // Map to track attendance changes
  final RxMap<String, String> attendanceChanges = <String, String>{}.obs;

  // Date formatter
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  final DateFormat displayDateFormatter = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    loadAttendanceData();
  }

  String getFormattedDate() {
    return dateFormatter.format(selectedDate.value);
  }

  String getDisplayDate() {
    return displayDateFormatter.format(selectedDate.value);
  }

  bool isFutureDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDateOnly = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );

    return selectedDateOnly.isAfter(today);
  }

  Future<void> loadAttendanceData() async {
    if (isFutureDate()) {
      students.clear();
      commonSnackBar(
        message: "Attendance cannot be marked for future dates",
        color: Colors.orange,
      );
      return;
    }

    isLoading.value = true;
    try {
      final attendanceList = await controller.getAttendanceDetails(
        date: getFormattedDate(),
      );

      if (attendanceList != null) {
        students.value = attendanceList;
        // Reset attendance changes when loading new data
        attendanceChanges.clear();
      } else {
        students.clear();
        commonSnackBar(
          message: "Failed to load attendance data",
          color: Colors.red,
        );
      }
    } catch (e) {
      log('Error loading attendance data: $e');
      commonSnackBar(
        message: "Error loading attendance data",
        color: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectDate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.blueColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textColor,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      await loadAttendanceData();
    }
  }

  void updateAttendanceStatus(String studentId, String newStatus) {
    // Update the attendance changes map
    attendanceChanges[studentId] = newStatus;

    // Update the local student list to reflect changes immediately
    final index = students.indexWhere((student) => student.id == studentId);
    if (index != -1) {
      final student = students[index];
      final updatedAttendanceDetails = AttendanceDetails(
        status: newStatus,
        dayStatus: student.attendanceDetails?.dayStatus ?? 'regular',
      );

      final updatedStudent = StudentAttendanceModel(
        id: student.id,
        name: student.name,
        profileImage: student.profileImage,
        attendanceDetails: updatedAttendanceDetails,
      );

      students[index] = updatedStudent;
    }
  }

  Future<void> saveAttendance() async {
    if (attendanceChanges.isEmpty) {
      commonSnackBar(
        message: "No attendance changes to save",
        color: Colors.orange,
      );
      return;
    }

    isSaving.value = true;
    try {
      // Format attendance data for API
      final List<Map<String, String>> attendanceData = [];

      attendanceChanges.forEach((studentId, status) {
        attendanceData.add({"studentId": studentId, "status": status});
      });

      final success = await controller.submitAttendance(
        date: getFormattedDate(),
        attendanceData: attendanceData,
      );

      if (success) {
        attendanceChanges.clear();
        isEditing.value = false;
        await loadAttendanceData(); // Reload to get server state
      }
    } catch (e) {
      log('Error saving attendance: $e');
      commonSnackBar(
        message: "Error saving attendance data",
        color: Colors.red,
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: "Student Attendance",
        actions: [
          Obx(
            () =>
                isEditing.value
                    ? Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            isEditing.value = false;
                            attendanceChanges.clear();
                            loadAttendanceData(); // Reset to server data
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: isSaving.value ? null : saveAttendance,
                          child: Text(
                            isSaving.value ? "Saving..." : "Save",
                            style: TextStyle(
                              color: AppColors.blueColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                    : IconButton(
                      icon: Icon(Icons.edit, color: AppColors.blueColor),
                      onPressed: () {
                        if (isFutureDate()) {
                          commonSnackBar(
                            message: "Cannot edit attendance for future dates",
                            color: Colors.orange,
                          );
                          return;
                        }
                        isEditing.value = true;
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (isEditing.value && attendanceChanges.isNotEmpty) {
          return FloatingActionButton.extended(
            onPressed: saveAttendance,
            backgroundColor: AppColors.blueColor,
            icon: Icon(Icons.save, color: Colors.white),
            label: Text("Save Changes", style: TextStyle(color: Colors.white)),
          );
        }
        return const SizedBox.shrink();
      }),
      body: Column(
        children: [
          // Date selector
          _buildDateSelector(),

          // Attendance status summary
          _buildAttendanceSummary(),

          // Students list
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return Center(child: commonLoader());
              }

              if (students.isEmpty) {
                return _buildEmptyState();
              }

              return _buildStudentsList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      margin: EdgeInsets.all(getWidth(16)),
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(16),
        vertical: getHeight(12),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(getWidth(12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: selectDate,
        borderRadius: BorderRadius.circular(getWidth(12)),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: AppColors.blueColor,
              size: getWidth(24),
            ),
            SizedBox(width: getWidth(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Date",
                    style: TextStyle(
                      fontSize: getWidth(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: getHeight(4)),
                  Obx(
                    () => Text(
                      getDisplayDate(),
                      style: TextStyle(
                        fontSize: getWidth(16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: AppColors.blueColor,
              size: getWidth(32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    if (students.isEmpty) return const SizedBox.shrink();

    int presentCount = 0;
    int absentCount = 0;
    int totalStudents = students.length;

    for (var student in students) {
      if (student.attendanceDetails?.status == 'present') {
        presentCount++;
      } else if (student.attendanceDetails?.status == 'absent') {
        absentCount++;
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: getWidth(16)),
      padding: EdgeInsets.all(getWidth(16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blueColor.withOpacity(0.1),
            AppColors.blueColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(getWidth(12)),
        border: Border.all(color: AppColors.blueColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              "Total",
              totalStudents,
              AppColors.blueColor,
              Icons.people_rounded,
            ),
          ),
          SizedBox(width: getWidth(16)),
          Expanded(
            child: _buildStatItem(
              "Present",
              presentCount,
              AppColors.green,
              Icons.check_circle_rounded,
            ),
          ),
          SizedBox(width: getWidth(16)),
          Expanded(
            child: _buildStatItem(
              "Absent",
              absentCount,
              AppColors.red,
              Icons.cancel_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: getWidth(20)),
            SizedBox(width: getWidth(8)),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: getWidth(18),
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
        SizedBox(height: getHeight(4)),
        Text(
          label,
          style: TextStyle(
            fontSize: getWidth(14),
            color: AppColors.textColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: getWidth(64),
            color: AppColors.grey.withOpacity(0.5),
          ),
          SizedBox(height: getHeight(16)),
          Text(
            "No Attendance Records",
            style: TextStyle(
              fontSize: getWidth(18),
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(8)),
          Text(
            "No attendance records found for this date",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: getWidth(14),
              color: AppColors.textColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: getHeight(24)),
          if (!isFutureDate()) ...[
            ElevatedButton.icon(
              onPressed: () {
                isEditing.value = true;
                // Mark all as present by default
                for (var student in students) {
                  if (student.id != null) {
                    attendanceChanges[student.id!] = "present";
                  }
                }
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                "Mark Attendance",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueColor,
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(24),
                  vertical: getHeight(12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(getWidth(8)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    return ListView.builder(
      padding: EdgeInsets.all(getWidth(16)),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return _buildStudentAttendanceCard(student);
      },
    );
  }

  Widget _buildStudentAttendanceCard(StudentAttendanceModel student) {
    final status = student.attendanceDetails?.status ?? 'absent';

    return Container(
      margin: EdgeInsets.only(bottom: getHeight(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getWidth(12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(getWidth(12)),
        child: Row(
          children: [
            // Student avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(getWidth(25)),
              child:
                  student.profileImage != null &&
                          student.profileImage!.isNotEmpty
                      ? Image.network(
                        student.profileImage!,
                        width: getWidth(50),
                        height: getWidth(50),
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                _buildDefaultAvatar(),
                      )
                      : _buildDefaultAvatar(),
            ),
            SizedBox(width: getWidth(16)),

            // Student name
            Expanded(
              child: Text(
                student.name ?? "Unknown Student",
                style: TextStyle(
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
            ),

            // Attendance status
            Obx(
              () =>
                  isEditing.value
                      ? _buildAttendanceSelector(student)
                      : _buildAttendanceStatusBadge(status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: getWidth(50),
      height: getWidth(50),
      decoration: BoxDecoration(
        color: AppColors.blueColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        color: AppColors.blueColor,
        size: getWidth(30),
      ),
    );
  }

  Widget _buildAttendanceStatusBadge(String status) {
    Color badgeColor;
    String label;
    IconData icon;

    switch (status) {
      case 'present':
        badgeColor = AppColors.green;
        label = "Present";
        icon = Icons.check_circle_rounded;
        break;
      case 'absent':
        badgeColor = AppColors.red;
        label = "Absent";
        icon = Icons.cancel_rounded;
        break;
      case 'holiday':
        badgeColor = AppColors.blueColor;
        label = "Holiday";
        icon = Icons.event_rounded;
        break;
      default:
        badgeColor = AppColors.grey;
        label = "No Record";
        icon = Icons.help_outline_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(12),
        vertical: getHeight(6),
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(getWidth(20)),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: getWidth(16)),
          SizedBox(width: getWidth(6)),
          Text(
            label,
            style: TextStyle(
              fontSize: getWidth(14),
              fontWeight: FontWeight.w500,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSelector(StudentAttendanceModel student) {
    if (student.id == null) return const SizedBox.shrink();

    final id = student.id!;
    final currentStatus = student.attendanceDetails?.status ?? 'absent';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusButton(
          id,
          currentStatus,
          'present',
          AppColors.green,
          Icons.check_circle_rounded,
        ),
        SizedBox(width: getWidth(8)),
        _buildStatusButton(
          id,
          currentStatus,
          'absent',
          AppColors.red,
          Icons.cancel_rounded,
        ),
      ],
    );
  }

  Widget _buildStatusButton(
    String studentId,
    String currentStatus,
    String status,
    Color color,
    IconData icon,
  ) {
    final isSelected = currentStatus == status;

    return InkWell(
      onTap: () => updateAttendanceStatus(studentId, status),
      borderRadius: BorderRadius.circular(getWidth(20)),
      child: Container(
        padding: EdgeInsets.all(getWidth(8)),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: isSelected ? 0 : 1),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : color,
          size: getWidth(20),
        ),
      ),
    );
  }
}
