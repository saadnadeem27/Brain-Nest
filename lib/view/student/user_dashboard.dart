import 'package:Vadai/controller/student/careergames_controller.dart';
import 'package:Vadai/controller/student/classroom_controller.dart';
import 'package:Vadai/controller/common/ethical_learning_controller.dart';
import 'package:Vadai/controller/student/student_profile_controller.dart';
import 'package:Vadai/controller/student/vad_test_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:Vadai/common_imports.dart';
import 'package:Vadai/view/student/career_games/career_games.dart';
import 'package:Vadai/view/student/tabs/class_room.dart';
import 'package:Vadai/view/common/ethical_learning/screens/ethical_learning.dart';
import 'package:Vadai/view/student/vad_test/screens/vad_test.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  StudentProfileController profileCtr = Get.put(StudentProfileController());
  ClassRoomController classRoomCtr = Get.put(ClassRoomController());
  EthicalLearningController ethicalCtr = Get.put(EthicalLearningController());
  CareerGamesController careerGamesCtr = Get.put(CareerGamesController());
  VadTestController vadTestCtr = Get.put(VadTestController());
  RxInt selectedIndex = 1.obs;
  RxBool isLoading = false.obs;
  List<Widget> screens = [
    const VadTest(),
    const ClassRoom(),
    const EthicalLearning(),
    const CareerGames(),
  ];

  @override
  void initState() {
    super.initState();
    initClassroomData();
    initEthicalLearningData();
    initCareerGamesData();
    initProfile();
    initVadTest();
  }

  initProfile() async {
    isLoading.value = true;
    profileCtr.isLoading.value = true;
    try {
      await profileCtr.getStudentProfile();
      if (profileCtr.studentProfile.value?.profileImage != null &&
          profileCtr.studentProfile.value!.profileImage!.isNotEmpty) {
        precacheImage(
          CachedNetworkImageProvider(
            profileCtr.studentProfile.value!.profileImage!,
          ),
          context,
        ).catchError((_) {});
      }
      profileCtr.getNotificationCount();
    } catch (e) {
      log('-------------->>>>>>>>>>>> Error in initData of UserDashboard: $e');
    } finally {
      profileCtr.isLoading.value = false;
      isLoading.value = false;
    }
  }

  initClassroomData() async {
    classRoomCtr.isLoading.value = true;
    try {
      await classRoomCtr.getSubjectList();
    } catch (e) {
      log('-------------->>>>>>>>>>>> Error in initData of UserDashboard: $e');
    } finally {
      classRoomCtr.isLoading.value = false;
    }
  }

  initEthicalLearningData() async {
    ethicalCtr.isLoading.value = true;
    try {
      await ethicalCtr.getCategories();

      if (ethicalCtr.categories.isEmpty) {
        log('No categories found');
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
      log('----------------->>>>>>>>>> Error in initEthicalLearningData: $e');
    } finally {
      ethicalCtr.isLoading.value = false;
    }
  }

  initCareerGamesData() async {
    careerGamesCtr.isLoading.value = true;
    try {
      await careerGamesCtr.getWebinars();
      await careerGamesCtr.getJobRole();
      await careerGamesCtr.getJobRoleCategories();
      for (var webinar in careerGamesCtr.webinarsList) {
        if (webinar?.coverImage != null && webinar!.coverImage!.isNotEmpty) {
          precacheImage(
            CachedNetworkImageProvider(webinar.coverImage!),
            context,
          ).catchError((_) {
            // Silently handle any errors during precaching
          });
        }
      }
    } catch (e) {
      log('----------------->>>>>>>>>> Error in initCareerGamesData: $e');
    } finally {
      careerGamesCtr.isLoading.value = false;
    }
  }

  initVadTest() async {
    vadTestCtr.isLoading.value = true;
    try {
      await vadTestCtr.getSubjectList();
      for (var subject in vadTestCtr.vadTestSubjects) {
        if (subject.icon != null && subject.icon!.isNotEmpty) {
          precacheImage(
            CachedNetworkImageProvider(subject.icon!),
            context,
          ).catchError((_) {});
        }
      }
    } catch (e) {
      log('----------------->>>>>>>>>> Error in initVadTest: $e');
    } finally {
      vadTestCtr.isLoading.value = false;
    }
  }

  String getTabName(int index) {
    profileCtr.getNotificationCount();
    switch (index) {
      case 0:
        return "Vad Teat";
      case 1:
        return "Class Room";
      case 2:
        return "Ethical Learning";
      case 3:
        return "Career Games";
      default:
        return "Home";
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
