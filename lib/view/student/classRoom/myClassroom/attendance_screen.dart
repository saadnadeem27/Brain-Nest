import 'dart:developer';
import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/classroom_controller.dart';
import 'package:Vadai/controller/student/student_profile_controller.dart';
import 'package:Vadai/model/students/attendance_data_model.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final ClassRoomController _controller = Get.find<ClassRoomController>();
  final StudentProfileController _profileController =
      Get.find<StudentProfileController>();

  RxBool isLoading = true.obs;
  Rx<AttendanceDataModel?> attendanceData = Rx<AttendanceDataModel?>(null);

  // Current month and year for fetching data
  RxInt currentMonth = DateTime.now().month.obs;
  RxInt currentYear = DateTime.now().year.obs;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    isLoading.value = true;
    try {
      final data = await _controller.getAttendance(
        month: currentMonth.value,
        year: currentYear.value,
      );
      attendanceData.value = data;
    } catch (e) {
      log('Error fetching attendance data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void goToPreviousMonth() {
    if (currentMonth.value == 1) {
      currentMonth.value = 12;
      currentYear.value--;
    } else {
      currentMonth.value--;
    }
    fetchAttendanceData();
  }

  void goToNextMonth() {
    // Don't allow future months beyond current
    final now = DateTime.now();
    if (currentYear.value == now.year && currentMonth.value == now.month) {
      return;
    }

    if (currentMonth.value == 12) {
      currentMonth.value = 1;
      currentYear.value++;
    } else {
      currentMonth.value++;
    }
    fetchAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(context: context, isBack: true, title: "Attendance"),
      body: Obx(
        () =>
            isLoading.value
                ? Center(child: commonLoader())
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAttendanceSummary(),
                      SizedBox(height: getHeight(16)),
                      _buildMonthSelector(),
                      SizedBox(height: getHeight(16)),
                      _buildCalendar(),
                      SizedBox(height: getHeight(16)),
                      _buildLegend(),
                      SizedBox(height: getHeight(30)),
                    ],
                  ).paddingSymmetric(horizontal: getWidth(16)),
                ),
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    final data = attendanceData.value;
    final attendancePercentage = data?.attendancePercentage ?? 0.0;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: getHeight(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(getWidth(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(getWidth(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textWid(
                      _profileController.studentProfile.value?.name ??
                          "Student",
                      style: TextStyle(
                        fontSize: getWidth(18),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: getHeight(4)),
                    textWid(
                      "Class ${_profileController.studentProfile.value?.className ?? ''} - ${_profileController.studentProfile.value?.section ?? ''}",
                      style: TextStyle(
                        fontSize: getWidth(14),
                        color: AppColors.textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: getWidth(12),
                    vertical: getHeight(6),
                  ),
                  decoration: BoxDecoration(
                    color: _getAttendanceColor(attendancePercentage),
                    borderRadius: BorderRadius.circular(getWidth(20)),
                  ),
                  child: textWid(
                    "${attendancePercentage.toStringAsFixed(1)}%",
                    style: TextStyle(
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: getHeight(8)),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Present",
                  data?.presentCount ?? 0,
                  AppColors.green,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  "Absent",
                  data?.absentCount ?? 0,
                  AppColors.red,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  "Holiday",
                  data?.holidayCount ?? 0,
                  AppColors.blueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 75) {
      return AppColors.green;
    } else if (percentage >= 50) {
      return AppColors.colorC56469;
    } else {
      return AppColors.red;
    }
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: getHeight(12)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border(
          top: BorderSide(color: color.withOpacity(0.3), width: 1),
          bottom: BorderSide(color: color, width: 3),
        ),
      ),
      child: Column(
        children: [
          textWid(
            count.toString(),
            style: TextStyle(
              fontSize: getWidth(18),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: getHeight(4)),
          textWid(
            label,
            style: TextStyle(
              fontSize: getWidth(14),
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    final monthName = DateFormat(
      'MMMM',
    ).format(DateTime(currentYear.value, currentMonth.value));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(16),
        vertical: getHeight(8),
      ),
      decoration: BoxDecoration(
        color: AppColors.blueColor,
        borderRadius: BorderRadius.circular(getWidth(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: goToPreviousMonth,
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.white,
              size: getWidth(20),
            ),
          ),
          textWid(
            "$monthName ${currentYear.value}",
            style: TextStyle(
              fontSize: getWidth(18),
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              // Check if we're at the current month
              final now = DateTime.now();
              if (currentYear.value == now.year &&
                  currentMonth.value == now.month) {
                return;
              }
              goToNextMonth();
            },
            icon: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.white,
              size: getWidth(20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    // Get days in month
    final daysInMonth =
        DateTime(currentYear.value, currentMonth.value + 1, 0).day;

    // Get first day of month (0 = Monday, 6 = Sunday)
    final firstDayOfMonth =
        DateTime(currentYear.value, currentMonth.value, 1).weekday;

    // Adjust for Sunday as first day (0 = Sunday, 6 = Saturday)
    final firstDayIndex = firstDayOfMonth % 7;

    // Create attendance map for quick lookups
    final attendanceMap = <String, AttendanceStatus>{};
    if (attendanceData.value != null) {
      for (var record in attendanceData.value!.attendance) {
        attendanceMap[record.date] = record.status;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(getWidth(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(getWidth(16)),
      child: Column(
        children: [
          // Calendar header (days of week)
          Row(
            children: [
              _buildDayHeader("Sun"),
              _buildDayHeader("Mon"),
              _buildDayHeader("Tue"),
              _buildDayHeader("Wed"),
              _buildDayHeader("Thu"),
              _buildDayHeader("Fri"),
              _buildDayHeader("Sat"),
            ],
          ),
          SizedBox(height: getHeight(8)),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: getWidth(4),
              mainAxisSpacing: getHeight(4),
            ),
            itemCount: firstDayIndex + daysInMonth,
            itemBuilder: (context, index) {
              // Empty cells before the first day of month
              if (index < firstDayIndex) {
                return Container();
              }

              final day = index - firstDayIndex + 1;
              final dateStr = DateFormat(
                'yyyy-MM-dd',
              ).format(DateTime(currentYear.value, currentMonth.value, day));

              final status =
                  attendanceMap[dateStr] ?? AttendanceStatus.noRecord;

              return _buildDayCell(day, status);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeader(String day) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: getHeight(8)),
        child: textWid(
          day,
          style: TextStyle(
            fontSize: getWidth(14),
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(int day, AttendanceStatus status) {
    // Determine cell color based on status
    Color backgroundColor;
    Color textColor = AppColors.white;

    switch (status) {
      case AttendanceStatus.present:
        backgroundColor = AppColors.green;
        break;
      case AttendanceStatus.absent:
        backgroundColor = AppColors.red;
        break;
      case AttendanceStatus.holiday:
        backgroundColor = AppColors.blueColor;
        break;
      case AttendanceStatus.noRecord:
        backgroundColor = AppColors.grey.withOpacity(0.3);
        textColor = AppColors.textColor;
        break;
    }

    // Check if this is today
    final now = DateTime.now();
    final isToday =
        day == now.day &&
        currentMonth.value == now.month &&
        currentYear.value == now.year;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(getWidth(8)),
        border: isToday ? Border.all(color: AppColors.black, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: textWid(
        day.toString(),
        style: TextStyle(
          fontSize: getWidth(14),
          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem("Present", AppColors.green),
        _buildLegendItem("Absent", AppColors.red),
        _buildLegendItem("Holiday", AppColors.blueColor),
        _buildLegendItem("No Record", AppColors.grey.withOpacity(0.3)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: getWidth(16),
          height: getWidth(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(getWidth(4)),
          ),
        ),
        SizedBox(width: getWidth(4)),
        textWid(
          label,
          style: TextStyle(fontSize: getWidth(12), color: AppColors.textColor),
        ),
      ],
    );
  }
}
