class TeacherAssignmentReport {
  final String subjectId;
  final String classId;
  final String sectionId;
  final List<AssignmentReportItem> report;
  final int totalAssignments;
  final int subjectAverage;

  TeacherAssignmentReport({
    required this.subjectId,
    required this.classId,
    required this.sectionId,
    required this.report,
    required this.totalAssignments,
    required this.subjectAverage,
  });

  factory TeacherAssignmentReport.fromJson(Map<String, dynamic> json) {
    return TeacherAssignmentReport(
      subjectId: json['subjectId'],
      classId: json['classId'],
      sectionId: json['sectionId'],
      report:
          (json['report'] as List)
              .map((item) => AssignmentReportItem.fromJson(item))
              .toList(),
      totalAssignments: json['totalAssignments'],
      subjectAverage: json['subjectAverage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'classId': classId,
      'sectionId': sectionId,
      'report': report.map((item) => item.toJson()).toList(),
      'totalAssignments': totalAssignments,
      'subjectAverage': subjectAverage,
    };
  }
}

class AssignmentReportItem {
  final DateTime date;
  final String assignmentTitle;
  final int submissionCount;
  final int totalStudents;
  final int average;

  AssignmentReportItem({
    required this.date,
    required this.assignmentTitle,
    required this.submissionCount,
    required this.totalStudents,
    required this.average,
  });

  factory AssignmentReportItem.fromJson(Map<String, dynamic> json) {
    return AssignmentReportItem(
      date: DateTime.parse(json['date']),
      assignmentTitle: json['assignmentTitle'],
      submissionCount: json['submissionCount'],
      totalStudents: json['totalStudents'],
      average: json['average'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'assignmentTitle': assignmentTitle,
      'submissionCount': submissionCount,
      'totalStudents': totalStudents,
      'average': average,
    };
  }
}
