import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/controller/teachers/teacher_profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ClassTeacherScreen extends StatefulWidget {
  const ClassTeacherScreen({Key? key}) : super(key: key);

  @override
  State<ClassTeacherScreen> createState() => _ClassTeacherScreenState();
}

class _ClassTeacherScreenState extends State<ClassTeacherScreen> {
  String teacherName = '';
  RxBool isLoading = false.obs;
  TeacherClassroomController controller =
      Get.find<TeacherClassroomController>();
  TeacherProfileController profileController =
      Get.find<TeacherProfileController>();

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
      // If profile isn't loaded yet, load it
      if (profileController.teacherProfile.value == null) {
        profileController.getTeacherProfile();
      }
    } catch (e) {
      log('Error in initData of class teacher screen: $e');
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
          title: "Teacher Dashboard",
          actions: [
            GestureDetector(
              onTap: () {
                Get.toNamed(RouteNames.teacherPeoples);
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Teacher welcome card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: getHeight(16),
                          horizontal: getWidth(20),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.blueColor.withOpacity(0.2),
                              AppColors.blueColor.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(getWidth(16)),
                          border: Border.all(
                            color: AppColors.blueColor.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Profile image or icon
                                _buildProfileImage(),
                                SizedBox(width: getWidth(16)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Welcome,",
                                      style: TextStyle(
                                        fontSize: getWidth(15),
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textColor.withOpacity(
                                          0.8,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: getHeight(4)),
                                    Text(
                                      _getTeacherName(),
                                      style: TextStyle(
                                        fontSize: getWidth(18),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: getHeight(12)),
                            // Class and section info
                            _buildClassSectionInfo(),
                          ],
                        ),
                      ),

                      SizedBox(height: getHeight(24)),

                      // Main sections header
                      Padding(
                        padding: EdgeInsets.only(
                          left: getWidth(8),
                          bottom: getHeight(16),
                        ),
                        child: Text(
                          "Classroom Management",
                          style: TextStyle(
                            fontSize: getWidth(18),
                            fontWeight: FontWeight.w600,
                            color: AppColors.blueColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      // Main feature sections
                      _buildSections(
                        title: "Attendance",
                        icon: Icons.checklist_rounded,
                        onTap: () {
                          Get.toNamed(
                            RouteNames.teacherAttendance,
                            arguments: {'teacherName': teacherName},
                          );
                        },
                      ),
                      _buildSections(
                        title: "Announcements",
                        icon: Icons.campaign_rounded,
                        onTap: () {
                          Get.toNamed(
                            RouteNames.teacherClassroomAnnouncements,
                            arguments: {'teacherName': teacherName},
                          );
                        },
                      ),
                      _buildSections(
                        title: "Remarks",
                        icon: Icons.comment_rounded,
                        onTap: () {
                          Get.toNamed(
                            RouteNames.teacherRemarks,
                            arguments: {'teacherName': teacherName},
                          );
                        },
                      ),

                      _buildSections(
                        title: "Performance",
                        icon: Icons.bar_chart_rounded,
                        onTap: () {
                          // Get the class teacher's assigned class and section
                          final teacher =
                              profileController.teacherProfile.value;
                          if (teacher != null &&
                              teacher.className != null &&
                              teacher.className!.isNotEmpty &&
                              teacher.section != null &&
                              teacher.section!.isNotEmpty) {
                            Get.toNamed(
                              RouteNames.teacherPerformance,
                              arguments: {
                                'className': teacher.className,
                                'sectionName': teacher.section,
                                // We're showing all subjects for the class teacher's view
                                'subjectName': 'All Subjects',
                                // 'classId': teacher.classId ?? '',
                                // 'sectionId': teacher.sectionId ?? '',
                                // 'subjectId':
                                //     '', // Empty as we want to show all subjects
                                'isClassTeacher': true,
                              },
                            );
                          } else {
                            // If no class/section is assigned
                            commonSnackBar(
                              message:
                                  "You don't have a class assigned. Please contact admin.",
                              color: Colors.red,
                            );
                          }
                        },
                      ),
                      _buildSections(
                        title: "Resources",
                        icon: Icons.menu_book_rounded,
                        onTap: () {
                          Get.toNamed(
                            RouteNames.teacherClassroomResources,
                            arguments: {'teacherName': teacherName},
                          );
                        },
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildProfileImage() {
    final profileImage = profileController.teacherProfile.value?.profileImage;

    if (profileImage != null && profileImage.isNotEmpty) {
      return Container(
        width: getWidth(56),
        height: getWidth(56),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.blueColor.withOpacity(0.5),
            width: getWidth(2),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(getWidth(28)),
          child: CachedNetworkImage(
            imageUrl: profileImage,
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
        ),
      );
    } else {
      // Fallback to icon if no image
      return Container(
        width: getWidth(56),
        height: getWidth(56),
        decoration: BoxDecoration(
          color: AppColors.blueColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person_rounded,
          color: AppColors.blueColor,
          size: getWidth(28),
        ),
      );
    }
  }

  String _getTeacherName() {
    final name = profileController.teacherProfile.value?.name;
    return (name != null && name.isNotEmpty) ? name : "Teacher";
  }

  Widget _buildClassSectionInfo() {
    final teacher = profileController.teacherProfile.value;
    final hasClassSectionInfo =
        teacher != null &&
        teacher.className != null &&
        teacher.className!.isNotEmpty &&
        teacher.section != null &&
        teacher.section!.isNotEmpty;

    if (hasClassSectionInfo) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(12),
          vertical: getHeight(8),
        ),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(getWidth(8)),
          border: Border.all(color: AppColors.blueColor.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_rounded,
              color: AppColors.blueColor,
              size: getWidth(20),
            ),
            SizedBox(width: getWidth(8)),
            Text(
              "Class ${teacher.className} ${teacher.section}",
              style: TextStyle(
                fontSize: getWidth(15),
                fontWeight: FontWeight.w500,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
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
