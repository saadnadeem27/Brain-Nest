import 'dart:io';

import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_profile_controller.dart';
import 'package:Vadai/helper/local_storage_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

class TeacherAccountScreen extends StatefulWidget {
  const TeacherAccountScreen({super.key});

  @override
  State<TeacherAccountScreen> createState() => _TeacherAccountScreenState();
}

class _TeacherAccountScreenState extends State<TeacherAccountScreen> {
  TeacherProfileController profileCtr = Get.find();

  void _selectProfileImage() {
    Get.dialog(
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            commonPadding(
              child: Container(
                width: getHeight(350),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.white,
                ),
                child: commonPadding(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: getHeight(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        textWid(
                          "${AppStrings.choose} ${AppStrings.anAction}",
                          style: AppTextStyles.textStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        sizeBoxHeight(16),
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _imgSource(
                                source: ImageSource.camera,
                                text: AppStrings.takeAPhoto,
                                camera: true,
                              ),
                              commonPadding(
                                child: const VerticalDivider(
                                  endIndent: 10,
                                  indent: 10,
                                  color: AppColors.white,
                                ),
                              ),
                              _imgSource(
                                source: ImageSource.gallery,
                                text: AppStrings.selectFromGallery,
                                camera: false,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgSource({
    required ImageSource source,
    required String text,
    required bool camera,
  }) {
    return GestureDetector(
      onTap: () {
        _pickAndUploadImage(source: source);
        Get.back();
      },
      child: SizedBox(
        width: getWidth(100),
        child: Column(
          children: [
            CircleAvatar(
              radius: getHeight(25),
              backgroundColor: AppColors.white,
              child:
                  camera
                      ? Icon(
                        Icons.camera_alt,
                        color: AppColors.textColor,
                        size: getWidth(40),
                      )
                      : Icon(
                        Icons.image,
                        color: AppColors.textColor,
                        size: getWidth(40),
                      ),
            ),
            textWid(
              text,
              textAlign: TextAlign.center,
              maxlines: 2,
              textOverflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage({required ImageSource source}) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return;
      Get.dialog(Center(child: commonLoader()), barrierDismissible: false);
      String imageFileName = pickedImage.path.split('/').last;
      String? imageSignedUrl = await profileCtr.getSignedUrl(
        fileName: imageFileName,
        fieldName: 'ProfileImage',
      );

      if (imageSignedUrl == null) {
        commonSnackBar(message: 'Failed to get upload URL for profile image');
        return;
      }
      bool uploadSuccess = await profileCtr.uploadFileWithSignedUrl(
        file: File(pickedImage.path),
        signedUrl: imageSignedUrl,
      );

      if (!uploadSuccess) {
        commonSnackBar(message: 'Failed to upload profile image');
        return;
      }
      Uri uri = Uri.parse(imageSignedUrl);
      String imageUrl = uri.origin + uri.path;
      await profileCtr.updateTeacherProfileImage(profileImg: imageUrl);
      await profileCtr.getTeacherProfile();
    } catch (e) {
      Get.back();
      commonSnackBar(
        message: "Failed to update profile image. Please try again.",
        color: AppColors.errorColor,
      );
      log("Error updating profile image: $e");
    } finally {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(
          "Account Details",
          style: AppTextStyles.textStyle(
            fontSize: getWidth(20),
            fontWeight: FontWeight.w600,
            txtColor: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (profileCtr.isLoading.value) {
          return Center(child: commonLoader());
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              _buildProfileBasicDetails(),
              _buildAcademicDetails(),
              _buildContactDetails(),
              _buildAssignedClasses(),
              materialButtonWithChild(
                width: double.infinity,
                onPressed: () => _showFeedbackDialog(),
                borderRadius: getWidth(10),
                color: AppColors.blueColor,
                child: Center(
                  child: Text(
                    "Share Feedback",
                    style: AppTextStyles.textStyle(
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.w500,
                      txtColor: AppColors.white,
                    ),
                  ),
                ).paddingOnly(top: getHeight(12), bottom: getHeight(12)),
              ).paddingOnly(
                top: getHeight(21),
                left: getWidth(18),
                right: getWidth(18),
              ),
              materialButtonWithChild(
                width: double.infinity,
                onPressed: () => _showLogoutConfirmationDialog(),
                borderRadius: getWidth(10),
                color: AppColors.red,
                child: Center(
                  child: Text(
                    "Logout",
                    style: AppTextStyles.textStyle(
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.w500,
                      txtColor: AppColors.white,
                    ),
                  ),
                ).paddingOnly(top: getHeight(12), bottom: getHeight(12)),
              ).paddingOnly(
                top: getHeight(21),
                left: getWidth(18),
                right: getWidth(18),
                bottom: getHeight(24),
              ),
            ],
          ).paddingOnly(
            left: getWidth(16),
            right: getWidth(16),
            bottom: getHeight(16),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: EdgeInsets.only(bottom: getHeight(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey01, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _selectProfileImage(),
            child: Container(
              width: getWidth(90),
              height: getWidth(90),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.black, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(getWidth(45)),
                child:
                    profileCtr.teacherProfile.value?.profileImage != null
                        ? CachedNetworkImage(
                          imageUrl:
                              profileCtr.teacherProfile.value!.profileImage!,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.blueColor,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Icon(
                                Icons.person,
                                color: AppColors.blueColor,
                                size: getWidth(40),
                              ),
                        )
                        : Icon(
                          Icons.person,
                          color: AppColors.blueColor,
                          size: getWidth(40),
                        ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  profileCtr.teacherProfile.value?.name ?? 'Teacher Name',
                  textAlign: TextAlign.end,
                  style: AppTextStyles.textStyle(
                    txtColor: AppColors.blueColor,
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: getHeight(4)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: getWidth(10),
                    vertical: getHeight(4),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor,
                    border: Border.all(color: AppColors.blueColor, width: 1),
                    borderRadius: BorderRadius.circular(getWidth(12)),
                  ),
                  child: Text(
                    'Status: ${profileCtr.teacherProfile.value?.accountStatus?.toUpperCase() ?? "Active"}',
                    style: AppTextStyles.textStyle(
                      txtColor: AppColors.white,
                      fontSize: getWidth(14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileBasicDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: getWidth(8), bottom: getHeight(8)),
          child: Text(
            "Basic Information",
            style: AppTextStyles.textStyle(
              fontSize: getWidth(16),
              fontWeight: FontWeight.w600,
              txtColor: AppColors.blueColor,
            ),
          ),
        ),
        _buildDetailRow(
          "Teacher ID",
          profileCtr.teacherProfile.value?.teachersId ?? "",
        ),
        _buildDetailRow("Name", profileCtr.teacherProfile.value?.name ?? ""),
        _buildDetailRow("Email", profileCtr.teacherProfile.value?.email ?? ""),
      ],
    );
  }

  Widget _buildAcademicDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: getWidth(8),
            bottom: getHeight(8),
            top: getHeight(16),
          ),
          child: Text(
            "School Information",
            style: AppTextStyles.textStyle(
              fontSize: getWidth(16),
              fontWeight: FontWeight.w600,
              txtColor: AppColors.blueColor,
            ),
          ),
        ),
        _buildDetailRow(
          "School",
          profileCtr.teacherProfile.value?.school ?? "",
        ),
        if (profileCtr.teacherProfile.value?.className?.isNotEmpty == true)
          _buildDetailRow(
            "Class Teacher",
            "${profileCtr.teacherProfile.value?.className ?? ""} ${profileCtr.teacherProfile.value?.section ?? ""}",
          ),
      ],
    );
  }

  Widget _buildContactDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: getWidth(8),
            bottom: getHeight(8),
            top: getHeight(16),
          ),
          child: Text(
            "Contact Information",
            style: AppTextStyles.textStyle(
              fontSize: getWidth(16),
              fontWeight: FontWeight.w600,
              txtColor: AppColors.blueColor,
            ),
          ),
        ),
        _buildDetailRow(
          "Phone Number",
          profileCtr.teacherProfile.value?.phoneNumber?.isNotEmpty == true
              ? profileCtr.teacherProfile.value!.phoneNumber!
              : "Not provided",
        ),
        _buildDetailRow(
          "WhatsApp Number",
          profileCtr.teacherProfile.value?.teachersWhatsappNumber ??
              "Not provided",
        ),
      ],
    );
  }

  Widget _buildAssignedClasses() {
    final classes = profileCtr.teacherProfile.value?.classesAndSubjects;

    if (classes == null || classes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: getWidth(8),
            bottom: getHeight(8),
            top: getHeight(16),
          ),
          child: Text(
            "Teaching Assignments",
            style: AppTextStyles.textStyle(
              fontSize: getWidth(16),
              fontWeight: FontWeight.w600,
              txtColor: AppColors.blueColor,
            ),
          ),
        ),
        ...classes
            .map(
              (assignment) => Container(
                margin: EdgeInsets.only(bottom: getHeight(10)),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(getWidth(8)),
                  border: Border.all(color: AppColors.grey01, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.05),
                      offset: const Offset(0, 3),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(16),
                  vertical: getHeight(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Class ${assignment.className ?? ""}-${assignment.section ?? ""}",
                          style: AppTextStyles.textStyle(
                            txtColor: AppColors.textColor,
                            fontSize: getWidth(15),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: getHeight(4)),
                        Text(
                          "Subject: ${assignment.subjectName ?? ""}",
                          style: AppTextStyles.textStyle(
                            txtColor: AppColors.blueColor,
                            fontSize: getWidth(14),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.blueColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(getWidth(20)),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: getWidth(12),
                        vertical: getHeight(6),
                      ),
                      child: Text(
                        "ID: ${assignment.sId?.substring(0, 6) ?? ""}...",
                        style: AppTextStyles.textStyle(
                          txtColor: AppColors.blueColor,
                          fontSize: getWidth(12),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: getHeight(10)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(getWidth(8)),
        border: Border.all(color: AppColors.grey01, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(16),
        vertical: getHeight(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              maxLines: 3,
              style: AppTextStyles.textStyle(
                txtColor: AppColors.textColor,
                fontSize: getWidth(15),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.textStyle(
                txtColor: AppColors.blueColor,
                fontSize: getWidth(15),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(20),
                vertical: getHeight(20),
              ),
              decoration: BoxDecoration(
                color: AppColors.blueColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textWid(
                    "Ready to log out?",
                    maxlines: 4,
                    style: TextStyle(
                      fontSize: getWidth(18),
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: getHeight(10)),
                  textWid(
                    "We'll miss you! Are you sure you want to leave now?",
                    maxlines: 4,
                    style: TextStyle(
                      fontSize: getWidth(16),
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: getHeight(20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MaterialButton(
                        color: AppColors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onPressed: () => Get.back(),
                        child: textWid(
                          "Stay",
                          style: TextStyle(
                            fontSize: getWidth(16),
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: getWidth(6)),
                      TextButton(
                        onPressed: () {
                          LocalStorage.delete(key: LocalStorageKeys.token);
                          LocalStorage.delete(
                            key: LocalStorageKeys.userDetails,
                          );
                          Get.offAllNamed(RouteNames.appSelection);
                        },
                        child: textWid(
                          "Log Out",
                          style: TextStyle(
                            fontSize: getWidth(16),
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showFeedbackDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(20),
                vertical: getHeight(20),
              ),
              decoration: BoxDecoration(
                color: AppColors.blueColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textWid(
                    "Share Your Feedback",
                    maxlines: 4,
                    style: TextStyle(
                      fontSize: getWidth(18),
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: getHeight(10)),
                  textWid(
                    "Help us improve VADAI! We value your thoughts.",
                    maxlines: 4,
                    style: TextStyle(
                      fontSize: getWidth(16),
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: getHeight(16)),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(getWidth(10)),
                      color: AppColors.white,
                    ),
                    child: commonTextFiled(
                      controller: titleController,
                      hintText: "Title",
                      borderRadius: 10,
                      backgroundColor: AppColors.white,
                    ),
                  ),
                  SizedBox(height: getHeight(12)),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(getWidth(10)),
                      color: AppColors.white,
                    ),
                    child: commonTextFiled(
                      controller: contentController,
                      hintText: "What would you like to tell us?",
                      borderRadius: 10,
                      backgroundColor: AppColors.white,
                      maxLines: 6,
                    ),
                  ),
                  SizedBox(height: getHeight(20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MaterialButton(
                        color: AppColors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onPressed: () => Get.back(),
                        child: textWid(
                          "Cancel",
                          style: TextStyle(
                            fontSize: getWidth(16),
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: getWidth(6)),
                      MaterialButton(
                        color: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) {
                            commonSnackBar(
                              message:
                                  "Please provide a title for your feedback",
                              color: AppColors.errorColor,
                            );
                            return;
                          }

                          if (contentController.text.trim().isEmpty) {
                            commonSnackBar(
                              message: "Please provide feedback content",
                              color: AppColors.errorColor,
                            );
                            return;
                          }

                          Get.back();
                          Get.dialog(
                            Center(child: commonLoader()),
                            barrierDismissible: false,
                          );

                          try {
                            await profileCtr.submitFeedback(
                              title: titleController.text.trim(),
                              content: contentController.text.trim(),
                            );
                            Get.back(); // Close loading dialog
                            commonSnackBar(
                              message: "Feedback submitted successfully!",
                            );
                          } catch (e) {
                            Get.back(); // Close loading dialog
                            commonSnackBar(
                              message:
                                  "Failed to submit feedback. Please try again.",
                              color: AppColors.errorColor,
                            );
                            log("Error submitting feedback: $e");
                          }
                        },
                        child: textWid(
                          "Submit",
                          style: TextStyle(
                            fontSize: getWidth(16),
                            fontWeight: FontWeight.w500,
                            color: AppColors.blueColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
