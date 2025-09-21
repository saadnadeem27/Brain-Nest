class SchoolExamModel {
  String? sId;
  bool? documentStatus;
  String? name;
  String? message;
  List<String>? classes;
  String? startDate;
  String? schoolId;
  List<Subjects>? subjects;

  SchoolExamModel({
    this.sId,
    this.documentStatus,
    this.name,
    this.message,
    this.classes,
    this.startDate,
    this.schoolId,
    this.subjects,
  });

  SchoolExamModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    documentStatus = json['documentStatus'];
    name = json['name'];
    message = json['message'];
    classes =
        json['classes'] != null ? List<String>.from(json['classes']) : null;
    startDate = json['startDate'];
    schoolId = json['schoolId'];
    if (json['subjects'] != null) {
      subjects = <Subjects>[];
      json['subjects'].forEach((v) {
        subjects!.add(Subjects.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['documentStatus'] = documentStatus;
    data['name'] = name;
    data['message'] = message;
    data['classes'] = classes;
    data['startDate'] = startDate;
    data['schoolId'] = schoolId;
    if (subjects != null) {
      data['subjects'] = subjects!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Subjects {
  String? sId;
  bool? documentStatus;
  String? exam;
  String? subject;
  String? chaptersAndDetails;
  int? totalMark;

  Subjects({
    this.sId,
    this.documentStatus,
    this.exam,
    this.subject,
    this.chaptersAndDetails,
    this.totalMark,
  });

  Subjects.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    documentStatus = json['documentStatus'];
    exam = json['exam'];
    subject = json['subject'];
    chaptersAndDetails = json['chaptersAndDetails'];
    totalMark = json['totalMark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['documentStatus'] = documentStatus;
    data['exam'] = exam;
    data['subject'] = subject;
    data['chaptersAndDetails'] = chaptersAndDetails;
    data['totalMark'] = totalMark;
    return data;
  }
}
