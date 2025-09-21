class TestModel {
  String? sId;
  String? chapterId;
  List<Questions>? questions;

  TestModel({this.sId, this.chapterId, this.questions});

  TestModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    chapterId = json['chapterId'];
    if (json['questions'] != null) {
      questions = <Questions>[];
      json['questions'].forEach((v) {
        questions!.add(Questions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['chapterId'] = chapterId;
    if (questions != null) {
      data['questions'] = questions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Questions {
  String? sId;
  int? questionId;
  String? question;
  bool? isMCQ;
  List<String>? answerOptions;
  int? correctOptionIndex;

  Questions(
      {this.sId,
      this.questionId,
      this.question,
      this.isMCQ,
      this.answerOptions,
      this.correctOptionIndex});

  Questions.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    questionId = int.tryParse(json['questionId'].toString());
    question = json['question'];
    isMCQ = json['isMCQ'];
    answerOptions = json['answerOptions'] != null
        ? json['answerOptions'].cast<String>()
        : <String>[];
    correctOptionIndex = int.tryParse(json['correctOptionIndex'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['questionId'] = questionId;
    data['question'] = question;
    data['isMCQ'] = isMCQ;
    data['answerOptions'] = answerOptions;
    data['correctOptionIndex'] = correctOptionIndex;
    return data;
  }
}
