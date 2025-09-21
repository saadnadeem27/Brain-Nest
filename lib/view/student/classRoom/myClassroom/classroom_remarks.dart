import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/classroom_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/remarks_model.dart';

class ClassroomRemarks extends StatefulWidget {
  const ClassroomRemarks({super.key});

  @override
  State<ClassroomRemarks> createState() => _ClassroomRemarksState();
}

class _ClassroomRemarksState extends State<ClassroomRemarks> {
  ClassRoomController classRoomCtr = Get.find();
  RxBool isLoading = false.obs;
  RxInt currentPage = 2.obs;
  RxBool hasNext = false.obs;
  final ScrollController scrollController = ScrollController();
  RxList<RemarksModel> remarksList = <RemarksModel>[].obs;

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
      await classRoomCtr.getClassroomRemarks().then((
        Map<String, dynamic>? value,
      ) {
        if (value != null) {
          if (value['remarks'] != null) {
            remarksList.assignAll(value['remarks'] as List<RemarksModel>);
          }
          hasNext.value = value[ApiParameter.hasNext] ?? false;
        }
      });
    } catch (e) {
      log('Error loading classroom remarks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadMoreRemarks();
    }
  }

  void loadMoreRemarks() {
    if (hasNext.value) {
      try {
        classRoomCtr.getClassroomRemarks(pageNumber: currentPage.value).then((
          Map<String, dynamic>? value,
        ) {
          if (value != null) {
            if (value['remarks'] != null) {
              List<RemarksModel> newRemarks =
                  value['remarks'] as List<RemarksModel>;
              remarksList.addAll(newRemarks);
            }
            hasNext.value = value[ApiParameter.hasNext] ?? false;
            currentPage.value++;
          }
        });
      } catch (e) {
        log('Error loading more remarks: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(context: context, isBack: true, title: "Remarks"),
      body: Obx(
        () =>
            isLoading.value
                ? Center(child: commonLoader())
                : (remarksList.isEmpty)
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: getWidth(64),
                        color: AppColors.grey,
                      ),
                      SizedBox(height: getHeight(16)),
                      Text(
                        "No remarks yet",
                        style: TextStyle(
                          fontSize: getWidth(18),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: getHeight(8)),
                      Text(
                        "Your teacher hasn't added any remarks for you",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: getWidth(14),
                          color: AppColors.textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
                : Container(
                  color: AppColors.white,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      currentPage.value = 2;
                      initData();
                    },
                    child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.all(getWidth(16)),
                      itemCount: remarksList.length + (hasNext.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == remarksList.length && hasNext.value) {
                          return Center(
                            child: commonLoader(
                              customHeight: getHeight(80),
                              customWidth: getWidth(80),
                            ),
                          );
                        }
                        if (index < remarksList.length) {
                          return _buildRemarkCard(
                            remarksList[index],
                          ).paddingOnly(bottom: getHeight(16));
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
      ),
    );
  }

  // Card widget for each remark
  Widget _buildRemarkCard(RemarksModel remark) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getWidth(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with teacher info and date
          Container(
            padding: EdgeInsets.all(getWidth(12)),
            decoration: BoxDecoration(
              color: AppColors.blueColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(getWidth(12)),
                topRight: Radius.circular(getWidth(12)),
              ),
            ),
            child: Row(
              children: [
                // Teacher profile image
                Container(
                  height: getWidth(40),
                  width: getWidth(40),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child:
                        remark.senderProfile?.profileImage != null
                            ? networkImage(
                              image: remark.senderProfile!.profileImage!,
                              errorImage: AppAssets.accountImageIcon,
                              fit: BoxFit.cover,
                            )
                            : assetImage(
                              image: AppAssets.accountImageIcon,
                              fit: BoxFit.contain,
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
                        remark.senderProfile?.name ?? "Teacher",
                        style: TextStyle(
                          fontSize: getWidth(16),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: getHeight(4)),
                      Text(
                        timeAgoMethod(remark.remarkedAt ?? ""),
                        style: TextStyle(
                          fontSize: getWidth(12),
                          color: AppColors.textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Remark type badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: getWidth(8),
                    vertical: getHeight(4),
                  ),
                  decoration: BoxDecoration(
                    color: _getRemarkTypeColor(remark.remarkedOn),
                    borderRadius: BorderRadius.circular(getWidth(4)),
                  ),
                  child: Text(
                    remark.remarkedOn ?? "General",
                    style: TextStyle(
                      fontSize: getWidth(10),
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Remark content
          Padding(
            padding: EdgeInsets.all(getWidth(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  remark.remarks ?? "",
                  style: TextStyle(
                    fontSize: getWidth(14),
                    color: AppColors.textColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get color based on remark type
  Color _getRemarkTypeColor(String? type) {
    switch (type) {
      case "Classroom":
        return AppColors.green;
      case "Behavior":
        return AppColors.colorC56469;
      case "Academic":
        return AppColors.blueColor;
      case "Attendance":
        return AppColors.red;
      default:
        return AppColors.webLinkColor;
    }
  }
}
