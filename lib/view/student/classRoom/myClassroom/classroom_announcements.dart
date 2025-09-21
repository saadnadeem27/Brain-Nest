import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/classroom_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/announcements_model.dart';

class ClassroomAnnouncements extends StatefulWidget {
  const ClassroomAnnouncements({super.key});

  @override
  State<ClassroomAnnouncements> createState() => _ClassroomAnnouncementsState();
}

class _ClassroomAnnouncementsState extends State<ClassroomAnnouncements> {
  ClassRoomController classRoomCtr = Get.find();
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

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void initData() async {
    isLoading.value = true;
    try {
      await classRoomCtr.getClassroomAnnouncementsList().then((
        Map<String, dynamic>? value,
      ) {
        if (value != null) {
          if (value[ApiParameter.announcements] != null) {
            announcementsList = value[ApiParameter.announcements];
          }
          hasNext.value = value[ApiParameter.hasNext] ?? false;
        }
      });
    } catch (e) {
      log('Error in classroom announcements: $e');
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
            .getClassroomAnnouncementsList(pageNumber: currentPage.value)
            .then((Map<String, dynamic>? value) {
              if (value != null) {
                if (value[ApiParameter.announcements] != null) {
                  for (var announcement in value[ApiParameter.announcements]) {
                    announcementsList?.add(announcement);
                  }
                }
                hasNext.value = value[ApiParameter.hasNext] ?? false;
                currentPage.value++;
              }
            });
      } catch (e) {
        log('Error loading more classroom announcements: $e');
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
        title: "Announcements",
      ),
      body: Obx(
        () =>
            isLoading.value
                ? Center(child: commonLoader())
                : (announcementsList?.isEmpty ?? true)
                ? Center(child: commonNoDataFound())
                : Container(
                  color: AppColors.white,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      currentPage.value = 2;
                      initData();
                    },
                    child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.only(top: getHeight(8)),
                      itemCount:
                          (announcementsList?.length ?? 0) +
                          (hasNext.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == announcementsList!.length &&
                            hasNext.value) {
                          return Center(
                            child: commonLoader(
                              customHeight: getHeight(80),
                              customWidth: getWidth(80),
                            ),
                          );
                        }
                        if (index < announcementsList!.length) {
                          return _buildCard(
                            announcementsList?[index],
                          ).paddingOnly(
                            bottom: getHeight(8),
                            top: getHeight(8),
                            left: getWidth(16),
                            right: getWidth(16),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
      ),
    );
  }

  // Card widget for each announcement
  Widget _buildCard(AnnouncementsModel? item) {
    return item == null || item.sId == null
        ? const SizedBox.shrink()
        : Material(
          elevation: 2,
          shadowColor: AppColors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(getWidth(6)),
          child: Container(
            padding: EdgeInsets.all(getWidth(16)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(getWidth(6)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(-2, -2),
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
                                customHeight: getWidth(25),
                                customWidth: getWidth(25),
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
