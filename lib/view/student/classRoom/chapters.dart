import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/classroom_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/common/chapter_model.dart';
import 'package:Vadai/model/students/subject_model.dart';
import 'package:Vadai/view/student/classRoom/chapter_quiz_screen.dart';

class ChaptersScreen extends StatefulWidget {
  const ChaptersScreen({super.key});

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  ClassRoomController classRoomCtr = Get.find();
  final ScrollController _scrollController = ScrollController();
  RxBool showScrollToTopButton = false.obs;
  RxBool isTest = false.obs;
  RxBool isLoading = false.obs;
  SubjectModel? currentSubject;
  String? comingFrom;
  List<ChapterModel> chaptersList = [];

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
      isTest.value = data?['isTest'] ?? false;
      currentSubject = data?[AppStrings.subjects];
      comingFrom = data?[AppStrings.comingFrom];
    }
    try {
      if (comingFrom == AppStrings.resources) {
        await classRoomCtr
            .getResourceChapterList(subjectId: currentSubject?.sId ?? '')
            .then((List<ChapterModel>? value) {
              if (value != null) {
                chaptersList = value;
              }
            });
      } else if (comingFrom == AppStrings.curriculum) {}
      {
        await classRoomCtr
            .getCurriculumChapterList(subjectId: currentSubject?.sId ?? '')
            .then((List<ChapterModel>? value) {
              if (value != null) {
                chaptersList = value;
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

  void scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => commonScaffold(
        context: context,
        appBar: commonAppBar(
          context: context,
          title: AppStrings.chapters,
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
                ? loader()
                : chaptersList.isEmpty
                ? commonNoDataFound()
                : SingleChildScrollView(
                  controller: _scrollController,
                  child: commonPadding(
                    padding: EdgeInsets.only(
                      left: getWidth(24),
                      right: getWidth(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: getHeight(24)),
                        ...List.generate(chaptersList.length, (index) {
                          return InkWell(
                            onTap: () {
                              if (isTest == null || isTest.value == false) {
                                Get.toNamed(
                                  RouteNames.chapterDetailsScreen,
                                  arguments: {
                                    AppStrings.chapterId:
                                        chaptersList[index].sId,
                                    AppStrings.comingFrom: comingFrom,
                                  },
                                );
                              } else {
                                Get.to(
                                  () => const ChapterQuizScreen(),
                                  arguments: {
                                    AppStrings.chapterId:
                                        chaptersList[index].sId,
                                    'chapterName':
                                        chaptersList[index].chapterName,
                                    AppStrings.comingFrom: comingFrom,
                                  },
                                );
                              }
                            },
                            child: commonPadding(
                              padding: EdgeInsets.only(
                                left: getWidth(16),
                                right: getWidth(16),
                                bottom: getHeight(16),
                              ),
                              child: _buildModuleContent(
                                item: chaptersList[index],
                                index: index,
                                lastIndex: index == chaptersList.length - 1,
                              ),
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
    required ChapterModel item,
    required bool lastIndex,
    required int index,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: getWidth(28),
              height: getWidth(28),
              decoration: BoxDecoration(
                color: AppColors.blueColor.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: textWid(
                index > 98 ? '' : (index + 1).toString(),
                style: TextStyle(
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
            SizedBox(width: getWidth(16)),
            SizedBox(
              width: getWidth(225),
              child: textWid(
                'Chapter ${index + 1}: ${(item.chapterName ?? '')}',
                maxlines: 2,
                style: AppTextStyles.textStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  txtColor: AppColors.textColor,
                ),
              ),
            ),
          ],
        ),
        lastIndex
            ? const SizedBox.shrink()
            : commonPadding(
              padding: EdgeInsets.only(left: getWidth(14), right: getWidth(14)),
              child: Divider(color: AppColors.lightBorder, thickness: 0.6),
            ),
      ],
    );
  }
}
