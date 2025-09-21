class NotificationModel {
  String? sId;
  String? type;
  List<String>? recipients;
  Sender? sender;
  String? title;
  String? description;
  String? sentOn;

  NotificationModel({
    this.sId,
    this.type,
    this.recipients,
    this.sender,
    this.title,
    this.description,
    this.sentOn,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
    recipients = json['recipients'].cast<String>();
    sender = json['sender'] != null ? Sender.fromJson(json['sender']) : null;
    title = json['title'];
    description = json['description'];
    sentOn = json['sentOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['type'] = type;
    data['recipients'] = recipients;
    if (sender != null) {
      data['sender'] = sender!.toJson();
    }
    data['title'] = title;
    data['description'] = description;
    data['sentOn'] = sentOn;
    return data;
  }
}

class Sender {
  String? name;
  String? profileImage;

  Sender({this.name, this.profileImage});

  Sender.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    profileImage = json['profileImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = name;
    data['profileImage'] = profileImage;
    return data;
  }
}
