import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/model/teachers/teacher_announcement_model.dart';

class EditTeacherAnnouncement extends StatefulWidget {
  const EditTeacherAnnouncement({Key? key}) : super(key: key);

  @override
  State<EditTeacherAnnouncement> createState() =>
      _EditTeacherAnnouncementState();
}

class _EditTeacherAnnouncementState extends State<EditTeacherAnnouncement> {
  final TeacherClassroomController controller =
      Get.find<TeacherClassroomController>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final RxBool isLoading = false.obs;

  RxString className = ''.obs;
  RxString sectionName = ''.obs;
  RxString subjectName = ''.obs;
  String classId = '';
  String sectionId = '';
  String subjectId = '';

  TeacherAnnouncementModel? announcement;
  String announcementId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void initData() {
    try {
      if (Get.arguments != null) {
        // Get the announcement data
        announcement = Get.arguments['announcement'];
        if (announcement != null) {
          // Set the announcement ID
          announcementId = announcement!.id;

          // Prefill the form fields
          titleController.text = announcement!.title;
          descriptionController.text = announcement!.description;

          // Set the class, section, and subject data
          className.value = Get.arguments['className'] ?? '';
          sectionName.value = Get.arguments['sectionName'] ?? '';
          subjectName.value = Get.arguments['subjectName'] ?? '';
          classId = Get.arguments['classId'] ?? '';
          sectionId = Get.arguments['sectionId'] ?? '';
          subjectId = Get.arguments['subjectId'] ?? '';
        }
      }
    } catch (e) {
      log('Error in initData of EditTeacherAnnouncement: $e');
    }
  }

  bool validateInputs() {
    if (titleController.text.trim().isEmpty) {
      commonSnackBar(
        message: "Please enter a title for the announcement",
        color: Colors.red,
      );
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      commonSnackBar(
        message: "Please enter a description for the announcement",
        color: Colors.red,
      );
      return false;
    }

    return true;
  }

  Future<void> updateAnnouncement() async {
    if (!validateInputs()) return;

    isLoading.value = true;

    final result = await controller.updateAnnouncement(
      announcementId: announcementId,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      classId: classId.isEmpty ? null : classId,
      sectionId: sectionId.isEmpty ? null : sectionId,
      subjectId: subjectId.isEmpty ? null : subjectId,
    );

    isLoading.value = false;

    if (result) {
      Get.back(result: true); // Return true to indicate success
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: "Edit Announcement",
      ),
      body: Obx(
        () =>
            isLoading.value
                ? Center(child: commonLoader())
                : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: commonPadding(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Class and subject info
                        if (className.value.isNotEmpty ||
                            subjectName.value.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: getHeight(16),
                              horizontal: getWidth(20),
                            ),
                            margin: EdgeInsets.only(bottom: getHeight(24)),
                            decoration: BoxDecoration(
                              color: AppColors.blueColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(getWidth(12)),
                              border: Border.all(
                                color: AppColors.blueColor.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(getWidth(8)),
                                      decoration: BoxDecoration(
                                        color: AppColors.blueColor.withOpacity(
                                          0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.info_outline,
                                        color: AppColors.blueColor,
                                        size: getWidth(18),
                                      ),
                                    ),
                                    SizedBox(width: getWidth(12)),
                                    Text(
                                      "Editing announcement for:",
                                      style: TextStyle(
                                        fontSize: getWidth(14),
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textColor.withOpacity(
                                          0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: getHeight(12)),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.school_rounded,
                                      size: getWidth(16),
                                      color: AppColors.textColor.withOpacity(
                                        0.6,
                                      ),
                                    ),
                                    SizedBox(width: getWidth(8)),
                                    Expanded(
                                      child: Text(
                                        className.isNotEmpty
                                            ? "Class $className"
                                            : "All Classes",
                                        style: TextStyle(
                                          fontSize: getWidth(14),
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (sectionName.isNotEmpty) ...[
                                  SizedBox(height: getHeight(6)),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.groups_rounded,
                                        size: getWidth(16),
                                        color: AppColors.textColor.withOpacity(
                                          0.6,
                                        ),
                                      ),
                                      SizedBox(width: getWidth(8)),
                                      Text(
                                        "Section $sectionName",
                                        style: TextStyle(
                                          fontSize: getWidth(14),
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (subjectName.isNotEmpty) ...[
                                  SizedBox(height: getHeight(6)),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.book_rounded,
                                        size: getWidth(16),
                                        color: AppColors.textColor.withOpacity(
                                          0.6,
                                        ),
                                      ),
                                      SizedBox(width: getWidth(8)),
                                      Text(
                                        subjectName.value,
                                        style: TextStyle(
                                          fontSize: getWidth(14),
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.blueColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                        // Title
                        Text(
                          "Announcement Title",
                          style: TextStyle(
                            fontSize: getWidth(16),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(height: getHeight(8)),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(getWidth(12)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                              hintText: "Enter announcement title",
                              hintStyle: TextStyle(
                                color: AppColors.textColor.withOpacity(0.5),
                                fontSize: getWidth(14),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: getWidth(16),
                                vertical: getHeight(14),
                              ),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontSize: getWidth(16),
                              color: AppColors.textColor,
                            ),
                          ),
                        ),

                        SizedBox(height: getHeight(24)),

                        // Description
                        Text(
                          "Announcement Description",
                          style: TextStyle(
                            fontSize: getWidth(16),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(height: getHeight(8)),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(getWidth(12)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: TextField(
                            controller: descriptionController,
                            maxLines: 8,
                            minLines: 5,
                            decoration: InputDecoration(
                              hintText: "Enter announcement description",
                              hintStyle: TextStyle(
                                color: AppColors.textColor.withOpacity(0.5),
                                fontSize: getWidth(14),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: getWidth(16),
                                vertical: getHeight(14),
                              ),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontSize: getWidth(16),
                              color: AppColors.textColor,
                            ),
                          ),
                        ),

                        SizedBox(height: getHeight(36)),

                        // Update button
                        Container(
                          width: double.infinity,
                          height: getHeight(54),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.blueColor,
                                AppColors.blueColor.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(getWidth(12)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blueColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: updateAnnouncement,
                              borderRadius: BorderRadius.circular(getWidth(12)),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.save_rounded,
                                      color: AppColors.white,
                                      size: getWidth(20),
                                    ),
                                    SizedBox(width: getWidth(10)),
                                    Text(
                                      "Update Announcement",
                                      style: TextStyle(
                                        fontSize: getWidth(16),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: getHeight(20)),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
