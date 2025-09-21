class RemarksModel {
  String? sId;
  String? remarkId;
  SenderProfile? senderProfile;
  String? remarkedBy;
  String? remarkedOn;
  String? remarks;
  String? remarkedAt;
  String? schoolId;
  Null? classId;
  Null? sectionId;
  Null? subjectId;
  String? receiver;
  bool? sendToWhatsapp;
  bool? sendToParentWhatsapp;

  RemarksModel({
    this.sId,
    this.remarkId,
    this.senderProfile,
    this.remarkedBy,
    this.remarkedOn,
    this.remarks,
    this.remarkedAt,
    this.schoolId,
    this.classId,
    this.sectionId,
    this.subjectId,
    this.receiver,
    this.sendToWhatsapp,
    this.sendToParentWhatsapp,
  });

  RemarksModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    remarkId = json['remarkId'];
    senderProfile =
        json['senderProfile'] != null
            ? SenderProfile.fromJson(json['senderProfile'])
            : null;
    remarkedBy = json['remarkedBy'];
    remarkedOn = json['remarkedOn'];
    remarks = json['remarks'];
    remarkedAt = json['remarkedAt'];
    schoolId = json['schoolId'];
    classId = json['classId'];
    sectionId = json['sectionId'];
    subjectId = json['subjectId'];
    receiver = json['receiver'];
    sendToWhatsapp = json['sendToWhatsapp'];
    sendToParentWhatsapp = json['sendToParentWhatsapp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['remarkId'] = remarkId;
    if (senderProfile != null) {
      data['senderProfile'] = senderProfile!.toJson();
    }
    data['remarkedBy'] = remarkedBy;
    data['remarkedOn'] = remarkedOn;
    data['remarks'] = remarks;
    data['remarkedAt'] = remarkedAt;
    data['schoolId'] = schoolId;
    data['classId'] = classId;
    data['sectionId'] = sectionId;
    data['subjectId'] = subjectId;
    data['receiver'] = receiver;
    data['sendToWhatsapp'] = sendToWhatsapp;
    data['sendToParentWhatsapp'] = sendToParentWhatsapp;
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
