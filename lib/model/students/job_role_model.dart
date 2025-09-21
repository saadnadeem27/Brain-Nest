class JobRoleModel {
  String? sId;
  String? jobRole;
  String? industry;
  String? description;
  String? categoryId;
  String? range;

  JobRoleModel(
      {this.sId,
      this.jobRole,
      this.industry,
      this.description,
      this.categoryId,
      this.range});

  JobRoleModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    jobRole = json['jobRole'];
    industry = json['industry'];
    description = json['description'];
    categoryId = json['categoryId'];
    range = json['range'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['jobRole'] = jobRole;
    data['industry'] = industry;
    data['description'] = description;
    data['categoryId'] = categoryId;
    data['range'] = range;
    return data;
  }
}

class JobRoleCategory {
  String? sId;
  String? categoryName;
  String? description;
  bool? documentStatus;
  String? createdAt;

  JobRoleCategory(
      {this.sId,
      this.categoryName,
      this.description,
      this.documentStatus,
      this.createdAt});

  JobRoleCategory.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    categoryName = json['categoryName'];
    description = json['description'];
    documentStatus = json['documentStatus'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['categoryName'] = categoryName;
    data['description'] = description;
    data['documentStatus'] = documentStatus;
    data['createdAt'] = createdAt;
    return data;
  }
}
