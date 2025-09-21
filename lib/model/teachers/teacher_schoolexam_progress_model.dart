import 'package:get/get_rx/src/rx_types/rx_types.dart';

class TeacherSchoolExamProgressModel {
  String? id;
  String? name;
  String? startDate;
  String? schoolId;
  SubjectDetails? subjectDetails;

  TeacherSchoolExamProgressModel({
    this.id,
    this.name,
    this.startDate,
    this.schoolId,
    this.subjectDetails,
  });

  TeacherSchoolExamProgressModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    startDate = json['startDate'];
    schoolId = json['schoolId'];
    subjectDetails =
        json['subjectDetails'] != null
            ? SubjectDetails.fromJson(json['subjectDetails'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['name'] = name;
    data['startDate'] = startDate;
    data['schoolId'] = schoolId;
    if (subjectDetails != null) {
      data['subjectDetails'] = subjectDetails!.toJson();
    }
    return data;
  }

  // Helper method to get formatted date
  DateTime? getStartDateTime() {
    if (startDate == null) return null;
    try {
      return DateTime.parse(startDate!);
    } catch (e) {
      return null;
    }
  }
}

class SubjectDetails {
  String? subject;
  List<LargerTopic>? largerTopics;

  SubjectDetails({this.subject, this.largerTopics});

  SubjectDetails.fromJson(Map<String, dynamic> json) {
    subject = json['subject'];
    if (json['largerTopics'] != null) {
      largerTopics = <LargerTopic>[];
      json['largerTopics'].forEach((v) {
        largerTopics!.add(LargerTopic.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subject'] = subject;
    if (largerTopics != null) {
      data['largerTopics'] = largerTopics!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LargerTopic {
  String? name;
  List<Subtopic>? subtopics;
  String? id;
  bool? _isCompleted;

  final Rx<bool> isCompletedRx = false.obs;

  LargerTopic({this.name, this.subtopics, this.id, bool? isCompleted}) {
    if (isCompleted != null) {
      _isCompleted = isCompleted;
      isCompletedRx.value = isCompleted;
    }
  }

  bool? get isCompleted => _isCompleted;
  set isCompleted(bool? value) {
    _isCompleted = value;
    if (value != null) {
      isCompletedRx.value = value;
    }
  }

  LargerTopic.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['subtopics'] != null) {
      subtopics = <Subtopic>[];
      json['subtopics'].forEach((v) {
        subtopics!.add(Subtopic.fromJson(v));
      });
    }
    id = json['_id'];
    _isCompleted = json['isCompleted'];
    isCompletedRx.value = _isCompleted ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (subtopics != null) {
      data['subtopics'] = subtopics!.map((v) => v.toJson()).toList();
    }
    data['_id'] = id;
    data['isCompleted'] = _isCompleted;
    return data;
  }
}

class Subtopic {
  String? name;
  String? id;
  bool? _isCompleted;
  final Rx<bool> isCompletedRx = false.obs;

  Subtopic({this.name, this.id, bool? isCompleted}) {
    if (isCompleted != null) {
      _isCompleted = isCompleted;
      isCompletedRx.value = isCompleted;
    }
  }

  bool? get isCompleted => _isCompleted;

  set isCompleted(bool? value) {
    _isCompleted = value;
    if (value != null) {
      isCompletedRx.value = value;
    }
  }

  Subtopic.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['_id'];
    _isCompleted = json['isCompleted'];
    isCompletedRx.value = _isCompleted ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['_id'] = id;
    data['isCompleted'] = isCompleted;
    return data;
  }
}
