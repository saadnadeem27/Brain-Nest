import 'package:Vadai/common/widgets/prompt_copied_dialog.dart';
import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/careergames_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/job_role_model.dart';
import 'package:Vadai/view/student/career_games/career_games.dart';
import 'package:flutter/services.dart';

class SavedJobRoles extends StatefulWidget {
  const SavedJobRoles({super.key});

  @override
  State<SavedJobRoles> createState() => _SavedJobRolesState();
}

class _SavedJobRolesState extends State<SavedJobRoles> {
  CareerGamesController ctr = Get.find<CareerGamesController>();
  final ScrollController scrollController = ScrollController();
  RxBool isLoading = false.obs;
  RxBool isLoadingMorePage = false.obs;
  RxList<JobRoleModel?> jobRoleList = <JobRoleModel?>[].obs;
  RxBool hasNext = false.obs;
  RxInt pageNumber = 2.obs;
  RxBool isLoadingPrompt = false.obs;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    initData();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  Future<void> initData() async {
    isLoading.value = true;
    try {
      await ctr.getSavedJobRole().then((value) {
        if (value != null) {
          jobRoleList.value = value[ApiParameter.jobRoles];
          hasNext.value = value[ApiParameter.hasNext];
        } else {
          log('Error in getSavedJobRoles: response is null');
        }
      });
    } catch (e) {
      log('Error in getSavedJobRoles: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadMore();
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMorePage.value || !hasNext.value) return;

    isLoadingMorePage.value = true;
    try {
      await ctr.getSavedJobRole(pageNumber: pageNumber.value).then((value) {
        if (value != null) {
          jobRoleList.addAll(value[ApiParameter.jobRoles]);
          hasNext.value = value[ApiParameter.hasNext];
          pageNumber.value++;
        } else {
          log('Error in getSavedJobRoles: response is null');
        }
      });
    } catch (e) {
      log('Error in getSavedJobRoles: $e');
    } finally {
      isLoadingMorePage.value = false;
    }
  }

  Future<void> unsaveJobRole(int index) async {
    try {
      final removed = await ctr.unsaveJobRole(
        jobRoleId: jobRoleList[index]?.sId ?? '',
      );
      log('================>>>>>>>>>>>>> removed: $removed');
      if (removed == true) {
        final updatedList = List<JobRoleModel?>.from(jobRoleList);
        updatedList.removeAt(index);
        jobRoleList.value = updatedList;
        jobRoleList.refresh();
      }
      log('================>>>>>>>>>>>>> removed: $removed');
    } catch (e) {
      log('Error removing job role: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: AppStrings.savedCareerRoles,
        actions: [],
      ),
      body: Obx(
        () =>
            isLoading.value
                ? commonLoader()
                : Stack(
                  children: [
                    SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => _buildJobRole()),
                          SizedBox(height: getHeight(28)),
                        ],
                      ),
                    ),
                    if (isLoadingMorePage.value)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            vertical: getHeight(10),
                          ),
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
      ),
    );
  }

  Widget _buildJobRole() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: jobRoleList.length,
      itemBuilder: (context, index) {
        final jobRole = jobRoleList[index];

        return GestureDetector(
          onTap: () => jobRoleDialog(jobRole),
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(getWidth(6)),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(getWidth(6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: getWidth(1),
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: textWid(
                      jobRole?.jobRole ?? '',
                      style: TextStyle(
                        fontSize: getWidth(13),
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => unsaveJobRole(index),
                    child: Icon(
                      Icons.cancel_outlined,
                      size: getWidth(18),
                      color: AppColors.red,
                    ),
                  ),
                ],
              ).paddingOnly(
                left: getWidth(8),
                right: getWidth(8),
                top: getHeight(8),
                bottom: getHeight(8),
              ),
            ),
          ).paddingOnly(
            left: getWidth(16),
            right: getWidth(16),
            top: getHeight(8),
          ),
        );
      },
    );
  }

  void jobRoleDialog(JobRoleModel? item) {
    if (item == null) return;
    Get.dialog(
      Obx(
        () => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              textWid(
                AppStrings.careerRoleDescription,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.close, color: AppColors.red),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              textWid(
                item.description ?? '',
                textAlign: TextAlign.center,
                maxlines: 15,
              ),
              isLoadingPrompt.value
                  ? commonLoader(
                    customHeight: getHeight(20),
                    customWidth: getWidth(20),
                  ).paddingOnly(top: getHeight(16))
                  : materialButtonWithChild(
                    color: AppColors.blueColor,
                    onPressed: () async {
                      isLoadingPrompt.value = true;
                      final prompt = await ctr.generateJobRolePrompt(
                        jobRoleId: item.sId ?? '',
                      );
                      isLoadingPrompt.value = false;
                      Get.back();
                      if (prompt != null) {
                        await Clipboard.setData(ClipboardData(text: prompt));
                        showPromptCopiedDialog(context, () {
                          Get.back();
                          Get.toNamed(RouteNames.aiScreen);
                        });
                      }
                    },
                    child: textWid(
                      AppStrings.aIMagic,
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: getWidth(16),
                      ),
                    ).paddingOnly(left: getWidth(16), right: getWidth(16)),
                  ).paddingOnly(top: getHeight(28)),
            ],
          ),
        ),
      ),
    );
  }
}
