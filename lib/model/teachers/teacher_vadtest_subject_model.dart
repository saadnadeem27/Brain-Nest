import 'package:intl/intl.dart';

class TeacherVadTestSubjectModel {
  String? className;
  List<VadTestSubject>? tests;

  TeacherVadTestSubjectModel({this.className, this.tests});

  factory TeacherVadTestSubjectModel.fromJson(Map<String, dynamic> json) {
    return TeacherVadTestSubjectModel(
      className: json['className'],
      tests:
          json['tests'] != null
              ? List<VadTestSubject>.from(
                json['tests'].map((test) => VadTestSubject.fromJson(test)),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['className'] = className;
    if (tests != null) {
      data['tests'] = tests!.map((test) => test.toJson()).toList();
    }
    return data;
  }
}

class VadTestSubject {
  String? id;
  String? vadTestId;
  String? subjectId;
  String? subject;
  String? date;
  String? name;
  String? icon;

  VadTestSubject({
    this.id,
    this.vadTestId,
    this.subjectId,
    this.subject,
    this.date,
    this.name,
    this.icon,
  });

  factory VadTestSubject.fromJson(Map<String, dynamic> json) {
    return VadTestSubject(
      id: json['_id'],
      vadTestId: json['vadTestId'],
      subjectId: json['subjectId'],
      subject: json['subject'],
      date: json['date'],
      name: json['name'] ?? "",
      icon: json['icon'] ?? "",
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
    data['icon'] = icon;
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

  // Helper method to get DateTime object
  DateTime? getDateTime() {
    if (date == null) return null;

    try {
      return DateTime.parse(date!);
    } catch (e) {
      return null;
    }
  }
}
