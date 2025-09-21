class CommentsReplyModel {
  String? sId;
  String? parentId;
  String? comment;
  String? reply;
  RepliedBy? repliedBy;

  CommentsReplyModel({
    this.sId,
    this.parentId,
    this.comment,
    this.reply,
    this.repliedBy,
  });

  CommentsReplyModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    parentId = json['parentId'];
    comment = json['comment'];
    reply = json['reply'];
    repliedBy =
        json['repliedBy'] != null
            ? RepliedBy.fromJson(json['repliedBy'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['parentId'] = parentId;
    data['comment'] = comment;
    data['reply'] = reply;
    if (repliedBy != null) {
      data['repliedBy'] = repliedBy!.toJson();
    }
    return data;
  }
}

class RepliedBy {
  String? sId;
  String? name;
  String? profileImage;

  RepliedBy({this.sId, this.name, this.profileImage});

  RepliedBy.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    profileImage = json['profileImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['name'] = name;
    data['profileImage'] = profileImage;
    return data;
  }
}
