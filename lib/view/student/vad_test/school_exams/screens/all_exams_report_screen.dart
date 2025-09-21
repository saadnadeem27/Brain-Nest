import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/vad_test_controller.dart';
import 'package:Vadai/model/students/school_all_exams_reports.dart';
import 'package:Vadai/view/student/vad_test/widgets/vadTest_common.dart';
import 'package:fl_chart/fl_chart.dart';

class AllExamsReportScreen extends StatefulWidget {
  const AllExamsReportScreen({Key? key}) : super(key: key);

  @override
  State<AllExamsReportScreen> createState() => _AllExamsReportScreenState();
}

class _AllExamsReportScreenState extends State<AllExamsReportScreen>
    with SingleTickerProviderStateMixin {
  final VadTestController controller = Get.find();
  final RxBool isLoading = true.obs;
  final Rx<ExamScoreReportResponse?> examReport = Rx<ExamScoreReportResponse?>(
    null,
  );
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    isLoading.value = true;
    try {
      final report = await controller.getExamScoreReportWithInfo();
      if (report != null) {
        examReport.value = report;
        // Initialize tab controller after getting data
        _tabController = TabController(
          length: report.reports?.length ?? 0,
          vsync: this,
        );
      }
    } catch (e) {
      log('Error loading exam reports: $e');
      commonSnackBar(message: 'Failed to load exam reports');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshData() async {
    await _loadReport();
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        title: 'All Exams Report',
        isBack: true,
      ),
      body: Obx(
        () =>
            isLoading.value
                ? Center(child: commonLoader())
                : RefreshIndicator(
                  onRefresh: _refreshData,
                  child:
                      examReport.value == null ||
                              (examReport.value?.reports?.isEmpty ?? true)
                          ? _buildEmptyState()
                          : _buildReportView(),
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
            Icons.assignment_late_outlined,
            size: getWidth(60),
            color: AppColors.grey.withOpacity(0.5),
          ),
          SizedBox(height: getHeight(16)),
          Text(
            "No exam reports available",
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

  Widget _buildReportView() {
    final report = examReport.value!;

    return Column(
      children: [
        // Student Info Card
        _buildStudentInfoCard(report),

        // Tab Bar for exams
        if (_tabController != null && (report.reports?.length ?? 0) > 0)
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: getWidth(16),
              vertical: getHeight(16),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.blueColor,
              unselectedLabelColor: AppColors.textColor.withOpacity(0.7),
              indicatorColor: AppColors.blueColor,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: TextStyle(
                fontSize: getWidth(14),
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: getWidth(14),
                fontWeight: FontWeight.w500,
              ),
              isScrollable: true,
              tabs:
                  report.reports!.map((examReport) {
                    return Tab(text: examReport.title ?? 'Exam');
                  }).toList(),
            ),
          ),

        // Tab Views
        if (_tabController != null && (report.reports?.length ?? 0) > 0)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children:
                  report.reports!.map((examReport) {
                    return _buildExamReportTab(examReport, report.reports!);
                  }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildExamReportTab(
    SchoolAllExamsReports examReport,
    List<SchoolAllExamsReports> allReports,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(getWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exam summary
          _buildExamSummary(examReport),

          // Subject scores
          _buildSubjectScores(examReport),

          // Performance chart
          _buildExamPerformanceChart(examReport),

          // Performance comparison if there are multiple exams
          if (allReports.length > 1) _buildPerformanceComparison(allReports),

          // Add extra space at the bottom for better scrolling
          SizedBox(height: getHeight(40)),
        ],
      ),
    );
  }

  Widget _buildStudentInfoCard(ExamScoreReportResponse report) {
    return Container(
      margin: EdgeInsets.fromLTRB(getWidth(16), getHeight(16), getWidth(16), 0),
      padding: EdgeInsets.all(getWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Student Icon
          Container(
            width: getWidth(60),
            height: getWidth(60),
            decoration: BoxDecoration(
              color: AppColors.blueColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: AppColors.blueColor,
              size: getWidth(36),
            ),
          ),
          SizedBox(width: getWidth(16)),

          // Student Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.studentName ?? 'Student',
                  style: TextStyle(
                    fontSize: getWidth(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: getHeight(4)),
                Row(
                  children: [
                    Icon(
                      Icons.class_,
                      size: getWidth(14),
                      color: AppColors.textColor.withOpacity(0.7),
                    ),
                    SizedBox(width: getWidth(4)),
                    Text(
                      "Class ${report.className ?? ''}-${report.section ?? ''}",
                      style: TextStyle(
                        fontSize: getWidth(14),
                        color: AppColors.textColor.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(width: getWidth(16)),
                    Icon(
                      Icons.calendar_today,
                      size: getWidth(14),
                      color: AppColors.textColor.withOpacity(0.7),
                    ),
                    SizedBox(width: getWidth(4)),
                    Text(
                      report.year ?? '',
                      style: TextStyle(
                        fontSize: getWidth(14),
                        color: AppColors.textColor.withOpacity(0.7),
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

  Widget _buildExamSummary(SchoolAllExamsReports examReport) {
    final percentage = double.tryParse(examReport.percentage ?? '0') ?? 0;
    final Color resultColor =
        percentage >= 70
            ? Colors.green
            : percentage >= 50
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: EdgeInsets.all(getWidth(16)),
      margin: EdgeInsets.only(bottom: getHeight(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            examReport.title ?? 'Exam Results',
            style: TextStyle(
              fontSize: getWidth(18),
              fontWeight: FontWeight.bold,
              color: AppColors.blueColor,
            ),
          ),
          SizedBox(height: getHeight(16)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Percentage circle
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
                        "${examReport.percentage}%",
                        style: TextStyle(
                          fontSize: getWidth(22),
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                      Text(
                        _getGradeFromPercentage(percentage),
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

              // Exam stats
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatItem(
                    icon: Icons.bar_chart,
                    label: 'Total Marks',
                    value: '${examReport.total}',
                  ),
                  SizedBox(height: getHeight(8)),
                  _buildStatItem(
                    icon: Icons.emoji_events,
                    label: 'Rank',
                    value: '${examReport.rank}',
                  ),
                  SizedBox(height: getHeight(8)),
                  _buildStatItem(
                    icon: Icons.subject,
                    label: 'Subjects',
                    value: '${examReport.scores?.length ?? 0}',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: getWidth(18), color: AppColors.blueColor),
        SizedBox(width: getWidth(8)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: getWidth(12),
                color: AppColors.textColor.withOpacity(0.7),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: getWidth(16),
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubjectScores(SchoolAllExamsReports examReport) {
    return Container(
      padding: EdgeInsets.all(getWidth(16)),
      margin: EdgeInsets.only(bottom: getHeight(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject-wise Scores',
            style: TextStyle(
              fontSize: getWidth(16),
              fontWeight: FontWeight.bold,
              color: AppColors.blueColor,
            ),
          ),
          SizedBox(height: getHeight(12)),

          // Subject list
          ...examReport.scores!.map((subject) {
            final percentage = ((subject.score ?? 0) / 100) * 100;
            Color scoreColor;

            if (percentage >= 80) {
              scoreColor = Colors.green;
            } else if (percentage >= 60) {
              scoreColor = Colors.blue;
            } else if (percentage >= 40) {
              scoreColor = Colors.orange;
            } else {
              scoreColor = Colors.red;
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        subject.subjectName ?? 'Subject',
                        style: TextStyle(
                          fontSize: getWidth(14),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${subject.score} Marks',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: getWidth(14),
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: getHeight(8)),
                LinearProgressIndicator(
                  value: (subject.score ?? 0) / 100,
                  backgroundColor: AppColors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  minHeight: getHeight(6),
                  borderRadius: BorderRadius.circular(3),
                ),
                SizedBox(height: getHeight(12)),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExamPerformanceChart(SchoolAllExamsReports examReport) {
    if (examReport.scores == null || examReport.scores!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: getHeight(300),
      padding: EdgeInsets.all(getWidth(16)),
      margin: EdgeInsets.only(bottom: getHeight(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Chart',
            style: TextStyle(
              fontSize: getWidth(16),
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
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final subject = examReport.scores![groupIndex];
                      return BarTooltipItem(
                        '${subject.subjectName}\n${subject.score} Marks',
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
                        if (value >= 0 &&
                            value < (examReport.scores?.length ?? 0)) {
                          final subject = examReport.scores![value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _getShortSubjectName(subject.subjectName ?? ''),
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
                barGroups: _getBarGroups(examReport.scores!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups(List<Scores> scores) {
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < scores.length; i++) {
      final subject = scores[i];
      final score = subject.score ?? 0;

      Color barColor;
      if (score >= 80)
        barColor = Colors.green;
      else if (score >= 60)
        barColor = Colors.blue;
      else if (score >= 40)
        barColor = Colors.orange;
      else
        barColor = Colors.red;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: score.toDouble(),
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

  Widget _buildPerformanceComparison(List<SchoolAllExamsReports> reports) {
    return Container(
      height: getHeight(350),
      margin: EdgeInsets.all(getWidth(16)),
      padding: EdgeInsets.all(getWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Comparison',
            style: TextStyle(
              fontSize: getWidth(16),
              fontWeight: FontWeight.bold,
              color: AppColors.blueColor,
            ),
          ),
          Text(
            'Your percentage scores across different exams',
            style: TextStyle(
              fontSize: getWidth(12),
              color: AppColors.textColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: getHeight(16)),
          Expanded(
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final examTitle = reports[barSpot.x.toInt()].title;
                        return LineTooltipItem(
                          '$examTitle\n${barSpot.y.toStringAsFixed(1)}%',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                  horizontalInterval: 20,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 20 == 0) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: getWidth(10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 28,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                    left: BorderSide(
                      color: AppColors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                minX: 0,
                maxX: reports.length - 1.0,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: _getPercentageSpots(reports),
                    isCurved: true,
                    color: AppColors.blueColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: AppColors.blueColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.blueColor.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: getHeight(16)),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: getHeight(8),
              horizontal: getWidth(12),
            ),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    reports.asMap().entries.map((entry) {
                      final index = entry.key;
                      final report = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(right: getWidth(16)),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.blueColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              "${index + 1}. ${report.title ?? 'Exam'}",
                              style: TextStyle(
                                fontSize: getWidth(12),
                                color: AppColors.textColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getPercentageSpots(List<SchoolAllExamsReports> reports) {
    List<FlSpot> spots = [];

    for (int i = 0; i < reports.length; i++) {
      final report = reports[i];
      final percentage = double.tryParse(report.percentage ?? '0') ?? 0;
      spots.add(FlSpot(i.toDouble(), percentage));
    }

    return spots;
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
}
