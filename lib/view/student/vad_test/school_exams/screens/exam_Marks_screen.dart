import 'package:Vadai/controller/student/vad_test_controller.dart';
import 'package:Vadai/model/students/school_exam_marks.dart';
import 'package:Vadai/model/students/school_exam_model.dart';
import 'package:Vadai/view/student/vad_test/widgets/vadTest_common.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../common_imports.dart';

class ExamMarksScreen extends StatefulWidget {
  final String examId;
  final String examName;

  const ExamMarksScreen({
    Key? key,
    required this.examId,
    required this.examName,
  }) : super(key: key);

  @override
  State<ExamMarksScreen> createState() => _ExamMarksScreenState();
}

class _ExamMarksScreenState extends State<ExamMarksScreen> {
  final VadTestController controller = Get.find();
  final RxBool isLoading = true.obs;
  final RxList<SchoolExamMarks> subjectMarks = <SchoolExamMarks>[].obs;
  RxInt totalMarks = 0.obs;
  RxInt totalScored = 0.obs;
  RxDouble percentage = 0.0.obs;

  @override
  void initState() {
    super.initState();
    _loadMarks();
  }

  Future<void> _loadMarks() async {
    isLoading.value = true;
    try {
      final marks = await controller.getExamSubjectsWithMarks(widget.examId);
      if (marks != null) {
        subjectMarks.assignAll(marks);
        _calculateResults();
      }
    } catch (e) {
      log('Error loading exam marks: $e');
      commonSnackBar(message: 'Failed to load exam marks');
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateResults() {
    int total = 0;
    int scored = 0;

    for (var subject in subjectMarks) {
      total += subject.totalMark ?? 0;
      scored += subject.markScored ?? 0;
    }

    totalMarks.value = total;
    totalScored.value = scored;

    if (total > 0) {
      percentage.value = (scored / total) * 100;
    } else {
      percentage.value = 0;
    }
  }

  Future<void> _refreshData() async {
    await _loadMarks();
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        title: widget.examName,
        isBack: true,
      ),
      body: Obx(
        () =>
            isLoading.value
                ? Center(child: commonLoader())
                : RefreshIndicator(
                  onRefresh: _refreshData,
                  child:
                      subjectMarks.isEmpty
                          ? _buildEmptyState()
                          : _buildMarksList(),
                ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: getWidth(60),
            color: AppColors.grey.withOpacity(0.5),
          ),
          SizedBox(height: getHeight(16)),
          Text(
            "No marks available for this exam",
            style: TextStyle(
              fontSize: getWidth(16),
              color: AppColors.textColor.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: getHeight(16)),
          materialButtonWithChild(
            color: AppColors.blueColor,
            padding: EdgeInsets.symmetric(
              horizontal: getWidth(16),
              vertical: getHeight(8),
            ),
            borderRadius: 8,
            onPressed: _refreshData,
            child: Text(
              "Refresh",
              style: TextStyle(
                fontSize: getWidth(16),
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarksList() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(getWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results summary card
          _buildResultsSummary(),

          // Performance chart
          _buildPerformanceChart(),

          // Subjects list
          _buildSubjectsList(),
        ],
      ),
    );
  }

  Widget _buildResultsSummary() {
    final Color resultColor =
        percentage.value >= 70
            ? Colors.green
            : percentage.value >= 50
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: EdgeInsets.all(getWidth(16)),
      margin: EdgeInsets.only(bottom: getHeight(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getWidth(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Your Results",
            style: TextStyle(
              fontSize: getWidth(20),
              fontWeight: FontWeight.bold,
              color: AppColors.blueColor,
            ),
          ),
          SizedBox(height: getHeight(16)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Result circle
              Container(
                width: getWidth(100),
                height: getWidth(100),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: resultColor, width: 4),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${percentage.value.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: getWidth(20),
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                      Text(
                        _getGradeFromPercentage(percentage.value),
                        style: TextStyle(
                          fontSize: getWidth(16),
                          fontWeight: FontWeight.w500,
                          color: resultColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Marks details
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildCategoryText(
                    title: 'Total Marks',
                    content: '${totalScored.value} / ${totalMarks.value}',
                    titleSize: 14,
                    contentSize: 16,
                    contentColor: AppColors.textColor,
                  ),
                  SizedBox(height: getHeight(10)),
                  buildCategoryText(
                    title: 'Subjects Count',
                    content: '${subjectMarks.length}',
                    titleSize: 14,
                    contentSize: 16,
                    contentColor: AppColors.textColor,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    if (subjectMarks.isEmpty) return const SizedBox.shrink();

    return Container(
      height: getHeight(270),
      padding: EdgeInsets.all(getWidth(16)),
      margin: EdgeInsets.only(bottom: getHeight(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getWidth(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Subject Performance",
            style: TextStyle(
              fontSize: getWidth(18),
              fontWeight: FontWeight.bold,
              color: AppColors.blueColor,
            ),
          ),
          SizedBox(height: getHeight(16)),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    // getTooltipColor: (group, groupIndex, rod, rodIndex) => Colors.grey.shade800,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final subject = subjectMarks[groupIndex];
                      final percentage =
                          (subject.markScored ?? 0) /
                          (subject.totalMark ?? 1) *
                          100;
                      return BarTooltipItem(
                        '${subject.subject}\n${percentage.toStringAsFixed(1)}%',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
                        if (value >= 0 && value < subjectMarks.length) {
                          final subject = subjectMarks[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _getShortSubjectName(subject.subject ?? ''),
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: getWidth(10),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 20 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: getWidth(10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                  horizontalInterval: 20,
                ),
                barGroups: _getBarGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < subjectMarks.length; i++) {
      final subject = subjectMarks[i];
      final totalMark = subject.totalMark ?? 1;
      final markScored = subject.markScored ?? 0;
      final percentage = (markScored / totalMark) * 100;

      Color barColor;
      if (percentage >= 80)
        barColor = Colors.green;
      else if (percentage >= 60)
        barColor = Colors.blue;
      else if (percentage >= 40)
        barColor = Colors.orange;
      else
        barColor = Colors.red;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: percentage,
              color: barColor,
              width: getWidth(20),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    return barGroups;
  }

  String _getShortSubjectName(String subject) {
    if (subject.length <= 6) return subject;

    final words = subject.split(' ');
    if (words.length > 1) {
      // Return initials
      return words
          .map((word) => word.isNotEmpty ? word[0] : '')
          .join('')
          .toUpperCase();
    } else {
      // Return first 6 characters
      return subject.substring(0, 6);
    }
  }

  String _getGradeFromPercentage(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C+';
    if (percentage >= 40) return 'C';
    if (percentage >= 33) return 'D';
    return 'F';
  }

  Widget _buildSubjectsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Subject-wise Marks",
          style: TextStyle(
            fontSize: getWidth(18),
            fontWeight: FontWeight.bold,
            color: AppColors.blueColor,
          ),
        ),
        SizedBox(height: getHeight(16)),

        // Subjects list
        ...subjectMarks.map((subject) => _buildSubjectCard(subject)),
      ],
    );
  }

  Widget _buildSubjectCard(SchoolExamMarks subject) {
    final percentage =
        (subject.markScored ?? 0) / (subject.totalMark ?? 1) * 100;

    Color statusColor;
    String statusText;

    if (percentage >= 80) {
      statusColor = Colors.green;
      statusText = "Excellent";
    } else if (percentage >= 60) {
      statusColor = Colors.blue;
      statusText = "Good";
    } else if (percentage >= 40) {
      statusColor = Colors.orange;
      statusText = "Average";
    } else {
      statusColor = Colors.red;
      statusText = "Needs Improvement";
    }

    return Container(
      margin: EdgeInsets.only(bottom: getHeight(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getWidth(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: getWidth(16),
              vertical: getHeight(12),
            ),
            decoration: BoxDecoration(
              color: AppColors.blueColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(getWidth(12)),
                topRight: Radius.circular(getWidth(12)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subject.subject ?? 'Unknown Subject',
                    style: TextStyle(
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.blueColor,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: getWidth(10),
                    vertical: getHeight(4),
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(getWidth(12)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: getWidth(12),
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Subject details
          Padding(
            padding: EdgeInsets.all(getWidth(16)),
            child: Column(
              children: [
                // Marks
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marks Obtained',
                          style: TextStyle(
                            fontSize: getWidth(14),
                            color: AppColors.textColor.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: getHeight(4)),
                        Text(
                          '${subject.markScored ?? 0} / ${subject.totalMark ?? 0}',
                          style: TextStyle(
                            fontSize: getWidth(18),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Percentage',
                          style: TextStyle(
                            fontSize: getWidth(14),
                            color: AppColors.textColor.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: getHeight(4)),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: getWidth(18),
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Progress bar
                SizedBox(height: getHeight(16)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(getWidth(8)),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: getHeight(8),
                    backgroundColor: AppColors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),

                // Chapters and details
                if (subject.chaptersAndDetails?.isNotEmpty ?? false)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: getHeight(16)),
                      Text(
                        'Topics Covered:',
                        style: TextStyle(
                          fontSize: getWidth(14),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: getHeight(4)),
                      Container(
                        padding: EdgeInsets.all(getWidth(12)),
                        decoration: BoxDecoration(
                          color: AppColors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(getWidth(8)),
                        ),
                        child: Text(
                          subject.chaptersAndDetails ?? '',
                          style: TextStyle(
                            fontSize: getWidth(14),
                            color: AppColors.textColor,
                          ),
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
}
