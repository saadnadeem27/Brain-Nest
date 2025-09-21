class ChapterModel {
  String? sId;
  int? chapterId;
  String? chapterName;
  String? createdAt;
  String? subjectId;

  ChapterModel(
      {this.sId,
      this.chapterId,
      this.chapterName,
      this.createdAt,
      this.subjectId});

  ChapterModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    chapterId = json['chapterId'];
    chapterName = json['chapterName'];
    createdAt = json['createdAt'];
    subjectId = json['subjectId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['chapterId'] = chapterId;
    data['chapterName'] = chapterName;
    data['createdAt'] = createdAt;
    data['subjectId'] = subjectId;
    return data;
  }
}
