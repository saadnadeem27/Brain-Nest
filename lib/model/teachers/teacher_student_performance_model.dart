import 'package:intl/intl.dart';

class TeacherStudentPerformanceModel {
  bool? status;
  int? statusCode;
  String? message;
  PerformanceReport? report;

  TeacherStudentPerformanceModel({
    this.status,
    this.statusCode,
    this.message,
    this.report,
  });

  TeacherStudentPerformanceModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    report =
        json['data'] != null && json['data']['report'] != null
            ? PerformanceReport.fromJson(json['data']['report'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['statusCode'] = statusCode;
    data['message'] = message;
    if (report != null) {
      data['data'] = {'report': report!.toJson()};
    }
    return data;
  }
}

class PerformanceReport {
  StudentInfo? student;
  List<ExamPerformance>? exams;

  PerformanceReport({this.student, this.exams});

  PerformanceReport.fromJson(Map<String, dynamic> json) {
    student =
        json['student'] != null ? StudentInfo.fromJson(json['student']) : null;

    if (json['exams'] != null) {
      exams = <ExamPerformance>[];
      json['exams'].forEach((v) {
        exams!.add(ExamPerformance.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (student != null) {
      data['student'] = student!.toJson();
    }
    if (exams != null) {
      data['exams'] = exams!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  // Helper method to get overall percentage across all exams
  double getOverallPercentage() {
    if (exams == null || exams!.isEmpty) return 0.0;

    int totalMarksScored = 0;
    int totalMarksAvailable = 0;

    for (var exam in exams!) {
      for (var subject in exam.subjects ?? []) {
        totalMarksScored += int.tryParse(subject.markScored.toString()) ?? 0;
        totalMarksAvailable += int.tryParse(subject.totalMark.toString()) ?? 0;
      }
    }

    if (totalMarksAvailable == 0) return 0.0;
    return (totalMarksScored / totalMarksAvailable) * 100;
  }
}

class StudentInfo {
  String? id;
  String? name;
  String? profileImage;
  String? className;
  String? section;

  StudentInfo({
    this.id,
    this.name,
    this.profileImage,
    this.className,
    this.section,
  });

  StudentInfo.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    profileImage = json['profileImage'];
    className = json['className'];
    section = json['section'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['name'] = name;
    data['profileImage'] = profileImage;
    data['className'] = className;
    data['section'] = section;
    return data;
  }

  // Get formatted class and section display
  String getClassDisplay() {
    if (className != null && section != null) {
      return "Class $className-$section";
    } else if (className != null) {
      return "Class $className";
    }
    return "N/A";
  }
}

class ExamPerformance {
  String? id;
  String? name;
  DateTime? startDate;
  List<SubjectPerformance>? subjects;

  ExamPerformance({this.id, this.name, this.startDate, this.subjects});

  ExamPerformance.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    startDate =
        json['startDate'] != null ? DateTime.parse(json['startDate']) : null;

    if (json['subjects'] != null) {
      subjects = <SubjectPerformance>[];
      json['subjects'].forEach((v) {
        subjects!.add(SubjectPerformance.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['name'] = name;
    if (startDate != null) {
      data['startDate'] = startDate!.toIso8601String();
    }
    if (subjects != null) {
      data['subjects'] = subjects!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  // Helper method to get formatted date
  String getFormattedDate() {
    if (startDate == null) return "N/A";
    return DateFormat("MMM d, yyyy").format(startDate!);
  }

  // Helper method to calculate average percentage for this exam
  double getAveragePercentage() {
    if (subjects == null || subjects!.isEmpty) return 0.0;

    int totalMarksScored = 0;
    int totalMarksAvailable = 0;

    for (var subject in subjects!) {
      totalMarksScored += subject.markScored ?? 0;
      totalMarksAvailable += subject.totalMark ?? 0;
    }

    if (totalMarksAvailable == 0) return 0.0;
    return (totalMarksScored / totalMarksAvailable) * 100;
  }

  // Helper method to get total marks
  int getTotalMarksScored() {
    if (subjects == null) return 0;

    int total = 0;
    for (var subject in subjects!) {
      total += subject.markScored ?? 0;
    }
    return total;
  }

  int getTotalMarksAvailable() {
    if (subjects == null) return 0;

    int total = 0;
    for (var subject in subjects!) {
      total += subject.totalMark ?? 0;
    }
    return total;
  }
}

class SubjectPerformance {
  String? id;
  String? subject;
  int? totalMark;
  DateTime? date;
  int? markScored;

  SubjectPerformance({
    this.id,
    this.subject,
    this.totalMark,
    this.date,
    this.markScored,
  });

  SubjectPerformance.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    subject = json['subject'];
    totalMark = json['totalMark'];
    date = json['date'] != null ? DateTime.parse(json['date']) : null;
    markScored = json['markScored'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['subject'] = subject;
    data['totalMark'] = totalMark;
    if (date != null) {
      data['date'] = date!.toIso8601String();
    }
    data['markScored'] = markScored;
    return data;
  }

  // Helper method to get formatted date
  String getFormattedDate() {
    if (date == null) return "N/A";
    return DateFormat("MMM d, yyyy").format(date!);
  }

  // Helper method to calculate percentage for this subject
  double getPercentage() {
    if (totalMark == null || markScored == null || totalMark == 0) {
      return 0.0;
    }
    return (markScored! / totalMark!) * 100;
  }

  // Helper method to get performance grade
  String getGrade() {
    double percentage = getPercentage();

    if (percentage >= 90) return "A+";
    if (percentage >= 80) return "A";
    if (percentage >= 70) return "B+";
    if (percentage >= 60) return "B";
    if (percentage >= 50) return "C";
    if (percentage >= 40) return "D";
    return "F";
  }
}
