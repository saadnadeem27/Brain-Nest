class ModuleModel {
  String? sId;
  int? moduleId;
  String? moduleName;
  String? createdAt;
  String? chapterId;
  List<Documents>? documents;

  ModuleModel(
      {this.sId,
      this.moduleId,
      this.moduleName,
      this.createdAt,
      this.chapterId,
      this.documents});

  ModuleModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    moduleId = json['moduleId'];
    moduleName = json['moduleName'];
    createdAt = json['createdAt'];
    chapterId = json['chapterId'];
    if (json['documents'] != null) {
      documents = <Documents>[];
      json['documents'].forEach((v) {
        documents!.add(new Documents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['moduleId'] = moduleId;
    data['moduleName'] = moduleName;
    data['createdAt'] = createdAt;
    data['chapterId'] = chapterId;
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
