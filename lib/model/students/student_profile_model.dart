class StudentProfileModel {
  String? sId;
  String? studentId;
  String? name;
  String? email;
  String? profileImage;
  String? schoolId;
  String? school;
  String? classId;
  String? className;
  String? sectionId;
  String? section;
  List<Subjects>? subjects;
  String? planStatus;
  bool? registrationCompleted;
  List<String>? fcmTokens;
  String? createdAt;
  int? rollNumber;
  String? language;
  double? learningIndex;
  String? parentWhatsappNumber;
  String? studentWhatsappNumber;
  String? phoneNumber;
  bool? hasFullPotentialAccess;

  StudentProfileModel({
    this.sId,
    this.studentId,
    this.name,
    this.email,
    this.profileImage,
    this.schoolId,
    this.school,
    this.classId,
    this.className,
    this.sectionId,
    this.section,
    this.subjects,
    this.planStatus,
    this.registrationCompleted,
    this.fcmTokens,
    this.createdAt,
    this.rollNumber,
    this.language,
    this.learningIndex,
    this.parentWhatsappNumber,
    this.studentWhatsappNumber,
    this.phoneNumber,
    this.hasFullPotentialAccess,
  });

  StudentProfileModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    studentId = json['studentId'];
    name = json['name'];
    email = json['email'];
    profileImage = json['profileImage'];
    schoolId = json['schoolId'];
    school = json['school'];
    classId = json['classId'];
    className = json['className'];
    sectionId = json['sectionId'];
    section = json['section'];
    if (json['subjects'] != null) {
      subjects = <Subjects>[];
      json['subjects'].forEach((v) {
        subjects!.add(new Subjects.fromJson(v));
      });
    }
    planStatus = json['planStatus'];
    registrationCompleted = json['registrationCompleted'];
    fcmTokens = json['fcmTokens'].cast<String>();
    createdAt = json['createdAt'];
    rollNumber = json['rollNumber'];
    language = json['language'];
    learningIndex = double.tryParse(json['learningIndex'].toString());
    parentWhatsappNumber = json['parentWhatsappNumber'];
    studentWhatsappNumber = json['studentWhatsappNumber'];
    phoneNumber = json['phoneNumber'];
    hasFullPotentialAccess = json['hasFullPotentialAccess'];
  }
}

class Subjects {
  String? subjectId;
  String? subjectName;
  String? type;
  String? sId;

  Subjects({this.subjectId, this.subjectName, this.type, this.sId});

  Subjects.fromJson(Map<String, dynamic> json) {
    subjectId = json['subjectId'];
    subjectName = json['subjectName'];
    type = json['type'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['type'] = type;
    data['_id'] = sId;
    return data;
  }
}
