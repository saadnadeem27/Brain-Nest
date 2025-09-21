import 'package:Vadai/common/widgets/prompt_copied_dialog.dart';
import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/careergames_controller.dart';
import 'package:Vadai/model/students/careerdashboard_model.dart';
import 'package:flutter/services.dart';

class CareerDashboard extends StatefulWidget {
  const CareerDashboard({super.key});

  @override
  State<CareerDashboard> createState() => Career_DashboardState();
}

class Career_DashboardState extends State<CareerDashboard> {
  CareerGamesController ctr = Get.find<CareerGamesController>();
  CareerDashboardModel? career;
  TextEditingController goalController = TextEditingController();
  RxBool isGoalChanged = false.obs;
  TextEditingController strengthController = TextEditingController();
  RxBool isStrengthChanged = false.obs;
  TextEditingController weaknessController = TextEditingController();
  RxBool isWeaknessChanged = false.obs;
  TextEditingController vadSquadReview = TextEditingController();
  final RxList<Plans> plans = <Plans>[].obs;
  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    goalController.dispose();
    strengthController.dispose();
    weaknessController.dispose();
    vadSquadReview.dispose();
    super.dispose();
  }

  void initData() async {
    isLoading.value = true;
    await ctr.getCareerDetails().then((CareerDashboardModel? value) {
      if (value != null) {
        career = value;
        goalController.text = career?.goal ?? '';
        strengthController.text = career?.strength ?? '';
        weaknessController.text = career?.weakness ?? '';
        List<Plans> ls = [];
        for (var p in career?.plans ?? []) {
          ls.add(p);
        }
        plans.addAll(ls);
      }
    });
    isLoading.value = false;
  }

  void _addNewPlan() {
    plans.add(Plans(industry: '', careerPath: ''));
  }

  void _removePlan(Plans item) {
    if (plans.length > 1) {
      plans.remove(item);
      ctr.saveCareerDetails(plans: plans);
    }
  }

  Future<void> submitVADSquadReviews(String partToReview) async {
    if (partToReview.isEmpty) {
      commonSnackBar(
        message:
            "We’re all ears! 📝 Share your review to help us grow together. 🌱",
      );
      return;
    }
    if (goalController.text.trim().isEmpty) {
      commonSnackBar(
        message: "Before we dream big, tell us what your goal is! 🚀",
      );
      return;
    }
    if (strengthController.text.trim().isEmpty) {
      commonSnackBar(
        message:
            "We believe in your strengths – now you tell us what they are! 💪",
      );
      return;
    }
    if (weaknessController.text.trim().isEmpty) {
      commonSnackBar(
        message: "Even heroes have weaknesses. Let us know yours 🧠💬",
      );
      return;
    }
    log('--------------->>>>>>>>>>> step 1');
    await ctr.submitVADSquadReviews(partToReview: partToReview);
  }

  bool? isUnsavedChange() {
    if (isGoalChanged.value ||
        isStrengthChanged.value ||
        isWeaknessChanged.value) {
      commonSnackBar(
        message: "Please save your changes before leaving the page.",
      );
      return false;
    }
    for (var plan in plans) {
      if (plan.isIndustryChanged.value || plan.isCareerPathChanged.value) {
        commonSnackBar(
          message:
              "Please save your changes in the plans before leaving the page.",
        );
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        leading: IconButton(
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            if (isUnsavedChange() == false) {
              return;
            }
            Get.back();
          },
          icon: Icon(Icons.arrow_back),
        ),
        titleWidget: Column(
          children: [
            textWid(
              AppStrings.careerDashboard,
              style: AppTextStyles.textStyle(
                fontSize: getWidth(16),
                fontWeight: FontWeight.w700,
                txtColor: AppColors.black,
              ),
            ),
            assetImage(image: AppAssets.subjectDivider, customWidth: 130),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => careerGamesRules(),
            child: Container(
              padding: EdgeInsets.all(getWidth(4)),
              decoration: const BoxDecoration(
                color: AppColors.blueColor,
                shape: BoxShape.circle,
              ),
              child: assetImage(
                image: AppAssets.compendiaInfo,
                fit: BoxFit.contain,
                customWidth: 21,
              ),
            ),
          ).paddingOnly(right: getWidth(12), bottom: getHeight(6)),
        ],
      ),
      body: Obx(
        () =>
            isLoading.value
                ? commonLoader()
                : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textWid(
                        AppStrings.yourRoadmaptotheFuture,
                        style: AppTextStyles.textStyle(
                          fontSize: getWidth(18),
                          fontWeight: FontWeight.w600,
                          txtColor: AppColors.blueColor,
                        ),
                      ),
                      _buildTitleTextField(
                        controller: goalController,
                        title: AppStrings.goal,
                        hintText: AppStrings.goalsWrittenIndetail,
                        maxLine: 8,
                        changed: isGoalChanged,
                        onChanged: (p0) {
                          if (career?.goal == p0) {
                            isGoalChanged.value = false;
                          } else {
                            isGoalChanged.value = true;
                          }
                        },
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (goalController.text.trim().isEmpty) {
                            commonSnackBar(
                              message:
                                  "Before we dream big, tell us what your goal is! 🚀",
                            );
                            return;
                          }
                          isGoalChanged.value = false;
                          ctr.saveCareerDetails(goal: goalController.text).then(
                            (bool? value) {
                              if (value == null || value == false) {
                                goalController.text = career?.goal ?? '';
                              }
                            },
                          );
                        },
                      ),
                      _buildTitleTextField(
                        controller: strengthController,
                        title: AppStrings.strengths,
                        hintText: AppStrings.strengthsWrittenIndetail,
                        maxLine: 5,
                        changed: isStrengthChanged,
                        onChanged: (p0) {
                          if (career?.strength == p0) {
                            isStrengthChanged.value = false;
                          } else {
                            isStrengthChanged.value = true;
                          }
                        },
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (strengthController.text.trim().isEmpty) {
                            commonSnackBar(
                              message:
                                  "We believe in your strengths – now you tell us what they are! 💪",
                            );
                            return;
                          }
                          isStrengthChanged.value = false;
                          ctr
                              .saveCareerDetails(
                                strength: strengthController.text,
                              )
                              .then((bool? value) {
                                if (value == null || value == false) {
                                  strengthController.text =
                                      career?.strength ?? '';
                                }
                              });
                        },
                      ),
                      _buildTitleTextField(
                        controller: weaknessController,
                        title: AppStrings.weaknesses,
                        hintText: AppStrings.weaknessesWrittenIndetail,
                        maxLine: 5,
                        changed: isWeaknessChanged,
                        onChanged: (p0) {
                          if (career?.weakness == p0) {
                            isWeaknessChanged.value = false;
                          } else {
                            isWeaknessChanged.value = true;
                          }
                        },
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (weaknessController.text.trim().isEmpty) {
                            commonSnackBar(
                              message:
                                  "Even heroes have weaknesses. Let us know yours 🧠💬",
                            );
                            return;
                          }
                          isWeaknessChanged.value = false;
                          ctr
                              .saveCareerDetails(
                                weakness: weaknessController.text,
                              )
                              .then((bool? value) {
                                if (value == null || value == false) {
                                  weaknessController.text =
                                      career?.weakness ?? '';
                                }
                              });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          textWid(
                            AppStrings.plan,
                            style: AppTextStyles.textStyle(
                              fontSize: getWidth(18),
                              fontWeight: FontWeight.w600,
                              txtColor: AppColors.blueColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _addNewPlan(),
                            child: Container(
                              padding: EdgeInsets.all(getWidth(4)),
                              decoration: const BoxDecoration(
                                color: AppColors.blueColor,
                                shape: BoxShape.circle,
                              ),
                              child: assetImage(
                                image: AppAssets.add,
                                fit: BoxFit.contain,
                                customWidth: 21,
                              ),
                            ),
                          ),
                        ],
                      ).paddingOnly(top: getHeight(16)),
                      if (plans.isEmpty)
                        Center(
                          child: textWid(
                            AppStrings.noPlanHerePleaseAdd,
                            maxlines: 3,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.textStyle(
                              fontSize: getWidth(16),
                              fontWeight: FontWeight.w400,
                              txtColor: AppColors.textColor,
                            ),
                          ),
                        ).paddingOnly(top: getHeight(16)),
                      Obx(
                        () => ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: plans.length,
                          itemBuilder: (context, index) {
                            return _buildPlanItem(plans[index], index + 1);
                          },
                        ),
                      ).paddingOnly(top: getHeight(8)),
                      materialButtonWithChild(
                        width: double.infinity,
                        onPressed: () {
                          if (goalController.text.trim().isEmpty) {
                            commonSnackBar(
                              message:
                                  "Before using AI Magic, please define your goal first! 🎯",
                            );
                          } else if (career != null) {
                            handleAiMagicButtonClick(career!);
                          } else {
                            commonSnackBar(
                              message:
                                  "Career data is not available. Please try again later.",
                            );
                          }
                        },
                        child: textWid(
                          AppStrings.aIMagic,
                          style: AppTextStyles.textStyle(
                            fontSize: getWidth(18),
                            fontWeight: FontWeight.w600,
                            txtColor: AppColors.white,
                          ),
                        ),
                        color: AppColors.blueColor,
                        padding: EdgeInsets.only(
                          top: getHeight(12),
                          bottom: getHeight(12),
                        ),
                      ).paddingOnly(
                        top: getHeight(32),
                        left: getWidth(32),
                        right: getWidth(32),
                      ),
                      materialButtonWithChild(
                        width: double.infinity,
                        onPressed: () => vadSquadeReview(),
                        child: textWid(
                          AppStrings.vadSquadReview,
                          style: AppTextStyles.textStyle(
                            fontSize: getWidth(18),
                            fontWeight: FontWeight.w600,
                            txtColor: AppColors.textColor,
                          ),
                        ),
                        color: AppColors.colorFFE734,
                        padding: EdgeInsets.only(
                          top: getHeight(12),
                          bottom: getHeight(12),
                        ),
                      ).paddingOnly(
                        top: getHeight(16),
                        left: getWidth(32),
                        right: getWidth(32),
                      ),
                    ],
                  ).paddingOnly(
                    left: getWidth(16),
                    right: getWidth(16),
                    bottom: getHeight(32),
                  ),
                ),
      ),
    );
  }

  Widget _buildPlanItem(Plans item, int i) {
    TextEditingController careerPathController = TextEditingController(
      text: item.careerPath,
    );
    TextEditingController industryController = TextEditingController(
      text: item.industry,
    );
    int index = career?.plans?.indexOf(item) ?? -1;
    return Container(
      margin: EdgeInsets.only(top: getHeight(16)),
      padding: EdgeInsets.all(getWidth(12)),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(
        () => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Plan $i',
                  style: TextStyle(
                    fontSize: getWidth(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueColor,
                  ),
                ),
                plans.length > 1
                    ? GestureDetector(
                      onTap: () => _removePlan(item),
                      child: const Icon(Icons.close, color: AppColors.red),
                    )
                    : const SizedBox.shrink(),
              ],
            ),
            Column(
              children: [
                Text(
                  AppStrings.industry,
                  style: TextStyle(
                    fontSize: getWidth(18),
                    fontWeight: FontWeight.bold,
                  ),
                ).paddingOnly(top: getHeight(16)),
                commonTextFiled(
                  hintText: AppStrings.industry,
                  borderRadius: 0,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: AppColors.grey,
                  onChanged: (p0) {
                    if (index != -1) {
                      if (career?.plans?[index].industry == p0) {
                        item.isIndustryChanged.value = false;
                      } else {
                        item.isIndustryChanged.value = true;
                      }
                    } else {
                      item.isIndustryChanged.value = true;
                    }
                  },
                  controller: industryController,
                  maxLines: 1,
                ).paddingOnly(top: getHeight(6)),
              ],
            ),
            Column(
              children: [
                Text(
                  AppStrings.careerPath,
                  style: TextStyle(
                    fontSize: getWidth(18),
                    fontWeight: FontWeight.bold,
                  ),
                ).paddingOnly(top: getHeight(16)),
                commonTextFiled(
                  hintText: AppStrings.careerPathSteps,
                  borderRadius: 0,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: AppColors.grey,
                  onChanged: (p0) {
                    if (index != -1) {
                      if (career?.plans?[index].careerPath == p0) {
                        item.isCareerPathChanged.value = false;
                      } else {
                        item.isCareerPathChanged.value = true;
                        // item.careerPath = p0;
                      }
                    } else {
                      item.isCareerPathChanged.value = true;
                    }
                  },
                  controller: careerPathController,
                  maxLines: 7,
                ).paddingOnly(top: getHeight(6)),
              ],
            ),
            if (item.isCareerPathChanged.value || item.isIndustryChanged.value)
              materialButtonWithChild(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (industryController.text.trim().isEmpty ?? true) {
                    commonSnackBar(message: "Please enter the industry!");
                    return;
                  }
                  if (careerPathController.text.trim().isEmpty ?? true) {
                    commonSnackBar(message: "Please enter the career path!");
                    return;
                  }
                  item.careerPath = careerPathController.text;
                  item.industry = industryController.text;
                  item.isCareerPathChanged.value = false;
                  item.isIndustryChanged.value = false;
                  ctr.saveCareerDetails(plans: plans).then((bool? value) {
                    if (value == null || value == false) {
                      item.isCareerPathChanged.value = true;
                      item.isIndustryChanged.value = true;
                    }
                  });
                },
                child: textWid(
                  AppStrings.saveChanges,
                  style: AppTextStyles.textStyle(
                    fontSize: getWidth(18),
                    fontWeight: FontWeight.w600,
                    txtColor: AppColors.white,
                  ),
                ),
                color: AppColors.blueColor,
                padding: EdgeInsets.only(
                  top: getHeight(12),
                  bottom: getHeight(12),
                  left: getWidth(16),
                  right: getWidth(16),
                ),
              ).paddingOnly(top: getHeight(16)),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleTextField({
    required String title,
    required String hintText,
    int maxLine = 1,
    Function(String)? onChanged,
    TextEditingController? controller,
    Function()? onTap,
    bool saveBtn = true,
    RxBool? changed,
  }) {
    Widget buildContent() {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: getWidth(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (saveBtn)
                GestureDetector(
                  onTap: () => onTap == null ? null : onTap(),
                  child: Row(
                    children: [
                      if (controller != null &&
                          (changed != null && changed.value))
                        Icon(
                          Icons.check_circle,
                          color: AppColors.green,
                          size: getWidth(25),
                        ).paddingOnly(right: getWidth(8)),
                      assetImage(image: AppAssets.edit, customWidth: 24),
                    ],
                  ),
                ),
            ],
          ).paddingOnly(top: getHeight(16)),
          commonTextFiled(
            hintText: hintText,
            borderRadius: 0,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.grey,
            onChanged: onChanged,
            controller: controller,
            maxLines: maxLine,
          ).paddingOnly(top: getHeight(6)),
        ],
      );
    }

    return (changed != null && saveBtn)
        ? Obx(() => buildContent())
        : buildContent();
  }

  void careerGamesRules() {
    Get.dialog(
      AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            textWid(
              "Main Rule",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(Icons.close, color: AppColors.red),
            ),
          ],
        ),
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Acknowledging that the world is advancing rapidly in technology, business, and the economy, we also recognize that students today have a greater capacity to learn complex concepts like AI.',
            ),
            SizedBox(height: 8),
            Text(
              'It is essential to provide real-world knowledge about businesses, professions, challenges, and solutions so that students are well-prepared to face the real world by the time they complete school.',
            ),
            SizedBox(height: 8),
            Text(
              'The primary reason for Ethical Learning is to foster a collaborative learning environment where students can research, learn from one another, and share knowledge. ',
            ),
            SizedBox(height: 8),
            Text(
              'Teachers and VAD Squad members will contribute valuable real-world insights through starred compendiums in the Ethical Learning tab, ensuring a rich and practical learning experience.',
            ),
          ],
        ),
      ),
    );
  }

  void vadSquadeReview() {
    Get.dialog(
      AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            textWid(
              AppStrings.vadSquadReview,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
            commonTextFiled(
              controller: vadSquadReview,
              hintText: AppStrings.writeYourQueryHere,
              maxLines: 8,
              fontSize: 12,
              hintStyle: const TextStyle(
                fontSize: 12,
                color: AppColors.textColor,
                fontWeight: FontWeight.w400,
              ),
              backgroundColor: AppColors.color949494.withOpacity(0.2),
              borderRadius: getWidth(12),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // if (item.amount != null)
                // (item.amount ?? 0) > 0
                // ? textWid('Price: ₹${formatDouble(item.amount)}',
                //     style: TextStyle(
                //         fontSize: getWidth(12),
                //         color: AppColors.textColor,
                //         fontWeight: FontWeight.w400))
                // : textWid('Price: free',
                //     style: TextStyle(
                //         fontSize: getWidth(12),
                //         color: AppColors.textColor,
                //         fontWeight: FontWeight.w400)),
                textWid(
                  'Price: free',
                  style: TextStyle(
                    fontSize: getWidth(12),
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                materialButtonWithChild(
                  color: AppColors.blueColor,
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    // if (item.amount != null && (item.amount ?? 0) > 0) {
                    //   registerWebinar(item.webinarId ?? '');
                    //   Get.back();
                    // } else {
                    //   Get.toNamed(RouteName.plansScreen);
                    // }
                    submitVADSquadReviews(vadSquadReview.text.trim());
                    vadSquadReview.clear();
                    Get.back();
                  },
                  child: textWid(
                    'Register',
                    style: TextStyle(
                      color: AppColors.white, // Or your desired color
                      fontWeight: FontWeight.bold,
                      fontSize: getWidth(16),
                    ),
                  ).paddingOnly(left: getWidth(16), right: getWidth(16)),
                ),
              ],
            ).paddingOnly(top: getHeight(16)),
          ],
        ),
      ),
    );
  }

  //! AI Magic Logic
  void handleAiMagicButtonClick(CareerDashboardModel careerData) {
    // Step 1: Show first popup for section and planId selection
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Choose any one for AI Integration',
                        style: TextStyle(
                          fontSize: getWidth(16),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.visible,
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(width: getWidth(4)),
                    InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(getWidth(4)),
                        child: Icon(
                          Icons.close,
                          size: getWidth(18),
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: getHeight(10)),
              ],
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: getWidth(16),
              vertical: getHeight(10),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Goal option
                _buildSelectionOption(
                  context: context,
                  title: 'Goal',
                  onTap: () {
                    Get.back();
                    _showSecondPopup(section: 'goal', planId: null);
                  },
                ),

                // Plans options - Use the current plans list instead of careerData.plans
                if (plans.isNotEmpty)
                  ...List.generate(
                    plans.length,
                    (index) => _buildSelectionOption(
                      context: context,
                      title: 'Plan - ${index + 1} with Goal',
                      onTap: () {
                        Get.back();
                        _showSecondPopup(
                          section: 'plan',
                          planId: plans[index].sId,
                        );
                      },
                    ),
                  ),

                // Overall plans option
                _buildSelectionOption(
                  context: context,
                  title: 'Overall plans with Goal',
                  onTap: () {
                    Get.back();
                    _showSecondPopup(section: 'plan', planId: null);
                  },
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(getWidth(16)),
            ),
          ),
    );
  }

  Widget _buildSelectionOption({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: getHeight(10)),
        padding: EdgeInsets.symmetric(
          vertical: getHeight(12),
          horizontal: getWidth(16),
        ),
        decoration: BoxDecoration(
          color: AppColors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(getWidth(8)),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: getWidth(15), fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showSecondPopup({required String section, String? planId}) {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Now Choose an action',
                      style: TextStyle(
                        fontSize: getWidth(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: getHeight(10)),
              ],
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: getWidth(16),
              vertical: getHeight(10),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSelectionOption(
                  context: context,
                  title: 'Available Competitions',
                  onTap:
                      () => _generatePrompt(
                        section,
                        planId,
                        'Available Competitions',
                        context,
                      ),
                ),
                _buildSelectionOption(
                  context: context,
                  title: 'Best way of attaining the goal',
                  onTap:
                      () => _generatePrompt(
                        section,
                        planId,
                        'Best way of attaining the goal',
                        context,
                      ),
                ),
                _buildSelectionOption(
                  context: context,
                  title: 'Comparison of all plans',
                  onTap:
                      () => _generatePrompt(
                        section,
                        planId,
                        'Comparison of all plans',
                        context,
                      ),
                ),
                _buildSelectionOption(
                  context: context,
                  title: 'Raise a question with the path',
                  onTap:
                      () => _generatePrompt(
                        section,
                        planId,
                        'Raise a question with the path',
                        context,
                      ),
                ),
                _buildSelectionOption(
                  context: context,
                  title: 'Skills needed to be learned',
                  onTap:
                      () => _generatePrompt(
                        section,
                        planId,
                        'Skills needed to be learned',
                        context,
                      ),
                ),
                _buildSelectionOption(
                  context: context,
                  title: 'Today\'s Demands for the path',
                  onTap:
                      () => _generatePrompt(
                        section,
                        planId,
                        'Today\'s Demands for the path',
                        context,
                      ),
                ),
                _buildSelectionOption(
                  context: context,
                  title: 'Is this a formidable plan?',
                  onTap:
                      () => _generatePrompt(
                        section,
                        planId,
                        'Is this a formidable plan?',
                        context,
                      ),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(getWidth(16)),
            ),
          ),
    );
  }

  Future<void> _generatePrompt(
    String section,
    String? planId,
    String selectedOption,
    BuildContext context,
  ) async {
    final BuildContext navigatorContext = Navigator.of(context).context;
    Get.back();
    Get.dialog(
      Center(
        child: commonLoader(
          customHeight: getHeight(50),
          customWidth: getWidth(50),
        ),
      ),
      barrierDismissible: false,
    );

    final CareerGamesController controller = Get.find<CareerGamesController>();

    try {
      final String? prompt = await controller.generateCareerDashboardPrompt(
        section: section,
        planId: planId,
        selectedOption: selectedOption,
      );

      Get.back();
      if (prompt != null) {
        await Clipboard.setData(ClipboardData(text: prompt));
        showPromptCopiedDialog(navigatorContext, () {
          Get.back();
          Get.toNamed(RouteNames.aiScreen);
        });
      } else {
        commonSnackBar(
          message: 'Failed to generate prompt. Please try again.',
          color: Colors.red,
        );
      }
    } catch (e) {
      Get.back();
      commonSnackBar(
        message: 'An error occurred. Please try again.',
        color: Colors.red,
      );
      log('Error generating prompt: $e');
    }
  }
}
