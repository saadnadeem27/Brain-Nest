import 'package:Vadai/controller/student/careergames_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/job_role_model.dart';
import 'package:Vadai/model/students/webinars_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_svg/svg.dart';

import '../../../common_imports.dart';

class CareerGames extends StatefulWidget {
  const CareerGames({super.key});

  @override
  State<CareerGames> createState() => _CareerGamesState();
}

class _CareerGamesState extends State<CareerGames> {
  CareerGamesController ctr = Get.find<CareerGamesController>();
  RxInt selectedFilter = 0.obs;
  RxBool _loadingJobRole = false.obs;
  RxBool isLoadingMoreJobRole = false.obs;
  Rx<JobRoleCategory?> selectedCategory = Rx<JobRoleCategory?>(null);
  TextEditingController searchController = TextEditingController();
  CancelToken cancelToken = CancelToken();
  final ScrollController scrollController = ScrollController();
  TextEditingController jobRoleSuggestion = TextEditingController();
  TextEditingController webinarSuggestion = TextEditingController();
  TextEditingController webinarRegister = TextEditingController();
  RxInt pageNumber = 2.obs;
  List<String> filters = ["National", "Global"];

  @override
  void initState() {
    super.initState();
    initData();
    scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    scrollController.dispose();
    cancelToken.cancel();
    jobRoleSuggestion.dispose();
    searchController.dispose();
    webinarRegister.dispose();
    webinarSuggestion.dispose();
    super.dispose();
  }

  initData() {
    if (ctr.jobRoleCategoryList.isEmpty) {
      return;
    }
    selectedCategory.value = ctr.jobRoleCategoryList.first;
  }

  void saveJobRole({required String id}) async {
    await ctr.jobRoleSaved(id: id);
  }

  void submitJobRoleSuggestion(String suggestion) async {
    if (jobRoleSuggestion.text == '') {
      commonSnackBar(message: 'Please enter a suggestion');
      return;
    }
    if (suggestion != '') {
      await ctr.jobRoleSuggestion(suggestion: suggestion);
      jobRoleSuggestion.clear();
    } else {
      commonSnackBar(message: 'Please enter a suggestion');
    }
  }

  void webinarSuggestionMethod(String suggestion) async {
    if (webinarSuggestion.text == '') {
      commonSnackBar(message: 'Please enter a suggestion');
      return;
    }
    if (suggestion != '') {
      await ctr.webinarsSuggestion(suggestion: suggestion);
      webinarSuggestion.clear();
    } else {
      commonSnackBar(message: 'Please enter a suggestion');
    }
  }

  Future<void> registerWebinar(String id) async {
    await ctr.registerWebinars(question: webinarRegister.text, webinarId: id);
    webinarRegister.clear();
  }

  Future<void> switchJobRoleSubCategory() async {
    _loadingJobRole.value = true;
    cancelToken.cancel();
    cancelToken = CancelToken();
    try {
      await ctr.getJobRole(
        category: selectedCategory.value?.sId ?? '',
        range: filters[selectedFilter.value],
        searchTag: searchController.text,
        cancelToken: cancelToken,
      );
    } finally {
      _loadingJobRole.value = false;
    }
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadMoreJobRole();
    }
  }

  Future<void> loadMoreJobRole() async {
    if (ctr.hasNextJobRolePage.value) {
      isLoadingMoreJobRole.value = true;
      try {
        await ctr
            .getJobRole(
              category: selectedCategory.value?.sId ?? '',
              range: filters[selectedFilter.value],
              searchTag: searchController.text,
              cancelToken: cancelToken,
              pageNumber: pageNumber.value,
            )
            .then((value) {
              if (value != null) {
                pageNumber.value++;
              }
            });
      } catch (e) {
        log('Error in loadMoreJobRole: $e');
      } finally {
        isLoadingMoreJobRole.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: commonScaffold(
        context: context,
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: getHeight(70)),
              child: Obx(
                () =>
                    ctr.isLoading.value
                        ? commonLoader()
                        : SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: materialButtonWithChild(
                                  width: double.infinity,
                                  onPressed:
                                      () => Get.toNamed(
                                        RouteNames.careerDashboard,
                                      ),
                                  child: textWid(
                                    AppStrings.dashboard,
                                    style: TextStyle(
                                      color:
                                          AppColors
                                              .white, // Or your desired color
                                      fontWeight: FontWeight.bold,
                                      fontSize: getWidth(16),
                                    ),
                                  ).paddingOnly(
                                    top: getHeight(16),
                                    bottom: getHeight(16),
                                  ),
                                ).paddingOnly(
                                  top: getHeight(48),
                                  left: getWidth(16),
                                  right: getWidth(16),
                                ),
                              ),
                              textWid(
                                AppStrings.webinars,
                                style: TextStyle(
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: getWidth(24),
                                ),
                              ).paddingOnly(
                                top: getHeight(16),
                                left: getWidth(16),
                              ),
                              if (ctr.webinarsList.length > 0)
                                SizedBox(
                                  height: getHeight(
                                    430,
                                  ), // Adjust height as needed
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: getWidth(16),
                                    ),
                                    itemCount:
                                        ctr
                                            .webinarsList
                                            .length, // Change this to your actual number of webinars
                                    itemBuilder: (context, index) {
                                      return Container(
                                        width: getWidth(
                                          300,
                                        ), // Adjust card width as needed
                                        margin: EdgeInsets.only(
                                          right: getWidth(16),
                                        ),
                                        child: _buildWebinarCard(
                                          ctr.webinarsList[index],
                                        ),
                                      );
                                    },
                                  ),
                                ).paddingOnly(top: getHeight(16)),
                              Center(
                                child: materialButtonWithChild(
                                  borderColor: AppColors.black,
                                  color: AppColors.transparent,
                                  onPressed: () => suggestionsWebinarsDialog(),
                                  borderWidth: getWidth(1),
                                  child: textWid(
                                    AppStrings.suggestions,
                                    style: TextStyle(
                                      color:
                                          AppColors
                                              .textColor, // Or your desired color
                                      fontWeight: FontWeight.bold,
                                      fontSize: getWidth(21),
                                    ),
                                  ).paddingOnly(
                                    left: getWidth(18),
                                    right: getWidth(18),
                                  ),
                                ),
                              ).paddingOnly(top: getHeight(24)),
                              commonHeadingWithDivider(
                                text: ApiParameter.jobRoles,
                              ).paddingOnly(
                                top: getHeight(24),
                                left: getWidth(16),
                                right: getWidth(16),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: _buildFilterTabs(),
                              ).paddingOnly(
                                top: getHeight(24),
                                left: getWidth(21),
                                right: getWidth(21),
                              ),
                              _buildCategory().paddingOnly(top: getHeight(24)),
                              commonTextFiled(
                                controller: searchController,
                                hintText: AppStrings.searchHere,
                                onEditingComplete: () {
                                  switchJobRoleSubCategory();
                                },
                                onChanged: (value) {
                                  switchJobRoleSubCategory();
                                },
                                hintStyle: AppTextStyles.textStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                contentPadding: EdgeInsets.only(
                                  left: getWidth(16),
                                ),
                                suffixWidget: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.blueColor,
                                  ),
                                  child: assetImage(
                                    image: AppAssets.search,
                                    customWidth: 35,
                                    customHeight: 35,
                                  ),
                                ),
                              ).paddingOnly(
                                top: getHeight(24),
                                left: getWidth(21),
                                right: getWidth(21),
                              ),
                              if (_loadingJobRole.value) ...{
                                Align(
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator()
                                      .paddingOnly(top: getHeight(24)),
                                ),
                              } else ...{
                                _buildJobRole().paddingOnly(top: getHeight(8)),
                                if (isLoadingMoreJobRole.value)
                                  Align(
                                    alignment: Alignment.center,
                                    child: const CircularProgressIndicator()
                                        .paddingOnly(top: getHeight(24)),
                                  ),
                              },
                              Center(
                                child: materialButtonWithChild(
                                  borderColor: AppColors.black,
                                  color: AppColors.transparent,
                                  borderWidth: getWidth(1),
                                  onPressed: () => suggestionsJobRoleDialog(),
                                  child: textWid(
                                    AppStrings.suggestions,
                                    style: TextStyle(
                                      color:
                                          AppColors
                                              .textColor, // Or your desired color
                                      fontWeight: FontWeight.bold,
                                      fontSize: getWidth(21),
                                    ),
                                  ).paddingOnly(
                                    left: getWidth(18),
                                    right: getWidth(18),
                                  ),
                                ),
                              ).paddingOnly(top: getHeight(24)),
                              Center(
                                child: materialButtonWithChild(
                                  borderColor: AppColors.black,
                                  color: AppColors.transparent,
                                  borderWidth: getWidth(1),
                                  onPressed:
                                      () =>
                                          Get.toNamed(RouteNames.savedJobRoles),
                                  child: textWid(
                                    AppStrings.savedCareerRoles,
                                    style: TextStyle(
                                      color:
                                          AppColors
                                              .textColor, // Or your desired color
                                      fontWeight: FontWeight.bold,
                                      fontSize: getWidth(21),
                                    ),
                                  ).paddingOnly(
                                    left: getWidth(18),
                                    right: getWidth(18),
                                  ),
                                ),
                              ).paddingOnly(top: getHeight(24)),
                            ],
                          ).paddingOnly(bottom: getHeight(28)),
                        ),
              ),
            ),
            studentsTabAppBar(title: AppStrings.careerGame),
          ],
        ),
      ),
    );
  }

  Widget _buildWebinarCard(WebinarsModel? item) {
    if (item == null || item.sId == null) return const SizedBox();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.color949494.withOpacity(0.2),
        borderRadius: BorderRadius.circular(getWidth(12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(getWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(getWidth(12)),
                border: Border.all(color: AppColors.black, width: getWidth(1)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: getWidth(16),
                  right: getWidth(16),
                  bottom: getHeight(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.industry != null || item.industry != '')
                      textWid(
                        item.industry ?? '',
                        style: TextStyle(
                          fontSize: getWidth(16),
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ).paddingOnly(bottom: getHeight(6), top: getHeight(6)),
                    AspectRatio(
                      aspectRatio: getWidth(5) / getHeight(4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(getWidth(12)),
                        child:
                            item.coverImage != null &&
                                    item.coverImage!.isNotEmpty
                                ? (item.coverImage!.toLowerCase().endsWith(
                                      '.svg',
                                    )
                                    ? SvgPicture.network(
                                      item.coverImage!,
                                      width: getWidth(100),
                                      fit: BoxFit.contain,
                                      placeholderBuilder:
                                          (BuildContext context) => Center(
                                            child: SizedBox(
                                              width: getWidth(30),
                                              height: getWidth(30),
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                    )
                                    : CachedNetworkImage(
                                      imageUrl: item.coverImage!,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => Container(
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                      errorWidget:
                                          (context, url, error) => Container(
                                            color: Colors.grey[300],
                                            child: Icon(
                                              Icons.error_outline,
                                              size: getWidth(40),
                                              color: Colors.red,
                                            ),
                                          ),
                                      // Enable memory caching
                                      memCacheWidth: 800,
                                      memCacheHeight: 600,
                                    ))
                                : assetImage(
                                  image: AppAssets.ethicalImg,
                                  fit: BoxFit.cover,
                                ),
                      ),
                    ),
                    if (item.title != null || item.title != '')
                      textWid(
                        item.title ?? '',
                        style: TextStyle(
                          fontSize: getWidth(16),
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ).paddingOnly(bottom: getHeight(6), top: getHeight(6)),
                    if (item.hostName != null || item.hostName != '')
                      textWid(
                        item.hostName ?? '',
                        style: TextStyle(
                          fontSize: getWidth(16),
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.dateAndTime != null ||
                        item.dateAndTime != '' ||
                        formatDate(item.dateAndTime ?? '') != '')
                      textWid(
                        formatDate(item.dateAndTime ?? ''),
                        style: TextStyle(
                          fontSize: getWidth(16),
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (item.dateAndTime != null ||
                        item.dateAndTime != '' ||
                        getWeekday(item.dateAndTime ?? '') != '')
                      textWid(
                        getWeekday(item.dateAndTime ?? ''),
                        style: TextStyle(
                          fontSize: getWidth(16),
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                materialButtonWithChild(
                  borderRadius: getWidth(12),
                  onPressed: () => registerDialog(item),
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
            ).paddingOnly(top: getHeight(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textWid(
                  AppStrings.time,
                  style: TextStyle(
                    fontSize: getWidth(16),
                    color: AppColors.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.people_alt_outlined,
                      color: AppColors.textColor,
                      size: getWidth(21),
                    ),
                    if (item.dateAndTime != null ||
                        item.dateAndTime != '' ||
                        getTime(item.dateAndTime ?? '') != '')
                      textWid(
                        ': ${getTime(item.dateAndTime ?? '')}',
                        style: TextStyle(
                          fontSize: getWidth(14),
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ).paddingOnly(top: getHeight(6)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        textWid(
          'Category: \t',
          style: AppTextStyles.textStyle(
            fontSize: getWidth(21),
            fontWeight: FontWeight.w700,
            txtColor: AppColors.textColor3,
          ),
        ),
        Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                showDynamicMenuStatus(
                  context: context,
                  selectedStatusIndex: ctr.jobRoleCategoryList.indexOf(
                    selectedCategory.value,
                  ),
                  list:
                      ctr.jobRoleCategoryList
                          .map((e) => e?.categoryName ?? '')
                          .toList(),
                  onItemSelected: (index) async {
                    selectedCategory.value = ctr.jobRoleCategoryList[index];
                    await switchJobRoleSubCategory();
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(16),
                  vertical: getHeight(8),
                ),
                decoration: BoxDecoration(
                  color: AppColors.color7D818A,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                // width: getWidth(110),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Row(
                            children: [
                              textWid(
                                selectedCategory.value?.categoryName ?? '',
                                style: AppTextStyles.textStyle(
                                  txtColor: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ).paddingOnly(right: getWidth(4)),
                              const Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: AppColors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: getHeight(30),
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            itemBuilder: (context, index) {
              // bool isSelected = selectedFilter.value == index;
              return Obx(
                () => GestureDetector(
                  onTap: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    selectedFilter.value = index;
                    await switchJobRoleSubCategory();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: getWidth(10)),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: getWidth(5)),
                      decoration: BoxDecoration(
                        color:
                            selectedFilter.value == index
                                ? AppColors.blueColor
                                : AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            selectedFilter.value == index
                                ? Border.all(
                                  color: AppColors.blueColor,
                                  width: 1,
                                )
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          filters[index],
                          style: TextStyle(
                            color:
                                selectedFilter.value == index
                                    ? AppColors.white
                                    : AppColors.textColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildJobRole() {
    if (ctr.jobRoleList.isEmpty) {
      return Center(
        child: textWid(
          AppStrings.nothingHereTryAgain,
          style: TextStyle(
            fontSize: getWidth(16),
            color: AppColors.textColor,
            fontWeight: FontWeight.w500,
          ),
        ).paddingOnly(top: getHeight(16)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ctr.jobRoleList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => jobRoleDialog(ctr.jobRoleList[index]),
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
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: textWid(
                ctr.jobRoleList[index]?.jobRole ?? '',
                style: TextStyle(
                  fontSize: getWidth(13),
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w500,
                ),
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

  void registerDialog(WebinarsModel? item) {
    if (item == null || item.sId == null) return;
    Get.dialog(
      AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            textWid(
              AppStrings.registration,
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
              controller: webinarRegister,
              hintText: AppStrings.writeYourQuestionHere,
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
                if (item.amount != null)
                  (item.amount ?? 0) > 0
                      ? textWid(
                        'Price: ₹${formatDouble(item.amount)}',
                        style: TextStyle(
                          fontSize: getWidth(12),
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                      : textWid(
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
                    if (item.amount != null && (item.amount ?? 0) <= 0) {
                      registerWebinar(item.webinarId ?? '');
                      Get.back();
                    } else {
                      Get.toNamed(RouteNames.plansScreen);
                    }
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

  void suggestionsWebinarsDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Expanded(
              child: textWid(
                AppStrings.suggestionsforWebinarSpeaker,
                maxlines: 2,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
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
            commonTextFiled(
              controller: webinarSuggestion,
              hintText: 'Add some of your own suggestions',
              hintStyle: AppTextStyles.textStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: EdgeInsets.only(left: getWidth(16)),
              suffixWidget: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blueColor,
                ),
                child: assetImage(
                  image: AppAssets.add,
                  customWidth: 35,
                  customHeight: 35,
                ),
              ),
            ),
            materialButtonWithChild(
              color: AppColors.blueColor,
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                webinarSuggestionMethod(webinarSuggestion.text);
                Get.back();
              },
              child: textWid(
                AppStrings.save,
                style: TextStyle(
                  color: AppColors.white, // Or your desired color
                  fontWeight: FontWeight.bold,
                  fontSize: getWidth(16),
                ),
              ).paddingOnly(left: getWidth(16), right: getWidth(16)),
            ).paddingOnly(top: getHeight(16)),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Note: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                      fontSize: getWidth(14),
                    ),
                  ),
                  TextSpan(
                    text:
                        'Please enter the name of the Speaker or the industry or the topic you want to be discussed in the upcoming seminars, we’ll arrange them for you.',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: getWidth(13),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).paddingOnly(top: getHeight(16)),
          ],
        ),
      ),
    );
  }

  void suggestionsJobRoleDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Expanded(
              child: textWid(
                AppStrings.suggestionsforCareerRole,
                maxlines: 2,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
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
            commonTextFiled(
              controller: jobRoleSuggestion,
              hintText: 'Add some of your own suggestions',
              hintStyle: AppTextStyles.textStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: EdgeInsets.only(left: getWidth(16)),
              suffixWidget: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blueColor,
                ),
                child: assetImage(
                  image: AppAssets.add,
                  customWidth: 35,
                  customHeight: 35,
                ),
              ),
            ),
            materialButtonWithChild(
              color: AppColors.blueColor,
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                submitJobRoleSuggestion(jobRoleSuggestion.text);
                Get.back();
              },
              child: textWid(
                AppStrings.save,
                style: TextStyle(
                  color: AppColors.white, // Or your desired color
                  fontWeight: FontWeight.bold,
                  fontSize: getWidth(16),
                ),
              ).paddingOnly(left: getWidth(16), right: getWidth(16)),
            ).paddingOnly(top: getHeight(16)),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Note: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                      fontSize: getWidth(14),
                    ),
                  ),
                  TextSpan(
                    text:
                        'Please enter a career role regarding ${selectedCategory.value?.categoryName} that you would like to explore so that the VAD Squad members can gather the details from the industry for you.',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: getWidth(13),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).paddingOnly(top: getHeight(16)),
          ],
        ),
      ),
    );
  }

  void jobRoleDialog(JobRoleModel? item) {
    if (item == null) return;
    Get.dialog(
      AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            textWid(
              AppStrings.careerRoleDescription,
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
            textWid(
              item.description ?? '',
              textAlign: TextAlign.center,
              maxlines: 15,
            ),
            materialButtonWithChild(
              color: AppColors.blueColor,
              onPressed: () => Get.back(),
              child: textWid(
                AppStrings.aIMagic,
                style: TextStyle(
                  color: AppColors.white, // Or your desired color
                  fontWeight: FontWeight.bold,
                  fontSize: getWidth(16),
                ),
              ).paddingOnly(left: getWidth(16), right: getWidth(16)),
            ).paddingOnly(top: getHeight(28)),
            materialButtonWithChild(
              color: AppColors.blueColor,
              onPressed: () {
                saveJobRole(id: item.sId ?? '');
                Get.back();
              },
              child: textWid(
                AppStrings.save,
                style: TextStyle(
                  color: AppColors.white, // Or your desired color
                  fontWeight: FontWeight.bold,
                  fontSize: getWidth(16),
                ),
              ).paddingOnly(left: getWidth(16), right: getWidth(16)),
            ).paddingOnly(top: getHeight(16)),
          ],
        ),
      ),
    );
  }
}
