import 'package:Vadai/common_imports.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/common/notification_model.dart';
import 'package:Vadai/controller/teachers/teacher_profile_controller.dart';
import 'package:intl/intl.dart';

class TeacherNotificationScreen extends StatefulWidget {
  const TeacherNotificationScreen({super.key});

  @override
  State<TeacherNotificationScreen> createState() =>
      _TeacherNotificationScreenState();
}

class _TeacherNotificationScreenState extends State<TeacherNotificationScreen> {
  final TeacherProfileController controller =
      Get.find<TeacherProfileController>();
  final ScrollController scrollController = ScrollController();

  RxBool isLoading = true.obs;
  RxBool isLoadingMore = false.obs;
  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  RxBool hasNextPage = false.obs;
  RxInt pageNumber = 1.obs;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (hasNextPage.value && !isLoadingMore.value) {
        loadMoreNotifications();
      }
    }
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final result = await controller.getNotifications();
      if (result != null) {
        notifications.value =
            result[ApiParameter.list].cast<NotificationModel>();
        hasNextPage.value = result[ApiParameter.hasNext];
        pageNumber.value = 2;
      }
    } catch (e) {
      log('Error fetching teacher notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreNotifications() async {
    if (isLoadingMore.value) return;

    isLoadingMore.value = true;
    try {
      final result = await controller.getNotifications(
        pageKey: pageNumber.value,
      );
      if (result != null) {
        notifications.addAll(
          result[ApiParameter.list].cast<NotificationModel>(),
        );
        hasNextPage.value = result[ApiParameter.hasNext];
        pageNumber.value++;
      }
    } catch (e) {
      log('Error loading more teacher notifications: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  String formatNotificationTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    try {
      final DateTime date = DateTime.parse(dateString).toLocal();
      final DateTime now = DateTime.now();
      final DateTime yesterday = now.subtract(const Duration(days: 1));
      final DateTime lastWeek = now.subtract(const Duration(days: 7));

      // Format for time
      final String timeFormat = DateFormat('h:mm a').format(date);

      // Today
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return 'Today at $timeFormat';
      }

      // Yesterday
      if (date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day) {
        return 'Yesterday at $timeFormat';
      }

      // Within last week
      if (date.isAfter(lastWeek)) {
        // Get day of week
        final String dayName = DateFormat('EEEE').format(date);
        return 'Last $dayName at $timeFormat';
      }

      // For older dates
      return '${DateFormat('MMM d').format(date)} at $timeFormat';
    } catch (e) {
      log('Error formatting date: $e');
      return dateString ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        title: AppStrings.notifications,
        isBack: true,
        titleColor: AppColors.textColor,
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(child: commonLoader());
        }

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: getWidth(48),
                  color: AppColors.grey,
                ),
                SizedBox(height: getHeight(16)),
                textWid(
                  'No notifications found',
                  style: AppTextStyles.textStyle(
                    fontSize: 16,
                    txtColor: AppColors.textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: fetchNotifications,
          child: Stack(
            children: [
              ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(16),
                  vertical: getHeight(8),
                ),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotification(
                    notifications[index],
                  ).paddingOnly(top: getHeight(10), bottom: getHeight(6));
                },
              ),
              if (isLoadingMore.value)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: getHeight(10)),
                    color: AppColors.white.withOpacity(0.8),
                    child: commonLoader(
                      customHeight: getHeight(40),
                      customWidth: getHeight(40),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNotification(NotificationModel notification) {
    String avatarText =
        (notification.sender?.name?.isNotEmpty == true)
            ? notification.sender!.name![0].toUpperCase()
            : 'A';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(getWidth(12)),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
        border: Border.all(
          color: AppColors.black.withOpacity(0.1),
          width: getWidth(1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: getHeight(4)),
            child: CircleAvatar(
              radius: getHeight(22),
              backgroundColor: AppColors.blueColor,
              backgroundImage:
                  notification.sender?.profileImage != null
                      ? NetworkImage(notification.sender!.profileImage!)
                      : null,
              child:
                  notification.sender?.profileImage == null
                      ? textWid(
                        avatarText,
                        style: AppTextStyles.textStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          txtColor: AppColors.white,
                        ),
                      )
                      : null,
            ),
          ),
          SizedBox(width: getWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: textWid(
                        notification.sender?.name ?? "Admin",
                        textOverflow: TextOverflow.ellipsis,
                        style: AppTextStyles.textStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: getWidth(15),
                          txtColor: AppColors.textColor,
                        ),
                      ),
                    ),
                    textWid(
                      formatNotificationTime(notification.sentOn),
                      style: AppTextStyles.textStyle(
                        txtColor: AppColors.textColor.withOpacity(0.7),
                        fontSize: getWidth(11),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: getHeight(8)),
                textWid(
                  notification.title ?? '',
                  textOverflow: TextOverflow.clip,
                  maxlines: 2,
                  style: AppTextStyles.textStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: getWidth(14),
                    txtColor: AppColors.textColor,
                  ),
                ),
                SizedBox(height: getHeight(4)),
                textWid(
                  notification.description ?? '',
                  textOverflow: TextOverflow.clip,
                  maxlines: 4,
                  style: AppTextStyles.textStyle(
                    fontSize: getWidth(13),
                    txtColor: AppColors.textColor.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ).paddingAll(getWidth(16)),
    );
  }
}
