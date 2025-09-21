import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/model/common/poeple_model.dart';
import 'package:Vadai/model/teachers/teacher_remark_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class TeacherStudentRemarksScreen extends StatefulWidget {
  const TeacherStudentRemarksScreen({Key? key}) : super(key: key);

  @override
  State<TeacherStudentRemarksScreen> createState() =>
      _TeacherStudentRemarksScreenState();
}

class _TeacherStudentRemarksScreenState
    extends State<TeacherStudentRemarksScreen> {
  final TeacherClassroomController controller = Get.find();
  final TextEditingController remarkController = TextEditingController();
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasNext = false.obs;
  final ScrollController scrollController = ScrollController();

  // Change late to nullable with Rx
  final Rx<PeopleModel?> student = Rx<PeopleModel?>(null);
  String teacherName = '';

  final RxList<TeacherRemarkModel> remarksList = <TeacherRemarkModel>[].obs;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
    });
  }

  void initData() {
    if (Get.arguments != null) {
      student.value = Get.arguments['student'] as PeopleModel?;
      teacherName = Get.arguments['teacherName'] ?? '';

      if (student.value != null && student.value!.sId != null) {
        loadRemarks();
      } else {
        handleMissingStudent();
      }
    } else {
      handleMissingStudent();
    }
  }

  void handleMissingStudent() {
    Get.back();
    commonSnackBar(
      message: "Student information not provided",
      color: Colors.red,
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  Future<void> loadRemarks() async {
    if (student.value == null || student.value!.sId == null) {
      handleMissingStudent();
      return;
    }

    isLoading.value = true;
    try {
      final result = await controller.getStudentRemarks(
        studentId: student.value!.sId!,
        pageNumber: currentPage.value,
      );

      if (result != null) {
        final remarks = result['remarks'] as List<TeacherRemarkModel>;

        if (currentPage.value == 1) {
          remarksList.value = remarks;
        } else {
          remarksList.addAll(remarks);
        }

        hasNext.value = result['hasNext'] ?? false;
      }
    } catch (e) {
      log('Error loading remarks: $e');
      commonSnackBar(
        message: "Failed to load remarks. Please try again.",
        color: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        hasNext.value &&
        !isLoading.value) {
      currentPage.value++;
      loadRemarks();
    }
  }

  void refreshData() {
    currentPage.value = 1;
    loadRemarks();
  }

  Future<void> submitRemark() async {
    if (student.value == null || student.value!.sId == null) {
      handleMissingStudent();
      return;
    }

    if (remarkController.text.trim().isEmpty) {
      commonSnackBar(message: "Please enter a remark", color: Colors.red);
      return;
    }

    isSubmitting.value = true;

    try {
      final success = await controller.addRemark(
        remarks: remarkController.text.trim(),
        receiverId: student.value!.sId!,
      );

      if (success) {
        remarkController.clear();
        refreshData(); // Reload the remarks list
      }
    } catch (e) {
      log('Error submitting remark: $e');
      commonSnackBar(
        message: "Failed to submit remark. Please try again.",
        color: Colors.red,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      resizeToAvoidBottomInset: true,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: "Student Remarks",
      ),
      body: Obx(() {
        // First, check if student is loaded
        if (student.value == null) {
          return Center(child: commonLoader());
        }

        return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Student info header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(getWidth(16)),
                margin: EdgeInsets.fromLTRB(
                  getWidth(16),
                  getHeight(16),
                  getWidth(16),
                  0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(getWidth(12)),
                  border: Border.all(
                    color: AppColors.blueColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: getWidth(56),
                      height: getWidth(56),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grey.withOpacity(0.1),
                        border: Border.all(
                          color: AppColors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child:
                          student.value!.profileImage != null &&
                                  student.value!.profileImage!.isNotEmpty
                              ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: student.value!.profileImage ?? '',
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Container(
                                        color: AppColors.grey.withOpacity(0.3),
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: AppColors.blueColor,
                                          size: getWidth(32),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Container(
                                        color: AppColors.blueColor.withOpacity(
                                          0.15,
                                        ),
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: AppColors.blueColor,
                                          size: getWidth(32),
                                        ),
                                      ),
                                ),
                              )
                              : Icon(
                                Icons.person,
                                color: AppColors.grey,
                                size: getWidth(32),
                              ),
                    ),
                    SizedBox(width: getWidth(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.value!.name ?? 'Unknown Student',
                            style: TextStyle(
                              fontSize: getWidth(18),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                          if (student.value!.email != null &&
                              student.value!.email!.isNotEmpty) ...[
                            SizedBox(height: getHeight(4)),
                            Text(
                              student.value!.email!,
                              style: TextStyle(
                                fontSize: getWidth(14),
                                color: AppColors.textColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Add remark section
              Container(
                padding: EdgeInsets.all(getWidth(16)),
                margin: EdgeInsets.symmetric(
                  horizontal: getWidth(16),
                  vertical: getHeight(16),
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(getWidth(12)),
                  border: Border.all(color: AppColors.grey.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Add a New Remark",
                      style: TextStyle(
                        fontSize: getWidth(16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.blueColor,
                      ),
                    ),
                    SizedBox(height: getHeight(12)),
                    commonTextFiled(
                      controller: remarkController,
                      maxLines: 5,
                      hintText: "Write your remark here...",
                      keyBoardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                    ),
                    SizedBox(height: getHeight(16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Obx(
                          () => ElevatedButton(
                            onPressed: isSubmitting.value ? null : submitRemark,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blueColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: getWidth(20),
                                vertical: getHeight(12),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  getWidth(8),
                                ),
                              ),
                            ),
                            child:
                                isSubmitting.value
                                    ? SizedBox(
                                      width: getWidth(20),
                                      height: getWidth(20),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.white,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      "Submit Remark",
                                      style: TextStyle(
                                        fontSize: getWidth(14),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Remarks list header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(16),
                  vertical: getHeight(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Remarks History",
                      style: TextStyle(
                        fontSize: getWidth(16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    IconButton(
                      onPressed: refreshData,
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: AppColors.blueColor,
                        size: getWidth(20),
                      ),
                    ),
                  ],
                ),
              ),

              // Remarks list
              Container(
                height:
                    MediaQuery.of(context).size.height *
                    0.4, // Allocate 40% of screen height
                padding: EdgeInsets.only(bottom: getHeight(16)),
                child: Obx(() {
                  if (isLoading.value && currentPage.value == 1) {
                    return Center(child: commonLoader());
                  }

                  if (remarksList.isEmpty) {
                    return _buildEmptyRemarksState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      refreshData();
                    },
                    child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.only(
                        left: getWidth(16),
                        right: getWidth(16),
                        bottom: getHeight(16),
                      ),
                      itemCount: remarksList.length + (hasNext.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == remarksList.length) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(getWidth(16)),
                              child: commonLoader(),
                            ),
                          );
                        }
                        return _buildRemarkTile(remarksList[index]);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRemarkTile(TeacherRemarkModel remark) {
    // Format the date if available
    String formattedDate = '';
    if (remark.remarkedAt != null) {
      try {
        final DateTime date = DateTime.parse(remark.remarkedAt!);
        formattedDate = DateFormat('dd MMM, yyyy • h:mm a').format(date);
      } catch (e) {
        formattedDate = remark.remarkedAt ?? '';
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: getHeight(12)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(getWidth(12)),
        border: Border.all(color: AppColors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(getWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher info row
            Row(
              children: [
                Container(
                  width: getWidth(32),
                  height: getWidth(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blueColor.withOpacity(0.1),
                  ),
                  child:
                      remark.senderProfile != null &&
                              remark.senderProfile!.profileImage != null &&
                              remark.senderProfile!.profileImage!.isNotEmpty
                          ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: remark.senderProfile!.profileImage!,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    color: AppColors.blueColor.withOpacity(0.1),
                                    child: Icon(
                                      Icons.person,
                                      color: AppColors.blueColor,
                                      size: getWidth(20),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Icon(
                                    Icons.person,
                                    color: AppColors.blueColor,
                                    size: getWidth(20),
                                  ),
                            ),
                          )
                          : Icon(
                            Icons.person,
                            color: AppColors.blueColor,
                            size: getWidth(20),
                          ),
                ),
                SizedBox(width: getWidth(8)),
                Expanded(
                  child: Text(
                    remark.senderProfile?.name ?? teacherName,
                    style: TextStyle(
                      fontSize: getWidth(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
                if (formattedDate.isNotEmpty)
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: getWidth(12),
                      color: AppColors.textColor.withOpacity(0.6),
                    ),
                  ),
              ],
            ),

            SizedBox(height: getHeight(12)),

            // Remark content
            Text(
              remark.remarks ?? '',
              style: TextStyle(
                fontSize: getWidth(15),
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyRemarksState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.comment_outlined,
            size: getWidth(64),
            color: AppColors.grey.withOpacity(0.5),
          ),
          SizedBox(height: getHeight(16)),
          Text(
            "No Remarks Found",
            style: TextStyle(
              fontSize: getWidth(18),
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(8)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: getWidth(32)),
            child: Text(
              "No remarks have been added for this student yet.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: getWidth(14),
                color: AppColors.textColor.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
