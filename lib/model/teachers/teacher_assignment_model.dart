class TeacherAssignmentModel {
  String? sId;
  String? assignmentId;
  String? lesson;
  List<String>? topics;
  String? createdAt;
  String? additionalInfo;
  String? dueDate;
  String? instructions;
  String? submissionFormat;
  bool? isMCQ;
  String? contents;
  List<AssignmentDocument>? documents;
  int? numberOfQuestions;
  List<MCQQuestion>? mCQs;
  String? subjectId;
  int? submittedCount;

  TeacherAssignmentModel({
    this.sId,
    this.assignmentId,
    this.lesson,
    this.topics,
    this.createdAt,
    this.additionalInfo,
    this.dueDate,
    this.instructions,
    this.submissionFormat,
    this.isMCQ,
    this.contents,
    this.documents,
    this.numberOfQuestions,
    this.mCQs,
    this.subjectId,
    this.submittedCount,
  });

  TeacherAssignmentModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    assignmentId = json['assignmentId'];
    lesson = json['lesson'];
    topics = json['topics'] != null ? List<String>.from(json['topics']) : null;
    createdAt = json['createdAt'];
    additionalInfo = json['additionalInfo'];
    dueDate = json['dueDate'];
    instructions = json['instructions'];
    submissionFormat = json['submissionFormat'];
    isMCQ = json['isMCQ'];
    contents = json['contents'];

    if (json['documents'] != null) {
      documents = <AssignmentDocument>[];
      json['documents'].forEach((v) {
        documents!.add(AssignmentDocument.fromJson(v));
      });
    }

    numberOfQuestions = json['numberOfQuestions'];

    if (json['MCQs'] != null) {
      mCQs = <MCQQuestion>[];
      json['MCQs'].forEach((v) {
        mCQs!.add(MCQQuestion.fromJson(v));
      });
    }

    subjectId = json['subjectId'];
    submittedCount = int.tryParse(json['submittedCount'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['assignmentId'] = assignmentId;
    data['lesson'] = lesson;
    data['topics'] = topics;
    data['createdAt'] = createdAt;
    data['additionalInfo'] = additionalInfo;
    data['dueDate'] = dueDate;
    data['instructions'] = instructions;
    data['submissionFormat'] = submissionFormat;
    data['isMCQ'] = isMCQ;
    data['contents'] = contents;

    if (documents != null) {
      data['documents'] = documents!.map((v) => v.toJson()).toList();
    }

    data['numberOfQuestions'] = numberOfQuestions;

    if (mCQs != null) {
      data['MCQs'] = mCQs!.map((v) => v.toJson()).toList();
    }

    data['subjectId'] = subjectId;
    data['submittedCount'] = submittedCount;
    return data;
  }

  // Helper methods for date formatting if needed
  DateTime? getCreatedAtDateTime() {
    return createdAt != null ? DateTime.parse(createdAt!) : null;
  }

  DateTime? getDueDateDateTime() {
    return dueDate != null ? DateTime.parse(dueDate!) : null;
  }

  // Get submission status based on due date
  bool isDueOver() {
    final dueDateTime = getDueDateDateTime();
    if (dueDateTime == null) return false;
    return DateTime.now().isAfter(dueDateTime);
  }
}

class AssignmentDocument {
  String? type;
  String? link;
  String? name;
  String? sId;

  AssignmentDocument({this.type, this.link, this.name, this.sId});

  AssignmentDocument.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    link = json['link'];
    name = json['name'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['link'] = link;
    data['name'] = name;
    data['_id'] = sId;
    return data;
  }
}

class MCQQuestion {
  String? question;
  List<String>? answerOptions;
  int? correctOptionIndex;
  String? sId;

  MCQQuestion({
    this.question,
    this.answerOptions,
    this.correctOptionIndex,
    this.sId,
  });

  MCQQuestion.fromJson(Map<String, dynamic> json) {
    question = json['question'];
    if (json['answerOptions'] != null) {
      answerOptions = List<String>.from(
        json['answerOptions'].map((option) => option.toString()),
      );
    } else {
      answerOptions = null;
    }
    correctOptionIndex = int.tryParse(json['correctOptionIndex'].toString());
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['question'] = question;
    data['answerOptions'] = answerOptions;
    data['correctOptionIndex'] = correctOptionIndex;
    data['_id'] = sId;
    return data;
  }
}
