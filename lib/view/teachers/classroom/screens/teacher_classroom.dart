import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/controller/teachers/teacher_profile_controller.dart';
import 'package:Vadai/model/teachers/teacher_classes_data.dart';

class TeacherClassroom extends StatefulWidget {
  const TeacherClassroom({Key? key}) : super(key: key);

  @override
  State<TeacherClassroom> createState() => _TeacherClassroomState();
}

class _TeacherClassroomState extends State<TeacherClassroom>
    with SingleTickerProviderStateMixin {
  late TeacherClassroomController controller;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _headerButtonAnimation;

  // Track if animations have been played
  final RxBool _animationsInitialized = false.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TeacherClassroomController>();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _headerButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    // Load data when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getTeachingSubjects();
    });

    // Initialize animations when data is loaded
    ever(controller.isLoading, (isLoading) {
      if (!isLoading && !_animationsInitialized.value && mounted) {
        _initializeAnimations();
      }
    });

    // Handle case where data is already loaded
    if (!controller.isLoading.value && !_animationsInitialized.value) {
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
            Obx(
              () =>
                  controller.isLoading.value
                      ? Center(child: commonLoader())
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            final teacherProfile =
                                Get.find<TeacherProfileController>()
                                    .teacherProfile
                                    .value;
                            bool isClassTeacher =
                                teacherProfile != null &&
                                teacherProfile.classId != null &&
                                teacherProfile.classId!.isNotEmpty &&
                                teacherProfile.sectionId != null &&
                                teacherProfile.sectionId!.isNotEmpty;

                            if (isClassTeacher) {
                              return ScaleTransition(
                                scale: _headerButtonAnimation,
                                child: materialButtonWithChild(
                                  onPressed:
                                      () => Get.toNamed(
                                        RouteNames.classTeacherScreen,
                                      ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Center(
                                      child: textWid(
                                        'My Classroom',
                                        style: AppTextStyles.textStyle(
                                          txtColor: AppColors.white,
                                          fontSize: 22,
                                          letterSpacing: 0.01,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ).paddingOnly(
                                        top: getHeight(16),
                                        bottom: getHeight(16),
                                        right: getWidth(15),
                                        left: getWidth(15),
                                      ),
                                    ),
                                  ),
                                  width: double.infinity,
                                ).paddingOnly(
                                  right: getWidth(10),
                                  left: getWidth(10),
                                  top: getHeight(28),
                                ),
                              );
                            } else {
                              return SizedBox(height: getHeight(16));
                            }
                          }),
                          Expanded(child: _buildClassList()),
                        ],
                      ).paddingOnly(
                        top: getHeight(70),
                        left: getWidth(16),
                        right: getWidth(16),
                        bottom: getHeight(16),
                      ),
            ),
            teachersTabAppBar(title: "Classroom"),
          ],
        ),
      ),
    );
  }

  Widget _buildClassList() {
    if (controller.teacherClassesData.value == null ||
        controller.teacherClassesData.value!.classesAndSubjects.isEmpty) {
      return _buildEmptyState();
    }

    // Create a flat list of all items
    List<Widget> listItems = [];
    int itemIndex = 0;

    for (var classData
        in controller.teacherClassesData.value!.classesAndSubjects) {
      // Animation for class header
      final classHeaderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.1 + (itemIndex * 0.05).clamp(0.0, 0.5),
            0.4 + (itemIndex * 0.05).clamp(0.0, 0.5),
            curve: Curves.easeOutQuart,
          ),
        ),
      );
      itemIndex++;

      // Add class header with animation
      listItems.add(
        ScaleTransition(
          scale: classHeaderAnimation,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: getHeight(12)),
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(20),
                vertical: getHeight(8),
              ),
              decoration: BoxDecoration(
                color: AppColors.blueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(getWidth(20)),
                border: Border.all(color: AppColors.blueColor.withOpacity(0.3)),
              ),
              child: Text(
                "Class ${classData.className}",
                style: TextStyle(
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.blueColor,
                ),
              ),
            ),
          ),
        ),
      );

      // Add each section with its subjects
      for (var section in classData.sections) {
        // Animation for section chip
        final sectionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              0.2 + (itemIndex * 0.05).clamp(0.0, 0.6),
              0.5 + (itemIndex * 0.05).clamp(0.0, 0.6),
              curve: Curves.easeOutCubic,
            ),
          ),
        );
        itemIndex++;

        // Add section chip with animation
        listItems.add(
          ScaleTransition(
            scale: sectionAnimation,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: getHeight(8)),
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(16),
                  vertical: getHeight(6),
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(getWidth(20)),
                ),
                child: Text(
                  "Sec - ${section.section}",
                  style: TextStyle(
                    fontSize: getWidth(14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ),
          ),
        );

        // Add subjects for this section
        for (var subject in section.subjects) {
          // Animation for subject item
          final subjectAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                0.3 + (itemIndex * 0.05).clamp(0.0, 0.7),
                0.6 + (itemIndex * 0.05).clamp(0.0, 0.7),
                curve: Curves.elasticOut,
              ),
            ),
          );
          itemIndex++;

          // Add subject item with animation
          listItems.add(
            ScaleTransition(
              scale: subjectAnimation,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(getWidth(12)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: MaterialButton(
                  padding: EdgeInsets.symmetric(
                    vertical: getHeight(16),
                    horizontal: getWidth(16),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(getWidth(12)),
                  ),
                  onPressed: () {
                    Get.toNamed(
                      RouteNames.teacherSubjectDetails,
                      arguments: {
                        'className': classData.className,
                        'sectionName': section.section,
                        'subjectName': subject.subjectName,
                        'classId': classData.classId,
                        'sectionId': section.sectionId,
                        'subjectId': subject.subjectId,
                      },
                    );
                  },
                  child: Center(
                    child: Text(
                      subject.subjectName,
                      style: TextStyle(
                        fontSize: getWidth(18),
                        fontWeight: FontWeight.w500,
                        color: AppColors.blueColor,
                      ),
                    ),
                  ),
                ),
              ).paddingOnly(bottom: getHeight(16)),
            ),
          );
        }
      }
    }

    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: getHeight(16),
        horizontal: getWidth(16),
      ),
      children: listItems,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          assetImage(
            image: AppAssets.tab2,
            color: AppColors.blueColor,
            customHeight: getHeight(80),
            customWidth: getWidth(80),
          ),
          SizedBox(height: getHeight(20)),
          Text(
            "No Classes Assigned",
            style: TextStyle(
              fontSize: getWidth(20),
              fontWeight: FontWeight.bold,
              color: AppColors.blueColor,
            ),
          ),
          SizedBox(height: getHeight(16)),
          Text(
            "You don't have any classes assigned yet.\nCheck back later or contact your administrator.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: getWidth(16),
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(24)),
          ElevatedButton(
            onPressed: () => controller.getTeachingSubjects(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueColor,
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(24),
                vertical: getHeight(12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(getWidth(8)),
              ),
            ),
            child: Text(
              "Refresh",
              style: TextStyle(fontSize: getWidth(16), color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
