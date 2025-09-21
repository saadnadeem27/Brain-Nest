class AnnouncementsModel {
  String? sId;
  String? announcementId;
  String? sender;
  String? title;
  String? description;
  String? createdOn;
  String? senderType;
  String? classId;
  String? schoolId;
  String? subjectId;
  SenderProfile? senderProfile;

  AnnouncementsModel(
      {this.sId,
      this.announcementId,
      this.sender,
      this.title,
      this.description,
      this.createdOn,
      this.senderType,
      this.classId,
      this.schoolId,
      this.subjectId,
      this.senderProfile});

  AnnouncementsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    announcementId = json['announcementId'];
    sender = json['sender'];
    title = json['title'];
    description = json['description'];
    createdOn = json['createdOn'];
    senderType = json['senderType'];
    classId = json['classId'];
    schoolId = json['schoolId'];
    subjectId = json['subjectId'];
    senderProfile = json['senderProfile'] != null
        ? new SenderProfile.fromJson(json['senderProfile'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['announcementId'] = announcementId;
    data['sender'] = sender;
    data['title'] = title;
    data['description'] = description;
    data['createdOn'] = createdOn;
    data['senderType'] = senderType;
    data['classId'] = classId;
    data['schoolId'] = schoolId;
    data['subjectId'] = subjectId;
    if (senderProfile != null) {
      data['senderProfile'] = senderProfile!.toJson();
    }
    return data;
  }
}

class SenderProfile {
  String? name;
  String? profileImage;

  SenderProfile({this.name, this.profileImage});

  SenderProfile.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    profileImage = json['profileImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['profileImage'] = profileImage;
    return data;
  }
}
