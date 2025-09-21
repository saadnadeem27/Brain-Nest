class TeachersProfileModel {
  String? sId;
  String? teachersId;
  String? name;
  String? email;
  String? phoneNumber;
  String? profileImage;
  String? schoolId;
  String? school;
  List<ClassesAndSubjects>? classesAndSubjects;
  String? classId;
  String? className;
  String? sectionId;
  String? section;
  String? teachersWhatsappNumber;
  bool? registrationCompleted;
  String? accountStatus;
  String? createdAt;

  TeachersProfileModel({
    this.sId,
    this.teachersId,
    this.name,
    this.email,
    this.phoneNumber,
    this.profileImage,
    this.schoolId,
    this.school,
    this.classesAndSubjects,
    this.classId,
    this.className,
    this.sectionId,
    this.section,
    this.teachersWhatsappNumber,
    this.registrationCompleted,
    this.accountStatus,
    this.createdAt,
  });

  TeachersProfileModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    teachersId = json['teachersId'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    profileImage = json['profileImage'];
    schoolId = json['schoolId'];
    school = json['school'];
    if (json['classesAndSubjects'] != null) {
      classesAndSubjects = <ClassesAndSubjects>[];
      json['classesAndSubjects'].forEach((v) {
        classesAndSubjects!.add(ClassesAndSubjects.fromJson(v));
      });
    }
    classId = json['classId'];
    className = json['className'];
    sectionId = json['sectionId'];
    section = json['section'];
    teachersWhatsappNumber = json['teachersWhatsappNumber'];
    registrationCompleted = json['registrationCompleted'];
    accountStatus = json['accountStatus'];
    createdAt = json['createdAt'];
  }
}

class ClassesAndSubjects {
  String? classId;
  String? className;
  String? sectionId;
  String? section;
  String? subjectId;
  String? subjectName;
  String? sId;

  ClassesAndSubjects({
    this.classId,
    this.className,
    this.sectionId,
    this.section,
    this.subjectId,
    this.subjectName,
    this.sId,
  });

  ClassesAndSubjects.fromJson(Map<String, dynamic> json) {
    classId = json['classId'];
    className = json['className'];
    sectionId = json['sectionId'];
    section = json['section'];
    subjectId = json['subjectId'];
    subjectName = json['subjectName'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['classId'] = classId;
    data['className'] = className;
    data['sectionId'] = sectionId;
    data['section'] = section;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['_id'] = sId;
    return data;
  }
}
