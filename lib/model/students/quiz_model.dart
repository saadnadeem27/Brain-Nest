class QuizModel {
  String? question;
  List<String>? answerOptions;
  int? correctOptionIndex;

  QuizModel({this.question, this.answerOptions, this.correctOptionIndex});

  QuizModel.fromJson(Map<String, dynamic> json) {
    question = json['question'];
    answerOptions = json['answerOptions'].cast<String>();
    correctOptionIndex = json['correctOptionIndex'];
  }
}
