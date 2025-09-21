class SchoolDetailModel {
  String? sId;
  String? schoolName;
  String? schoolAddress;
  List<Classes>? classes;

  SchoolDetailModel(
      {this.sId, this.schoolName, this.schoolAddress, this.classes});

  SchoolDetailModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    schoolName = json['schoolName'];
    schoolAddress = json['schoolAddress'];
    if (json['classes'] != null) {
      classes = <Classes>[];
      json['classes'].forEach((v) {
        classes!.add(Classes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['schoolName'] = schoolName;
    data['schoolAddress'] = schoolAddress;
    if (classes != null) {
      data['classes'] = classes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Classes {
  String? sId;
  String? name;
  List<Sections>? sections;

  Classes({this.sId, this.name, this.sections});

  Classes.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    if (json['sections'] != null) {
      sections = <Sections>[];
      json['sections'].forEach((v) {
        sections!.add(Sections.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['name'] = name;
    if (sections != null) {
      data['sections'] = sections!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Sections {
  String? sId;
  String? classId;
  String? section;

  Sections({this.sId, this.classId, this.section});

  Sections.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    classId = json['classId'];
    section = json['section'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['classId'] = classId;
    data['section'] = section;
    return data;
  }
}
