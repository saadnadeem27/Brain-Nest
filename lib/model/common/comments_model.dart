class CommentsModel {
  String? sId;
  String? parentId;
  String? commentedOn;
  CommentedBy? commentedBy;
  String? comment;
  String? relatesTo;
  List<Replies>? replies;
  int? replyCount;

  CommentsModel({
    this.sId,
    this.parentId,
    this.commentedOn,
    this.commentedBy,
    this.comment,
    this.relatesTo,
    this.replies,
    this.replyCount,
  });

  CommentsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    parentId = json['parentId'];
    commentedOn = json['commentedOn'];
    commentedBy =
        json['commentedBy'] != null
            ? CommentedBy.fromJson(json['commentedBy'])
            : null;
    comment = json['comment'];
    relatesTo = json['relatesTo'];
    if (json['replies'] != null) {
      replies = <Replies>[];
      json['replies'].forEach((v) {
        replies!.add(Replies.fromJson(v));
      });
    }
    replyCount = json['replyCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['parentId'] = parentId;
    data['commentedOn'] = commentedOn;
    if (commentedBy != null) {
      data['commentedBy'] = commentedBy!.toJson();
    }
    data['comment'] = comment;
    data['relatesTo'] = relatesTo;
    if (replies != null) {
      data['replies'] = replies!.map((v) => v.toJson()).toList();
    }
    data['replyCount'] = replyCount;
    return data;
  }
}

class CommentedBy {
  String? sId;
  String? name;
  String? profileImageUrl;

  CommentedBy({this.sId, this.name, this.profileImageUrl});

  CommentedBy.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    profileImageUrl = json['profileImageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['name'] = name;
    data['profileImageUrl'] = profileImageUrl;
    return data;
  }
}

class Replies {
  String? sId;
  String? parentId;
  String? comment;
  String? reply;
  RepliedBy? repliedBy;
  int? iV;

  Replies({
    this.sId,
    this.parentId,
    this.comment,
    this.reply,
    this.repliedBy,
    this.iV,
  });

  Replies.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    parentId = json['parentId'];
    comment = json['comment'];
    reply = json['reply'];
    repliedBy =
        json['repliedBy'] != null
            ? RepliedBy.fromJson(json['repliedBy'])
            : null;
    iV = json['__v'];
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
    data['__v'] = iV;
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
