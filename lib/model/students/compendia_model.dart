import 'dart:ui';

import 'package:Vadai/common/app_colors.dart';
import 'package:get/get.dart';

class CompendiaOverviewModel {
  String? continuedFrom;
  String? sId;
  String? compendiumId;
  String? title;
  String? contents;
  List<String?>? websiteLinks;
  String? coverImage;
  List<String>? images;
  String? category;
  String? categoryId;
  String? subcategory;
  String? subcategoryId;
  RxBool? isPinned;
  int? numberOfQuestions;
  List<MCQs?>? mCQs;
  Rx<int?> pinnedCount = Rx<int?>(null);
  String? createdAt;
  String? createdBy;
  double? rating;

  CompendiaOverviewModel({
    this.continuedFrom,
    this.sId,
    this.compendiumId,
    this.title,
    this.contents,
    this.websiteLinks,
    this.coverImage,
    this.images,
    this.category,
    this.subcategory,
    this.categoryId,
    this.subcategoryId,
    this.numberOfQuestions,
    this.mCQs,
    this.isPinned,
    this.createdBy,
    this.rating,
    required this.pinnedCount,
    this.createdAt,
  });

  CompendiaOverviewModel.fromJson(Map<String, dynamic> json) {
    continuedFrom = json['continuedFrom'];
    sId = json['_id'];
    compendiumId = json['compendiumId'];
    title = json['title'];
    contents = json['contents'];
    websiteLinks =
        json['websiteLinks'] != null
            ? List<String>.from(json['websiteLinks'])
            : [];
    coverImage = json['coverImage'];
    images = json['images'] != null ? List<String>.from(json['images']) : [];
    category = json['category'] != null ? json['category']['name'] : null;
    categoryId = json['category'] != null ? json['category']['_id'] : null;
    subcategory =
        json['subcategory'] != null ? json['subcategory']['name'] : null;
    subcategoryId =
        json['subcategory'] != null ? json['subcategory']['_id'] : null;
    numberOfQuestions = json['numberOfQuestions'];
    if (json['MCQs'] != null) {
      mCQs = <MCQs>[];
      json['MCQs'].forEach((v) {
        mCQs?.add(MCQs.fromJson(v));
      });
    }
    pinnedCount = int.tryParse(json['pinnedCount'].toString()).obs;
    createdAt = json['createdAt'];
    isPinned = RxBool(json['isPinned'] ?? false);
    createdBy =
        json['createdBy'] != null && json['createdBy']['name'] != null
            ? json['createdBy']['name']
            : null;
    rating = double.tryParse(json['rating'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['continuedFrom'] = continuedFrom;
    data['_id'] = sId;
    data['compendiumId'] = compendiumId;
    data['title'] = title;
    data['contents'] = contents;
    data['websiteLinks'] = websiteLinks;
    data['coverImage'] = coverImage;
    data['images'] = images;
    data['category'] = category;
    data['subcategory'] = subcategory;
    data['numberOfQuestions'] = numberOfQuestions;
    if (mCQs != null) {
      data['MCQs'] = mCQs?.map((v) => v?.toJson()).toList();
    }
    data['pinnedCount'] = pinnedCount;
    data['createdAt'] = createdAt;
    return data;
  }
}

class MCQs {
  String? sId;
  String? questionId;
  String? question;
  List<String?>? answerOptions;
  int? correctOptionIndex;

  MCQs({
    this.sId,
    this.questionId,
    this.question,
    this.answerOptions,
    this.correctOptionIndex,
  });

  MCQs.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    questionId = json['questionId'];
    question = json['question'];
    answerOptions =
        json['answerOptions'] != null
            ? List<String>.from(json['answerOptions'])
            : [];
    correctOptionIndex = int.tryParse(json['correctOptionIndex'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['questionId'] = questionId;
    data['question'] = question;
    data['answerOptions'] = answerOptions;
    data['correctOptionIndex'] = correctOptionIndex;
    return data;
  }
}

class CompendiaSubCategoryModel {
  String? sId;
  String? categoryId;
  String? name;
  String? createdAt;

  CompendiaSubCategoryModel({
    this.sId,
    this.categoryId,
    this.name,
    this.createdAt,
  });

  CompendiaSubCategoryModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    categoryId = json['categoryId'];
    name = json['name'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['categoryId'] = categoryId;
    data['name'] = name;
    data['createdAt'] = createdAt;
    return data;
  }
}

class CompendiaCategoryModel {
  String? sId;
  String? name;
  String? createdAt;

  CompendiaCategoryModel({this.sId, this.name, this.createdAt});

  CompendiaCategoryModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['name'] = name;
    data['createdAt'] = createdAt;
    return data;
  }
}

//! Comopendia Detail Model

class CompendiaDetailModel {
  Compendium? compendium;
  ContinuedFrom? continuedFrom;
  List<Continuations?>? continuations;

  CompendiaDetailModel({
    this.compendium,
    this.continuedFrom,
    this.continuations,
  });

  CompendiaDetailModel.fromJson(Map<String, dynamic> json) {
    compendium =
        json['compendium'] != null
            ? Compendium.fromJson(json['compendium'])
            : null;
    if (json['continuedFrom'] != null) {
      if (json['continuedFrom'] is Map) {
        continuedFrom = ContinuedFrom.fromJson(json['continuedFrom']);
      } else if (json['continuedFrom'] is String) {
        continuedFrom = ContinuedFrom(sId: json['continuedFrom']);
      }
    } else {
      continuedFrom = null;
    }
    if (json['continuations'] != null && json['continuations'] is List) {
      continuations = <Continuations>[];
      json['continuations'].forEach((v) {
        continuations?.add(Continuations.fromJson(v));
      });
    } else {
      continuations = null;
    }
  }
}

class Compendium {
  String? sId;
  String? compendiumId;
  String? title;
  String? contents;
  List<String>? websiteLinks;
  String? coverImage;
  List<String>? images;
  String? category;
  String? categoryId;
  String? subcategory;
  String? subcategoryId;
  int? numberOfQuestions;
  List<MCQs?>? mCQs;
  int? pinnedCount;
  RxBool? isPinned;
  String? continuedFrom;
  String? createdAt;
  String? createdBy;
  String? className;

  Compendium({
    this.sId,
    this.compendiumId,
    this.title,
    this.contents,
    this.websiteLinks,
    this.coverImage,
    this.images,
    this.category,
    this.categoryId,
    this.subcategory,
    this.subcategoryId,
    this.numberOfQuestions,
    this.mCQs,
    this.pinnedCount,
    this.isPinned,
    this.continuedFrom,
    this.createdAt,
  });

  Compendium.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    compendiumId = json['compendiumId'];
    title = json['title'];
    contents = json['contents'];
    // websiteLinks = json['websiteLinks'].cast<String>();
    coverImage = json['coverImage'];
    images = json['images'] != null ? List<String>.from(json['images']) : [];
    // category = json['category'];
    // subcategory = json['subcategory'];
    websiteLinks =
        json['websiteLinks'] != null
            ? List<String>.from(json['websiteLinks'])
            : [];
    // coverImage = json['coverImage'];
    // images = json['images'] != null ? List<String>.from(json['images']) : [];
    category = json['category'] != null ? json['category']['name'] : null;
    categoryId = json['category'] != null ? json['category']['_id'] : null;
    subcategory =
        json['subcategory'] != null ? json['subcategory']['name'] : null;
    subcategoryId =
        json['subcategory'] != null ? json['subcategory']['_id'] : null;
    numberOfQuestions = json['numberOfQuestions'];
    if (json['MCQs'] != null) {
      mCQs = <MCQs>[];
      json['MCQs'].forEach((v) {
        mCQs?.add(MCQs.fromJson(v));
      });
    }
    pinnedCount = json['pinnedCount'];
    if (json['continuedFrom'] != null) {
      if (json['continuedFrom'] is Map) {
        continuedFrom = json['continuedFrom']['_id']?.toString();
      } else {
        continuedFrom = json['continuedFrom']?.toString();
      }
    } else {
      continuedFrom = null;
    }
    createdAt = json['createdAt'];
    isPinned = RxBool(json['isPinned'] ?? false);
    createdBy =
        json['createdBy'] != null && json['createdBy']['name'] != null
            ? json['createdBy']['name']
            : null;
    className = json['className'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['compendiumId'] = compendiumId;
    data['title'] = title;
    data['contents'] = contents;
    data['websiteLinks'] = websiteLinks;
    data['coverImage'] = coverImage;
    data['images'] = images;
    data['category'] = category;
    data['subcategory'] = subcategory;
    data['numberOfQuestions'] = numberOfQuestions;
    data['pinnedCount'] = pinnedCount;
    data['continuedFrom'] = continuedFrom;
    data['createdAt'] = createdAt;
    return data;
  }
}

class ContinuedFrom {
  String? sId;
  String? compendiumId;
  String? title;
  String? contents;
  List<String>? websiteLinks;
  String? coverImage;
  List<String>? images;
  String? category;
  String? subcategory;
  int? numberOfQuestions;
  List<MCQs?>? mCQs;
  int? pinnedCount;
  String? createdAt;
  String? createdBy;
  String? className;

  ContinuedFrom({
    this.sId,
    this.compendiumId,
    this.title,
    this.contents,
    this.websiteLinks,
    this.coverImage,
    this.images,
    this.category,
    this.subcategory,
    this.numberOfQuestions,
    this.mCQs,
    this.pinnedCount,
    this.createdAt,
  });

  ContinuedFrom.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    compendiumId = json['compendiumId'];
    title = json['title'];
    contents = json['contents'];
    websiteLinks = json['websiteLinks'].cast<String>();
    coverImage = json['coverImage'];
    images = json['images'].cast<String>();
    category = json['category'];
    subcategory = json['subcategory'];
    numberOfQuestions = json['numberOfQuestions'];
    if (json['MCQs'] != null) {
      mCQs = <MCQs>[];
      json['MCQs'].forEach((v) {
        mCQs?.add(MCQs.fromJson(v));
      });
    }
    pinnedCount = json['pinnedCount'];
    createdAt = json['createdAt'];
    createdBy =
        json['createdBy'] != null && json['createdBy']['name'] != null
            ? json['createdBy']['name']
            : null;
    className = json['className'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['compendiumId'] = compendiumId;
    data['title'] = title;
    data['contents'] = contents;
    data['websiteLinks'] = websiteLinks;
    data['coverImage'] = coverImage;
    data['images'] = images;
    data['category'] = category;
    data['subcategory'] = subcategory;
    data['numberOfQuestions'] = numberOfQuestions;
    data['pinnedCount'] = pinnedCount;
    data['createdAt'] = createdAt;
    return data;
  }
}

class Continuations {
  String? sId;
  String? compendiumId;
  String? title;
  String? contents;
  List<String>? websiteLinks;
  String? coverImage;
  List<String>? images;
  String? category;
  String? subcategory;
  int? numberOfQuestions;
  List<MCQs?>? mCQs;
  int? pinnedCount;
  String? continuedFrom;
  String? createdAt;
  String? createdBy;
  String? className;

  Continuations({
    this.sId,
    this.compendiumId,
    this.title,
    this.contents,
    this.websiteLinks,
    this.coverImage,
    this.images,
    this.category,
    this.subcategory,
    this.numberOfQuestions,
    this.mCQs,
    this.pinnedCount,
    this.continuedFrom,
    this.createdAt,
  });

  Continuations.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    compendiumId = json['compendiumId'];
    title = json['title'];
    contents = json['contents'];
    websiteLinks = json['websiteLinks'].cast<String>();
    coverImage = json['coverImage'];
    images = json['images'].cast<String>();
    category = json['category'];
    subcategory = json['subcategory'];
    numberOfQuestions = json['numberOfQuestions'];
    if (json['MCQs'] != null) {
      mCQs = <MCQs>[];
      json['MCQs'].forEach((v) {
        mCQs?.add(MCQs.fromJson(v));
      });
    }
    pinnedCount = json['pinnedCount'];
    if (json['continuedFrom'] != null) {
      if (json['continuedFrom'] is Map) {
        continuedFrom = json['continuedFrom']['_id']?.toString();
      } else {
        continuedFrom = json['continuedFrom']?.toString();
      }
    } else {
      continuedFrom = null;
    }
    createdAt = json['createdAt'];
    createdBy =
        json['createdBy'] != null && json['createdBy']['name'] != null
            ? json['createdBy']['name']
            : null;
    className = json['className'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['compendiumId'] = compendiumId;
    data['title'] = title;
    data['contents'] = contents;
    data['websiteLinks'] = websiteLinks;
    data['coverImage'] = coverImage;
    data['images'] = images;
    data['category'] = category;
    data['subcategory'] = subcategory;
    data['numberOfQuestions'] = numberOfQuestions;
    data['pinnedCount'] = pinnedCount;
    data['continuedFrom'] = continuedFrom;
    data['createdAt'] = createdAt;
    return data;
  }
}
