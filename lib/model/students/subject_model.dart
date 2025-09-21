class SubjectModel {
  String? sId;
  String? subjectId;
  String? subjectName;
  String? type;
  int? announcementsCount;
  int? assignmentsCount;

  SubjectModel({this.sId, this.subjectId, this.subjectName, this.type});

  SubjectModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    subjectId = json['subjectId'];
    subjectName = json['subjectName'];
    type = json['type'];
    announcementsCount = int.tryParse(json['announcementsCount'].toString());
    assignmentsCount = int.tryParse(json['assignmentsCount'].toString());
  }
}
