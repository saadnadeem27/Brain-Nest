import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import '../../firebase_options.dart';
import 'authentication_service.dart';
import 'firestore_service.dart';
import 'storage_service.dart';
import 'cloud_function_service.dart';

/// Firebase Services Initializer
/// Handles initialization and dependency injection of all Firebase services
class FirebaseServiceInitializer {
  /// Initialize Firebase and register all services
  static Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Register all Firebase services with GetX
      await _registerServices();

      print('✅ Firebase services initialized successfully');
    } catch (e) {
      print('❌ Error initializing Firebase services: $e');
      rethrow;
    }
  }

  /// Register all Firebase services with GetX dependency injection
  static Future<void> _registerServices() async {
    // Register services in order of dependency
    Get.put(AuthenticationService(), permanent: true);
    Get.put(FirestoreService(), permanent: true);
    Get.put(StorageService(), permanent: true);
    Get.put(CloudFunctionService(), permanent: true);

    print('✅ All Firebase services registered with GetX');
  }

  /// Clean up services (call when app is closing)
  static Future<void> cleanup() async {
    try {
      // Remove services from GetX
      if (Get.isRegistered<AuthenticationService>()) {
        await Get.delete<AuthenticationService>();
      }
      if (Get.isRegistered<FirestoreService>()) {
        await Get.delete<FirestoreService>();
      }
      if (Get.isRegistered<StorageService>()) {
        await Get.delete<StorageService>();
      }
      if (Get.isRegistered<CloudFunctionService>()) {
        await Get.delete<CloudFunctionService>();
      }

      print('✅ Firebase services cleaned up successfully');
    } catch (e) {
      print('❌ Error cleaning up Firebase services: $e');
    }
  }

  /// Check if all services are initialized
  static bool get areServicesInitialized {
    return Get.isRegistered<AuthenticationService>() &&
        Get.isRegistered<FirestoreService>() &&
        Get.isRegistered<StorageService>() &&
        Get.isRegistered<CloudFunctionService>();
  }

  /// Get quick access to all services
  static AuthenticationService get auth => Get.find<AuthenticationService>();
  static FirestoreService get firestore => Get.find<FirestoreService>();
  static StorageService get storage => Get.find<StorageService>();
  static CloudFunctionService get functions => Get.find<CloudFunctionService>();
}
