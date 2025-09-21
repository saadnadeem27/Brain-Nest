import 'package:intl/intl.dart';

class TeacherVadTestDetailsModel {
  String? id;
  String? vadTestId;
  String? subjectId;
  String? subject;
  String? date;
  String? name;
  String? topics;
  String? additionalInfo;
  int? numberOfTopics;
  List<DocumentModel>? documents;
  String? icon;
  String? boardId;
  String? startTime;
  int? durationInMinutes;
  String? endTime;
  List<LargerTopicModel>? largerTopics;
  bool? reportGenerated;

  TeacherVadTestDetailsModel({
    this.id,
    this.vadTestId,
    this.subjectId,
    this.subject,
    this.date,
    this.name,
    this.topics,
    this.additionalInfo,
    this.numberOfTopics,
    this.documents,
    this.icon,
    this.boardId,
    this.startTime,
    this.durationInMinutes,
    this.endTime,
    this.largerTopics,
    this.reportGenerated,
  });

  factory TeacherVadTestDetailsModel.fromJson(Map<String, dynamic> json) {
    return TeacherVadTestDetailsModel(
      id: json['_id'],
      vadTestId: json['vadTestId'],
      subjectId: json['subjectId'],
      subject: json['subject'],
      date: json['date'],
      name: json['name'] ?? '',
      topics: json['topics'] ?? '',
      additionalInfo: json['additionalInfo'] ?? '',
      numberOfTopics: json['numberOfTopics'],
      documents:
          json['documents'] != null
              ? List<DocumentModel>.from(
                json['documents'].map((doc) => DocumentModel.fromJson(doc)),
              )
              : null,
      icon: json['icon'] ?? '',
      boardId: json['boardId'],
      startTime: json['startTime'],
      durationInMinutes: json['durationInMinutes'],
      endTime: json['endTime'],
      largerTopics:
          json['largerTopics'] != null
              ? List<LargerTopicModel>.from(
                json['largerTopics'].map(
                  (topic) => LargerTopicModel.fromJson(topic),
                ),
              )
              : null,
      reportGenerated: json['reportGenerated'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['vadTestId'] = vadTestId;
    data['subjectId'] = subjectId;
    data['subject'] = subject;
    data['date'] = date;
    data['name'] = name;
    data['topics'] = topics;
    data['additionalInfo'] = additionalInfo;
    data['numberOfTopics'] = numberOfTopics;
    if (documents != null) {
      data['documents'] = documents!.map((doc) => doc.toJson()).toList();
    }
    data['icon'] = icon;
    data['boardId'] = boardId;
    data['startTime'] = startTime;
    data['durationInMinutes'] = durationInMinutes;
    data['endTime'] = endTime;
    if (largerTopics != null) {
      data['largerTopics'] =
          largerTopics!.map((topic) => topic.toJson()).toList();
    }
    data['reportGenerated'] = reportGenerated;
    return data;
  }

  // Helper method to get a formatted date
  String getFormattedDate() {
    if (date == null) return 'No date';

    try {
      final DateTime dateTime = DateTime.parse(date!);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Helper method to get formatted start time
  String getFormattedStartTime() {
    if (startTime == null) return 'No time';

    try {
      final DateTime time = DateTime.parse(startTime!);
      return DateFormat('hh:mm a').format(time);
    } catch (e) {
      return 'Invalid time';
    }
  }

  // Helper method to get formatted end time
  String getFormattedEndTime() {
    if (endTime == null) return 'No time';

    try {
      final DateTime time = DateTime.parse(endTime!);
      return DateFormat('hh:mm a').format(time);
    } catch (e) {
      return 'Invalid time';
    }
  }

  // Helper method to get formatted duration
  String getFormattedDuration() {
    if (durationInMinutes == null) return '';

    final int hours = durationInMinutes! ~/ 60;
    final int minutes = durationInMinutes! % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Helper method to get test date as DateTime
  DateTime? getTestDate() {
    if (date == null) return null;

    try {
      return DateTime.parse(date!);
    } catch (e) {
      return null;
    }
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

  // Helper to check if document is a PDF
  bool isPdf() {
    return type?.contains('pdf') ?? false;
  }

  // Helper to check if document is an image
  bool isImage() {
    return type?.contains('image') ?? false;
  }

  // Helper to check if document is a link
  bool isLink() {
    return type == 'link';
  }

  // Helper to get file extension
  String getFileExtension() {
    if (name == null) return '';

    final parts = name!.split('.');
    if (parts.length > 1) {
      return parts.last;
    }
    return '';
  }
}

class LargerTopicModel {
  String? name;
  List<SubtopicModel>? subtopics;
  String? id;

  LargerTopicModel({this.name, this.subtopics, this.id});

  factory LargerTopicModel.fromJson(Map<String, dynamic> json) {
    return LargerTopicModel(
      name: json['name'],
      subtopics:
          json['subtopics'] != null
              ? List<SubtopicModel>.from(
                json['subtopics'].map(
                  (subtopic) => SubtopicModel.fromJson(subtopic),
                ),
              )
              : null,
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (subtopics != null) {
      data['subtopics'] =
          subtopics!.map((subtopic) => subtopic.toJson()).toList();
    }
    data['_id'] = id;
    return data;
  }

  // Helper to get number of subtopics
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
