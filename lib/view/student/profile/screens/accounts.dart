import 'dart:io';

import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/student/student_profile_controller.dart';
import 'package:Vadai/helper/local_storage_helper.dart';
import 'package:Vadai/view/student/profile/screens/plans_screen.dart';
import 'package:Vadai/view/student/profile/screens/rule_book_screen.dart';
import 'package:Vadai/view/student/profile/screens/vad_squad_review_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  StudentProfileController profileCtr = Get.find();

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
      final imageFile = File(pickedImage.path);
      await profileCtr.updateUserInfo(profileImg: imageFile.path);
      await profileCtr.getStudentProfile();
      Get.back();
      commonSnackBar(
        message: "Profile image updated successfully",
        color: AppColors.blueColor,
      );
    } catch (e) {
      Get.back(); // Close loading dialog if open
      commonSnackBar(
        message: "Failed to update profile image. Please try again.",
        color: AppColors.errorColor,
      );
      log("Error updating profile image: $e");
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
              materialButtonWithChild(
                width: double.infinity,
                onPressed: () => Get.to(() => const RuleBookScreen()),
                borderRadius: getWidth(10),
                color: AppColors.blueColor,
                child: Center(
                  child: Text(
                    "Rule Book",
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
                onPressed: () => Get.to(() => const VADSquadReviewScreen()),
                borderRadius: getWidth(10),
                color: AppColors.blueColor,
                child: Center(
                  child: Text(
                    "View → VAD Squad Reviews",
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
                    profileCtr.studentProfile.value?.profileImage != null
                        ? CachedNetworkImage(
                          imageUrl:
                              profileCtr.studentProfile.value!.profileImage!,
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
                  profileCtr.studentProfile.value?.name ?? 'Student Name',
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
                    'Learning Index: ${profileCtr.studentProfile.value?.learningIndex?.toStringAsFixed(1) ?? "N/A"}',
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
      children: [
        _buildAccessRow(
          "Access",
          profileCtr.studentProfile.value?.hasFullPotentialAccess == true
              ? "Premium"
              : "Basic",
        ),
        _buildDetailRow(
          "Student ID",
          profileCtr.studentProfile.value?.studentId ?? "",
        ),
        _buildDetailRow(
          "Language",
          profileCtr.studentProfile.value?.language ?? "",
        ),
      ],
    );
  }

  Widget _buildAcademicDetails() {
    return Column(
      children: [
        _buildDetailRow(
          "School",
          profileCtr.studentProfile.value?.school ?? "",
        ),
        _buildDetailRow(
          "Class",
          '${profileCtr.studentProfile.value?.className ?? ""} ${profileCtr.studentProfile.value?.section ?? ""}',
        ),
        _buildDetailRow(
          "Roll Number",
          '${profileCtr.studentProfile.value?.rollNumber ?? ""}',
        ),
        _buildDetailRow(
          "Subjects",
          _formatSubjects(
            profileCtr.studentProfile.value?.subjects
                ?.map((subject) => subject.subjectName)
                .toList(),
          ),
        ),
        _buildDetailRow(
          "Learning Index",
          '${profileCtr.studentProfile.value?.learningIndex?.toStringAsFixed(1) ?? ""}',
        ),
      ],
    );
  }

  Widget _buildContactDetails() {
    return Column(
      children: [
        _buildDetailRow(
          "Email Address",
          profileCtr.studentProfile.value?.email ?? "",
        ),
        _buildDetailRow(
          "Phone Number",
          profileCtr.studentProfile.value?.phoneNumber?.isNotEmpty == true
              ? profileCtr.studentProfile.value!.phoneNumber!
              : "",
        ),
        _buildDetailRow(
          "Student WhatsApp",
          profileCtr.studentProfile.value?.studentWhatsappNumber ?? "",
        ),
        _buildDetailRow(
          "Parent WhatsApp",
          profileCtr.studentProfile.value?.parentWhatsappNumber ?? "",
        ),
      ],
    );
  }

  Widget _buildAccessRow(String label, String value) {
    return GestureDetector(
      onTap: () {
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
                    children: [
                      Text(
                        "Before proceeding to the next screen, please ensure that your parent or guardian is present, as you have opted to change your VADAI Access level",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: getWidth(16),
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: getHeight(20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: getWidth(16),
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          MaterialButton(
                            color: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            onPressed: () {
                              Get.back();
                              Get.to(
                                () => const PlansScreen(),
                              ); // Navigate to plans screen
                            },
                            child: Text(
                              "Confirm",
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
      },
      child: Container(
        margin: EdgeInsets.only(bottom: getHeight(10)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(getWidth(8)),
          border: Border.all(color: AppColors.blueColor, width: 1.5),
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getWidth(12),
                      vertical: getHeight(4),
                    ),
                    decoration: BoxDecoration(
                      color:
                          value == "Premium"
                              ? AppColors.blueColor.withOpacity(0.1)
                              : AppColors.grey01,
                      borderRadius: BorderRadius.circular(getWidth(16)),
                    ),
                    child: Text(
                      value,
                      style: AppTextStyles.textStyle(
                        txtColor:
                            value == "Premium"
                                ? AppColors.blueColor
                                : AppColors.textColor,
                        fontSize: getWidth(14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: getWidth(8)),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: getWidth(16),
                    color: AppColors.blueColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  String _formatSubjects(List<String?>? subjects) {
    if (subjects == null || subjects.isEmpty) {
      return "";
    }
    return subjects.where((subject) => subject != null).join(", ");
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return "";
    try {
      final DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
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
                          //! uncomment this code to enable logout functionality
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
