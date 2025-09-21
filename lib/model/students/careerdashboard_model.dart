import 'package:Vadai/common_imports.dart';

class CareerDashboardModel {
  String? sId;
  String? studentId;
  String? goal;
  String? strength;
  String? weakness;
  List<Plans>? plans;

  CareerDashboardModel(
      {this.sId,
      this.studentId,
      this.goal,
      this.strength,
      this.weakness,
      this.plans});

  CareerDashboardModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    studentId = json['studentId'];
    goal = json['goal'];
    strength = json['strength'];
    weakness = json['weakness'];
    if (json['plans'] != null) {
      plans = <Plans>[];
      json['plans'].forEach((v) {
        plans!.add(Plans.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['studentId'] = studentId;
    data['goal'] = goal;
    data['strength'] = strength;
    data['weakness'] = weakness;
    if (plans != null) {
      data['plans'] = plans!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Plans {
  String? plan;
  String? industry;
  String? careerPath;
  String? sId;
  RxBool isIndustryChanged = false.obs;
  RxBool isCareerPathChanged = false.obs;
  Plans({
    this.plan,
    this.industry,
    this.careerPath,
    this.sId,
  });

  Plans.fromJson(Map<String, dynamic> json) {
    plan = json['plan'];
    industry = json['industry'];
    careerPath = json['careerPath'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['plan'] = plan;
    data['industry'] = industry;
    data['careerPath'] = careerPath;
    data['_id'] = sId;
    return data;
  }
}
