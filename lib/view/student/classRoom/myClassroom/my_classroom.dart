import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/classroom_controller.dart';
import 'package:Vadai/controller/student/student_profile_controller.dart';

class MyClassroom extends StatefulWidget {
  const MyClassroom({super.key});

  @override
  State<MyClassroom> createState() => _MyClassroomState();
}

class _MyClassroomState extends State<MyClassroom> {
  ClassRoomController classroomController = Get.find<ClassRoomController>();
  StudentProfileController profileController =
      Get.find<StudentProfileController>();
  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() {
    isLoading.value = true;
    try {
      classroomController.getMyClassroomBadgeCount();
    } catch (e) {
      log('Error initializing MyClassroom data: $e');
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
          title: "My Classroom",
          actions: [
            GestureDetector(
              onTap: () {
                // Navigate to classmates/people screen
                Get.toNamed(RouteNames.peoplesScreen);
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
                      SizedBox(height: getHeight(16)),
                      _buildClassHeader(),
                      SizedBox(height: getHeight(16)),
                      commonPadding(
                        padding: EdgeInsets.only(
                          left: getWidth(24),
                          right: getWidth(24),
                        ),
                        child: Divider(
                          color: AppColors.black.withOpacity(0.3),
                          thickness: getWidth(1.5),
                        ),
                      ),
                      SizedBox(height: getHeight(16)),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              _buildSection(
                                title: "Attendance",
                                onTap:
                                    () => Get.toNamed(
                                      RouteNames.attendanceScreen,
                                    ),
                              ),
                              _buildSection(
                                title: "Announcements",
                                count:
                                    classroomController
                                        .myClassroomAnnouncementCount
                                        .value,
                                countColor: AppColors.green,
                                onTap:
                                    () => Get.toNamed(
                                      RouteNames.classroomAnnouncements,
                                    )?.then((value) {
                                      classroomController
                                          .getMyClassroomBadgeCount();
                                    }),
                              ),
                              _buildSection(
                                title: "Remarks",
                                onTap:
                                    () => Get.toNamed(
                                      RouteNames.classroomRemarks,
                                    ),
                              ),
                              _buildSection(
                                title: "Resources",
                                onTap:
                                    () => Get.toNamed(
                                      RouteNames.classroomResources,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildClassHeader() {
    return Container(
      height: getHeight(80),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.black.withOpacity(0.7),
          width: getWidth(2),
        ),
        borderRadius: BorderRadius.circular(getWidth(16)),
      ),
      child: Container(
        margin: EdgeInsets.all(getWidth(2)),
        decoration: BoxDecoration(
          color: AppColors.blueColor,
          borderRadius: BorderRadius.circular(getWidth(12)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(16),
          vertical: getWidth(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                textWid(
                  "${profileController.studentProfile.value?.name ?? 'Student'}",
                  style: TextStyle(
                    fontSize: getWidth(20),
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: getHeight(4)),
                textWid(
                  "Class ${profileController.studentProfile.value?.className ?? ''} - ${profileController.studentProfile.value?.section ?? ''}",
                  style: TextStyle(
                    fontSize: getWidth(14),
                    fontWeight: FontWeight.w400,
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.all(getWidth(8)),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(getWidth(8)),
                  ),
                  child: textWid(
                    "Roll #${profileController.studentProfile.value?.rollNumber ?? ''}",
                    style: TextStyle(
                      fontSize: getWidth(14),
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
                SizedBox(height: getHeight(4)),
                textWid(
                  "${profileController.studentProfile.value?.school ?? 'School'}",
                  style: TextStyle(
                    fontSize: getWidth(12),
                    fontWeight: FontWeight.w400,
                    color: AppColors.white.withOpacity(0.8),
                  ),
                  maxlines: 1,
                  textOverflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required VoidCallback onTap,
    required String title,
    int? count,
    Color? countColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: getHeight(80),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.black.withOpacity(0.2),
            width: getWidth(2.6),
          ),
          borderRadius: BorderRadius.circular(getWidth(25)),
        ),
        padding: EdgeInsets.only(left: getWidth(16), right: getWidth(16)),
        margin: EdgeInsets.only(bottom: getHeight(18)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            textWid(
              title,
              style: TextStyle(
                fontSize: getWidth(18),
                fontWeight: FontWeight.w800,
                color: AppColors.black.withOpacity(0.6),
              ),
            ),
            if (count != null && count != 0)
              Container(
                width: getWidth(28),
                height: getWidth(28),
                decoration: BoxDecoration(
                  color: countColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: textWid(
                  count.toString(),
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
    );
  }
}
