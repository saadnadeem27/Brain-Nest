class VadTestSubjectsModel {
  String? subject;
  String? icon;
  String? latestTestDate;
  String? subjectId;

  VadTestSubjectsModel({
    this.subject,
    this.icon,
    this.latestTestDate,
    this.subjectId,
  });

  VadTestSubjectsModel.fromJson(Map<String, dynamic> json) {
    subject = json['subject'];
    icon = json['icon'];
    latestTestDate = json['latestTestDate'];
    subjectId = json['subjectId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['subject'] = subject;
    data['icon'] = icon;
    data['latestTestDate'] = latestTestDate;
    data['subjectId'] = subjectId;
    return data;
  }
}
