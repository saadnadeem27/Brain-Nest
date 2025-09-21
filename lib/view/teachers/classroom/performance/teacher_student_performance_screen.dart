import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/model/teachers/teacher_student_performance_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';

class TeacherStudentPerformanceScreen extends StatefulWidget {
  const TeacherStudentPerformanceScreen({Key? key}) : super(key: key);

  @override
  State<TeacherStudentPerformanceScreen> createState() =>
      _TeacherStudentPerformanceScreenState();
}

class _TeacherStudentPerformanceScreenState
    extends State<TeacherStudentPerformanceScreen>
    with SingleTickerProviderStateMixin {
  final TeacherClassroomController controller = Get.find();

  final RxBool isLoading = true.obs;
  final RxBool isSchoolReportLoading = false.obs;
  final RxBool isVadReportLoading = false.obs;

  final Rx<TeacherStudentPerformanceModel?> schoolExamReport =
      Rx<TeacherStudentPerformanceModel?>(null);
  final Rx<TeacherStudentPerformanceModel?> vadTestReport =
      Rx<TeacherStudentPerformanceModel?>(null);

  late TabController _tabController;

  String studentId = '';
  String studentName = '';
  String? studentImage;
  String className = '';
  String sectionName = '';
  String subjectName = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void initData() async {
    isLoading.value = true;

    try {
      // Extract arguments
      if (Get.arguments != null) {
        studentId = Get.arguments['studentId'] ?? '';
        studentName = Get.arguments['studentName'] ?? '';
        studentImage = Get.arguments['studentImage'];
        className = Get.arguments['className'] ?? '';
        sectionName = Get.arguments['sectionName'] ?? '';
        subjectName = Get.arguments['subjectName'] ?? '';
      }

      // Load both reports concurrently
      await Future.wait([loadSchoolExamReport(), loadVadTestReport()]);
    } catch (e) {
      log('Error in initData of TeacherStudentPerformanceScreen: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSchoolExamReport() async {
    if (studentId.isEmpty) return;

    isSchoolReportLoading.value = true;

    try {
      final report = await controller.getStudentSchoolExamReport(
        studentId: studentId,
      );

      schoolExamReport.value = report;
    } catch (e) {
      log('Error loading school exam report: $e');
    } finally {
      isSchoolReportLoading.value = false;
    }
  }

  Future<void> loadVadTestReport() async {
    if (studentId.isEmpty) return;

    isVadReportLoading.value = true;

    try {
      final report = await controller.getStudentVadTestExamReport(
        studentId: studentId,
      );

      vadTestReport.value = report;
    } catch (e) {
      log('Error loading VAD test report: $e');
    } finally {
      isVadReportLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: "Performance Report",
      ),
      body: Obx(
        () =>
            isLoading.value
                ? Center(child: commonLoader())
                : Column(
                  children: [
                    // Student profile and info card
                    _buildStudentInfoCard(),

                    // Tab bar
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.blueColor,
                      unselectedLabelColor: AppColors.textColor.withOpacity(
                        0.5,
                      ),
                      indicatorColor: AppColors.blueColor,
                      tabs: [
                        Tab(
                          text: "School Exams",
                          icon: Icon(Icons.school_rounded),
                        ),
                        Tab(text: "VAD Tests", icon: Icon(Icons.quiz_rounded)),
                      ],
                    ),

                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // School Exams Tab
                          _buildSchoolExamReportTab(),

                          // VAD Tests Tab
                          _buildVadTestReportTab(),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(getWidth(16)),
      margin: EdgeInsets.all(getWidth(16)),
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
        border: Border.all(color: AppColors.blueColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Student profile image
          Container(
            width: getWidth(56),
            height: getWidth(56),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey.withOpacity(0.1),
              border: Border.all(
                color: AppColors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child:
                studentImage != null && studentImage!.isNotEmpty
                    ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: studentImage!,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              color: AppColors.grey.withOpacity(0.3),
                              child: Icon(
                                Icons.person_rounded,
                                color: AppColors.blueColor,
                                size: getWidth(40),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: AppColors.blueColor.withOpacity(0.15),
                              child: Icon(
                                Icons.person_rounded,
                                color: AppColors.blueColor,
                                size: getWidth(40),
                              ),
                            ),
                      ),
                    )
                    : Icon(
                      Icons.person,
                      color: AppColors.grey,
                      size: getWidth(32),
                    ),
          ),
          SizedBox(width: getWidth(16)),

          // Student information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: TextStyle(
                    fontSize: getWidth(18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: getHeight(4)),
                if (className.isNotEmpty)
                  Text(
                    "Class $className${sectionName.isNotEmpty ? '-$sectionName' : ''}",
                    style: TextStyle(
                      fontSize: getWidth(14),
                      color: AppColors.textColor.withOpacity(0.8),
                    ),
                  ),
                SizedBox(height: getHeight(4)),
                if (subjectName.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.book,
                        size: getWidth(14),
                        color: AppColors.blueColor,
                      ),
                      SizedBox(width: getWidth(4)),
                      Text(
                        subjectName,
                        style: TextStyle(
                          fontSize: getWidth(14),
                          color: AppColors.blueColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolExamReportTab() {
    return Obx(() {
      if (isSchoolReportLoading.value) {
        return Center(child: commonLoader());
      }

      final report = schoolExamReport.value;

      if (report == null ||
          report.report == null ||
          report.report!.exams == null ||
          report.report!.exams!.isEmpty) {
        return _buildEmptyReportState(
          "No school exam data available for this student.",
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(getWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall performance card
            _buildOverallPerformanceCard(report.report!),

            SizedBox(height: getHeight(16)),

            // Performance by exam
            Text(
              "Performance by Exam",
              style: TextStyle(
                fontSize: getWidth(16),
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: getHeight(8)),

            // Chart for each exam
            _buildExamPerformanceBarChart(report.report!),

            SizedBox(height: getHeight(24)),

            // Detailed exam reports
            Text(
              "Detailed Exam Reports",
              style: TextStyle(
                fontSize: getWidth(16),
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: getHeight(8)),

            // List each exam with details
            ...report.report!.exams!
                .map((exam) => _buildExamDetailCard(exam))
                .toList(),
          ],
        ),
      );
    });
  }

  Widget _buildVadTestReportTab() {
    return Obx(() {
      if (isVadReportLoading.value) {
        return Center(child: commonLoader());
      }

      final report = vadTestReport.value;

      if (report == null ||
          report.report == null ||
          report.report!.exams == null ||
          report.report!.exams!.isEmpty) {
        return _buildEmptyReportState(
          "No VAD test data available for this student.",
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(getWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall performance card
            _buildOverallPerformanceCard(report.report!),

            SizedBox(height: getHeight(16)),

            // Performance by exam
            Text(
              "Performance by Test",
              style: TextStyle(
                fontSize: getWidth(16),
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: getHeight(8)),

            // Chart for each exam
            _buildExamPerformanceBarChart(report.report!),

            SizedBox(height: getHeight(24)),

            // Detailed exam reports
            Text(
              "Detailed Test Reports",
              style: TextStyle(
                fontSize: getWidth(16),
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: getHeight(8)),

            // List each exam with details
            ...report.report!.exams!
                .map((exam) => _buildExamDetailCard(exam))
                .toList(),
          ],
        ),
      );
    });
  }

  Widget _buildOverallPerformanceCard(PerformanceReport report) {
    final overallPercentage = report.getOverallPercentage();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(getWidth(16)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Overall Performance",
            style: TextStyle(
              fontSize: getWidth(16),
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(16)),

          // Circular progress indicator
          SizedBox(
            height: getHeight(160),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: getWidth(140),
                  height: getWidth(140),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: getWidth(140),
                        height: getWidth(140),
                        child: CircularProgressIndicator(
                          value: overallPercentage / 100,
                          strokeWidth: getWidth(12),
                          backgroundColor: AppColors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getColorForPercentage(overallPercentage),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${overallPercentage.toStringAsFixed(1)}%",
                              style: TextStyle(
                                fontSize: getWidth(24),
                                fontWeight: FontWeight.bold,
                                color: _getColorForPercentage(
                                  overallPercentage,
                                ),
                              ),
                            ),
                            Text(
                              "Average",
                              style: TextStyle(
                                fontSize: getWidth(14),
                                color: AppColors.textColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPerformanceMetric(
                      "Excellent",
                      Colors.green,
                      overallPercentage >= 80,
                    ),
                    SizedBox(height: getHeight(8)),
                    _buildPerformanceMetric(
                      "Good",
                      Colors.blue,
                      overallPercentage >= 60 && overallPercentage < 80,
                    ),
                    SizedBox(height: getHeight(8)),
                    _buildPerformanceMetric(
                      "Average",
                      Colors.orange,
                      overallPercentage >= 40 && overallPercentage < 60,
                    ),
                    SizedBox(height: getHeight(8)),
                    _buildPerformanceMetric(
                      "Needs Improvement",
                      Colors.red,
                      overallPercentage < 40,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: getHeight(16)),

          // Total exams info
          Text(
            "Based on ${report.exams?.length ?? 0} exams",
            style: TextStyle(
              fontSize: getWidth(14),
              fontStyle: FontStyle.italic,
              color: AppColors.textColor.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(String label, Color color, bool isActive) {
    return Row(
      children: [
        Container(
          width: getWidth(12),
          height: getWidth(12),
          decoration: BoxDecoration(
            color: isActive ? color : color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: getWidth(8)),
        Text(
          label,
          style: TextStyle(
            fontSize: getWidth(14),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color:
                isActive
                    ? AppColors.textColor
                    : AppColors.textColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildExamPerformanceBarChart(PerformanceReport report) {
    // Early return if no exams
    if (report.exams == null || report.exams!.isEmpty) {
      return SizedBox();
    }

    final exams = report.exams!;

    return Container(
      height: getHeight(300),
      padding: EdgeInsets.all(getWidth(16)),
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
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${exams[groupIndex].name}\n${rod.toY.round()}%',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < exams.length) {
                    // Abbreviate exam names to fit
                    String examName = exams[value.toInt()].name ?? 'Exam';
                    if (examName.length > 10) {
                      examName = examName.substring(0, 10) + '...';
                    }
                    return Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        examName,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: getWidth(12),
                        ),
                      ),
                    );
                  }
                  return SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value % 20 == 0) {
                    return Text(
                      '${value.toInt()}%',
                      style: TextStyle(
                        color: AppColors.textColor.withOpacity(0.6),
                        fontSize: getWidth(12),
                      ),
                    );
                  }
                  return SizedBox();
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups:
              exams.asMap().entries.map((entry) {
                int index = entry.key;
                ExamPerformance exam = entry.value;
                double percentage = exam.getAveragePercentage();

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: percentage,
                      color: _getColorForPercentage(percentage),
                      width: getWidth(20),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(getWidth(4)),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildExamDetailCard(ExamPerformance exam) {
    final subjectsCount = exam.subjects?.length ?? 0;
    final examPercentage = exam.getAveragePercentage();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: getHeight(16)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exam header
          Container(
            padding: EdgeInsets.all(getWidth(16)),
            decoration: BoxDecoration(
              color: AppColors.blueColor.withOpacity(0.05),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(getWidth(12)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.name ?? 'Exam',
                        style: TextStyle(
                          fontSize: getWidth(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      if (exam.startDate != null) ...[
                        SizedBox(height: getHeight(4)),
                        Text(
                          "Date: ${exam.getFormattedDate()}",
                          style: TextStyle(
                            fontSize: getWidth(12),
                            color: AppColors.textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: getWidth(12),
                    vertical: getHeight(6),
                  ),
                  decoration: BoxDecoration(
                    color: _getColorForPercentage(examPercentage),
                    borderRadius: BorderRadius.circular(getWidth(16)),
                  ),
                  child: Text(
                    "${examPercentage.toStringAsFixed(1)}%",
                    style: TextStyle(
                      fontSize: getWidth(14),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Subjects performance list
          if (subjectsCount > 0) ...[
            Padding(
              padding: EdgeInsets.all(getWidth(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Subjects ($subjectsCount)",
                    style: TextStyle(
                      fontSize: getWidth(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: getHeight(8)),
                  ...?exam.subjects
                      ?.map((subject) => _buildSubjectPerformanceItem(subject))
                      .toList(),

                  SizedBox(height: getHeight(12)),

                  // Total score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Score:",
                        style: TextStyle(
                          fontSize: getWidth(14),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      Text(
                        "${exam.getTotalMarksScored()}/${exam.getTotalMarksAvailable()}",
                        style: TextStyle(
                          fontSize: getWidth(14),
                          fontWeight: FontWeight.w600,
                          color: AppColors.blueColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubjectPerformanceItem(SubjectPerformance subject) {
    final percentage = subject.getPercentage();
    final grade = subject.getGrade();

    return Container(
      padding: EdgeInsets.symmetric(vertical: getHeight(8)),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  subject.subject ?? 'Subject',
                  style: TextStyle(
                    fontSize: getWidth(14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              Text(
                "${subject.markScored ?? 0}/${subject.totalMark ?? 0}",
                style: TextStyle(
                  fontSize: getWidth(14),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(width: getWidth(8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(8),
                  vertical: getHeight(4),
                ),
                decoration: BoxDecoration(
                  color: _getColorForPercentage(percentage),
                  borderRadius: BorderRadius.circular(getWidth(4)),
                ),
                child: Text(
                  grade,
                  style: TextStyle(
                    fontSize: getWidth(12),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: getHeight(8)),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(getWidth(2)),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.grey.withOpacity(0.2),
              color: _getColorForPercentage(percentage),
              minHeight: getHeight(4),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.blue;
    } else if (percentage >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildEmptyReportState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: getWidth(64),
            color: AppColors.grey.withOpacity(0.5),
          ),
          SizedBox(height: getHeight(16)),
          Text(
            "No Data Available",
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
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: getWidth(14),
                color: AppColors.textColor.withOpacity(0.7),
              ),
            ),
          ),
          SizedBox(height: getHeight(24)),
          materialButtonOnlyText(
            text: "Refresh",
            onTap: () {
              if (_tabController.index == 0) {
                loadSchoolExamReport();
              } else {
                loadVadTestReport();
              }
            },
          ),
        ],
      ),
    );
  }
}
