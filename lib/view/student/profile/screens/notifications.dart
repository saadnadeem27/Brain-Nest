import 'package:Vadai/common_imports.dart';
import 'package:Vadai/helper/api_helper.dart';
import '../../../../model/common/notification_model.dart';
import 'package:Vadai/controller/student/student_profile_controller.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final StudentProfileController controller =
      Get.find<StudentProfileController>();
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
      final result = await controller.getNotification();
      if (result != null) {
        notifications.value =
            result[ApiParameter.list].cast<NotificationModel>();
        hasNextPage.value = result[ApiParameter.hasNext];
        pageNumber.value = 2;
      }
    } catch (e) {
      log('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreNotifications() async {
    if (isLoadingMore.value) return;

    isLoadingMore.value = true;
    try {
      final result = await controller.getNotification(
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
      log('Error loading more notifications: $e');
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
            child: textWid(
              'No notifications found',
              style: AppTextStyles.textStyle(
                fontSize: 16,
                txtColor: AppColors.textColor.withOpacity(0.7),
              ),
            ),
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotification(
                        notifications[index],
                      ).paddingOnly(top: getHeight(16));
                    },
                  ),
                ],
              ).paddingOnly(
                left: getWidth(16),
                right: getWidth(16),
                bottom: getHeight(28),
              ),
            ),
            if (isLoadingMore.value)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: getHeight(10)),
                  child: commonLoader(
                    customHeight: getHeight(40),
                    customWidth: getHeight(40),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildNotification(NotificationModel notification) {
    String avatarText =
        (notification.sender?.name?.isNotEmpty == true)
            ? notification.sender!.name![0].toUpperCase()
            : '?';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.white,
        border: Border.all(
          color: AppColors.black.withOpacity(0.2),
          width: getWidth(1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: getHeight(20),
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
          sizeBoxWidth(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textWid(
                  notification.sender?.name ?? "Unknown",
                  textOverflow: TextOverflow.clip,
                  style: AppTextStyles.textStyle(
                    fontWeight: FontWeight.w600,
                    txtColor: AppColors.textColor,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: getHeight(6),
                    bottom: getHeight(2),
                  ),
                  child: textWid(
                    notification.title ?? '',
                    textOverflow: TextOverflow.clip,
                    maxlines: 2,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: getHeight(6)),
                  child: textWid(
                    notification.description ?? '',
                    textOverflow: TextOverflow.clip,
                    maxlines: 4,
                  ),
                ),
                textWid(
                  formatNotificationTime(notification.sentOn),
                  style: AppTextStyles.textStyle(
                    txtColor: AppColors.textColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ).paddingOnly(
        left: getWidth(16),
        right: getWidth(16),
        top: getHeight(16),
        bottom: getHeight(16),
      ),
    );
  }
}
