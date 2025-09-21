class TeacherSchoolExamMarkEntryModel {
  final String? id;
  final String? student;
  final String? exam;
  final String? subject;
  final int? markScored;
  final int? totalMark;

  TeacherSchoolExamMarkEntryModel({
    this.id,
    this.student,
    this.exam,
    this.subject,
    this.markScored,
    this.totalMark,
  });

  factory TeacherSchoolExamMarkEntryModel.fromJson(Map<String, dynamic> json) {
    return TeacherSchoolExamMarkEntryModel(
      id: json['_id'],
      student: json['student'],
      exam: json['exam'],
      subject: json['subject'],
      markScored: json['markScored'],
      totalMark: json['totalMark'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['student'] = student;
    data['exam'] = exam;
    data['subject'] = subject;
    data['markScored'] = markScored;
    data['totalMark'] = totalMark;
    return data;
  }

  // Helper method to get percentage
  double getPercentage() {
    if (totalMark == null || markScored == null || totalMark == 0) {
      return 0.0;
    }
    return (markScored! / totalMark!) * 100;
  }

  // Helper method to determine if the student passed
  bool isPassed() {
    return getPercentage() >= 40; // Assuming 40% is the pass mark
  }
}
