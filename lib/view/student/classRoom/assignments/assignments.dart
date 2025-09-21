import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/classroom_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/assignements_model.dart';
import 'package:Vadai/model/students/subject_model.dart';
import 'package:Vadai/view/student/classRoom/assignments/assignment_detail_screen.dart';

class Assignments extends StatefulWidget {
  const Assignments({super.key});

  @override
  State<Assignments> createState() => _AssignmentsState();
}

class _AssignmentsState extends State<Assignments> {
  ClassRoomController classRoomCtr = Get.find();
  RxBool isLoading = false.obs;
  RxInt selectedTab = 0.obs;
  RxList<String> tabs = ['Pending', 'Completed'].obs;
  SubjectModel? currentSubject;
  List<AssignmentsModel> completed = [];
  List<AssignmentsModel> notCompleted = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    isLoading.value = true;
    var data = Get.arguments;
    if (data != null) {
      currentSubject = data?[AppStrings.subjects];
    }
    try {
      await classRoomCtr
          .getAssignments(subjectId: currentSubject?.sId ?? '')
          .then((Map<String, dynamic>? value) {
            if (value != null) {
              completed = value[ApiParameter.isCompleted] ?? [];
              notCompleted = value[ApiParameter.isNotCompleted] ?? [];
            }
          });
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in assignments: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: AppStrings.assignments,
      ),
      body: Obx(
        () =>
            isLoading.value
                ? commonLoader()
                : Container(
                  color: AppColors.white,
                  height: double.infinity,
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    left: getWidth(24),
                    right: getWidth(24),
                    top: getHeight(8),
                  ),
                  child: Column(
                    children: [
                      _buildTabBar().paddingOnly(
                        left: getWidth(24),
                        right: getWidth(24),
                        bottom: getHeight(3),
                      ),
                      Expanded(child: _buildTabContent()),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Material(
      elevation: 2, // Adjust elevation for the Material widget
      shadowColor: AppColors.black.withOpacity(0.2), // Shadow color
      borderRadius: BorderRadius.circular(getWidth(6)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(getWidth(12))),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.15), // Shadow color
              spreadRadius: 1, // Spread of the shadow
              blurRadius: 8, // Blur radius for smoothness
              offset: Offset(0, 4), // Vertical shadow
            ),
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(2, 2), // Right-down shadow
            ),
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(-2, -2), // Left-up shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  selectedTab.value = 0;
                },
                child: Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      color:
                          selectedTab.value == 0
                              ? AppColors.black
                              : AppColors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(getWidth(12)),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tabs[0],
                        style: TextStyle(
                          color:
                              selectedTab.value == 0
                                  ? AppColors.white
                                  : AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ).paddingOnly(top: getHeight(4), bottom: getHeight(4)),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  selectedTab.value = 1;
                },
                child: Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      color:
                          selectedTab.value == 1
                              ? AppColors.black
                              : AppColors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(getWidth(12)),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tabs[1],
                        style: TextStyle(
                          color:
                              selectedTab.value == 1
                                  ? AppColors.white
                                  : AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ).paddingOnly(top: getHeight(4), bottom: getHeight(4)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Obx(
      () =>
          selectedTab.value == 0
              ? _buildRecentAssignments(item: notCompleted)
              : _buildCompletedAssignments(item: completed),
    );
  }

  Widget _buildRecentAssignments({required List<AssignmentsModel> item}) {
    if (item.isEmpty) {
      return commonNoDataFound();
    }
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        textWid(
          AppStrings.todo,
          style: AppTextStyles.textStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            txtColor: AppColors.red,
          ),
        ).paddingOnly(top: getHeight(16)),
        ...List.generate(
          item.length,
          (index) => _buildRecentAssignmentCard(
            item: item[index],
          ).paddingOnly(top: getHeight(16)),
        ),
      ],
    );
  }

  Widget _buildCompletedAssignments({required List<AssignmentsModel> item}) {
    if (item.isEmpty) {
      return commonNoDataFound();
    }
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        textWid(
          AppStrings.submitted,
          style: AppTextStyles.textStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            txtColor: AppColors.black,
          ),
        ).paddingOnly(top: getHeight(16)),
        ...List.generate(
          item.length,
          (index) => _buildCompletedAssignmentCard(
            item: item[index],
          ).paddingOnly(top: getHeight(16)),
        ),
      ],
    );
  }

  Widget _buildRecentAssignmentCard({required AssignmentsModel item}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(getWidth(16)),
      decoration: BoxDecoration(
        color: AppColors.colorC56469,
        borderRadius: BorderRadius.circular(getWidth(10)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textWid(
                  item.lesson ?? '',
                  style: AppTextStyles.textStyle(
                    fontSize: 16,
                    txtColor: AppColors.textColor3,
                    fontWeight: FontWeight.w600,
                  ),
                ).paddingOnly(bottom: getHeight(4)),
                textWid(
                  item.topics
                          ?.map(
                            (topic) =>
                                topic[0].toUpperCase() + topic.substring(1),
                          )
                          .join(', ') ??
                      '',
                  maxlines: 13,
                  style: AppTextStyles.textStyle(
                    fontSize: 12,
                    txtColor: AppColors.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ).paddingOnly(bottom: getHeight(4)),
                textWid(
                  item.additionalInfo ?? '',
                  style: AppTextStyles.textStyle(
                    fontSize: 14,
                    txtColor: AppColors.textColor,
                  ),
                ).paddingOnly(bottom: getHeight(12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    materialButtonWithChild(
                      color: AppColors.white,
                      borderRadius: 12,
                      height: 28,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Get.to(
                          () => const AssignmentDetailScreen(),
                          arguments: {'assignment': item},
                        );
                      },

                      child: textWid(
                        AppStrings.attempt,
                        style: AppTextStyles.textStyle(
                          fontSize: 12,
                          txtColor: AppColors.textColor3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    materialButtonWithChild(
                      color: AppColors.transparent,
                      borderColor: AppColors.white,
                      borderWidth: 1,
                      borderRadius: 12,
                      height: 28,
                      padding: EdgeInsets.zero,
                      child: textWid(
                        AppStrings.comment,
                        style: AppTextStyles.textStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          txtColor: AppColors.textColor3,
                        ),
                      ),
                      onPressed:
                          () => Get.toNamed(
                            RouteNames.comments,
                            arguments: {'parentId': item.sId},
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: getHeight(80), // Explicitly set height
              alignment: Alignment.center,
              child: const VerticalDivider(
                color: AppColors.black,
                thickness: 1,
              ),
            ).paddingOnly(left: getWidth(16)),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                textWid(
                  AppStrings.dueDate,
                  style: AppTextStyles.textStyle(
                    fontSize: 12,
                    txtColor: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                textWid(
                  formatDate(item.dueDate),
                  maxlines: 2,
                  style: AppTextStyles.textStyle(
                    fontSize: 12,
                    txtColor: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ).paddingOnly(top: getHeight(8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedAssignmentCard({required AssignmentsModel item}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(getWidth(16)),
      decoration: BoxDecoration(
        color: AppColors.colorC56469,
        borderRadius: BorderRadius.circular(getWidth(10)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textWid(
                  item.lesson ?? '',
                  style: AppTextStyles.textStyle(
                    fontSize: 16,
                    txtColor: AppColors.textColor3,
                    fontWeight: FontWeight.w600,
                  ),
                ).paddingOnly(bottom: getHeight(4)),
                textWid(
                  item.topics
                          ?.map(
                            (topic) =>
                                topic[0].toUpperCase() + topic.substring(1),
                          )
                          .join(', ') ??
                      '',
                  maxlines: 13,
                  style: AppTextStyles.textStyle(
                    fontSize: 12,
                    txtColor: AppColors.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ).paddingOnly(bottom: getHeight(4)),
                textWid(
                  item.additionalInfo ?? '',
                  style: AppTextStyles.textStyle(
                    fontSize: 14,
                    txtColor: AppColors.textColor,
                  ),
                ).paddingOnly(bottom: getHeight(12)),
                materialButtonWithChild(
                  color: AppColors.transparent,
                  borderColor: AppColors.white,
                  borderWidth: 1,
                  borderRadius: 12,
                  height: 28,
                  padding: EdgeInsets.zero,
                  child: textWid(
                    AppStrings.comment,
                    style: AppTextStyles.textStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      txtColor: AppColors.textColor3,
                    ),
                  ),
                  onPressed: () => Get.toNamed(RouteNames.comments),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: getHeight(80), // Explicitly set height
              alignment: Alignment.center,
              child: const VerticalDivider(
                color: AppColors.black,
                thickness: 1,
              ),
            ).paddingOnly(left: getWidth(16)),
          ),
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                textWid(
                  AppStrings.submissionDate,
                  style: AppTextStyles.textStyle(
                    fontSize: 12,
                    txtColor: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                textWid(
                  formatDate(item.dueDate),
                  maxlines: 2,
                  style: AppTextStyles.textStyle(
                    fontSize: 12,
                    txtColor: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ).paddingOnly(top: getHeight(8)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
