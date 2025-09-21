import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/teachers/teacher_announcement_model.dart';

class TeacherClassroomAnnouncements extends StatefulWidget {
  const TeacherClassroomAnnouncements({Key? key}) : super(key: key);

  @override
  State<TeacherClassroomAnnouncements> createState() =>
      _TeacherClassroomAnnouncementsState();
}

class _TeacherClassroomAnnouncementsState
    extends State<TeacherClassroomAnnouncements> {
  final TeacherClassroomController controller =
      Get.find<TeacherClassroomController>();

  String teacherName = '';
  RxBool isLoading = false.obs;
  RxInt currentPage = 1.obs;
  RxBool hasNext = false.obs;

  final ScrollController scrollController = ScrollController();
  RxList<TeacherAnnouncementModel> announcementsList =
      <TeacherAnnouncementModel>[].obs;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
    });
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
      if (Get.arguments != null) {
        // Extract arguments
        teacherName = Get.arguments['teacherName'] ?? '';
      }

      // Reset pagination
      currentPage.value = 1;
      announcementsList.clear();

      // Fetch initial announcements
      await loadAnnouncements();
    } catch (e) {
      log('Error in teacher classroom announcements: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAnnouncements() async {
    try {
      final result = await controller.getClassroomAnnouncementsList(
        pageNumber: currentPage.value,
      );

      if (result != null) {
        if (currentPage.value == 1) {
          // First page - replace list
          announcementsList.assignAll(result[ApiParameter.announcements]);
        } else {
          // Subsequent pages - add to list
          announcementsList.addAll(result[ApiParameter.announcements]);
        }

        hasNext.value = result[ApiParameter.hasNext] ?? false;
        if (hasNext.value) {
          currentPage.value++;
        }
      }
    } catch (e) {
      log('Error loading classroom announcements: $e');
    }
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (hasNext.value && !isLoading.value) {
        loadAnnouncements();
      }
    }
  }

  void createNewAnnouncement() {
    Get.toNamed(
      RouteNames.createAnnouncement,
      arguments: {'teacherName': teacherName},
    )?.then((result) {
      if (result == true) {
        // Refresh the announcements list when we return after successful creation
        initData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: "Classroom Announcements",
        actions: [
          // Add announcement button for teachers
          GestureDetector(
            onTap: createNewAnnouncement,
            child: Container(
              margin: EdgeInsets.only(right: getWidth(16)),
              padding: EdgeInsets.all(getWidth(8)),
              decoration: BoxDecoration(
                color: AppColors.blueColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: AppColors.blueColor,
                size: getWidth(24),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info card
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: getHeight(10),
              horizontal: getWidth(16),
            ),
            decoration: BoxDecoration(
              color: AppColors.blueColor.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.campaign_rounded,
                  color: AppColors.blueColor.withOpacity(0.7),
                  size: getWidth(16),
                ),
                SizedBox(width: getWidth(8)),
                Text(
                  'Announcements for all your classes',
                  style: TextStyle(
                    fontSize: getWidth(12),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor.withOpacity(0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Announcements list
          Expanded(
            child: Obx(
              () =>
                  isLoading.value && announcementsList.isEmpty
                      ? Center(child: commonLoader())
                      : announcementsList.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                        onRefresh: initData,
                        child: ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(
                            vertical: getHeight(12),
                            horizontal: getWidth(16),
                          ),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount:
                              announcementsList.length +
                              (hasNext.value ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == announcementsList.length) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(getHeight(16)),
                                  child: commonLoader(
                                    customHeight: getHeight(24),
                                    customWidth: getHeight(24),
                                  ),
                                ),
                              );
                            }
                            return _buildAnnouncementCard(
                              announcementsList[index],
                            ).paddingOnly(bottom: getHeight(16));
                          },
                        ),
                      ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewAnnouncement,
        backgroundColor: AppColors.blueColor,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(getWidth(20)),
            decoration: BoxDecoration(
              color: AppColors.blueColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.campaign_rounded,
              color: AppColors.blueColor,
              size: getWidth(40),
            ),
          ),
          SizedBox(height: getHeight(16)),
          Text(
            "No Announcements Yet",
            style: TextStyle(
              fontSize: getWidth(18),
              fontWeight: FontWeight.bold,
              color: AppColors.blueColor,
            ),
          ),
          SizedBox(height: getHeight(8)),
          Text(
            "Create your first announcement for your classes",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: getWidth(14),
              color: AppColors.textColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: getHeight(24)),
          ElevatedButton.icon(
            onPressed: createNewAnnouncement,
            icon: Icon(Icons.add, color: AppColors.white, size: getWidth(16)),
            label: Text(
              "Create Announcement",
              style: TextStyle(color: AppColors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueColor,
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(16),
                vertical: getHeight(12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(getWidth(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(TeacherAnnouncementModel announcement) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(getWidth(12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.grey.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(getWidth(12)),
        onTap: () {
          // Navigate to announcement details or comments
          Get.toNamed(
            RouteNames.teacherComments,
            arguments: {
              'parentId': announcement.id,
              'announcementTitle': announcement.title,
            },
          );
        },
        child: Padding(
          padding: EdgeInsets.all(getWidth(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with sender info and date
              Row(
                children: [
                  // Profile image
                  Container(
                    height: getWidth(40),
                    width: getWidth(40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.grey.withOpacity(0.2),
                    ),
                    child: ClipOval(
                      child:
                          announcement.senderProfile.profileImage.isNotEmpty
                              ? networkImage(
                                image: announcement.senderProfile.profileImage,
                                errorImage: AppAssets.accountImageIcon,
                                fit: BoxFit.cover,
                              )
                              : assetImage(
                                image: AppAssets.accountImageIcon,
                                fit: BoxFit.cover,
                              ),
                    ),
                  ),
                  SizedBox(width: getWidth(12)),

                  // Teacher name and timestamp
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement.senderProfile.name,
                          style: TextStyle(
                            fontSize: getWidth(14),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(height: getHeight(2)),
                        Text(
                          timeAgoMethod(
                            announcement.createdOn.toIso8601String(),
                          ),
                          style: TextStyle(
                            fontSize: getWidth(12),
                            color: AppColors.textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Options menu
                  IconButton(
                    onPressed: () {
                      // Show options dialog (edit, delete, etc.)
                      showOptionsMenu(announcement);
                    },
                    icon: Icon(
                      Icons.more_vert,
                      color: AppColors.textColor.withOpacity(0.6),
                      size: getWidth(20),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              SizedBox(height: getHeight(16)),

              // Title
              Text(
                announcement.title,
                style: TextStyle(
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),

              SizedBox(height: getHeight(8)),

              // Description
              Text(
                announcement.description,
                style: TextStyle(
                  fontSize: getWidth(14),
                  height: 1.4,
                  color: AppColors.textColor.withOpacity(0.8),
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: getHeight(16)),

              // Footer
              Row(
                children: [
                  // Comments button
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        RouteNames.teacherComments,
                        arguments: {
                          'parentId': announcement.id,
                          'announcementTitle': announcement.title,
                        },
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: getWidth(16),
                          color: AppColors.blueColor.withOpacity(0.8),
                        ),
                        SizedBox(width: getWidth(4)),
                        Text(
                          "Comments",
                          style: TextStyle(
                            fontSize: getWidth(12),
                            fontWeight: FontWeight.w500,
                            color: AppColors.blueColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Spacer(),

                  // Recipient indicator - shown for class teacher announcements
                  Row(
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        size: getWidth(16),
                        color: AppColors.blueColor.withOpacity(0.6),
                      ),
                      SizedBox(width: getWidth(4)),
                      Text(
                        "All Classes",
                        style: TextStyle(
                          fontSize: getWidth(12),
                          color: AppColors.textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showOptionsMenu(TeacherAnnouncementModel announcement) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(getWidth(16))),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.symmetric(
              vertical: getHeight(24),
              horizontal: getWidth(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Announcement Options",
                  style: TextStyle(
                    fontSize: getWidth(18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: getHeight(24)),

                // Edit option
                ListTile(
                  leading: Icon(Icons.edit, color: AppColors.blueColor),
                  title: Text(
                    "Edit Announcement",
                    style: TextStyle(
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(
                      RouteNames.editAnnouncement,
                      arguments: {
                        'announcement': announcement,
                        'teacherName': teacherName,
                      },
                    )?.then((result) {
                      if (result == true) {
                        // Refresh the announcements list when we return after successful update
                        initData();
                      }
                    });
                  },
                ),

                // Delete option
                ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    "Delete Announcement",
                    style: TextStyle(
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Show delete confirmation
                    showDeleteConfirmation(announcement);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void showDeleteConfirmation(TeacherAnnouncementModel announcement) {
    Get.defaultDialog(
      title: "Delete Announcement",
      titleStyle: TextStyle(
        fontSize: getWidth(18),
        fontWeight: FontWeight.w600,
      ),
      content: Text(
        "Are you sure you want to delete this announcement? This action cannot be undone.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: getWidth(14), color: AppColors.textColor),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          Get.back(); // Close the dialog

          // Show loading indicator
          Get.dialog(Center(child: commonLoader()), barrierDismissible: false);

          // Delete the announcement using controller
          final success = await controller.deleteAnnouncement(
            announcementId: announcement.id,
          );

          // Close loading indicator
          Get.back();

          if (success) {
            // Refresh the announcements list
            initData();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(
            horizontal: getWidth(24),
            vertical: getHeight(8),
          ),
        ),
        child: Text("Delete"),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.grey),
          padding: EdgeInsets.symmetric(
            horizontal: getWidth(24),
            vertical: getHeight(8),
          ),
        ),
        child: Text("Cancel"),
      ),
    );
  }
}
