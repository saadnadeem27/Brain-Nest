class PeopleModel {
  String? sId;
  String? studentId;
  String? name;
  String? email;
  String? profileImage;

  PeopleModel(
      {this.sId, this.studentId, this.name, this.email, this.profileImage});

  PeopleModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    studentId = json['studentId'];
    name = json['name'];
    email = json['email'];
    profileImage = json['profileImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['studentId'] = studentId;
    data['name'] = name;
    data['email'] = email;
    data['profileImage'] = profileImage;
    return data;
  }
}

class TeacherModel {
  String? sId;
  String? name;
  String? profileImage;

  TeacherModel({this.sId, this.name});

  TeacherModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    profileImage = json['profileImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['name'] = name;
    return data;
  }
}
