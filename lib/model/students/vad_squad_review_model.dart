class VADSquadReviewModel {
  String? sId;
  String? review;

  VADSquadReviewModel({this.sId, this.review});

  VADSquadReviewModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    review = json['review'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['review'] = review;
    return data;
  }
}
