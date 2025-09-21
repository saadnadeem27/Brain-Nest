import 'package:Vadai/controller/student/vad_test_controller.dart';
import 'package:Vadai/view/student/vad_test/school_exams/screens/school_exams_screen.dart';
import 'package:Vadai/view/student/vad_test/screens/vad_test_list_screen.dart';
import 'package:Vadai/view/student/vad_test/widgets/vadTest_common.dart';
import 'package:Vadai/view/student/vad_test/widgets/vadtest_subject_container.dart';
import '../../../../common_imports.dart';

class VadTest extends StatefulWidget {
  const VadTest({super.key});

  @override
  State<VadTest> createState() => _VadTestState();
}

class _VadTestState extends State<VadTest> {
  VadTestController vadTestCtr = Get.find();

  @override
  void initState() {
    super.initState();
  }

  Future<void> refreshData() async {
    vadTestCtr.isLoading.value = true;
    try {
      await vadTestCtr.getSubjectList();
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
                                    child: _buildHeader(),
                                  ),
                                  vadTestCtr.vadTestSubjects.isEmpty
                                      ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(height: getHeight(80)),
                                            Icon(
                                              Icons.assignment_outlined,
                                              size: getWidth(60),
                                              color: AppColors.grey.withOpacity(
                                                0.5,
                                              ),
                                            ),
                                            SizedBox(height: getHeight(16)),
                                            Text(
                                              "No VAD tests available",
                                              style: TextStyle(
                                                fontSize: getWidth(16),
                                                color: AppColors.textColor
                                                    .withOpacity(0.7),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      : ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount:
                                            vadTestCtr.vadTestSubjects.length,
                                        itemBuilder: (context, index) {
                                          final subject =
                                              vadTestCtr.vadTestSubjects[index];
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom: getHeight(16),
                                            ),
                                            child: VADTestSubjectContainer(
                                              subjectName:
                                                  subject.subject ??
                                                  "Unknown Subject",
                                              date:
                                                  subject.latestTestDate != null
                                                      ? _formatDate(
                                                        subject.latestTestDate,
                                                      )
                                                      : "Available",
                                              subjectIntro: subject.icon ?? "",
                                              isNetwork: true,
                                              onContinue: () {
                                                Get.to(
                                                  () => VadTestListScreen(
                                                    subjectId:
                                                        subject.subjectId ?? "",
                                                    subjectName:
                                                        subject.subject ??
                                                        "Unknown Subject",
                                                    subjectIcon: subject.icon,
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                ],
                              ),
                            ),
                          ),
                        ),
              ),
            ),
            studentsTabAppBar(title: AppStrings.vadTest),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return "";
    }
    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Get.to(() => const SchoolExamsScreen()),
          child: Container(
            width: getWidth(77),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(getWidth(9)),
              color: AppColors.colorD9D9D9,
              border: Border.all(color: AppColors.black, width: getWidth(1)),
            ),
            child: commonPadding(
              padding: EdgeInsets.only(
                left: getWidth(10),
                right: getWidth(10),
                top: getHeight(4),
                bottom: getHeight(4),
              ),
              child: textWid(
                AppStrings.schoolExam,
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
              AppStrings.vadTest,
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
}
