class RuleBookModel {
  String? sId;
  String? title;
  List<String>? rules;
  String? scope;

  RuleBookModel({this.sId, this.title, this.rules, this.scope});

  RuleBookModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    rules = json['rules'].cast<String>();
    scope = json['scope'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['title'] = title;
    data['rules'] = rules;
    data['scope'] = scope;
    return data;
  }
}
