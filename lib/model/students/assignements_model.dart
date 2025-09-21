class AssignmentsModel {
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
  int? numberOfQuestions;
  List<MCQs>? mCQs;
  String? subjectId;
  String? contents;
  List<Documents>? documents;
  bool? isCompleted;

  AssignmentsModel({
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
    this.numberOfQuestions,
    this.mCQs,
    this.subjectId,
    this.contents,
    this.documents,
    this.isCompleted,
  });

  AssignmentsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    assignmentId = json['assignmentId'];
    lesson = json['lesson'];
    topics = json['topics'].cast<String>();
    createdAt = json['createdAt'];
    additionalInfo = json['additionalInfo'];
    dueDate = json['dueDate'];
    instructions = json['instructions'];
    submissionFormat = json['submissionFormat'];
    isMCQ = json['isMCQ'];
    numberOfQuestions = json['numberOfQuestions'];
    if (json['MCQs'] != null) {
      mCQs = <MCQs>[];
      json['MCQs'].forEach((v) {
        mCQs!.add(new MCQs.fromJson(v));
      });
    }
    subjectId = json['subjectId'];
    contents = json['contents'];
    if (json['documents'] != null) {
      documents = <Documents>[];
      json['documents'].forEach((v) {
        documents!.add(new Documents.fromJson(v));
      });
    }
    isCompleted = json['isCompleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['assignmentId'] = this.assignmentId;
    data['lesson'] = this.lesson;
    data['topics'] = this.topics;
    data['createdAt'] = this.createdAt;
    data['additionalInfo'] = this.additionalInfo;
    data['dueDate'] = this.dueDate;
    data['instructions'] = this.instructions;
    data['submissionFormat'] = this.submissionFormat;
    data['isMCQ'] = this.isMCQ;
    data['numberOfQuestions'] = this.numberOfQuestions;
    if (this.mCQs != null) {
      data['MCQs'] = this.mCQs!.map((v) => v.toJson()).toList();
    }
    data['subjectId'] = this.subjectId;
    data['contents'] = this.contents;
    if (this.documents != null) {
      data['documents'] = this.documents!.map((v) => v.toJson()).toList();
    }
    data['isCompleted'] = this.isCompleted;
    return data;
  }
}

class MCQs {
  String? question;
  List<String>? answerOptions;
  int? correctOptionIndex;
  String? sId;

  MCQs({this.question, this.answerOptions, this.correctOptionIndex, this.sId});

  MCQs.fromJson(Map<String, dynamic> json) {
    question = json['question'];
    answerOptions = json['answerOptions'].cast<String>();
    correctOptionIndex = json['correctOptionIndex'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['question'] = this.question;
    data['answerOptions'] = this.answerOptions;
    data['correctOptionIndex'] = this.correctOptionIndex;
    data['_id'] = this.sId;
    return data;
  }
}

class Documents {
  String? sId;
  String? type;
  String? link;
  String? name;

  Documents({this.sId, this.type, this.link, this.name});

  Documents.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
    link = json['link'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['type'] = this.type;
    data['link'] = this.link;
    data['name'] = this.name;
    return data;
  }
}
