class StudentAttendanceModel {
  String? id;
  String? name;
  String? profileImage;
  AttendanceDetails? attendanceDetails;

  StudentAttendanceModel({
    this.id,
    this.name,
    this.profileImage,
    this.attendanceDetails,
  });

  StudentAttendanceModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    profileImage = json['profileImage'];
    attendanceDetails = AttendanceDetails.fromJson(json['attendanceDetails']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['name'] = name;
    data['profileImage'] = profileImage;
    if (attendanceDetails != null) {
      data['attendanceDetails'] = attendanceDetails!.toJson();
    }
    return data;
  }
}

class AttendanceDetails {
  String? status;
  String? dayStatus;

  AttendanceDetails({this.status, this.dayStatus});

  AttendanceDetails.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      status = json['status'];
      dayStatus = json['dayStatus'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['dayStatus'] = dayStatus;
    return data;
  }
}
