import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/classroom_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/announcements_model.dart';
import 'package:Vadai/model/students/subject_model.dart';

class Announcements extends StatefulWidget {
  const Announcements({super.key});

  @override
  State<Announcements> createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  ClassRoomController classRoomCtr = Get.find();
  SubjectModel? currentSubject;
  RxBool isLoading = false.obs;
  RxInt currentPage = 2.obs;
  RxBool hasNext = false.obs;
  final ScrollController scrollController = ScrollController();
  List<AnnouncementsModel>? announcementsList = [];

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    initData();
  }

  void initData() async {
    isLoading.value = true;
    var data = Get.arguments;
    if (data != null) {
      currentSubject = data?[AppStrings.subjects];
    }
    try {
      await classRoomCtr
          .getSubjectAnnouncementsList(subjectId: currentSubject?.sId ?? '')
          .then((Map<String, dynamic>? value) {
            if (value != null) {
              if (value[ApiParameter.announcements] != null) {
                announcementsList = value[ApiParameter.announcements];
              }
              hasNext.value = value[ApiParameter.hasNext];
            }
          });
    } catch (e) {
      log(
        '------------------------------->>>>>>>>>>>>>> Error in announcement: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadMoreAnnouncements();
    }
  }

  void loadMoreAnnouncements() {
    if (hasNext.value) {
      try {
        classRoomCtr
            .getSubjectAnnouncementsList(
              subjectId: currentSubject?.sId ?? '',
              pageNumber: currentPage.value,
            )
            .then((Map<String, dynamic>? value) {
              if (value != null) {
                if (value[ApiParameter.announcements] != null) {
                  for (var announcement in value[ApiParameter.announcements]) {
                    announcementsList?.add(announcement);
                  }
                }
                hasNext.value = value[ApiParameter.hasNext];
                currentPage.value++;
              }
            });
      } catch (e) {
        log(
          '------------------------------->>>>>>>>>>>>>> Error in announcement: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: AppStrings.announcements,
      ),
      body: Obx(
        () =>
            isLoading.value
                ? commonLoader()
                : (announcementsList?.isEmpty ?? true)
                ? commonNoDataFound()
                : Container(
                  color: AppColors.white,
                  child: RefreshIndicator(
                    onRefresh: () async => initData(),
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount:
                          (announcementsList?.length ?? 0) +
                          (hasNext.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= announcementsList!.length - 1) {
                          Obx(
                            () =>
                                hasNext.value
                                    ? commonLoader()
                                    : const SizedBox.shrink(),
                          );
                        }
                        return _buildCard(
                          announcementsList?[index],
                        ).paddingOnly(
                          bottom: getHeight(8),
                          top: getHeight(8),
                          left: getWidth(16),
                          right: getWidth(16),
                        );
                      },
                    ),
                  ),
                ),
      ),
    );
  }

  //* card method
  Widget _buildCard(AnnouncementsModel? item) {
    return item == null || item.sId == null
        ? const SizedBox.shrink()
        : Material(
          elevation: 2, // Adjust elevation for the Material widget
          shadowColor: AppColors.black.withOpacity(0.2), // Shadow color
          borderRadius: BorderRadius.circular(getWidth(6)),
          child: Container(
            padding: EdgeInsets.all(getWidth(16)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(getWidth(6)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          (item.senderProfile?.profileImage != null)
                              ? Container(
                                height: getWidth(25),
                                width: getWidth(25),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: networkImage(
                                    image:
                                        item.senderProfile?.profileImage ?? '',
                                    errorImage: AppAssets.accountImageIcon,
                                    customWidth: getWidth(150),
                                    customHeight: getHeight(150),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                              : assetImage(
                                image: AppAssets.accountImageIcon,
                                fit: BoxFit.contain,
                              ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                textWid(
                                  item.senderProfile?.name ?? '',
                                  maxlines: 1,
                                  textOverflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.textStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: getWidth(12),
                                    txtColor: AppColors.textColor,
                                  ),
                                ),
                                textWid(
                                  timeAgoMethod(item.createdOn ?? ''),
                                  maxlines: 1,
                                  textOverflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.textStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: getWidth(8),
                                    txtColor: AppColors.textColor2,
                                  ),
                                ).paddingOnly(left: getWidth(2)),
                              ],
                            ),
                          ).paddingOnly(left: getWidth(8)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            () => Get.toNamed(
                              RouteNames.comments,
                              arguments: {'parentId': item.sId},
                            ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            assetImage(
                              image: AppAssets.reply,
                              fit: BoxFit.contain,
                              customHeight: 16,
                              customWidth: 16,
                            ),
                            textWid(
                              AppStrings.comment,
                              style: AppTextStyles.textStyle(
                                fontSize: getWidth(12),
                                fontWeight: FontWeight.w600,
                                txtColor: AppColors.blueColor,
                              ),
                            ).paddingOnly(left: getWidth(4)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                textWid(
                  item.title ?? '',
                  maxlines: 2,
                  style: AppTextStyles.textStyle(
                    fontSize: getWidth(11),
                    fontWeight: FontWeight.w600,
                    txtColor: AppColors.textColor,
                  ),
                ).paddingOnly(top: getHeight(8)),
                textWid(
                  item.description ?? '',
                  maxlines: 5,
                  style: AppTextStyles.textStyle(
                    fontSize: getWidth(11),
                    fontWeight: FontWeight.w400,
                    txtColor: AppColors.textColor,
                  ),
                ).paddingOnly(top: getHeight(8)),
              ],
            ),
          ),
        );
  }
}
