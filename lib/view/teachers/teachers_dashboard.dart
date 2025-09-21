import 'package:Vadai/controller/common/ethical_learning_controller.dart';
import 'package:Vadai/controller/teachers/teacher_auth_controller.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/controller/teachers/teacher_profile_controller.dart';
import 'package:Vadai/controller/teachers/teacher_progress_tracking_controller.dart';
import 'package:Vadai/controller/teachers/teacher_vadtest_controller.dart';
import 'package:Vadai/view/teachers/classroom/screens/teacher_classroom.dart';
import 'package:Vadai/view/teachers/timeline/screens/teacher_timeline.dart';
import 'package:Vadai/view/teachers/vad_test/screens/teacher_vad_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:Vadai/common_imports.dart';
import 'package:Vadai/view/common/ethical_learning/screens/ethical_learning.dart';

class TeachersDashboard extends StatefulWidget {
  const TeachersDashboard({super.key});

  @override
  State<TeachersDashboard> createState() => _TeachersDashboardState();
}

class _TeachersDashboardState extends State<TeachersDashboard> {
  TeacherClassroomController classroomCtr = Get.put(
    TeacherClassroomController(),
  );

  EthicalLearningController ethicalCtr = Get.put(EthicalLearningController());
  TeacherProgressTrackingController timelineCtr = Get.put(
    TeacherProgressTrackingController(),
  );
  TeacherVadTestController vadTestCtr = Get.put(TeacherVadTestController());
  TeacherProfileController teacherProfileCtr = Get.put(
    TeacherProfileController(),
  );

  RxInt selectedIndex = 1.obs;
  RxBool isLoading = false.obs;

  // Tabs screens
  late List<Widget> screens = [
    const TeacherVadTest(),
    const TeacherClassroom(),
    const EthicalLearning(fromTeachers: true),
    const TeacherTimeline(),
  ];

  @override
  void initState() {
    super.initState();
    initDashboardData();
  }

  Future<void> initDashboardData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        initTeacherProfile(),
        initClassroomData(),
        initVadTestData(),
        initEthicalLearningData(),
        initTimelineData(),
      ]);
    } catch (e) {
      log('Error initializing teacher dashboard: $e');
      commonSnackBar(
        message: "There was an error loading your dashboard. Please try again.",
        color: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initTeacherProfile() async {
    teacherProfileCtr.isLoading.value = true;
    try {
      await teacherProfileCtr.getTeacherProfile();
      if (teacherProfileCtr.teacherProfile.value == null) {
        log('No teacher profile found');
        return;
      }
      // Precache profile image
      final profileImage = teacherProfileCtr.teacherProfile.value?.profileImage;
      if (profileImage != null && profileImage.isNotEmpty) {
        precacheImage(
          CachedNetworkImageProvider(profileImage),
          context,
        ).catchError((_) {});
      }
    } catch (e) {
      log('Error loading teacher profile: $e');
    } finally {
      teacherProfileCtr.isLoading.value = false;
    }
  }

  Future<void> initClassroomData() async {
    classroomCtr.isLoading.value = true;
    try {
      await classroomCtr.getTeachingSubjects();
      if (classroomCtr.teacherClassesData.value == null) {
        log('No teacher classes data found');
      }
    } catch (e) {
      log('Error loading classroom data: $e');
    } finally {
      classroomCtr.isLoading.value = false;
    }
  }

  Future<void> initVadTestData() async {
    vadTestCtr.isLoading.value = true;
    try {
      await vadTestCtr.getVadTestSubjects();

      if (vadTestCtr.vadTestSubjectList.isEmpty) {
        log('No VAD test subjects found');
        return;
      }

      for (var subject in vadTestCtr.vadTestSubjectList) {
        if (subject.tests != null) {
          for (var test in subject.tests!) {
            if (test.icon != null &&
                test.icon!.isNotEmpty &&
                test.icon!.startsWith('http')) {
              precacheImage(
                CachedNetworkImageProvider(test.icon!),
                context,
              ).catchError((_) {});
            }
          }
        }
      }
    } catch (e) {
      log('Error loading VAD test data: $e');
    } finally {
      vadTestCtr.isLoading.value = false;
    }
  }

  Future<void> initEthicalLearningData() async {
    ethicalCtr.isLoading.value = true;
    try {
      await ethicalCtr.getCategories();

      if (ethicalCtr.categories.isEmpty) {
        log('No ethical learning categories found');
        return;
      }

      // Get first category's subcategories
      final firstCategoryId = ethicalCtr.categories.first?.sId;
      if (firstCategoryId == null || firstCategoryId.isEmpty) {
        log('Invalid first category ID');
        return;
      }

      await ethicalCtr.getSubCategories(categoryId: firstCategoryId);

      if (ethicalCtr.subCategories.isEmpty) {
        log('No subcategories found for category $firstCategoryId');
        return;
      }

      // Get compendia for first subcategory
      final firstSubCategoryId = ethicalCtr.subCategories.first?.sId;
      if (firstSubCategoryId == null || firstSubCategoryId.isEmpty) {
        log('Invalid first subcategory ID');
        return;
      }

      await ethicalCtr.getAllCompendia(
        category: firstCategoryId,
        subCategory: firstSubCategoryId,
      );

      // Precache compendium cover images
      for (var compendium in ethicalCtr.compendia) {
        if (compendium?.coverImage != null &&
            compendium!.coverImage!.isNotEmpty) {
          precacheImage(
            CachedNetworkImageProvider(compendium.coverImage!),
            context,
          ).catchError((_) {
            // Silently handle any errors during precaching
          });
        }
      }
    } catch (e) {
      log('Error loading ethical learning data: $e');
    } finally {
      ethicalCtr.isLoading.value = false;
    }
  }

  Future<void> initTimelineData() async {
    timelineCtr.isLoading.value = true;
    try {
      await timelineCtr.getTeachingSubjects();

      // If we have classes, preload some progress data for the first class/section/subject
      if (timelineCtr.teacherClassesData.value != null &&
          timelineCtr.teacherClassesData.value!.classesAndSubjects.isNotEmpty) {
        final firstClass =
            timelineCtr.teacherClassesData.value!.classesAndSubjects.first;

        if (firstClass.sections.isNotEmpty) {
          final firstSection = firstClass.sections.first;

          if (firstSection.subjects.isNotEmpty) {
            final firstSubject = firstSection.subjects.first;

            // Preload initial progress data
            await Future.wait([
              timelineCtr.getVadTestProgress(
                classId: firstClass.classId,
                sectionId: firstSection.sectionId,
                subjectId: firstSubject.subjectId,
              ),
              timelineCtr.getSchoolExamProgress(
                classId: firstClass.classId,
                sectionId: firstSection.sectionId,
                subjectId: firstSubject.subjectId,
              ),
            ]);
          }
        }
      }
    } catch (e) {
      log('Error loading timeline data: $e');
    } finally {
      timelineCtr.isLoading.value = false;
    }
  }

  String getTabName(int index) {
    switch (index) {
      case 0:
        return "VAD Test";
      case 1:
        return "Classroom";
      case 2:
        return "Ethical Learning";
      case 3:
        return "Timeline";
      default:
        return "Dashboard";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => commonScaffold(
        context: context,
        bottomNavigationBar: Stack(
          children: [
            StylishBottomBar(
              backgroundColor: AppColors.grey01,
              borderRadius: BorderRadius.circular(getWidth(20)),
              elevation: getWidth(21),
              option: AnimatedBarOptions(
                iconStyle: IconStyle.animated,
                barAnimation: BarAnimation.fade,
                padding: EdgeInsets.only(
                  top: getHeight(15),
                  bottom: getHeight(15),
                ),
              ),
              items: [
                BottomBarItem(
                  icon: SizedBox(
                    height: getWidth(28),
                    width: getWidth(28),
                    child: assetImage(image: AppAssets.tab1),
                  ),
                  selectedIcon: SizedBox(
                    height: getWidth(28),
                    width: getWidth(28),
                    child: assetImage(
                      image: AppAssets.tab1,
                      color: AppColors.blueColor,
                    ),
                  ),
                  selectedColor: AppColors.blueColor,
                  title: textWid(''),
                  backgroundColor: Colors.white,
                ),
                BottomBarItem(
                  icon: SizedBox(
                    height: getWidth(28),
                    width: getWidth(28),
                    child: assetImage(image: AppAssets.tab2),
                  ),
                  selectedIcon: SizedBox(
                    height: getWidth(28),
                    width: getWidth(28),
                    child: assetImage(
                      image: AppAssets.tab2,
                      color: AppColors.blueColor,
                    ),
                  ),
                  selectedColor: AppColors.blueColor,
                  title: textWid(''),
                  backgroundColor: Colors.white,
                ),
                BottomBarItem(
                  icon: SizedBox(
                    height: getWidth(28),
                    width: getWidth(28),
                    child: assetImage(image: AppAssets.tab3),
                  ),
                  selectedIcon: SizedBox(
                    height: getWidth(28),
                    width: getWidth(28),
                    child: assetImage(
                      image: AppAssets.tab3,
                      color: AppColors.blueColor,
                    ),
                  ),
                  selectedColor: AppColors.blueColor,
                  title: textWid(''),
                  backgroundColor: Colors.white,
                ),
                BottomBarItem(
                  icon: SizedBox(
                    height: getWidth(28),
                    width: getWidth(28),
                    child: assetImage(image: AppAssets.tab4),
                  ),
                  selectedIcon: SizedBox(
                    height: getWidth(28),
                    width: getWidth(28),
                    child: assetImage(
                      image: AppAssets.tab4,
                      color: AppColors.blueColor,
                    ),
                  ),
                  selectedColor: AppColors.blueColor,
                  title: textWid(''),
                  backgroundColor: Colors.white,
                ),
              ],
              fabLocation: StylishBarFabLocation.center,
              hasNotch: true,
              currentIndex: selectedIndex.value,
              onTap: (index) {
                selectedIndex.value = index;
              },
              notchStyle: NotchStyle.circle,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: getHeight(12),
              child: Center(
                child: textWid(
                  getTabName(selectedIndex.value),
                  style: TextStyle(
                    color: AppColors.blueColor,
                    fontSize: getWidth(14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: GestureDetector(
          onTap: () => Get.toNamed(RouteNames.aiScreen),
          child: Container(
            padding: EdgeInsets.all(getWidth(20)),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blueColor,
            ),
            child: SizedBox(
              height: getWidth(24),
              width: getWidth(24),
              child: assetImage(image: AppAssets.tab5, color: AppColors.white),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body:
            isLoading.value
                ? Center(
                  child: commonLoader(
                    customHeight: double.infinity,
                    customWidth: double.infinity,
                  ),
                )
                : screens[selectedIndex.value < screens.length
                    ? selectedIndex.value
                    : 0],
      ),
    );
  }
}
