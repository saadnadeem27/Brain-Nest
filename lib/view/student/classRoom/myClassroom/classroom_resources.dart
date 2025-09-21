import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/classroom_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/common/chapter_model.dart';
import 'package:Vadai/view/student/classRoom/chapter_quiz_screen.dart';

class ClassroomResources extends StatefulWidget {
  const ClassroomResources({super.key});

  @override
  State<ClassroomResources> createState() => _ClassroomResourcesState();
}

class _ClassroomResourcesState extends State<ClassroomResources> {
  ClassRoomController classRoomCtr = Get.find();
  final ScrollController _scrollController = ScrollController();
  RxBool showScrollToTopButton = false.obs;
  RxBool isLoading = false.obs;
  List<ChapterModel> chaptersList = [];

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      showScrollToTopButton.value = _scrollController.offset > 200;
    });

    initData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(() {});
    _scrollController.dispose();
    super.dispose();
  }

  void initData() async {
    isLoading.value = true;
    try {
      await classRoomCtr.getMyClassroomResourceChapterList().then((
        List<ChapterModel>? value,
      ) {
        if (value != null) {
          chaptersList = value;
        }
      });
    } catch (e) {
      log('Error loading classroom resources: $e');
      commonSnackBar(
        message: "Failed to load resources. Please try again.",
        color: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
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
          title: "Classroom Resources",
          elevation: 0,
          isBack: true,
          actions:
              !showScrollToTopButton.value
                  ? []
                  : [
                    commonPadding(
                      padding: EdgeInsets.only(right: getWidth(16)),
                      child: IconButton(
                        onPressed: scrollToTop,
                        icon: const Icon(Icons.arrow_circle_up_outlined),
                      ),
                    ),
                  ],
        ),
        body:
            isLoading.value
                ? Center(child: commonLoader())
                : chaptersList.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: getWidth(64),
                        color: AppColors.grey,
                      ),
                      SizedBox(height: getHeight(16)),
                      Text(
                        "No resources available",
                        style: TextStyle(
                          fontSize: getWidth(18),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: getHeight(8)),
                      Text(
                        "Your teacher hasn't added any resources yet",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: getWidth(14),
                          color: AppColors.textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: () async {
                    initData();
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
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
                                Get.toNamed(
                                  RouteNames.chapterDetailsScreen,
                                  arguments: {
                                    AppStrings.chapterId:
                                        chaptersList[index].sId,
                                    AppStrings.comingFrom: AppStrings.resources,
                                  },
                                );
                              },
                              child: commonPadding(
                                padding: EdgeInsets.only(
                                  left: getWidth(16),
                                  right: getWidth(16),
                                  bottom: getHeight(16),
                                ),
                                child: _buildChapterItem(
                                  item: chaptersList[index],
                                  index: index,
                                  lastIndex: index == chaptersList.length - 1,
                                ),
                              ),
                            );
                          }),
                          SizedBox(height: getHeight(24)),
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildChapterItem({
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
                index > 98 ? '∞' : (index + 1).toString(),
                style: TextStyle(
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
            SizedBox(width: getWidth(16)),
            Expanded(
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
              padding: EdgeInsets.only(
                left: getWidth(14),
                right: getWidth(14),
                top: getHeight(8),
              ),
              child: Divider(color: AppColors.lightBorder, thickness: 0.6),
            ),
      ],
    );
  }
}
