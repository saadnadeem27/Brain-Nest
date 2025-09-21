import 'package:intl/intl.dart';

class TeacherSchoolExamSubjectDetailsModel {
  String? id;
  bool? documentStatus;
  String? name;
  String? message;
  DateTime? startDate;
  String? schoolId;
  SubjectDetailsModel? subject;

  TeacherSchoolExamSubjectDetailsModel({
    this.id,
    this.documentStatus,
    this.name,
    this.message,
    this.startDate,
    this.schoolId,
    this.subject,
  });

  factory TeacherSchoolExamSubjectDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TeacherSchoolExamSubjectDetailsModel(
      id: json['_id'],
      documentStatus: json['documentStatus'],
      name: json['name'],
      message: json['message'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      schoolId: json['schoolId'],
      subject:
          json['subject'] != null
              ? SubjectDetailsModel.fromJson(json['subject'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['documentStatus'] = documentStatus;
    data['name'] = name;
    data['message'] = message;
    if (startDate != null) {
      data['startDate'] = startDate!.toIso8601String();
    }
    data['schoolId'] = schoolId;
    if (subject != null) {
      data['subject'] = subject!.toJson();
    }
    return data;
  }

  String getFormattedDate() {
    if (startDate == null) return "No date";
    return DateFormat("MMMM d, yyyy").format(startDate!);
  }
}

class SubjectDetailsModel {
  bool? documentStatus;
  String? exam;
  String? subject;
  String? chaptersAndDetails;
  int? totalMark;
  List<LargerTopicModel>? largerTopics;
  List<DocumentModel>? documents;
  String? subjectId;
  String? className;
  DateTime? date;

  SubjectDetailsModel({
    this.documentStatus,
    this.exam,
    this.subject,
    this.chaptersAndDetails,
    this.totalMark,
    this.largerTopics,
    this.documents,
    this.subjectId,
    this.className,
    this.date,
  });

  factory SubjectDetailsModel.fromJson(Map<String, dynamic> json) {
    List<LargerTopicModel>? topics;
    if (json['largerTopics'] != null) {
      topics = <LargerTopicModel>[];
      json['largerTopics'].forEach((v) {
        topics!.add(LargerTopicModel.fromJson(v));
      });
    }

    List<DocumentModel>? docs;
    if (json['documents'] != null) {
      docs = <DocumentModel>[];
      json['documents'].forEach((v) {
        docs!.add(DocumentModel.fromJson(v));
      });
    }

    return SubjectDetailsModel(
      documentStatus: json['documentStatus'],
      exam: json['exam'],
      subject: json['subject'],
      chaptersAndDetails: json['chaptersAndDetails'],
      totalMark: json['totalMark'],
      largerTopics: topics,
      documents: docs,
      subjectId: json['subjectId'],
      className: json['className'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['documentStatus'] = documentStatus;
    data['exam'] = exam;
    data['subject'] = subject;
    data['chaptersAndDetails'] = chaptersAndDetails;
    data['totalMark'] = totalMark;
    if (largerTopics != null) {
      data['largerTopics'] = largerTopics!.map((v) => v.toJson()).toList();
    }
    if (documents != null) {
      data['documents'] = documents!.map((v) => v.toJson()).toList();
    }
    data['subjectId'] = subjectId;
    data['className'] = className;
    if (date != null) {
      data['date'] = date!.toIso8601String();
    }
    return data;
  }

  int getSubtopicsCount() {
    int count = 0;
    largerTopics?.forEach((topic) {
      count += topic.subtopics?.length ?? 0;
    });
    return count;
  }
}

class LargerTopicModel {
  String? name;
  List<SubtopicModel>? subtopics;
  String? id;

  LargerTopicModel({this.name, this.subtopics, this.id});

  factory LargerTopicModel.fromJson(Map<String, dynamic> json) {
    List<SubtopicModel>? subtopicsList;
    if (json['subtopics'] != null) {
      subtopicsList = <SubtopicModel>[];
      json['subtopics'].forEach((v) {
        subtopicsList!.add(SubtopicModel.fromJson(v));
      });
    }

    return LargerTopicModel(
      name: json['name'],
      subtopics: subtopicsList,
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (subtopics != null) {
      data['subtopics'] = subtopics!.map((v) => v.toJson()).toList();
    }
    data['_id'] = id;
    return data;
  }
}

class SubtopicModel {
  String? name;
  String? id;

  SubtopicModel({this.name, this.id});

  factory SubtopicModel.fromJson(Map<String, dynamic> json) {
    return SubtopicModel(name: json['name'], id: json['_id']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['_id'] = id;
    return data;
  }
}

class DocumentModel {
  String? type;
  String? link;
  String? name;
  String? id;

  DocumentModel({this.type, this.link, this.name, this.id});

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      type: json['type'],
      link: json['link'],
      name: json['name'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['link'] = link;
    data['name'] = name;
    data['_id'] = id;
    return data;
  }
}
