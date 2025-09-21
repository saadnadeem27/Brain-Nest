import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

/// Firestore Database Service
/// Handles all database operations with Cloud Firestore
class FirestoreService extends GetxService {
  static FirestoreService get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  static const String assignmentsCollection = 'assignments';
  static const String submissionsCollection = 'submissions';
  static const String enrollmentsCollection = 'enrollments';
  static const String notificationsCollection = 'notifications';

  /// Generic method to create a document
  Future<void> createDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  /// Generic method to update a document
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  /// Generic method to get a document
  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  /// Generic method to delete a document
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  /// Generic method to get multiple documents with query
  Future<QuerySnapshot> getDocuments({
    required String collection,
    Query Function(CollectionReference)? queryBuilder,
    int? limit,
  }) async {
    try {
      CollectionReference collectionRef = _firestore.collection(collection);
      Query query = queryBuilder?.call(collectionRef) ?? collectionRef;

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      throw Exception('Failed to get documents: $e');
    }
  }

  /// Stream method to listen to document changes
  Stream<DocumentSnapshot> streamDocument({
    required String collection,
    required String docId,
  }) {
    try {
      return _firestore.collection(collection).doc(docId).snapshots();
    } catch (e) {
      throw Exception('Failed to stream document: $e');
    }
  }

  /// Stream method to listen to collection changes
  Stream<QuerySnapshot> streamCollection({
    required String collection,
    Query Function(CollectionReference)? queryBuilder,
    int? limit,
  }) {
    try {
      CollectionReference collectionRef = _firestore.collection(collection);
      Query query = queryBuilder?.call(collectionRef) ?? collectionRef;

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots();
    } catch (e) {
      throw Exception('Failed to stream collection: $e');
    }
  }

  // USER SPECIFIC METHODS

  /// Create user profile
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String displayName,
    required String role, // 'student' or 'educator'
    Map<String, dynamic>? additionalData,
  }) async {
    final userData = {
      'email': email,
      'displayName': displayName,
      'role': role,
      'isActive': true,
      'lastLoginAt': FieldValue.serverTimestamp(),
      ...?additionalData,
    };

    await createDocument(
      collection: usersCollection,
      docId: userId,
      data: userData,
    );
  }

  /// Get user profile
  Future<DocumentSnapshot> getUserProfile(String userId) async {
    return await getDocument(
      collection: usersCollection,
      docId: userId,
    );
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await updateDocument(
      collection: usersCollection,
      docId: userId,
      data: data,
    );
  }

  // COURSE SPECIFIC METHODS

  /// Create a new course
  Future<String> createCourse({
    required String title,
    required String description,
    required String educatorId,
    required String category,
    Map<String, dynamic>? additionalData,
  }) async {
    final courseRef = _firestore.collection(coursesCollection).doc();
    final courseData = {
      'title': title,
      'description': description,
      'educatorId': educatorId,
      'category': category,
      'isPublished': false,
      'enrollmentCount': 0,
      'rating': 0.0,
      'ratingCount': 0,
      ...?additionalData,
    };

    await createDocument(
      collection: coursesCollection,
      docId: courseRef.id,
      data: courseData,
    );

    return courseRef.id;
  }

  /// Get courses by educator
  Future<QuerySnapshot> getCoursesByEducator(String educatorId) async {
    return await getDocuments(
      collection: coursesCollection,
      queryBuilder: (collection) =>
          collection.where('educatorId', isEqualTo: educatorId),
    );
  }

  /// Get published courses
  Future<QuerySnapshot> getPublishedCourses({int? limit}) async {
    return await getDocuments(
      collection: coursesCollection,
      queryBuilder: (collection) => collection
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true),
      limit: limit,
    );
  }

  // ASSIGNMENT SPECIFIC METHODS

  /// Create an assignment
  Future<String> createAssignment({
    required String courseId,
    required String title,
    required String description,
    required DateTime dueDate,
    required int maxPoints,
    Map<String, dynamic>? additionalData,
  }) async {
    final assignmentRef = _firestore.collection(assignmentsCollection).doc();
    final assignmentData = {
      'courseId': courseId,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'maxPoints': maxPoints,
      'isPublished': false,
      'submissionCount': 0,
      ...?additionalData,
    };

    await createDocument(
      collection: assignmentsCollection,
      docId: assignmentRef.id,
      data: assignmentData,
    );

    return assignmentRef.id;
  }

  /// Get assignments by course
  Future<QuerySnapshot> getAssignmentsByCourse(String courseId) async {
    return await getDocuments(
      collection: assignmentsCollection,
      queryBuilder: (collection) =>
          collection.where('courseId', isEqualTo: courseId).orderBy('dueDate'),
    );
  }

  // ENROLLMENT SPECIFIC METHODS

  /// Enroll student in course
  Future<void> enrollInCourse({
    required String userId,
    required String courseId,
  }) async {
    final enrollmentId = '${userId}_$courseId';
    await createDocument(
      collection: enrollmentsCollection,
      docId: enrollmentId,
      data: {
        'userId': userId,
        'courseId': courseId,
        'enrolledAt': FieldValue.serverTimestamp(),
        'progress': 0,
        'isActive': true,
      },
    );

    // Update course enrollment count
    await _firestore.collection(coursesCollection).doc(courseId).update({
      'enrollmentCount': FieldValue.increment(1),
    });
  }

  /// Get user enrollments
  Future<QuerySnapshot> getUserEnrollments(String userId) async {
    return await getDocuments(
      collection: enrollmentsCollection,
      queryBuilder: (collection) => collection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true),
    );
  }

  // BATCH OPERATIONS

  /// Perform batch write operations
  Future<void> performBatch(List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        final type = operation['type'] as String;
        final collection = operation['collection'] as String;
        final docId = operation['docId'] as String;
        final data = operation['data'] as Map<String, dynamic>?;

        final docRef = _firestore.collection(collection).doc(docId);

        switch (type) {
          case 'set':
            batch.set(docRef, {
              ...?data,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            break;
          case 'update':
            batch.update(docRef, {
              ...?data,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to perform batch operation: $e');
    }
  }

  /// Perform transaction
  Future<T> performTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    try {
      return await _firestore.runTransaction(updateFunction);
    } catch (e) {
      throw Exception('Failed to perform transaction: $e');
    }
  }
}
