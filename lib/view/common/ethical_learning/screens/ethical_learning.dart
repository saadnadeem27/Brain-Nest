import 'package:Vadai/controller/common/ethical_learning_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/compendia_model.dart';
import 'package:Vadai/view/common/ethical_learning/widgets/compendia_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

import '../../../../common_imports.dart';

class EthicalLearning extends StatefulWidget {
  final bool fromTeachers;

  const EthicalLearning({super.key, this.fromTeachers = false});

  @override
  State<EthicalLearning> createState() => _EthicalLearningState();
}

class _EthicalLearningState extends State<EthicalLearning>
    with SingleTickerProviderStateMixin {
  EthicalLearningController ethicalCtr = Get.find();
  Rx<CompendiaCategoryModel?> selectedCategory = Rx<CompendiaCategoryModel?>(
    null,
  );
  Rx<CompendiaSubCategoryModel?> selectedSubcategory =
      Rx<CompendiaSubCategoryModel?>(null);
  final ScrollController scrollController = ScrollController();
  RxInt currentPage = 2.obs;
  RxBool isLoadingSUbCategories = false.obs;
  RxBool isLoadingCompendia = false.obs;
  TextEditingController searchController = TextEditingController();
  CancelToken cancelToken = CancelToken();
  RxBool isSearch = false.obs;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _categoryAnimation;
  late Animation<double> _searchAnimation;

  // Track if animations have been played
  final RxBool _animationsInitialized = false.obs;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);

    // Initialize animation controller with same duration as other screens
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Create animations for different UI elements
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    _categoryAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOutQuart),
      ),
    );

    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Initialize animations when data is loaded
    ever(ethicalCtr.isLoading, (isLoading) {
      if (!isLoading && !_animationsInitialized.value && mounted) {
        _initializeAnimations();
      }
    });

    // Handle case where data is already loaded
    if (!ethicalCtr.isLoading.value && !_animationsInitialized.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        initData();
        _initializeAnimations();
      });
    } else {
      initData();
    }
  }

  void _initializeAnimations() {
    _animationsInitialized.value = true;
    _animationController.forward();
  }

  @override
  void dispose() {
    scrollController.dispose();
    cancelToken.cancel();
    _animationController.dispose();
    super.dispose();
  }

  initData() {
    if (ethicalCtr.categories.isEmpty || ethicalCtr.subCategories.isEmpty) {
      return;
    }
    selectedCategory.value = ethicalCtr.categories.first;
    selectedSubcategory.value = ethicalCtr.subCategories.first;
  }

  loadSubCategories(String categoryId) async {
    isLoadingSUbCategories.value = true;
    try {
      await ethicalCtr.getSubCategories(categoryId: categoryId).then((
        value,
      ) async {
        if (ethicalCtr.subCategories.isEmpty) {
          log('No subcategories found for category $categoryId');
          return;
        }
        final firstSubCategoryId = ethicalCtr.subCategories.first?.sId;
        if (firstSubCategoryId == null || firstSubCategoryId.isEmpty) {
          log('Invalid first subcategory ID');
          return;
        }
        selectedSubcategory.value = ethicalCtr.subCategories.first;
        await ethicalCtr.getAllCompendia(
          category: categoryId,
          subCategory: firstSubCategoryId,
        );
      });
    } catch (e) {
      log('Error in loadSubCategories: $e');
    } finally {
      isLoadingSUbCategories.value = false;
    }
  }

  loadCompendia({String? category, String? subCategory}) async {
    isLoadingCompendia.value = true;
    log(
      'loadCompendia called with category: ${selectedCategory.value?.name}, subCategory: ${selectedSubcategory.value?.name}',
    );
    cancelToken.cancel();
    cancelToken = CancelToken();
    if (category == null || subCategory == null) {
      category = selectedCategory.value?.sId;
      subCategory = selectedSubcategory.value?.sId;
    }
    if (category == null || subCategory == null) {
      log('Invalid category or subcategory ID');
      return;
    }
    try {
      await ethicalCtr.getAllCompendia(
        category: category,
        subCategory: subCategory,
        cancelToken: cancelToken,
      );
    } catch (e) {
      log('Error in loadCompendia: $e');
    } finally {
      isLoadingCompendia.value = false;
    }
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadMoreCompendia();
    }
  }

  void loadMoreCompendia() async {
    if (ethicalCtr.hasNext.value) {
      String? category = selectedCategory.value?.sId;
      String? subCategory = selectedSubcategory.value?.sId;
      if (category == null || subCategory == null) {
        log('Invalid category or subcategory ID');
        return;
      }
      try {
        await ethicalCtr.getAllCompendia(
          category: category,
          subCategory: subCategory,
          pageNumber: currentPage.value,
        );
        currentPage.value++;
      } catch (e) {
        log('Error in loadCompendia: $e');
      }
    }
  }

  void searchCompendia({
    String? category,
    String? subCategory,
    required String searchTag,
  }) async {
    isSearch.value = true;
    cancelToken.cancel();
    cancelToken = CancelToken();
    if (category == null || subCategory == null) {
      category = selectedCategory.value?.sId;
      subCategory = selectedSubcategory.value?.sId;
    }
    if (category == null || subCategory == null) {
      log('Invalid category or subcategory ID');
      return;
    }
    try {
      await ethicalCtr.getAllCompendia(
        category: category,
        subCategory: subCategory,
        searchTag: searchTag,
        pageNumber: 1,
        cancelToken: cancelToken,
      );
      currentPage.value = 2;
    } catch (e) {
      log('Error in searchCompendia: $e');
    } finally {
      isSearch.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: commonScaffold(
        backgroundColor: AppColors.white,
        context: context,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: getHeight(70)),
                child: Obx(() {
                  if (ethicalCtr.isLoading.value) {
                    return commonLoader();
                  }
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        ScaleTransition(
                          scale: _headerAnimation,
                          child: _buildHeaderActions(),
                        ),
                        ScaleTransition(
                          scale: _categoryAnimation,
                          child: _buildCategory().paddingOnly(
                            top: getHeight(16),
                          ),
                        ),
                        if (isLoadingSUbCategories.value)
                          commonLoader(
                            customHeight: getHeight(100),
                            customWidth: getWidth(100),
                          ).paddingOnly(top: getHeight(100))
                        else ...{
                          _buildAnimatedSubCategoryTabs(),
                          ScaleTransition(
                            scale: _searchAnimation,
                            child: _buildSearchBar().paddingOnly(
                              top: getHeight(10),
                            ),
                          ),
                          if (isLoadingCompendia.value)
                            commonLoader(
                              customHeight: getHeight(100),
                              customWidth: getWidth(100),
                            ).paddingOnly(top: getHeight(100))
                          else
                            ethicalCtr.compendia.isEmpty
                                ? SizedBox(
                                  height: getHeight(350),
                                  child: Center(
                                    child: textWid(
                                      AppStrings.nothingHereTryAgain,
                                      style: AppTextStyles.textStyle(
                                        fontSize: getWidth(16),
                                        fontWeight: FontWeight.w700,
                                        txtColor: AppColors.textColor3,
                                      ),
                                    ),
                                  ),
                                )
                                : _buildAnimatedCompendiaGrid().paddingOnly(
                                  top: getHeight(16),
                                  bottom: getHeight(8),
                                ),
                        },
                      ],
                    ).paddingOnly(
                      left: getWidth(16),
                      right: getWidth(16),
                      top: getHeight(8),
                    ),
                  );
                }),
              ),
              if (widget.fromTeachers)
                teachersTabAppBar(title: AppStrings.ethicalLearning)
              else
                studentsTabAppBar(title: AppStrings.ethicalLearning),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap:
              () =>
                  Get.toNamed(RouteNames.uploadCompendia)?.then((value) async {
                    isLoadingSUbCategories.value = true;
                    initData();
                    await loadCompendia(
                      category: selectedCategory.value?.sId,
                      subCategory: selectedSubcategory.value?.sId,
                    );
                    isLoadingSUbCategories.value = false;
                  }),
          child: Container(
            padding: EdgeInsets.all(getWidth(8)),
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
        Column(
          children: [
            textWid(
              AppStrings.compendia,
              style: AppTextStyles.textStyle(
                fontSize: getWidth(21),
                fontWeight: FontWeight.w700,
                txtColor: AppColors.textColor3,
              ),
            ),
            assetImage(image: AppAssets.subjectDivider, customWidth: 130),
          ],
        ),
        GestureDetector(
          onTap: () => ethicalLearningRules(),
          child: Container(
            padding: EdgeInsets.all(getWidth(4)),
            decoration: const BoxDecoration(
              color: AppColors.color7D818A,
              shape: BoxShape.circle,
            ),
            child: assetImage(
              image: AppAssets.compendiaInfo,
              fit: BoxFit.contain,
              customWidth: 24,
            ),
          ),
        ),
      ],
    ).paddingOnly(top: getHeight(12), left: getWidth(16), right: getWidth(16));
  }

  Widget _buildSearchBar() {
    return commonTextFiled(
      controller: searchController,
      hintText: AppStrings.searchCompendia,
      onEditingComplete: () {
        searchCompendia(searchTag: searchController.text);
      },
      onChanged: (value) {
        searchCompendia(searchTag: value);
      },
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
          image: AppAssets.search,
          customWidth: 35,
          customHeight: 35,
        ),
      ),
    );
  }

  Widget _buildAnimatedSubCategoryTabs() {
    return SizedBox(
      height: getHeight(25),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ethicalCtr.subCategories.length,
        itemBuilder: (context, index) {
          // Animation for subcategory tab
          final tabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                0.25 + (index * 0.02).clamp(0.0, 0.4),
                0.55 + (index * 0.02).clamp(0.0, 0.4),
                curve: Curves.easeOutCubic,
              ),
            ),
          );

          final currentIndex = ethicalCtr.subCategories.indexOf(
            selectedSubcategory.value,
          );

          return ScaleTransition(
            scale: tabAnimation,
            child: Obx(
              () => GestureDetector(
                onTap: () {
                  if (isLoadingCompendia.value) return;
                  selectedSubcategory.value = ethicalCtr.subCategories[index];
                  loadCompendia();
                },
                child: Padding(
                  padding: EdgeInsets.only(right: getWidth(10)),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: getWidth(5)),
                    decoration: BoxDecoration(
                      color:
                          currentIndex == index
                              ? AppColors.blueColor
                              : AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          currentIndex == index
                              ? Border.all(color: AppColors.blueColor, width: 1)
                              : null,
                    ),
                    child: Center(
                      child: Text(
                        ethicalCtr.subCategories[index]?.name ?? '',
                        style: TextStyle(
                          color:
                              currentIndex == index
                                  ? AppColors.white
                                  : AppColors.textColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // New animated compendia grid method
  Widget _buildAnimatedCompendiaGrid() {
    return GridView.builder(
      itemCount: ethicalCtr.compendia.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: getWidth(16),
        mainAxisSpacing: getHeight(14),
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        // Animation for compendia card
        final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              0.4 + (index * 0.05).clamp(0.0, 0.5),
              0.7 + (index * 0.05).clamp(0.0, 0.5),
              curve: Curves.elasticOut,
            ),
          ),
        );

        return ScaleTransition(
          scale: itemAnimation,
          child: CompendiaCard(
            item: ethicalCtr.compendia[index],
            ethicalCtr: ethicalCtr,
          ),
        );
      },
    ).paddingOnly(top: getHeight(8));
  }

  Widget _buildCategory() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 7,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              textWid(
                'Category: \t',
                style: AppTextStyles.textStyle(
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.w700,
                  txtColor: AppColors.textColor3,
                ),
              ),
              Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      showDynamicMenuStatus(
                        context: context,
                        selectedStatusIndex: ethicalCtr.categories.indexOf(
                          selectedCategory.value,
                        ),
                        list:
                            ethicalCtr.categories
                                .map((category) => category?.name ?? '')
                                .toList(),
                        onItemSelected: (index) {
                          if (isLoadingSUbCategories.value) return;
                          selectedCategory.value = ethicalCtr.categories[index];
                          loadSubCategories(
                            ethicalCtr.categories[index]?.sId ?? '',
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        left: getWidth(4),
                        right: getWidth(0),
                        top: getHeight(2),
                        bottom: getHeight(2),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blueColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      // width: getWidth(110),
                      child: Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            textWid(
                              (selectedCategory.value?.name ?? '')
                                      .capitalizeFirst ??
                                  '',
                              style: AppTextStyles.textStyle(
                                txtColor: AppColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_outlined,
                              color: AppColors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: materialButtonWithChild(
            child: Text(
              textAlign: TextAlign.center,
              AppStrings.myCompendium,
              style: TextStyle(
                color: AppColors.white,
                fontSize: getWidth(11),
                fontWeight: FontWeight.w800,
              ),
            ).paddingOnly(left: getWidth(8), right: getWidth(8)),
            onPressed: () => Get.toNamed(RouteNames.myCompendia),
            color: AppColors.color7D818A,
            // color: AppColors.transparent,
            borderColor: AppColors.textColor,
            borderRadius: getWidth(10),
            borderWidth: getWidth(1),
          ),
        ),
      ],
    );
  }

  void ethicalLearningRules() {
    Get.dialog(
      AlertDialog(
        title: const Text("Ethical Learning Rules:"),
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '• VADAI\'s Ethical Learning content must be created by VAD Squad members, including students, professionals, and teachers.',
            ),
            SizedBox(height: 8),
            Text(
              '• All Ethical Learning topics must be relevant, insightful, and aligned with real-world applications.',
            ),
            SizedBox(height: 8),
            Text(
              '• Content created for Ethical Learning should cover a wide range of subjects such as personal development, mental health, career skills, and industry knowledge.',
            ),
            SizedBox(height: 8),
            Text(
              '• Ethical Learning content must be reviewed and approved by the VADAI admin before publishing.',
            ),
            SizedBox(height: 8),
            Text(
              '• All Ethical Learning compendia must include interactive elements like quizzes and discussions.',
            ),
            SizedBox(height: 8),
            Text(
              '• Ethical Learning materials should be updated periodically to reflect the latest trends, research, and industry needs.',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }
}
