class VadTestModel {
  String? sId;
  String? vadTestId;
  String? subjectId;
  String? subject;
  String? date;
  String? name;
  String? topics;
  String? additionalInfo;
  int? numberOfTopics;
  String? icon;
  List<Documents>? documents;

  VadTestModel({
    this.sId,
    this.vadTestId,
    this.subjectId,
    this.subject,
    this.date,
    this.name,
    this.topics,
    this.additionalInfo,
    this.numberOfTopics,
    this.icon,
    this.documents,
  });

  VadTestModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    vadTestId = json['vadTestId'];
    subjectId = json['subjectId'];
    subject = json['subject'];
    date = json['date'];
    name = json['name'];
    topics = json['topics'];
    additionalInfo = json['additionalInfo'];
    numberOfTopics = json['numberOfTopics'];
    icon = json['icon'];
    if (json['documents'] != null) {
      documents = <Documents>[];
      json['documents'].forEach((v) {
        documents?.add(Documents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['vadTestId'] = vadTestId;
    data['subjectId'] = subjectId;
    data['subject'] = subject;
    data['date'] = date;
    data['name'] = name;
    data['topics'] = topics;
    data['additionalInfo'] = additionalInfo;
    data['numberOfTopics'] = numberOfTopics;
    data['icon'] = icon;
    if (documents != null) {
      data['documents'] = documents!.map((v) => v.toJson()).toList();
    }
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['type'] = type;
    data['link'] = link;
    data['name'] = name;
    return data;
  }
}
