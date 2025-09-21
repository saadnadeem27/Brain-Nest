import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/model/teachers/teacher_classes_data.dart';

class TeacherSubjectDetails extends StatefulWidget {
  const TeacherSubjectDetails({Key? key}) : super(key: key);

  @override
  State<TeacherSubjectDetails> createState() => _TeacherSubjectDetailsState();
}

class _TeacherSubjectDetailsState extends State<TeacherSubjectDetails> {
  String className = '';
  String sectionName = '';
  String subjectName = '';
  String classId = '';
  String sectionId = '';
  String subjectId = '';
  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
    });
  }

  initData() {
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
      }
    } catch (e) {
      log(
        '------------------>>>>>>>>>>>>>> error in initData of teacher subject details screen $e',
      );
    } finally {
      isLoading.value = false;
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
          title: subjectName,
          actions: [
            GestureDetector(
              onTap: () {
                // Navigate to people/students list
                Get.toNamed(
                  RouteNames.teacherPeoples,
                  arguments: {
                    'className': className,
                    'sectionName': sectionName,
                    'subjectName': subjectName,
                    'classId': classId,
                    'sectionId': sectionId,
                    'subjectId': subjectId,
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.textColor.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                width: getWidth(42),
                height: getHeight(42),
                child: Padding(
                  padding: EdgeInsets.all(getWidth(12)),
                  child: assetImage(
                    image: AppAssets.peopleIcon,
                    customWidth: getWidth(40),
                    customHeight: getHeight(40),
                  ),
                ),
              ),
            ).paddingOnly(right: getWidth(16)),
          ],
        ),
        body:
            isLoading.value
                ? Center(child: commonLoader())
                : commonPadding(
                  child: Column(
                    children: [
                      // Class and section info card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: getHeight(12),
                          horizontal: getWidth(16),
                        ),
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
                          border: Border.all(
                            color: AppColors.blueColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(getWidth(10)),
                              decoration: BoxDecoration(
                                color: AppColors.blueColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.school_rounded,
                                color: AppColors.blueColor,
                                size: getWidth(24),
                              ),
                            ),
                            SizedBox(width: getWidth(16)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Class $className",
                                  style: TextStyle(
                                    fontSize: getWidth(16),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                SizedBox(height: getHeight(4)),
                                Text(
                                  "Section $sectionName",
                                  style: TextStyle(
                                    fontSize: getWidth(14),
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textColor.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Added extra spacing to compensate for removed curriculum section
                      SizedBox(height: getHeight(24)),

                      // Main sections header
                      Padding(
                        padding: EdgeInsets.only(
                          left: getWidth(8),
                          bottom: getHeight(16),
                        ),
                        child: Text(
                          "Subject Management",
                          style: TextStyle(
                            fontSize: getWidth(18),
                            fontWeight: FontWeight.w600,
                            color: AppColors.blueColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      _buildSections(
                        title: AppStrings.announcements,
                        icon: Icons.campaign_rounded,
                        onTap: () {
                          Get.toNamed(
                            RouteNames.teacherAnnouncements,
                            arguments: {
                              'className': className,
                              'sectionName': sectionName,
                              'subjectName': subjectName,
                              'classId': classId,
                              'sectionId': sectionId,
                              'subjectId': subjectId,
                            },
                          );
                        },
                      ),
                      _buildSections(
                        title: AppStrings.assignments,
                        icon: Icons.assignment_rounded,
                        onTap: () {
                          Get.toNamed(
                            RouteNames.teacherAssignments,
                            arguments: {
                              'className': className,
                              'sectionName': sectionName,
                              'subjectName': subjectName,
                              'classId': classId,
                              'sectionId': sectionId,
                              'subjectId': subjectId,
                            },
                          );
                        },
                      ),
                      _buildSections(
                        title: AppStrings.resources,
                        icon: Icons.menu_book_rounded,
                        onTap: () {
                          Get.toNamed(
                            RouteNames.teacherResources,
                            arguments: {
                              'className': className,
                              'sectionName': sectionName,
                              'subjectName': subjectName,
                              'classId': classId,
                              'sectionId': sectionId,
                              'subjectId': subjectId,
                            },
                          );
                        },
                      ),
                      _buildSections(
                        title: "Performance",
                        icon: Icons.bar_chart_rounded,
                        onTap: () {
                          Get.toNamed(
                            RouteNames.teacherPerformance,
                            arguments: {
                              'className': className,
                              'sectionName': sectionName,
                              'subjectName': subjectName,
                              'classId': classId,
                              'sectionId': sectionId,
                              'subjectId': subjectId,
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildSections({
    required VoidCallback onTap,
    required String title,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: getHeight(80),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.black.withOpacity(0.2),
            width: getWidth(2),
          ),
          borderRadius: BorderRadius.circular(getWidth(16)),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(16),
          vertical: getHeight(8),
        ),
        margin: EdgeInsets.only(bottom: getHeight(16)),
        child: Row(
          children: [
            Container(
              width: getWidth(48),
              height: getWidth(48),
              decoration: BoxDecoration(
                color: AppColors.blueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(getWidth(12)),
              ),
              child: Icon(icon, color: AppColors.blueColor, size: getWidth(24)),
            ),
            SizedBox(width: getWidth(16)),
            Text(
              title,
              style: TextStyle(
                fontSize: getWidth(18),
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.blueColor.withOpacity(0.6),
              size: getWidth(16),
            ),
          ],
        ),
      ),
    );
  }
}
