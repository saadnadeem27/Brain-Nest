import 'dart:io';

import 'package:Vadai/common_imports.dart';
import 'package:Vadai/controller/teachers/teacher_classroom_controller.dart';
import 'package:Vadai/model/common/module_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class TeacherModuleDetailsScreen extends StatefulWidget {
  const TeacherModuleDetailsScreen({Key? key}) : super(key: key);

  @override
  State<TeacherModuleDetailsScreen> createState() =>
      _TeacherModuleDetailsScreenState();
}

class _TeacherModuleDetailsScreenState
    extends State<TeacherModuleDetailsScreen> {
  final TeacherClassroomController controller = Get.find();
  ModuleModel? module;
  String? chapterName;
  final RxBool isLoading = false.obs;
  RxList<DocumentToUpload> documentsToAdd = <DocumentToUpload>[].obs;
  RxBool isUploading = false.obs;

  // Controllers for adding new document
  final TextEditingController documentNameController = TextEditingController();
  final TextEditingController documentLinkController = TextEditingController();
  final RxString selectedDocType = 'document/pdf'.obs;

  final List<Map<String, dynamic>> documentTypes = [
    {
      'value': 'document/pdf',
      'label': 'PDF Document',
      'icon': Icons.picture_as_pdf_rounded,
    },
    {'value': 'document/image', 'label': 'Image', 'icon': Icons.image_rounded},
    {'value': 'document/link', 'label': 'Web Link', 'icon': Icons.link_rounded},
    {
      'value': 'document/text',
      'label': 'Text Document',
      'icon': Icons.text_snippet_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    documentNameController.dispose();
    documentLinkController.dispose();
    super.dispose();
  }

  void initData() {
    try {
      if (Get.arguments != null) {
        module = Get.arguments['module'];
        chapterName = Get.arguments['chapterName'];
      }

      if (module == null) {
        Get.back();
      }
    } catch (e) {
      log('Error in initData of TeacherModuleDetailsScreen: $e');
    }
  }

  Color getDocumentColor(String? type) {
    if (type == null) return AppColors.grey;

    if (type.contains('pdf')) {
      return AppColors.red.withOpacity(0.8);
    } else if (type.contains('image')) {
      return AppColors.blueColor.withOpacity(0.7);
    } else if (type.contains('link')) {
      return AppColors.webLinkColor;
    } else if (type.contains('text')) {
      return AppColors.green.withOpacity(0.7);
    } else {
      return AppColors.grey;
    }
  }

  IconData getDocumentIcon(String? type) {
    if (type == null) return Icons.insert_drive_file_outlined;

    if (type.contains('pdf')) {
      return Icons.picture_as_pdf_rounded;
    } else if (type.contains('image')) {
      return Icons.image_rounded;
    } else if (type.contains('link')) {
      return Icons.link_rounded;
    } else if (type.contains('text')) {
      return Icons.text_snippet_rounded;
    } else {
      return Icons.insert_drive_file_outlined;
    }
  }

  Future<void> openDocument(String? url) async {
    if (url == null || url.isEmpty) {
      commonSnackBar(message: "Document URL is invalid", color: Colors.red);
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri);
      } else {
        commonSnackBar(message: "Could not open document", color: Colors.red);
      }
    } catch (e) {
      log('Error opening document: $e');
      commonSnackBar(message: "Error opening document", color: Colors.red);
    }
  }

  Future<void> refreshModuleData() async {
    isLoading.value = true;

    try {
      // Fetch the updated module data
      final modulesList = await controller.getTeachersResourceModuleList(
        chapterId: module?.chapterId ?? '',
      );

      if (modulesList != null) {
        // Find the current module in the updated list
        for (var updatedModule in modulesList) {
          if (updatedModule.sId == module?.sId) {
            module = updatedModule;
            // Force UI refresh
            setState(() {});
            break;
          }
        }
      }
    } catch (e) {
      log('Error refreshing module data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickFile({required String type}) async {
    try {
      if (type.contains('image')) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (image == null) return;

        DocumentToUpload newDoc = DocumentToUpload(
          name: image.name,
          type: 'document/image',
          file: File(image.path),
        );
        documentsToAdd.add(newDoc);

        // Set first document name to the text field if empty
        if (documentNameController.text.isEmpty && documentsToAdd.length == 1) {
          documentNameController.text = image.name;
        }
      } else {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: type.contains('pdf') ? FileType.custom : FileType.any,
          allowedExtensions: type.contains('pdf') ? ['pdf'] : null,
          allowMultiple: true,
        );

        if (result == null || result.files.isEmpty) return;

        for (var file in result.files) {
          if (file.path != null) {
            String fileType = _determineFileType(file.extension ?? '');

            DocumentToUpload newDoc = DocumentToUpload(
              name: file.name,
              type: fileType,
              file: File(file.path!),
            );
            documentsToAdd.add(newDoc);
          }
        }

        // Set first document name to the text field if empty
        if (documentNameController.text.isEmpty && documentsToAdd.isNotEmpty) {
          documentNameController.text = documentsToAdd.first.name;
        }
      }
    } on PlatformException catch (e) {
      log('Failed to pick file: $e');
      commonSnackBar(
        message: "Failed to pick file: ${e.message}",
        color: Colors.red,
      );
    } catch (e) {
      log('Error picking file: $e');
      commonSnackBar(
        message: "Error selecting file. Please try again.",
        color: Colors.red,
      );
    }
  }

  String _determineFileType(String extension) {
    extension = extension.toLowerCase();
    if ([
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'bmp',
      'heic',
    ].contains(extension)) {
      return 'document/image';
    } else if (extension == 'pdf') {
      return 'document/pdf';
    } else if (['doc', 'docx', 'txt', 'rtf', 'odt'].contains(extension)) {
      return 'document/text';
    } else {
      return 'document/file';
    }
  }

  Future<bool> uploadAllFiles() async {
    if (documentsToAdd.isEmpty) {
      return true; // Nothing to upload
    }

    isUploading.value = true;
    bool allUploaded = true;

    try {
      for (int i = 0; i < documentsToAdd.length; i++) {
        final doc = documentsToAdd[i];

        // Skip web links or already uploaded files
        if (doc.type.contains('link') || doc.isUploaded) {
          continue;
        }

        if (doc.file == null) {
          allUploaded = false;
          continue;
        }

        // Mark this document as currently uploading
        doc.isUploading = true;
        documentsToAdd[i] = doc;

        // Get signed URL
        String? signedUrl = await controller.getSignedUrl(
          fileName: doc.name,
          fieldName: 'ModuleFile',
        );

        if (signedUrl == null) {
          log('Failed to get upload URL for ${doc.name}');
          doc.isUploading = false;
          allUploaded = false;
          continue;
        }

        // Upload the file
        bool uploadSuccess = await controller.uploadFileWithSignedUrl(
          file: doc.file!,
          signedUrl: signedUrl,
        );

        if (!uploadSuccess) {
          log('Failed to upload file ${doc.name}');
          doc.isUploading = false;
          allUploaded = false;
          continue;
        }

        // Extract just the URL path from the signed URL
        Uri uri = Uri.parse(signedUrl);
        String fileUrl = uri.origin + uri.path;

        // Update document with the uploaded URL
        doc.uploadedLink = fileUrl;
        doc.isUploading = false;
        doc.isUploaded = true;
        documentsToAdd[i] = doc;
      }

      return allUploaded;
    } catch (e) {
      log('Error uploading files: $e');
      return false;
    } finally {
      isUploading.value = false;
    }
  }

  void showAddDocumentDialog() {
    // Reset controllers and state
    documentNameController.clear();
    documentLinkController.clear();
    documentsToAdd.clear();
    selectedDocType.value = 'document/pdf';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(getWidth(16)),
        ),
        child: Container(
          width: getWidth(400),
          padding: EdgeInsets.all(getWidth(20)),
          child: Obx(
            () => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add New Documents",
                    style: TextStyle(
                      fontSize: getWidth(18),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: getHeight(24)),

                  // Document type toggle - simplified to just offer file or web link
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            selectedDocType.value = 'document/file';
                            documentsToAdd.clear();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                !selectedDocType.value.contains('link')
                                    ? AppColors.blueColor
                                    : AppColors.grey.withOpacity(0.2),
                            foregroundColor:
                                !selectedDocType.value.contains('link')
                                    ? Colors.white
                                    : AppColors.textColor,
                            elevation:
                                !selectedDocType.value.contains('link') ? 2 : 0,
                            padding: EdgeInsets.symmetric(
                              vertical: getHeight(12),
                            ),
                          ),
                          child: Text("Upload Files"),
                        ),
                      ),
                      SizedBox(width: getWidth(12)),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            selectedDocType.value = 'document/link';
                            documentsToAdd.clear();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                selectedDocType.value.contains('link')
                                    ? AppColors.blueColor
                                    : AppColors.grey.withOpacity(0.2),
                            foregroundColor:
                                selectedDocType.value.contains('link')
                                    ? Colors.white
                                    : AppColors.textColor,
                            elevation:
                                selectedDocType.value.contains('link') ? 2 : 0,
                            padding: EdgeInsets.symmetric(
                              vertical: getHeight(12),
                            ),
                          ),
                          child: Text("Web Link"),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: getHeight(20)),

                  // Group name field (for all documents)
                  Text(
                    selectedDocType.value.contains('link')
                        ? "Link Name"
                        : "Group Name (Optional)",
                    style: TextStyle(
                      fontSize: getWidth(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: getHeight(8)),

                  commonTextFiled(
                    controller: documentNameController,
                    hintText:
                        selectedDocType.value.contains('link')
                            ? "Enter link name"
                            : "Enter name for these documents (optional)",
                  ),

                  SizedBox(height: getHeight(20)),

                  // File upload section - show for file option
                  if (!selectedDocType.value.contains('link')) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Upload Files (${documentsToAdd.length})",
                          style: TextStyle(
                            fontSize: getWidth(14),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        ElevatedButton(
                          onPressed: () => pickFile(type: 'any'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blueColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidth(12),
                              vertical: getHeight(8),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(getWidth(8)),
                            ),
                          ),
                          child: Text(
                            "Add Files",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: getHeight(8)),

                    // Show selected files list
                    if (documentsToAdd.isNotEmpty) ...[
                      Container(
                        constraints: BoxConstraints(maxHeight: getHeight(200)),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.grey.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(getWidth(8)),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: documentsToAdd.length,
                          itemBuilder: (context, index) {
                            final doc = documentsToAdd[index];
                            return ListTile(
                              leading: Icon(
                                getDocumentIcon(doc.type),
                                color: getDocumentColor(doc.type),
                              ),
                              title: Text(
                                doc.name,
                                style: TextStyle(fontSize: getWidth(14)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                _getReadableDocType(doc.type),
                                style: TextStyle(fontSize: getWidth(12)),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  documentsToAdd.removeAt(index);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(getWidth(16)),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.grey.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(getWidth(8)),
                          color: AppColors.grey.withOpacity(0.05),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: getWidth(32),
                              color: AppColors.grey,
                            ),
                            SizedBox(height: getHeight(8)),
                            Text(
                              "No files selected",
                              style: TextStyle(
                                fontSize: getWidth(14),
                                color: AppColors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: getHeight(4)),
                            Text(
                              "Click 'Add Files' to select multiple files",
                              style: TextStyle(
                                fontSize: getWidth(12),
                                color: AppColors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],

                  // Web link field - show only for 'link' type
                  if (selectedDocType.value.contains('link')) ...[
                    Text(
                      "Web Link",
                      style: TextStyle(
                        fontSize: getWidth(14),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: getHeight(8)),

                    commonTextFiled(
                      controller: documentLinkController,
                      hintText: "Enter URL (https://...)",
                    ),
                  ],

                  SizedBox(height: getHeight(24)),

                  // Info text based on document type
                  Text(
                    selectedDocType.value.contains('link')
                        ? "Note: Web links must be valid URLs beginning with http:// or https://"
                        : "Note: Each file size should be less than 10MB",
                    style: TextStyle(
                      fontSize: getWidth(12),
                      color: AppColors.textColor2,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: getHeight(24)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: getWidth(14),
                          ),
                        ),
                      ),
                      SizedBox(width: getWidth(12)),
                      ElevatedButton(
                        onPressed:
                            isUploading.value
                                ? null // Disable during upload
                                : () async {
                                  // For link type, validate and add link
                                  if (selectedDocType.value.contains('link')) {
                                    if (documentNameController.text
                                        .trim()
                                        .isEmpty) {
                                      commonSnackBar(
                                        message:
                                            "Please enter a name for the link",
                                        color: Colors.red,
                                      );
                                      return;
                                    }

                                    if (documentLinkController.text
                                        .trim()
                                        .isEmpty) {
                                      commonSnackBar(
                                        message: "Please enter a web link",
                                        color: Colors.red,
                                      );
                                      return;
                                    }

                                    if (!documentLinkController.text
                                        .trim()
                                        .startsWith('http')) {
                                      commonSnackBar(
                                        message:
                                            "Please enter a valid URL starting with http:// or https://",
                                        color: Colors.red,
                                      );
                                      return;
                                    }

                                    // Add the link as a document
                                    documentsToAdd.add(
                                      DocumentToUpload(
                                        name:
                                            documentNameController.text.trim(),
                                        type: 'document/link',
                                        link:
                                            documentLinkController.text.trim(),
                                      ),
                                    );
                                  }
                                  // For file types, validate file selection
                                  else if (documentsToAdd.isEmpty) {
                                    commonSnackBar(
                                      message:
                                          "Please select at least one file to upload",
                                      color: Colors.red,
                                    );
                                    return;
                                  }

                                  Get.back(); // Close dialog

                                  // Show loading dialog
                                  Get.dialog(
                                    Center(child: commonLoader()),
                                    barrierDismissible: false,
                                  );

                                  // Upload all files
                                  final uploadSuccess = await uploadAllFiles();

                                  if (!uploadSuccess) {
                                    Get.back(); // Close loading dialog
                                    commonSnackBar(
                                      message: "Some files failed to upload",
                                      color: Colors.orange,
                                    );
                                    return;
                                  }

                                  // Prepare documents data structure for API
                                  final List<Map<String, String>> docsData = [];
                                  for (var doc in documentsToAdd) {
                                    Map<String, String> docData = {
                                      'name': doc.name,
                                      'type': doc.type,
                                      'link':
                                          doc.uploadedLink ?? doc.link ?? '',
                                    };
                                    docsData.add(docData);
                                  }

                                  // Add documents to the module
                                  final result = await controller.addDocument(
                                    moduleId: module?.sId ?? '',
                                    documents: docsData,
                                  );

                                  Get.back(); // Close loading dialog

                                  if (result) {
                                    // Refresh module data to show the new documents
                                    await refreshModuleData();
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isUploading.value
                                  ? AppColors.grey
                                  : AppColors.blueColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: getWidth(16),
                            vertical: getHeight(10),
                          ),
                        ),
                        child: Text(
                          isUploading.value
                              ? "Uploading..."
                              : selectedDocType.value.contains('link')
                              ? "Add Link"
                              : "Add Documents",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: getWidth(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getReadableDocType(String type) {
    if (type.contains('pdf')) {
      return 'PDF Document';
    } else if (type.contains('image')) {
      return 'Image';
    } else if (type.contains('text')) {
      return 'Text Document';
    } else if (type.contains('application')) {
      return 'Office Document';
    } else {
      return 'File';
    }
  }

  void showDeleteDocumentConfirmation(Documents document) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(getWidth(16)),
        ),
        child: Container(
          padding: EdgeInsets.all(getWidth(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: getWidth(48),
              ),
              SizedBox(height: getHeight(16)),

              Text(
                "Delete Document?",
                style: TextStyle(
                  fontSize: getWidth(18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: getHeight(8)),

              Text(
                "Are you sure you want to delete '${document.name}'? This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: getWidth(14),
                  color: AppColors.textColor.withOpacity(0.7),
                ),
              ),

              SizedBox(height: getHeight(24)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.grey),
                        padding: EdgeInsets.symmetric(vertical: getHeight(12)),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: getWidth(14),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: getWidth(12)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back(); // Close dialog

                        // Show loading indicator
                        Get.dialog(
                          Center(child: commonLoader()),
                          barrierDismissible: false,
                        );

                        final success = await controller.deleteDocument(
                          moduleId: module?.sId ?? '',
                          documentId: document.sId ?? '',
                        );

                        Get.back(); // Close loading dialog

                        if (success) {
                          // Refresh module data to update documents list
                          await refreshModuleData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: getHeight(12)),
                      ),
                      child: Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: getWidth(14),
                        ),
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

  @override
  Widget build(BuildContext context) {
    return commonScaffold(
      context: context,
      appBar: commonAppBar(
        context: context,
        title: module?.moduleName ?? "Module Details",
        isBack: true,
        actions: [
          // Add document button in app bar
          IconButton(
            onPressed: showAddDocumentDialog,
            icon: Icon(Icons.add_circle_outline, color: AppColors.blueColor),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDocumentDialog,
        backgroundColor: AppColors.blueColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(
        () =>
            isLoading.value
                ? Center(child: commonLoader())
                : SingleChildScrollView(
                  padding: EdgeInsets.all(getWidth(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Module info card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(getWidth(16)),
                        margin: EdgeInsets.only(bottom: getHeight(24)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.blueColor.withOpacity(0.1),
                              AppColors.blueColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
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
                                  padding: EdgeInsets.all(getWidth(10)),
                                  decoration: BoxDecoration(
                                    color: AppColors.blueColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.folder_rounded,
                                    color: AppColors.blueColor,
                                    size: getWidth(24),
                                  ),
                                ),
                                SizedBox(width: getWidth(12)),
                                Expanded(
                                  child: Text(
                                    chapterName ?? "Chapter",
                                    style: TextStyle(
                                      fontSize: getWidth(16),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: getHeight(16)),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(getWidth(10)),
                                  decoration: BoxDecoration(
                                    color: AppColors.blueColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.article_rounded,
                                    color: AppColors.blueColor,
                                    size: getWidth(24),
                                  ),
                                ),
                                SizedBox(width: getWidth(12)),
                                Expanded(
                                  child: Text(
                                    module?.moduleName ?? "Module",
                                    style: TextStyle(
                                      fontSize: getWidth(16),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.blueColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: getHeight(12)),
                            Padding(
                              padding: EdgeInsets.only(left: getWidth(46)),
                              child: Text(
                                "Created: ${timeAgoMethod(module?.createdAt ?? '')}",
                                style: TextStyle(
                                  fontSize: getWidth(14),
                                  color: AppColors.textColor.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Documents count
                      Padding(
                        padding: EdgeInsets.only(
                          left: getWidth(8),
                          bottom: getHeight(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${module?.documents?.length ?? 0} ${(module?.documents?.length ?? 0) == 1 ? 'Document' : 'Documents'}",
                              style: TextStyle(
                                fontSize: getWidth(16),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor.withOpacity(0.7),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: showAddDocumentDialog,
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: AppColors.blueColor,
                                size: getWidth(16),
                              ),
                              label: Text(
                                "Add Document",
                                style: TextStyle(
                                  fontSize: getWidth(14),
                                  color: AppColors.blueColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Documents list
                      if (module?.documents == null ||
                          module!.documents!.isEmpty)
                        _buildEmptyState()
                      else
                        ...module!.documents!
                            .map((doc) => _buildDocumentItem(doc))
                            .toList(),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: getHeight(48)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: getWidth(64),
            color: AppColors.grey.withOpacity(0.5),
          ),
          SizedBox(height: getHeight(16)),
          Text(
            "No Documents Available",
            style: TextStyle(
              fontSize: getWidth(18),
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: getHeight(8)),
          Text(
            "Add your first document to this module.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: getWidth(14),
              color: AppColors.textColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: getHeight(24)),
          ElevatedButton.icon(
            onPressed: showAddDocumentDialog,
            icon: Icon(Icons.add, color: Colors.white),
            label: Text("Add Document", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueColor,
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(24),
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

  Widget _buildDocumentItem(Documents document) {
    final color = getDocumentColor(document.type);
    final icon = getDocumentIcon(document.type);

    return Container(
      margin: EdgeInsets.only(bottom: getHeight(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getWidth(12)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => openDocument(document.link),
          borderRadius: BorderRadius.circular(getWidth(12)),
          child: Padding(
            padding: EdgeInsets.all(getWidth(16)),
            child: Row(
              children: [
                Container(
                  width: getWidth(48),
                  height: getWidth(48),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(getWidth(8)),
                  ),
                  child: Icon(icon, color: color, size: getWidth(24)),
                ),
                SizedBox(width: getWidth(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.name ?? 'Unnamed Document',
                        style: TextStyle(
                          fontSize: getWidth(16),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: getHeight(4)),
                      Text(
                        document.type ?? 'Unknown Type',
                        style: TextStyle(
                          fontSize: getWidth(12),
                          color: color.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Open document button
                    Container(
                      margin: EdgeInsets.only(right: getWidth(8)),
                      padding: EdgeInsets.all(getWidth(8)),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.open_in_new_rounded,
                        color: color,
                        size: getWidth(20),
                      ),
                    ),
                    // Delete document button
                    Container(
                      padding: EdgeInsets.all(getWidth(8)),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: InkWell(
                        onTap: () => showDeleteDocumentConfirmation(document),
                        borderRadius: BorderRadius.circular(getWidth(20)),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: getWidth(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DocumentToUpload {
  String name;
  String type;
  File? file;
  String? link;
  String? uploadedLink;
  bool isUploading = false;
  bool isUploaded = false;

  DocumentToUpload({
    required this.name,
    required this.type,
    this.file,
    this.link,
    this.uploadedLink,
  });

  Map<String, String> toJson() {
    return {'name': name, 'type': type, 'link': uploadedLink ?? link ?? ''};
  }
}
