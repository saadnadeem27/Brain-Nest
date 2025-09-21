import 'package:intl/intl.dart';

class TeacherVadTestReportModel {
  String? id;
  SubmittedByModel? submittedBy;
  String? submittedOn;
  int? marksScored;

  TeacherVadTestReportModel({
    this.id,
    this.submittedBy,
    this.submittedOn,
    this.marksScored,
  });

  factory TeacherVadTestReportModel.fromJson(Map<String, dynamic> json) {
    return TeacherVadTestReportModel(
      id: json['_id'],
      submittedBy:
          json['submittedBy'] != null
              ? SubmittedByModel.fromJson(json['submittedBy'])
              : null,
      submittedOn: json['submittedOn'],
      marksScored: json['marksScored'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    if (submittedBy != null) {
      data['submittedBy'] = submittedBy!.toJson();
    }
    data['submittedOn'] = submittedOn;
    data['marksScored'] = marksScored;
    return data;
  }

  // Helper method to format submission date
  String getFormattedSubmissionDate() {
    if (submittedOn == null) return 'No date';

    try {
      final DateTime dateTime = DateTime.parse(submittedOn!);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Helper method to format submission time
  String getFormattedSubmissionTime() {
    if (submittedOn == null) return 'No time';

    try {
      final DateTime dateTime = DateTime.parse(submittedOn!);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return 'Invalid time';
    }
  }

  // Helper method to get full formatted submission date and time
  String getFullFormattedSubmissionDateTime() {
    if (submittedOn == null) return 'Not submitted';

    try {
      final DateTime dateTime = DateTime.parse(submittedOn!);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return 'Invalid date/time';
    }
  }

  // Helper method to get submission date as DateTime
  DateTime? getSubmissionDateTime() {
    if (submittedOn == null) return null;

    try {
      return DateTime.parse(submittedOn!);
    } catch (e) {
      return null;
    }
  }

  // Helper method to get student full name with class/section
  String getStudentFullDetails() {
    if (submittedBy == null) return 'Unknown student';

    final String name = submittedBy!.name ?? 'Unknown';
    final String className = submittedBy!.className ?? '';
    final String section = submittedBy!.section ?? '';

    if (className.isNotEmpty && section.isNotEmpty) {
      return '$name (Class $className-$section)';
    } else {
      return name;
    }
  }
}

class SubmittedByModel {
  String? id;
  String? name;
  String? className;
  String? section;

  SubmittedByModel({this.id, this.name, this.className, this.section});

  factory SubmittedByModel.fromJson(Map<String, dynamic> json) {
    return SubmittedByModel(
      id: json['_id'],
      name: json['name'],
      className: json['className'],
      section: json['section'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['name'] = name;
    data['className'] = className;
    data['section'] = section;
    return data;
  }

  // Helper to get formatted class and section
  String getFormattedClassSection() {
    if (className != null && section != null) {
      return 'Class $className-$section';
    } else if (className != null) {
      return 'Class $className';
    } else if (section != null) {
      return 'Section $section';
    } else {
      return '';
    }
  }
}
