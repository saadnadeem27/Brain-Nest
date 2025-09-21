class TeacherSubmittedAssignment {
  final String id;
  final bool documentStatus;
  final String submissionId;
  final String assignmentId;
  final Student submittedBy;
  final DateTime submittedOn;
  final List<MCQAnswer> mcqAnswers;
  final List<String> filesAttached;
  final String approvalStatus;
  final int version;

  TeacherSubmittedAssignment({
    required this.id,
    required this.documentStatus,
    required this.submissionId,
    required this.assignmentId,
    required this.submittedBy,
    required this.submittedOn,
    required this.mcqAnswers,
    required this.filesAttached,
    required this.approvalStatus,
    required this.version,
  });

  factory TeacherSubmittedAssignment.fromJson(Map<String, dynamic> json) {
    return TeacherSubmittedAssignment(
      id: json['_id'],
      documentStatus: json['documentStatus'],
      submissionId: json['submissionId'],
      assignmentId: json['assignmentId'],
      submittedBy: Student.fromJson(json['submittedBy']),
      submittedOn: DateTime.parse(json['submittedOn']),
      mcqAnswers:
          (json['MCQAnswers'] as List)
              .map((answer) => MCQAnswer.fromJson(answer))
              .toList(),
      filesAttached: List<String>.from(json['filesAttached']),
      approvalStatus: json['approvalStatus'],
      version: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'documentStatus': documentStatus,
      'submissionId': submissionId,
      'assignmentId': assignmentId,
      'submittedBy': submittedBy.toJson(),
      'submittedOn': submittedOn.toISOString(),
      'MCQAnswers': mcqAnswers.map((answer) => answer.toJson()).toList(),
      'filesAttached': filesAttached,
      'approvalStatus': approvalStatus,
      '__v': version,
    };
  }
}

class Student {
  final String id;
  final String name;
  final String profileImage;
  final String className;
  final String section;

  Student({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.className,
    required this.section,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['_id'],
      name: json['name'],
      profileImage: json['profileImage'],
      className: json['className'],
      section: json['section'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'profileImage': profileImage,
      'className': className,
      'section': section,
    };
  }
}

class MCQAnswer {
  final String questionId;
  final int selectedOptionIndex;
  final String id;

  MCQAnswer({
    required this.questionId,
    required this.selectedOptionIndex,
    required this.id,
  });

  factory MCQAnswer.fromJson(Map<String, dynamic> json) {
    return MCQAnswer(
      questionId: json['questionId'],
      selectedOptionIndex: json['selectedOptionIndex'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedOptionIndex': selectedOptionIndex,
      '_id': id,
    };
  }
}

extension DateTimeExtension on DateTime {
  String toISOString() {
    return toUtc().toIso8601String();
  }
}
