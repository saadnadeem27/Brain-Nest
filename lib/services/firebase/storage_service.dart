import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

/// Firebase Storage Service
/// Handles file upload, download, and management operations
class StorageService extends GetxService {
  static StorageService get instance => Get.find();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Storage paths
  static const String profileImagesPath = 'profile_images';
  static const String courseImagesPath = 'course_images';
  static const String assignmentFilesPath = 'assignment_files';
  static const String submissionFilesPath = 'submission_files';
  static const String courseMaterialsPath = 'course_materials';
  static const String documentsPath = 'documents';

  /// Upload file from file path
  Future<String> uploadFile({
    required String filePath,
    required String fileName,
    required String storagePath,
    Function(TaskSnapshot)? onProgress,
  }) async {
    try {
      final file = File(filePath);
      final ref = _storage.ref().child('$storagePath/$fileName');

      final uploadTask = ref.putFile(file);

      // Listen to upload progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen(onProgress);
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Upload file from bytes (web compatible)
  Future<String> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    required String storagePath,
    String? contentType,
    Function(TaskSnapshot)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child('$storagePath/$fileName');

      SettableMetadata? metadata;
      if (contentType != null) {
        metadata = SettableMetadata(contentType: contentType);
      }

      final uploadTask = ref.putData(bytes, metadata);

      // Listen to upload progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen(onProgress);
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload bytes: $e');
    }
  }

  /// Download file as bytes
  Future<Uint8List?> downloadFileAsBytes({
    required String fileName,
    required String storagePath,
  }) async {
    try {
      final ref = _storage.ref().child('$storagePath/$fileName');
      return await ref.getData();
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  /// Get download URL for a file
  Future<String> getDownloadURL({
    required String fileName,
    required String storagePath,
  }) async {
    try {
      final ref = _storage.ref().child('$storagePath/$fileName');
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }

  /// Delete a file
  Future<void> deleteFile({
    required String fileName,
    required String storagePath,
  }) async {
    try {
      final ref = _storage.ref().child('$storagePath/$fileName');
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Delete file by URL
  Future<void> deleteFileByURL(String downloadURL) async {
    try {
      final ref = _storage.refFromURL(downloadURL);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file by URL: $e');
    }
  }

  /// List files in a directory
  Future<List<Reference>> listFiles({
    required String storagePath,
    int? maxResults,
  }) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final result = await ref.listAll();
      return result.items;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  /// Get file metadata
  Future<FullMetadata> getFileMetadata({
    required String fileName,
    required String storagePath,
  }) async {
    try {
      final ref = _storage.ref().child('$storagePath/$fileName');
      return await ref.getMetadata();
    } catch (e) {
      throw Exception('Failed to get file metadata: $e');
    }
  }

  /// Update file metadata
  Future<void> updateFileMetadata({
    required String fileName,
    required String storagePath,
    required SettableMetadata metadata,
  }) async {
    try {
      final ref = _storage.ref().child('$storagePath/$fileName');
      await ref.updateMetadata(metadata);
    } catch (e) {
      throw Exception('Failed to update file metadata: $e');
    }
  }

  // SPECIFIC USE CASE METHODS

  /// Upload profile image
  Future<String> uploadProfileImage({
    required String userId,
    required String filePath,
    Function(TaskSnapshot)? onProgress,
  }) async {
    final fileName = 'profile_$userId.jpg';
    return await uploadFile(
      filePath: filePath,
      fileName: fileName,
      storagePath: profileImagesPath,
      onProgress: onProgress,
    );
  }

  /// Upload profile image from bytes
  Future<String> uploadProfileImageBytes({
    required String userId,
    required Uint8List bytes,
    Function(TaskSnapshot)? onProgress,
  }) async {
    final fileName = 'profile_$userId.jpg';
    return await uploadBytes(
      bytes: bytes,
      fileName: fileName,
      storagePath: profileImagesPath,
      contentType: 'image/jpeg',
      onProgress: onProgress,
    );
  }

  /// Upload course image
  Future<String> uploadCourseImage({
    required String courseId,
    required String filePath,
    Function(TaskSnapshot)? onProgress,
  }) async {
    final fileName = 'course_$courseId.jpg';
    return await uploadFile(
      filePath: filePath,
      fileName: fileName,
      storagePath: courseImagesPath,
      onProgress: onProgress,
    );
  }

  /// Upload assignment file
  Future<String> uploadAssignmentFile({
    required String assignmentId,
    required String filePath,
    required String originalFileName,
    Function(TaskSnapshot)? onProgress,
  }) async {
    final fileName = '${assignmentId}_$originalFileName';
    return await uploadFile(
      filePath: filePath,
      fileName: fileName,
      storagePath: assignmentFilesPath,
      onProgress: onProgress,
    );
  }

  /// Upload submission file
  Future<String> uploadSubmissionFile({
    required String submissionId,
    required String filePath,
    required String originalFileName,
    Function(TaskSnapshot)? onProgress,
  }) async {
    final fileName = '${submissionId}_$originalFileName';
    return await uploadFile(
      filePath: filePath,
      fileName: fileName,
      storagePath: submissionFilesPath,
      onProgress: onProgress,
    );
  }

  /// Upload course material
  Future<String> uploadCourseMaterial({
    required String courseId,
    required String filePath,
    required String originalFileName,
    Function(TaskSnapshot)? onProgress,
  }) async {
    final fileName = '${courseId}_$originalFileName';
    return await uploadFile(
      filePath: filePath,
      fileName: fileName,
      storagePath: courseMaterialsPath,
      onProgress: onProgress,
    );
  }

  /// Upload document
  Future<String> uploadDocument({
    required String userId,
    required String filePath,
    required String originalFileName,
    Function(TaskSnapshot)? onProgress,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${userId}_${timestamp}_$originalFileName';
    return await uploadFile(
      filePath: filePath,
      fileName: fileName,
      storagePath: documentsPath,
      onProgress: onProgress,
    );
  }

  /// Get file size in a human-readable format
  String getReadableFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Generate unique file name with timestamp
  String generateUniqueFileName(String originalFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = originalFileName.split('.').last;
    return '${timestamp}_$originalFileName';
  }

  /// Validate file type
  bool isValidFileType(String fileName, List<String> allowedExtensions) {
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  /// Validate file size
  bool isValidFileSize(int fileSize, int maxSizeInMB) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return fileSize <= maxSizeInBytes;
  }

  /// Get common file extensions for different types
  static const Map<String, List<String>> fileTypeExtensions = {
    'image': ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
    'document': ['pdf', 'doc', 'docx', 'txt', 'rtf'],
    'spreadsheet': ['xls', 'xlsx', 'csv'],
    'presentation': ['ppt', 'pptx'],
    'video': ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm'],
    'audio': ['mp3', 'wav', 'aac', 'ogg', 'wma'],
    'archive': ['zip', 'rar', '7z', 'tar', 'gz'],
  };
}
