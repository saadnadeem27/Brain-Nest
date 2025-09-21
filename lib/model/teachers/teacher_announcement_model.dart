class TeacherAnnouncementModel {
  final String id;
  final String announcementId;
  final String sender;
  final SenderProfile senderProfile;
  final String title;
  final String description;
  final DateTime createdOn;
  final String senderType;
  final String schoolId;
  final String? classId;
  final String? sectionId;
  final String? subjectId;
  final bool sendToStudentWhatsapp;
  final bool sendToParentWhatsapp;
  final String scope;
  final bool isViewed;

  TeacherAnnouncementModel({
    required this.id,
    required this.announcementId,
    required this.sender,
    required this.senderProfile,
    required this.title,
    required this.description,
    required this.createdOn,
    required this.senderType,
    required this.schoolId,
    this.classId,
    this.sectionId,
    this.subjectId,
    required this.sendToStudentWhatsapp,
    required this.sendToParentWhatsapp,
    required this.scope,
    required this.isViewed,
  });

  factory TeacherAnnouncementModel.fromJson(Map<String, dynamic> json) {
    return TeacherAnnouncementModel(
      id: json['_id'] ?? '',
      announcementId: json['announcementId'] ?? '',
      sender: json['sender'] ?? '',
      senderProfile: SenderProfile.fromJson(json['senderProfile'] ?? {}),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdOn:
          json['createdOn'] != null
              ? DateTime.parse(json['createdOn'])
              : DateTime.now(),
      senderType: json['senderType'] ?? '',
      schoolId: json['schoolId'] ?? '',
      classId: json['classId'],
      sectionId: json['sectionId'],
      subjectId: json['subjectId'],
      sendToStudentWhatsapp: json['sendToStudentWhatsapp'] ?? false,
      sendToParentWhatsapp: json['sendToParentWhatsapp'] ?? false,
      scope: json['scope'] ?? '',
      isViewed: json['isViewed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'announcementId': announcementId,
      'sender': sender,
      'senderProfile': senderProfile.toJson(),
      'title': title,
      'description': description,
      'createdOn': createdOn.toIso8601String(),
      'senderType': senderType,
      'schoolId': schoolId,
      'classId': classId,
      'sectionId': sectionId,
      'subjectId': subjectId,
      'sendToStudentWhatsapp': sendToStudentWhatsapp,
      'sendToParentWhatsapp': sendToParentWhatsapp,
      'scope': scope,
      'isViewed': isViewed,
    };
  }
}

class SenderProfile {
  final String name;
  final String profileImage;

  SenderProfile({required this.name, required this.profileImage});

  factory SenderProfile.fromJson(Map<String, dynamic> json) {
    return SenderProfile(
      name: json['name'] ?? '',
      profileImage: json['profileImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'profileImage': profileImage};
  }
}
