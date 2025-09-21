import 'dart:io';

import 'package:Vadai/common/widgets/image_source.dart';
import 'package:Vadai/controller/common/ethical_learning_controller.dart';
import 'package:Vadai/helper/api_helper.dart';
import 'package:Vadai/model/students/compendia_model.dart';
import 'package:Vadai/model/students/quiz_model.dart';
import 'package:Vadai/view/common/ethical_learning/upload_compendia/screens/edit_quiz.dart';
import 'package:Vadai/view/common/ethical_learning/upload_compendia/widgets/additional_image_section.dart';
import 'package:Vadai/view/common/ethical_learning/upload_compendia/widgets/category_subcategory_selector.dart';
import 'package:Vadai/view/common/ethical_learning/upload_compendia/widgets/content_section.dart';
import 'package:Vadai/view/common/ethical_learning/upload_compendia/widgets/cover_image_section.dart';
import 'package:Vadai/view/common/ethical_learning/upload_compendia/widgets/note_action_website_section.dart';
import 'package:Vadai/view/common/ethical_learning/upload_compendia/widgets/title_Section.dart';
import 'package:flutter/services.dart';
import 'package:Vadai/common_imports.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class UploadCompendia extends StatefulWidget {
  const UploadCompendia({super.key});

  @override
  State<UploadCompendia> createState() => _UploadCompendiaState();
}

class _UploadCompendiaState extends State<UploadCompendia> {
  EthicalLearningController ethicalCtr = Get.find();
  Rx<File?> coverImage = Rx<File?>(null);
  RxList<QuizModel> generatedQuizzes = <QuizModel>[].obs;
  Rx<File?> contentImage = Rx<File?>(null);
  RxList<File?> imageList = RxList<File?>([]);
  RxList<String> websiteLinks = <String>[].obs;
  RxBool isLoading = false.obs;
  final TextRecognizer textRecognizer = TextRecognizer();
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController websiteLinkController = TextEditingController();
  Rx<CompendiaCategoryModel?> selectedCategory = Rx<CompendiaCategoryModel?>(
    null,
  );
  Rx<CompendiaSubCategoryModel?> selectedSubcategory =
      Rx<CompendiaSubCategoryModel?>(null);
  RxBool isLoadingSUbCategories = false.obs;
  String? continuedFrom;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() {
    if (Get.arguments != null) {
      continuedFrom = Get.arguments[ApiParameter.continuedFrom];
    }
    selectedCategory.value = ethicalCtr.categories.first;
    selectedSubcategory.value = ethicalCtr.subCategories.first;
  }

  void loadSubCategories(String categoryId) async {
    isLoadingSUbCategories.value = true;
    try {
      await ethicalCtr.getSubCategories(categoryId: categoryId).then((
        value,
      ) async {
        if (ethicalCtr.subCategories.isEmpty) {
          log('No subcategories found for category $categoryId');
          return;
        }
        final firstSubCategoryId = ethicalCtr.subCategories.first?.sId;
        if (firstSubCategoryId == null || firstSubCategoryId.isEmpty) {
          log('Invalid first subcategory ID');
          return;
        }
        selectedSubcategory.value = ethicalCtr.subCategories.first;
        await ethicalCtr.getAllCompendia(
          category: categoryId,
          subCategory: firstSubCategoryId,
        );
      });
    } catch (e) {
      log('Error in loadSubCategories: $e');
    } finally {
      isLoadingSUbCategories.value = false;
    }
  }

  void handleQuizCreated(List<QuizModel>? quizzes) {
    if (quizzes != null && quizzes.isNotEmpty) {
      generatedQuizzes.value = quizzes;
      commonSnackBar(
        message: "Successfully generated ${quizzes.length} questions!",
      );
    }
  }

  Future<void> pickImage({
    required ImageSource source,
    required bool isContentImage,
  }) async {
    try {
      isLoading.value = true;
      final proImage = await ImagePicker().pickImage(source: source);
      if (proImage == null) return;

      final imageTemp = File(proImage.path);
      if (isContentImage) {
        contentImage.value = imageTemp;

        // OCR
        final inputImage = InputImage.fromFile(imageTemp);
        final RecognizedText recognizedText = await textRecognizer.processImage(
          inputImage,
        );

        String extractedText = '';
        for (TextBlock block in recognizedText.blocks) {
          extractedText += '${block.text}\n';
        }

        // Set the extracted text to the content controller
        contentController.text = extractedText;
      } else {
        coverImage.value = imageTemp;
      }
    } on PlatformException catch (e) {
      log("Failed to pick image: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void addWebsiteLink() {
    final link = websiteLinkController.text.trim();
    if (link.isEmpty) {
      commonSnackBar(message: 'Please enter a website link.');
      return;
    }

    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      final correctedLink = 'https://$link';
      websiteLinks.add(correctedLink);
      websiteLinkController.clear();
    } else {
      websiteLinks.add(link);
      websiteLinkController.clear();
    }
  }

  Future<void> pickMultipleImage() async {
    try {
      final images = await ImagePicker().pickMultiImage(imageQuality: 80);
      if (images == null || images.isEmpty) return;
      imageList.addAll(images.map((e) => File(e.path)).toList());
    } on PlatformException catch (e) {
      log("Failed to pick image: $e");
    }
  }

  Future<void> submit() async {
    // Validate required fields
    if (titleController.text.trim().isEmpty) {
      commonSnackBar(message: 'Please enter a title.');
      return;
    } else if (contentController.text.trim().isEmpty) {
      commonSnackBar(message: 'Please enter content.');
      return;
    } else if (selectedCategory.value == null) {
      commonSnackBar(message: 'Please select a category.');
      return;
    } else if (selectedSubcategory.value == null) {
      commonSnackBar(message: 'Please select a subcategory.');
      return;
    } else if (coverImage.value == null) {
      commonSnackBar(message: 'Please add a cover image.');
      return;
    }
    List<Map<String, dynamic>> mcqsFormatted = [];
    for (var quiz in generatedQuizzes) {
      mcqsFormatted.add({
        "question": quiz.question,
        "answerOptions": quiz.answerOptions,
        "correctOptionIndex": quiz.correctOptionIndex,
        "imageUrl": "",
      });
    }

    isLoading.value = true;

    try {
      // 1. Process cover image - Get signed URL and upload
      String coverImageUrl = '';
      if (coverImage.value != null) {
        // Extract filename from path
        String coverImageFileName = coverImage.value!.path.split('/').last;

        // Get signed URL for cover image
        String? coverImageSignedUrl = await ethicalCtr.getSignedUrl(
          fileName: coverImageFileName,
          fieldName: 'Compendia',
        );

        if (coverImageSignedUrl != null) {
          // Upload cover image using signed URL
          bool coverUploadSuccess = await ethicalCtr.uploadFileWithSignedUrl(
            file: coverImage.value!,
            signedUrl: coverImageSignedUrl,
          );

          if (coverUploadSuccess) {
            // Extract the actual URL from the signed URL (remove query params)
            Uri uri = Uri.parse(coverImageSignedUrl);
            coverImageUrl = uri.origin + uri.path;
            log('Cover image uploaded successfully: $coverImageUrl');
          } else {
            isLoading.value = false;
            commonSnackBar(message: 'Failed to upload cover image.');
            return;
          }
        } else {
          isLoading.value = false;
          commonSnackBar(message: 'Failed to get signed URL for cover image.');
          return;
        }
      }

      // 2. Process additional images - Get signed URLs and upload all
      List<String> uploadedImageUrls = [];
      if (imageList.isNotEmpty) {
        for (int i = 0; i < imageList.length; i++) {
          if (imageList[i] != null) {
            // Extract filename from path
            String imageFileName = imageList[i]!.path.split('/').last;

            // Get signed URL for image
            String? imageSignedUrl = await ethicalCtr.getSignedUrl(
              fileName: imageFileName,
              fieldName: 'Compendia',
            );

            if (imageSignedUrl != null) {
              // Upload image using signed URL
              bool imageUploadSuccess = await ethicalCtr
                  .uploadFileWithSignedUrl(
                    file: imageList[i]!,
                    signedUrl: imageSignedUrl,
                  );

              if (imageUploadSuccess) {
                // Extract the actual URL from the signed URL
                Uri uri = Uri.parse(imageSignedUrl);
                String imageUrl = uri.origin + uri.path;
                uploadedImageUrls.add(imageUrl);
                log('Image ${i + 1} uploaded successfully: $imageUrl');
              } else {
                log('Failed to upload image ${i + 1}');
              }
            }
          }
        }
      }

      // 3. Submit compendia with all data
      await ethicalCtr
          .addCompendia(
            title: titleController.text.trim(),
            contents: contentController.text.trim(),
            websiteLinks: websiteLinks, // Use list of website links
            coverImage: coverImageUrl,
            images: uploadedImageUrls,
            category: selectedCategory.value?.sId ?? '',
            subcategory: selectedSubcategory.value?.sId ?? '',
            numberOfQuestions: 0,
            MCQs: mcqsFormatted,
            continuedFrom: continuedFrom ?? '',
          )
          .then((bool? value) {
            if (value == true) {
              Get.back(result: true);
            } else {
              commonSnackBar(message: 'Failed to create compendia.');
            }
          });
    } catch (e) {
      log('Error in submit: $e');
      commonSnackBar(message: 'An error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    textRecognizer.close();
    titleController.dispose();
    contentController.dispose();
    websiteLinkController.dispose();
    super.dispose();
  }

  void selectImage({required bool isContentImage}) async {
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
                              ImageSourceOption(
                                source: ImageSource.camera,
                                text: AppStrings.takeAPhoto,
                                icon: Icons.camera_alt,
                                isContentImage: isContentImage,
                                onTap: () {
                                  pickImage(
                                    source: ImageSource.camera,
                                    isContentImage: isContentImage,
                                  );
                                  Get.back();
                                },
                              ),
                              commonPadding(
                                child: const VerticalDivider(
                                  endIndent: 10,
                                  indent: 10,
                                  color: AppColors.grey,
                                ),
                              ),
                              ImageSourceOption(
                                source: ImageSource.gallery,
                                text: AppStrings.selectFromGallery,
                                icon: Icons.image_outlined,
                                isContentImage: isContentImage,
                                onTap: () {
                                  pickImage(
                                    source: ImageSource.gallery,
                                    isContentImage: isContentImage,
                                  );
                                  Get.back();
                                },
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

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        isBack: true,
        title: AppStrings.uploadCompendium,
        actions: [],
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleSection(controller: titleController),
                  ContentSection(
                    controller: contentController,
                    onImageTap: () => selectImage(isContentImage: true),
                  ).paddingOnly(top: getHeight(16)),
                  const NoteSection().paddingOnly(
                    left: getWidth(8),
                    right: getWidth(8),
                    top: getHeight(16),
                  ),
                  WebsiteLinkSection(
                    controller: websiteLinkController,
                    websiteLinks: websiteLinks,
                    onAddLink: addWebsiteLink,
                  ),
                  CoverImageSection(
                    coverImage: coverImage,
                    onSelectImage: () => selectImage(isContentImage: false),
                  ).paddingOnly(top: getHeight(16)),
                  AdditionalImagesSection(
                    imageList: imageList,
                    onPickImages: pickMultipleImage,
                  ).paddingOnly(top: getHeight(16)),
                  CategorySelector(
                    ethicalCtr: ethicalCtr,
                    selectedCategory: selectedCategory,
                    onCategorySelected: (index) {
                      selectedCategory.value = ethicalCtr.categories[index];
                      loadSubCategories(
                        ethicalCtr.categories[index]?.sId ?? '',
                      );
                    },
                  ).paddingOnly(top: getHeight(16)),
                  if (isLoadingSUbCategories.value)
                    const Center(child: CircularProgressIndicator())
                  else
                    SubcategorySelector(
                      ethicalCtr: ethicalCtr,
                      selectedSubcategory: selectedSubcategory,
                      onSubcategorySelected: (subCategory) {
                        selectedSubcategory.value = subCategory;
                      },
                    ).paddingOnly(top: getHeight(8)),
                  _buildQuizPreviewSection(),
                  ActionButtons(
                    contentController: contentController,
                    ethicalCtr: ethicalCtr,
                    onQuizCreate: handleQuizCreated,
                    onSubmit: submit,
                    generatedQuizzes: generatedQuizzes,
                  ).paddingOnly(top: getHeight(16)),
                ],
              ).paddingOnly(
                left: getWidth(16),
                right: getWidth(16),
                bottom: getHeight(36),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildQuizPreviewSection() {
    return Obx(
      () =>
          generatedQuizzes.isNotEmpty
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Quiz Questions (${generatedQuizzes.length})",
                        style: TextStyle(
                          fontSize: getWidth(18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: AppColors.blueColor,
                          size: getWidth(20),
                        ),
                        onPressed: () {
                          Get.to(
                            () => const UploadCompendiaEditQize(),
                            arguments: {'quizzes': generatedQuizzes},
                          )?.then((result) {
                            if (result != null && result is List<QuizModel>) {
                              generatedQuizzes.value = result;
                            }
                          });
                        },
                      ),
                    ],
                  ).paddingOnly(top: getHeight(16), bottom: getHeight(8)),

                  // Question preview cards
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // Success message at top
                        Container(
                          padding: EdgeInsets.all(getWidth(12)),
                          decoration: BoxDecoration(
                            color: AppColors.blueColor.withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            border: Border.all(
                              color: AppColors.blueColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.blueColor,
                                size: getWidth(20),
                              ),
                              SizedBox(width: getWidth(8)),
                              Expanded(
                                child: Text(
                                  "${generatedQuizzes.length} multiple-choice questions ready",
                                  style: TextStyle(
                                    fontSize: getWidth(14),
                                    color: AppColors.blueColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...List.generate(
                          generatedQuizzes.length > 3
                              ? 3
                              : generatedQuizzes.length,
                          (index) => _buildQuestionPreview(index),
                        ),
                        if (generatedQuizzes.length > 3)
                          InkWell(
                            onTap: () {
                              Get.to(
                                () => const UploadCompendiaEditQize(),
                                arguments: {'quizzes': generatedQuizzes},
                              )?.then((result) {
                                if (result != null &&
                                    result is List<QuizModel>) {
                                  generatedQuizzes.value = result;
                                }
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(getWidth(12)),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "View all ${generatedQuizzes.length} questions",
                                  style: const TextStyle(
                                    color: AppColors.blueColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              )
              : const SizedBox.shrink(),
    );
  }

  Widget _buildQuestionPreview(int index) {
    final quiz = generatedQuizzes[index];

    return Container(
      padding: EdgeInsets.all(getWidth(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.3))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text with number
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(getWidth(6)),
                decoration: BoxDecoration(
                  color: AppColors.blueColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: getWidth(10),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: getWidth(8)),
              Expanded(
                child: Text(
                  quiz.question ?? "Question ${index + 1}",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),

          // Show correct answer
          if (quiz.answerOptions != null &&
              quiz.correctOptionIndex != null &&
              quiz.correctOptionIndex! < quiz.answerOptions!.length)
            Padding(
              padding: EdgeInsets.only(left: getWidth(24), top: getHeight(4)),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.green,
                    size: getWidth(14),
                  ),
                  SizedBox(width: getWidth(4)),
                  Expanded(
                    child: Text(
                      "Answer: ${quiz.answerOptions![quiz.correctOptionIndex!]}",
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: getWidth(12),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
