import 'package:Vadai/common_imports.dart';
import 'package:Vadai/model/students/subject_model.dart';

class SubjectDetailsScreen extends StatefulWidget {
  const SubjectDetailsScreen({super.key});

  @override
  State<SubjectDetailsScreen> createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  // String subjectName = 'Subject Name';
  Rx<SubjectModel?> currentSubject = Rx<SubjectModel?>(null);
  RxBool isLoading = false.obs;

  @override
  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() {
    isLoading.value = true;
    try {
      if (Get.arguments != null && Get.arguments is SubjectModel) {
        currentSubject(Get.arguments);
      }
    } catch (e) {
      log(
        '------------------>>>>>>>>>>>>>> error in initData of subject details screen $e',
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
          title: currentSubject.value?.subjectName,
          actions: [
            GestureDetector(
              onTap: () {
                Get.toNamed(
                  RouteNames.peoplesScreen,
                  arguments: {AppStrings.subjects: currentSubject.value},
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
        body: commonPadding(
          child: Column(
            children: [
              SizedBox(height: getHeight(16)),
              _buildCurriculum(),
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
              _buildSections(
                title: AppStrings.announcements,
                count: currentSubject.value?.announcementsCount,
                countColor: AppColors.green,
                onTap:
                    () => Get.toNamed(
                      RouteNames.announcements,
                      arguments: {AppStrings.subjects: currentSubject.value},
                    ),
              ),
              _buildSections(
                title: AppStrings.assignments,
                count: currentSubject.value?.assignmentsCount,
                countColor: AppColors.red,
                onTap:
                    () => Get.toNamed(
                      RouteNames.assignments,
                      arguments: {AppStrings.subjects: currentSubject.value},
                    ),
              ),
              _buildSections(
                title: AppStrings.resources,
                onTap:
                    () => Get.toNamed(
                      RouteNames.chaptersScreen,
                      arguments: {
                        AppStrings.comingFrom: AppStrings.resources,
                        AppStrings.subjects: currentSubject.value,
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurriculum() {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          RouteNames.curriculum,
          arguments: {
            AppStrings.comingFrom: AppStrings.curriculum,
            AppStrings.subjects: currentSubject.value,
          },
        );
      },
      child: Container(
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
          padding: EdgeInsets.only(
            left: getWidth(16),
            right: getWidth(16),
            top: getWidth(8),
            bottom: getWidth(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(right: getWidth(55.0)),
                child: textWid(
                  AppStrings.curriculum,
                  style: TextStyle(
                    fontSize: getWidth(26),
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: getWidth(40)),
                child: VerticalDivider(
                  color: AppColors.white,
                  thickness: getWidth(1),
                ),
              ),
              SizedBox(
                width: getWidth(60),
                child: textWid(
                  AppStrings.testYourAcademic,
                  maxlines: 2,
                  textOverflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: getWidth(12),
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
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
            // Row(
            //   children: [
            //     item.announcement != 0
            //         ? Container(
            //             width: getWidth(28),
            //             height: getWidth(28),
            //             decoration: const BoxDecoration(
            //               color: AppColors.green,
            //               shape: BoxShape.circle,
            //             ),
            //             alignment: Alignment.center,
            //             child: textWid(
            //               item.announcement.toString(),
            //               style: TextStyle(
            //                 fontSize: getWidth(16),
            //                 fontWeight: FontWeight.bold,
            //                 color: AppColors.white,
            //               ),
            //             ),
            //           )
            //         : SizedBox(),
            //     SizedBox(
            //       width: getWidth(8),
            //     ),
            //     item.assignment != 0
            //         ? Container(
            //             width: getWidth(28),
            //             height: getWidth(28),
            //             decoration: BoxDecoration(
            //               color: AppColors.red,
            //               shape: BoxShape.circle,
            //             ),
            //             alignment: Alignment.center,
            //             child: textWid(
            //               item.assignment.toString(),
            //               style: TextStyle(
            //                 fontSize: getWidth(16),
            //                 fontWeight: FontWeight.bold,
            //                 color: AppColors.white,
            //               ),
            //             ),
            //           )
            //         : const SizedBox(),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
