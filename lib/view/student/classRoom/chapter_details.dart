import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/classroom_controller.dart';
import 'package:Vadai/model/common/module_model.dart';
import 'package:dio/dio.dart';

class ChapterDetailsScreen extends StatefulWidget {
  const ChapterDetailsScreen({super.key});

  @override
  State<ChapterDetailsScreen> createState() => _ChapterDetailsScreenState();
}

class _ChapterDetailsScreenState extends State<ChapterDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  ClassRoomController classRoomCtr = Get.find();
  TextEditingController searchController = TextEditingController();
  CancelToken _cancelToken = CancelToken();
  RxBool isSearch = false.obs;
  RxBool showScrollToTopButton = false.obs;
  List<ModuleModel> moduleList = [];
  RxBool isLoading = false.obs;
  String? chapterId;
  String? comingFrom;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      showScrollToTopButton.value = _scrollController.offset > 200;
    });
    initData();
  }

  void initData() async {
    isLoading.value = true;
    var data = Get.arguments;
    if (data != null) {
      chapterId = data?[AppStrings.chapterId];
      comingFrom = data?[AppStrings.comingFrom];
    }
    try {
      if (comingFrom == AppStrings.resources) {
        await classRoomCtr
            .getResourseModuleList(chapterId: chapterId ?? '')
            .then((List<ModuleModel>? value) {
              if (value != null) {
                moduleList = value;
              }
            });
      } else if (comingFrom == AppStrings.curriculum) {
        await classRoomCtr
            .getCurriculumModuleList(chapterId: chapterId ?? '')
            .then((List<ModuleModel>? value) {
              if (value != null) {
                moduleList = value;
              }
            });
      }
    } catch (e) {
      log(
        '------------------>>>>>>>>>>>>>> error in initData of module screen $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Color getColor(String type) {
    if (type.contains(AppStrings.pdf)) {
      return AppColors.red.withOpacity(0.45);
    } else if (type.contains(AppStrings.image)) {
      return AppColors.blueColor.withOpacity(0.6);
    } else if (type.contains(AppStrings.link)) {
      return AppColors.webLinkColor;
    } else if (type.contains(AppStrings.text)) {
      return AppColors.green.withOpacity(0.6);
    } else {
      return AppColors.black;
    }
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> searchModule({required String searchTag}) async {
    isSearch.value = true;
    _cancelToken.cancel();
    _cancelToken = CancelToken();
    try {
      if (comingFrom == AppStrings.resources) {
        await classRoomCtr
            .getResourseModuleList(
              chapterId: chapterId ?? '',
              searchTag: searchTag,
              cancelToken: _cancelToken,
            )
            .then((List<ModuleModel>? value) {
              if (value != null) {
                moduleList.clear();
                moduleList = value;
              }
            });
      } else if (comingFrom == AppStrings.curriculum) {
        await classRoomCtr
            .getCurriculumModuleList(
              chapterId: chapterId ?? '',
              searchTag: searchTag,
              cancelToken: _cancelToken,
            )
            .then((List<ModuleModel>? value) {
              if (value != null) {
                moduleList.clear();
                moduleList = value;
              }
            });
      }
    } catch (e) {
      log(
        '------------------>>>>>>>>>>>>>> error in searchModule of module screen $e',
      );
    } finally {
      isSearch.value = false;
    }
  }

  @override
  void dispose() {
    _cancelToken.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => commonScaffold(
        context: context,
        appBar: commonAppBar(
          context: context,
          title: AppStrings.modules,
          elevation: 0,
          isBack: true,
          actions:
              !showScrollToTopButton.value
                  ? []
                  : [
                    commonPadding(
                      padding: EdgeInsets.only(right: getWidth(16)),
                      child: IconButton(
                        onPressed: () {
                          scrollToTop();
                        },
                        icon: const Icon(Icons.arrow_circle_up_outlined),
                      ),
                    ),
                  ],
        ),
        body:
            isLoading.value
                ? commonLoader()
                : SingleChildScrollView(
                  controller: _scrollController,
                  child: commonPadding(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: getHeight(24)),
                        commonPadding(
                          padding: EdgeInsets.only(
                            left: getWidth(24),
                            right: getWidth(24),
                          ),
                          child: commonTextFiled(
                            hintText: AppStrings.searchModule,
                            controller: searchController,
                            onEditingComplete: () {
                              searchModule(searchTag: searchController.text);
                            },
                            onChanged: (value) {
                              searchModule(searchTag: value);
                            },
                            hintStyle: AppTextStyles.textStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: EdgeInsets.only(left: getWidth(16)),
                            suffixWidget: Container(
                              padding: EdgeInsets.all(getWidth(3)),
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
                          ),
                        ),
                        SizedBox(height: getHeight(32)),
                        if (moduleList.isEmpty)
                          commonNoDataFound()
                        else if (isSearch.value)
                          Center(child: CircularProgressIndicator())
                        else
                          ...List.generate(moduleList.length, (index) {
                            return commonPadding(
                              padding: EdgeInsets.only(
                                left: getWidth(16),
                                right: getWidth(16),
                                bottom: getHeight(48),
                              ),
                              child: _buildModuleContent(
                                item: moduleList[index],
                                lastIndex: index == moduleList.length - 1,
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildModuleContent({
    required ModuleModel item,
    required bool lastIndex,
  }) {
    return Column(
      children: [
        textWid(
          item.moduleName ?? '',
          maxlines: 1,
          style: AppTextStyles.textStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            txtColor: AppColors.black.withOpacity(0.7),
          ),
        ),
        SizedBox(height: getHeight(32)),
        ...List.generate(item.documents?.length ?? 0, (index) {
          return GestureDetector(
            onTap: () => launchUrl(item.documents?[index].link),
            child: Container(
              margin: EdgeInsets.only(bottom: getHeight(18)),
              height: getHeight(65),
              padding: EdgeInsets.only(
                left: getWidth(16),
                right: getWidth(16),
                top: getHeight(16),
                bottom: getHeight(16),
              ),
              decoration: BoxDecoration(
                color: getColor(item.documents?[index].type ?? ''),
                borderRadius: BorderRadius.circular(getWidth(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textWid(
                    item.documents?[index].name ?? '',
                    style: AppTextStyles.textStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => launchUrl(item.documents?[index].link),
                    child: commonPadding(
                      padding: EdgeInsets.only(right: getWidth(8)),
                      child: assetImage(image: AppAssets.download),
                    ),
                  ),
                  // (item.documents?[index].type ?? '').contains(AppStrings.pdf) ||
                  //         (item.documents?[index].type ?? '')
                  //             .contains(AppStrings.image)
                  //     ? GestureDetector(
                  //         onTap: () => launchUrl(item.documents?[index].link),
                  //         child: commonPadding(
                  //             padding: EdgeInsets.only(right: getWidth(8)),
                  //             child: assetImage(image: AppAssets.download)),
                  //       )
                  //     : GestureDetector(
                  //         onTap: () => launchUrl(item.documents?[index].link),
                  //         child: Container(
                  //           padding: EdgeInsets.all(getWidth(6)),
                  //           decoration: BoxDecoration(
                  //             border: Border.all(
                  //                 color: AppColors.black.withOpacity(0.6),
                  //                 width: 0.6),
                  //             borderRadius: BorderRadius.circular(getWidth(12)),
                  //           ),
                  //           child: textWid(AppStrings.open,
                  //               style: AppTextStyles.textStyle(
                  //                   fontSize: 9,
                  //                   fontWeight: FontWeight.w400,
                  //                   txtColor: AppColors.black)),
                  //         ),
                  //       )
                ],
              ),
            ),
          );
        }),
        SizedBox(height: getHeight(16)),
        lastIndex
            ? const SizedBox.shrink()
            : Divider(color: AppColors.lightBorder, thickness: 0.6),
      ],
    );
  }
}
