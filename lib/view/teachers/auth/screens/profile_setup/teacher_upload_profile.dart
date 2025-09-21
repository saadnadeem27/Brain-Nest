import 'dart:io';
import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_auth_controller.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class TeacherUploadProfile extends StatefulWidget {
  const TeacherUploadProfile({super.key});

  @override
  State<TeacherUploadProfile> createState() => _TeacherUploadProfileState();
}

class _TeacherUploadProfileState extends State<TeacherUploadProfile> {
  TeacherAuthController authController = Get.find<TeacherAuthController>();
  RxBool isImageLoading = false.obs;
  RxBool isLoading = false.obs;
  RxBool isUploading = false.obs;
  Rx<File?> profileImage = Rx<File?>(null);
  Rx<String?> uploadedImageUrl = Rx<String?>(null);

  Future<void> pickImage({required ImageSource source}) async {
    try {
      isImageLoading.value = true;
      final proImage = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
      );
      if (proImage == null) return;

      final imageTemp = File(proImage.path);
      profileImage.value = imageTemp;
      uploadedImageUrl.value = null;

      // Automatically trigger upload after image selection
      isImageLoading.value = false;
      await uploadProfileImage();
    } on PlatformException catch (e) {
      log("------------------->>>>>>Failed to pick image: $e", error: e);
      isImageLoading.value = false;
    }
  }

  Future<bool> uploadProfileImage() async {
    if (profileImage.value == null) {
      return false;
    }

    isUploading.value = true;
    try {
      String imageFileName = profileImage.value!.path.split('/').last;
      String? imageSignedUrl = await authController.getSignedUrl(
        fileName: imageFileName,
        fieldName: 'ProfileImage',
      );

      if (imageSignedUrl == null) {
        commonSnackBar(message: 'Failed to get upload URL for profile image');
        return false;
      }
      bool uploadSuccess = await authController.uploadFileWithSignedUrl(
        file: profileImage.value!,
        signedUrl: imageSignedUrl,
      );

      if (!uploadSuccess) {
        commonSnackBar(message: 'Failed to upload profile image');
        return false;
      }
      Uri uri = Uri.parse(imageSignedUrl);
      String imageUrl = uri.origin + uri.path;
      uploadedImageUrl.value = imageUrl;
      return true;
    } catch (e) {
      log('Error uploading profile image: $e');
      commonSnackBar(message: 'Failed to upload image. Please try again.');
      return false;
    } finally {
      isUploading.value = false;
    }
  }

  submit() async {
    if (profileImage.value == null) {
      commonSnackBar(message: 'Please select a profile image');
      return;
    }

    if (uploadedImageUrl.value == null) {
      commonSnackBar(message: 'Please wait for the image to upload');
      return;
    }

    isLoading.value = true;
    try {
      Get.toNamed(
        RouteNames.teacherUploadSchoolDetails,
        arguments: {'profileImageUrl': uploadedImageUrl.value},
      );
    } catch (e) {
      log('Error in profile submission: $e');
      commonSnackBar(message: 'An error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(context: context, isBack: true, title: ""),
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: getHeight(40)),
              Image.asset(AppAssets.logo, width: getWidth(220)),
              Text(
                "Your profile picture helps students and colleagues recognize you",
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textColor.withOpacity(0.7),
                  fontSize: getWidth(14),
                ),
              ).paddingOnly(left: getWidth(16), right: getWidth(16)),
              Align(
                alignment: Alignment.centerLeft,
                child: textWid(
                  "Teacher Profile Picture",
                  style: AppTextStyles.textStyle(
                    fontSize: getWidth(20),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ).paddingOnly(top: getHeight(48)),

              // Upload status indicator
              if (uploadedImageUrl.value != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: getWidth(16),
                      ),
                      SizedBox(width: getWidth(8)),
                      Text(
                        'Image uploaded successfully',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: getWidth(14),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ).paddingOnly(top: getHeight(8), bottom: getHeight(16)),

              // Profile image with loading states
              if (isLoading.value || isImageLoading.value) ...{
                SizedBox(
                  height: getHeight(150),
                  width: getWidth(150),
                  child: commonLoader(),
                ),
              } else if (isUploading.value) ...{
                // Upload in progress UI
                Container(
                  height: getHeight(150),
                  width: getHeight(150),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.blueColor,
                      width: getWidth(3),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.blueColor,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: getHeight(8)),
                        Text(
                          'Uploading...',
                          style: TextStyle(
                            fontSize: getWidth(12),
                            color: AppColors.blueColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              } else
                // Profile image display with border
                GestureDetector(
                  onTap: () => selectImage(),
                  child: Center(
                    child:
                        profileImage.value != null
                            ? Container(
                              height: getHeight(150),
                              width: getHeight(150),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      uploadedImageUrl.value != null
                                          ? Colors.green
                                          : AppColors.blueColor,
                                  width: getWidth(3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.file(
                                  profileImage.value ?? File(""),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                            : Icon(
                              Icons.account_circle_rounded,
                              size: getWidth(170),
                              color: AppColors.color7D818A,
                            ),
                  ).paddingOnly(top: getHeight(32)),
                ),

              // Select image button - only show if no image is selected yet or upload failed
              if (profileImage.value == null || uploadedImageUrl.value == null)
                materialButtonWithChild(
                  width: double.infinity,
                  onPressed: () => selectImage(),
                  borderColor: AppColors.color7D818A,
                  borderWidth: getWidth(2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        profileImage.value != null
                            ? Icons.refresh
                            : Icons.add_photo_alternate,
                        color: AppColors.textColor,
                        size: getWidth(20),
                      ),
                      SizedBox(width: getWidth(8)),
                      textWid(
                        profileImage.value != null
                            ? (isUploading.value ? 'Uploading...' : 'Try Again')
                            : AppStrings.addPicture,
                        style: AppTextStyles.textStyle(
                          fontSize: getWidth(14),
                          fontWeight: FontWeight.w500,
                          txtColor: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                  color: AppColors.transparent,
                  padding: EdgeInsets.only(
                    top: getHeight(16),
                    bottom: getHeight(16),
                  ),
                ).paddingOnly(
                  top: getHeight(42),
                  left: getWidth(8),
                  right: getWidth(8),
                ),

              // Continue button - disabled until image is uploaded
              materialButtonWithChild(
                width: double.infinity,
                onPressed: uploadedImageUrl.value != null ? submit : null,
                color:
                    uploadedImageUrl.value != null
                        ? AppColors.blueColor
                        : AppColors.blueColor.withOpacity(0.5),
                child: textWid(
                  AppStrings.continueString,
                  style: AppTextStyles.textStyle(
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w500,
                    txtColor: AppColors.white,
                  ),
                ),
                padding: EdgeInsets.only(
                  top: getHeight(18),
                  bottom: getHeight(18),
                ),
              ).paddingOnly(
                top: getHeight(24),
                left: getWidth(8),
                right: getWidth(8),
              ),
            ],
          ).paddingOnly(
            left: getWidth(28),
            right: getWidth(28),
            top: getHeight(16),
            bottom: getHeight(130),
          ),
        ),
      ),
    );
  }

  imgSource({
    required ImageSource source,
    required String text,
    required bool camera,
  }) {
    return GestureDetector(
      onTap: () {
        pickImage(source: source);
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

  selectImage() async {
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
                              imgSource(
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
                              imgSource(
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
}
