import 'dart:math' as Math;

import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_vadtest_controller.dart';
import 'package:Vadai/model/teachers/teacher_vadtest_subject_model.dart';
import 'package:Vadai/view/student/vad_test/widgets/vadTest_common.dart';
import 'package:Vadai/view/student/vad_test/widgets/vadtest_subject_container.dart';
import 'package:Vadai/view/teachers/vad_test/screens/teacher_school_exams_screen.dart';
import 'package:Vadai/view/teachers/vad_test/screens/teacher_vadTest_details_screen.dart';

class TeacherVadTest extends StatefulWidget {
  const TeacherVadTest({Key? key}) : super(key: key);

  @override
  State<TeacherVadTest> createState() => _TeacherVadTestState();
}

class _TeacherVadTestState extends State<TeacherVadTest>
    with SingleTickerProviderStateMixin {
  final TeacherVadTestController vadTestCtr = Get.find();

  // Animation controllers
  late AnimationController _animationController;
  late Animation<Offset> _headerAnimation;

  // Track if animations have been played
  final RxBool _animationsInitialized = false.obs;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _headerAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.0,
          0.5,
          curve: Curves.easeOutCubic,
        ), // Adjusted interval
      ),
    );
    ever(vadTestCtr.isLoading, (isLoading) {
      if (!isLoading && !_animationsInitialized.value && mounted) {
        _initializeAnimations();
      }
    });

    // Handle case where data is already loaded
    if (!vadTestCtr.isLoading.value && !_animationsInitialized.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeAnimations();
      });
    }
  }

  void _initializeAnimations() {
    _animationsInitialized.value = true;
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> refreshData() async {
    vadTestCtr.isLoading.value = true;
    try {
      await vadTestCtr.getVadTestSubjects();
    } catch (e) {
      log('Error refreshing VAD test data: $e');
    } finally {
      vadTestCtr.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: commonScaffold(
        context: context,
        body: Stack(
          children: [
            Positioned(
              top: getHeight(130),
              bottom: getHeight(30),
              right: getWidth(-130),
              child: Image.asset(
                AppAssets.tabBackGround,
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.6),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: getHeight(70)),
              child: Obx(
                () =>
                    vadTestCtr.isLoading.value
                        ? Center(child: commonLoader())
                        : RefreshIndicator(
                          onRefresh: refreshData,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: commonPadding(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: getHeight(25),
                                      bottom: getHeight(20),
                                    ),
                                    child: SlideTransition(
                                      position: _headerAnimation,
                                      child: _buildHeader(),
                                    ),
                                  ),
                                  _buildSubjectList(),
                                  SizedBox(height: getHeight(16)),
                                ],
                              ),
                            ),
                          ),
                        ),
              ),
            ),
            teachersTabAppBar(title: "VAD Test"),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Get.to(() => const TeacherSchoolExamsScreen()),
          child: Container(
            width: getWidth(77),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(getWidth(9)),
              color: AppColors.colorD9D9D9,
              border: Border.all(color: AppColors.black, width: getWidth(1)),
            ),
            child: commonPadding(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(10),
                vertical: getHeight(4),
              ),
              child: textWid(
                "School Exam",
                textAlign: TextAlign.center,
                maxlines: 5,
                style: AppTextStyles.textStyle(
                  fontSize: getWidth(12),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        Column(
          children: [
            textWid(
              "VAD Test",
              style: AppTextStyles.textStyle(
                fontSize: getWidth(25),
                fontWeight: FontWeight.w700,
                txtColor: AppColors.black,
              ),
            ),
            assetImage(image: AppAssets.subjectDivider, customWidth: 130),
          ],
        ),
        GestureDetector(
          onTap: () => VadTestRules(),
          child: Container(
            padding: EdgeInsets.all(getWidth(4)),
            decoration: const BoxDecoration(
              color: AppColors.blueColor,
              shape: BoxShape.circle,
            ),
            child: assetImage(
              image: AppAssets.compendiaInfo,
              fit: BoxFit.contain,
              customWidth: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectList() {
    if (vadTestCtr.vadTestSubjectList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: getHeight(80)),
            Icon(
              Icons.assignment_outlined,
              size: getWidth(60),
              color: AppColors.grey.withOpacity(0.5),
            ),
            SizedBox(height: getHeight(16)),
            Text(
              "No VAD tests available",
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

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: vadTestCtr.vadTestSubjectList.length,
      itemBuilder: (context, index) {
        final classData = vadTestCtr.vadTestSubjectList[index];

        // First build heading for class
        if (classData.tests == null || classData.tests!.isEmpty) {
          return const SizedBox.shrink();
        }

        // Animation for class heading
        final headingAnimation = Tween<Offset>(
          begin: const Offset(2.0, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              0.1 + (index * 0.1).clamp(0.0, 0.5),
              0.4 + (index * 0.1).clamp(0.0, 0.5),
              curve: Curves.easeOutQuart,
            ),
          ),
        );

        return SlideTransition(
          position: headingAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class heading
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(12),
                  vertical: getHeight(6),
                ),
                margin: EdgeInsets.only(
                  bottom: getHeight(8),
                  top: index > 0 ? getHeight(16) : 0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(getWidth(8)),
                  border: Border.all(
                    color: AppColors.blueColor.withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Class ${classData.className ?? 'Unknown'}",
                    style: TextStyle(
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueColor,
                    ),
                  ),
                ),
              ),

              // Tests for this class
              ...classData.tests!.asMap().entries.map((entry) {
                final testIndex = entry.key;
                final test = entry.value;

                // Alternating animations from left and right
                final isEven = testIndex % 2 == 0;

                // Calculate safe start and end values for the interval
                final double startValue =
                    0.1 + Math.min(0.1, (index * 0.05) + (testIndex * 0.03));
                final double endValue =
                    0.7 + Math.min(0.25, (index * 0.05) + (testIndex * 0.03));

                final testAnimation = Tween<Offset>(
                  begin: Offset(isEven ? 1.5 : -1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      startValue,
                      endValue,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                );

                return SlideTransition(
                  position: testAnimation,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: getHeight(16)),
                    child: VADTestSubjectContainer(
                      subjectName: test.subject ?? "Unknown Subject",
                      date: test.getFormattedDate(),
                      subjectIntro: test.icon ?? "",
                      isNetwork: true,
                      continueText: "View Details",
                      onContinue: () {
                        _navigateToTestDetails(test);
                      },
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _navigateToTestDetails(VadTestSubject test) {
    if (test.id == null || test.id!.isEmpty) {
      commonSnackBar(message: "Test ID not available");
      return;
    }
    Get.to(() => TeacherVadTestDetailsScreen(vadTestId: test.id!));
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return "No date";
    }
    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }
}
