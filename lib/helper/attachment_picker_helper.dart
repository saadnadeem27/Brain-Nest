import 'dart:developer';
import 'dart:io';
import 'package:brain_nest/common/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class AttachmentPickerHelper {
  final ImagePicker _imagePicker = ImagePicker();

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      log('Error picking image from gallery: $e');
    }
    return null;
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      log('Error picking image from camera: $e');
    }
    return null;
  }

  // Pick document file
  Future<File?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      log('Error picking document: $e');
    }
    return null;
  }

  // Pick and upload a file
  Future<Map<String, dynamic>?> pickAndUploadFile() async {
    try {
      // Show a dialog to choose source
      final source = await Get.dialog<String>(
        AlertDialog(
          title: const Text('Choose File Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: AppColors.blueColor),
                title: const Text('Image from Gallery'),
                onTap: () => Get.back(result: 'gallery'),
              ),
              ListTile(
                leading:
                    const Icon(Icons.camera_alt, color: AppColors.blueColor),
                title: const Text('Take Photo'),
                onTap: () => Get.back(result: 'camera'),
              ),
              ListTile(
                leading:
                    const Icon(Icons.file_copy, color: AppColors.blueColor),
                title: const Text('Document'),
                onTap: () => Get.back(result: 'document'),
              ),
              ListTile(
                leading: const Icon(Icons.link, color: AppColors.blueColor),
                title: const Text('Link'),
                onTap: () => Get.back(result: 'link'),
              ),
            ],
          ),
        ),
      );

      if (source == null) return null;

      File? file;
      String? link;
      String? type;

      switch (source) {
        case 'gallery':
          file = await pickImageFromGallery();
          type = 'image';
          break;
        case 'camera':
          file = await pickImageFromCamera();
          type = 'image';
          break;
        case 'document':
          file = await pickDocument();
          final extension = path.extension(file?.path ?? '').toLowerCase();
          if (extension == '.pdf' ||
              extension == '.doc' ||
              extension == '.docx') {
            type = 'document/pdf';
          } else if (extension == '.jpg' ||
              extension == '.jpeg' ||
              extension == '.png') {
            type = 'image';
          } else if (extension == '.txt') {
            type = 'text';
          } else {
            type = 'document';
          }
          break;
        case 'link':
          // Show dialog to enter link
          final result = await Get.dialog<Map<String, String>>(
            AlertDialog(
              title: const Text('Enter Link'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'URL',
                      hintText: 'https://example.com',
                    ),
                    onSubmitted: (value) {
                      Get.back(result: {'url': value, 'name': 'link'});
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Get.back(), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    final textController =
                        (Get.context?.findRenderObject() as TextField?)
                            ?.controller;
                    if (textController != null &&
                        textController.text.isNotEmpty) {
                      Get.back(
                        result: {'url': textController.text, 'name': 'link'},
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          );

          if (result != null) {
            link = result['url'];
            type = 'link';
            return {
              'type': type,
              'url': link,
              'name': result['name'] ?? 'link',
            };
          }
          return null;
      }

      if (file == null) return null;

      // Upload file to server
      final uploadResult = await _uploadFile(file);
      if (uploadResult != null) {
        return {
          'type': type,
          'url': uploadResult['url'],
          'name': path.basename(file.path),
        };
      }
    } catch (e) {
      log('Error in pickAndUploadFile: $e');
    }
    return null;
  }

  // Upload file to server
  Future<Map<String, dynamic>?> _uploadFile(File file) async {
    try {
      // TODO: Implement file upload to your server
      // For now, let's simulate an upload

      await Future.delayed(
          const Duration(seconds: 2)); // Simulate network delay

      // Return a fake URL for demonstration
      return {
        'url':
            'https://vadaiawsbucket.s3.ap-south-1.amazonaws.com/moduleFiles/${path.basename(file.path)}',
      };
    } catch (e) {
      log('Error uploading file: $e');
      return null;
    }
  }
}
