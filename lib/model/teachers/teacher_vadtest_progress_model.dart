import 'package:Vadai/model/teachers/teacher_schoolexam_progress_model.dart';

class TeacherVadTestProgressModel {
  String? id;
  String? vadTestId;
  String? name;
  String? boardId;
  String? className;
  SubjectDetails? subjectDetails;

  TeacherVadTestProgressModel({
    this.id,
    this.vadTestId,
    this.name,
    this.boardId,
    this.className,
    this.subjectDetails,
  });

  TeacherVadTestProgressModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    vadTestId = json['vadTestId'];
    name = json['name'];
    boardId = json['boardId'];
    className = json['className'];
    subjectDetails =
        json['subjectDetails'] != null
            ? SubjectDetails.fromJson(json['subjectDetails'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['vadTestId'] = vadTestId;
    data['name'] = name;
    data['boardId'] = boardId;
    data['className'] = className;
    if (subjectDetails != null) {
      data['subjectDetails'] = subjectDetails!.toJson();
    }
    return data;
  }
}

class SubjectDetails {
  String? subjectId;
  String? subject;
  String? name;
  List<LargerTopic>? largerTopics;

  SubjectDetails({this.subjectId, this.subject, this.name, this.largerTopics});

  SubjectDetails.fromJson(Map<String, dynamic> json) {
    subjectId = json['subjectId'];
    subject = json['subject'];
    name = json['name'];
    if (json['largerTopics'] != null) {
      largerTopics = <LargerTopic>[];
      json['largerTopics'].forEach((v) {
        largerTopics!.add(LargerTopic.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subjectId'] = subjectId;
    data['subject'] = subject;
    data['name'] = name;
    if (largerTopics != null) {
      data['largerTopics'] = largerTopics!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
