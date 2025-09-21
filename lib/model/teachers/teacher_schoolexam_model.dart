import 'package:intl/intl.dart';

class TeacherSchoolExamModel {
  String? id;
  bool? documentStatus;
  String? name;
  String? message;
  String? startDate;
  String? schoolId;
  List<SubjectModel>? subjects;

  TeacherSchoolExamModel({
    this.id,
    this.documentStatus,
    this.name,
    this.message,
    this.startDate,
    this.schoolId,
    this.subjects,
  });

  factory TeacherSchoolExamModel.fromJson(Map<String, dynamic> json) {
    List<SubjectModel>? subjectsList;
    if (json['subjects'] != null) {
      subjectsList = <SubjectModel>[];
      json['subjects'].forEach((v) {
        subjectsList!.add(SubjectModel.fromJson(v));
      });
    }

    return TeacherSchoolExamModel(
      id: json['_id'],
      documentStatus: json['documentStatus'],
      name: json['name'],
      message: json['message'],
      startDate: json['startDate'],
      schoolId: json['schoolId'],
      subjects: subjectsList,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['documentStatus'] = documentStatus;
    data['name'] = name;
    data['message'] = message;
    data['startDate'] = startDate;
    data['schoolId'] = schoolId;
    if (subjects != null) {
      data['subjects'] = subjects!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  String getFormattedDate() {
    if (startDate == null || startDate!.isEmpty) {
      return "No date";
    }
    try {
      final date = DateTime.parse(startDate!);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return "Invalid date";
    }
  }
}

class SubjectModel {
  String? id;
  bool? documentStatus;
  String? exam;
  String? subject;
  String? chaptersAndDetails;
  int? totalMark;
  List<LargerTopicModel>? largerTopics;
  List<DocumentModel>? documents;

  SubjectModel({
    this.id,
    this.documentStatus,
    this.exam,
    this.subject,
    this.chaptersAndDetails,
    this.totalMark,
    this.largerTopics,
    this.documents,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    List<LargerTopicModel>? topicsList;
    if (json['largerTopics'] != null) {
      topicsList = <LargerTopicModel>[];
      json['largerTopics'].forEach((v) {
        topicsList!.add(LargerTopicModel.fromJson(v));
      });
    }

    List<DocumentModel>? docsList;
    if (json['documents'] != null) {
      docsList = <DocumentModel>[];
      json['documents'].forEach((v) {
        docsList!.add(DocumentModel.fromJson(v));
      });
    }

    return SubjectModel(
      id: json['_id'],
      documentStatus: json['documentStatus'],
      exam: json['exam'],
      subject: json['subject'],
      chaptersAndDetails: json['chaptersAndDetails'],
      totalMark: json['totalMark'],
      largerTopics: topicsList,
      documents: docsList,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
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
    return data;
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

  int getSubtopicCount() {
    return subtopics?.length ?? 0;
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
