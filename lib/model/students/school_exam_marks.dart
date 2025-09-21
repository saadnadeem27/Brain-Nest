class SchoolExamMarks {
  String? sId;
  bool? documentStatus;
  String? exam;
  String? subject;
  String? chaptersAndDetails;
  int? totalMark;
  int? markScored;

  SchoolExamMarks({
    this.sId,
    this.documentStatus,
    this.exam,
    this.subject,
    this.chaptersAndDetails,
    this.totalMark,
    this.markScored,
  });

  SchoolExamMarks.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    documentStatus = json['documentStatus'];
    exam = json['exam'];
    subject = json['subject'];
    chaptersAndDetails = json['chaptersAndDetails'];
    totalMark = json['totalMark'];
    markScored = json['markScored'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['documentStatus'] = documentStatus;
    data['exam'] = exam;
    data['subject'] = subject;
    data['chaptersAndDetails'] = chaptersAndDetails;
    data['totalMark'] = totalMark;
    data['markScored'] = markScored;
    return data;
  }
}
