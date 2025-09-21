class TeacherStudentReport {
  final String subjectId;
  final String classId;
  final String sectionId;
  final List<StudentAssignmentItem> report;

  TeacherStudentReport({
    required this.subjectId,
    required this.classId,
    required this.sectionId,
    required this.report,
  });

  factory TeacherStudentReport.fromJson(Map<String, dynamic> json) {
    return TeacherStudentReport(
      subjectId: json['subjectId'],
      classId: json['classId'],
      sectionId: json['sectionId'],
      report:
          (json['report'] as List)
              .map((item) => StudentAssignmentItem.fromJson(item))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'classId': classId,
      'sectionId': sectionId,
      'report': report.map((item) => item.toJson()).toList(),
    };
  }
}

class StudentAssignmentItem {
  final DateTime date;
  final String assignmentTitle;
  final bool submitted;

  StudentAssignmentItem({
    required this.date,
    required this.assignmentTitle,
    required this.submitted,
  });

  factory StudentAssignmentItem.fromJson(Map<String, dynamic> json) {
    return StudentAssignmentItem(
      date: DateTime.parse(json['date']),
      assignmentTitle: json['assignmentTitle'],
      submitted: json['submitted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'assignmentTitle': assignmentTitle,
      'submitted': submitted,
    };
  }
}
