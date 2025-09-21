import 'package:Vadai/controller/student/vad_test_controller.dart';
import 'package:Vadai/model/students/school_exam_model.dart';
import 'package:Vadai/view/student/vad_test/school_exams/screens/all_exams_report_screen.dart';
import 'package:Vadai/view/student/vad_test/school_exams/screens/exam_Marks_screen.dart';
import 'package:Vadai/view/student/vad_test/widgets/vadTest_common.dart';
import '../../../../../common_imports.dart';

class SchoolExamsScreen extends StatefulWidget {
  const SchoolExamsScreen({Key? key}) : super(key: key);

  @override
  State<SchoolExamsScreen> createState() => _SchoolExamsScreenState();
}

class _SchoolExamsScreenState extends State<SchoolExamsScreen> {
  final VadTestController controller = Get.find();
  final RxBool isLoading = true.obs;
  final RxList<SchoolExamModel> schoolExams = <SchoolExamModel>[].obs;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    isLoading.value = true;
    try {
      final exams = await controller.getSchoolExams();
      if (exams != null) {
        schoolExams.assignAll(exams);
      }
    } catch (e) {
      log('Error loading school exams: $e');
      commonSnackBar(message: 'Failed to load school exams');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshData() async {
    await _loadExams();
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        title: 'School Exams',
        isBack: true,
      ),
      body: Obx(
        () =>
            isLoading.value
                ? Center(child: commonLoader())
                : RefreshIndicator(
                  onRefresh: _refreshData,
                  child:
                      schoolExams.isEmpty
                          ? _buildEmptyState()
                          : _buildExamsList(),
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
            "No school exams available",
            style: TextStyle(
              fontSize: getWidth(16),
              color: AppColors.textColor.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamsList() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: getHeight(20)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.blueColor.withOpacity(0.8),
                AppColors.blueColor,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.blueColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background design elements
              Positioned(
                right: -20,
                top: -20,
                child: CircleAvatar(
                  radius: getWidth(60),
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: CircleAvatar(
                  radius: getWidth(50),
                  backgroundColor: Colors.white.withOpacity(0.05),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(getWidth(20)),
                child: Row(
                  children: [
                    // Left side - report card icon and decorative elements
                    Container(
                      width: getWidth(80),
                      height: getWidth(80),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assessment_rounded,
                            color: AppColors.blueColor,
                            size: getWidth(40),
                          ),
                          SizedBox(height: getHeight(4)),
                          Text(
                            "Report",
                            style: TextStyle(
                              fontSize: getWidth(12),
                              fontWeight: FontWeight.bold,
                              color: AppColors.blueColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: getWidth(16)),

                    // Right side - text and button
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Performance Report Card",
                            style: TextStyle(
                              fontSize: getWidth(18),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: getHeight(8)),
                          Text(
                            "View your complete academic performance across all exams and subjects",
                            style: TextStyle(
                              fontSize: getWidth(14),
                              color: Colors.white.withOpacity(0.9),
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: getHeight(16)),

                          // View Report Button
                          InkWell(
                            onTap: () {
                              Get.to(() => const AllExamsReportScreen());
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: getWidth(16),
                                vertical: getHeight(10),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bar_chart_rounded,
                                    color: AppColors.blueColor,
                                    size: getWidth(18),
                                  ),
                                  SizedBox(width: getWidth(8)),
                                  Text(
                                    'View Analysis',
                                    style: TextStyle(
                                      fontSize: getWidth(14),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.blueColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: schoolExams.length,
            itemBuilder: (context, index) {
              final exam = schoolExams[index];
              return _buildExamCard(exam);
            },
          ),
        ),
      ],
    ).paddingOnly(left: getWidth(16), right: getWidth(16), top: getHeight(16));
  }

  Widget _buildExamCard(SchoolExamModel exam) {
    return Container(
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
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: getWidth(16),
              vertical: getHeight(12),
            ),
            decoration: BoxDecoration(
              color: AppColors.blueColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(getWidth(12)),
                topRight: Radius.circular(getWidth(12)),
              ),
            ),
            child: Text(
              exam.name ?? 'Unknown Exam',
              style: TextStyle(
                fontSize: getWidth(18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(getWidth(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exam info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildCategoryText(
                            title: 'Start Date',
                            content: formatDate(exam.startDate),
                            titleSize: 14,
                            contentSize: 14,
                          ),
                          SizedBox(height: getHeight(8)),
                          buildCategoryText(
                            title: 'Message',
                            content: exam.message ?? '',
                            titleSize: 14,
                            contentSize: 14,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => _showClassesDialog(exam.classes),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidth(10),
                              vertical: getHeight(5),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(getWidth(5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.class_outlined,
                                  size: getWidth(16),
                                  color: AppColors.blueColor,
                                ),
                                SizedBox(width: getWidth(5)),
                                Text(
                                  'Classes',
                                  style: TextStyle(
                                    fontSize: getWidth(14),
                                    color: AppColors.blueColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: getHeight(8)),
                        GestureDetector(
                          onTap: () => _showSubjectsDialog(exam.subjects),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidth(10),
                              vertical: getHeight(5),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(getWidth(5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.subject,
                                  size: getWidth(16),
                                  color: AppColors.blueColor,
                                ),
                                SizedBox(width: getWidth(5)),
                                Text(
                                  'Subjects',
                                  style: TextStyle(
                                    fontSize: getWidth(14),
                                    color: AppColors.blueColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: getHeight(16)),

                // Action buttons
                Center(
                  child: materialButtonWithChild(
                    color: AppColors.blueColor,
                    borderRadius: 8,
                    padding: EdgeInsets.symmetric(
                      horizontal: getWidth(20),
                      vertical: getHeight(10),
                    ),
                    onPressed: () {
                      Get.to(
                        () => ExamMarksScreen(
                          examId: exam.sId ?? '',
                          examName: exam.name ?? 'Exam Details',
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          color: Colors.white,
                          size: getWidth(18),
                        ),
                        SizedBox(width: getWidth(8)),
                        Text(
                          'View Marks',
                          style: TextStyle(
                            fontSize: getWidth(16),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClassesDialog(List<String>? classes) {
    if (classes == null || classes.isEmpty) {
      commonSnackBar(message: 'No classes available for this exam');
      return;
    }

    showDialog(
      context: context,
      builder:
          (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(20),
                vertical: getHeight(20),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Classes',
                        style: TextStyle(
                          fontSize: getWidth(18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Icon(
                          Icons.close,
                          color: AppColors.red,
                          size: getWidth(20),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: getHeight(15)),
                  Container(
                    padding: EdgeInsets.all(getWidth(10)),
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(getWidth(8)),
                    ),
                    child: Wrap(
                      spacing: getWidth(10),
                      runSpacing: getHeight(8),
                      alignment: WrapAlignment.center,
                      children:
                          classes.map((classItem) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: getWidth(15),
                                vertical: getHeight(8),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blueColor,
                                borderRadius: BorderRadius.circular(
                                  getWidth(20),
                                ),
                              ),
                              child: Text(
                                'Class $classItem',
                                style: TextStyle(
                                  fontSize: getWidth(14),
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  SizedBox(height: getHeight(15)),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: getWidth(16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.blueColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showSubjectsDialog(List<Subjects>? subjects) {
    if (subjects == null || subjects.isEmpty) {
      commonSnackBar(message: 'No subjects available for this exam');
      return;
    }

    showDialog(
      context: context,
      builder:
          (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(20),
                vertical: getHeight(20),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Exam Subjects',
                        style: TextStyle(
                          fontSize: getWidth(18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Icon(
                          Icons.close,
                          color: AppColors.red,
                          size: getWidth(20),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: getHeight(15)),
                  Container(
                    constraints: BoxConstraints(maxHeight: Get.height * 0.5),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjects[index];

                        return Container(
                          margin: EdgeInsets.only(bottom: getHeight(10)),
                          decoration: BoxDecoration(
                            color: AppColors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(getWidth(8)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(getWidth(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        subject.subject ?? 'Unknown Subject',
                                        style: TextStyle(
                                          fontSize: getWidth(16),
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.blueColor,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: getWidth(12),
                                        vertical: getHeight(6),
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.blueColor,
                                        borderRadius: BorderRadius.circular(
                                          getWidth(20),
                                        ),
                                      ),
                                      child: Text(
                                        'Marks: ${subject.totalMark ?? 0}',
                                        style: TextStyle(
                                          fontSize: getWidth(14),
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (subject.chaptersAndDetails != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: getHeight(8)),
                                      Text(
                                        'Chapters & Details:',
                                        style: TextStyle(
                                          fontSize: getWidth(14),
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                      SizedBox(height: getHeight(4)),
                                      Container(
                                        padding: EdgeInsets.all(getWidth(8)),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            getWidth(6),
                                          ),
                                        ),
                                        child: Text(
                                          subject.chaptersAndDetails!,
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
                        );
                      },
                    ),
                  ),
                  SizedBox(height: getHeight(15)),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: getWidth(16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.blueColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
