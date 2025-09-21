import 'package:flutter/material.dart';

class WebinarsModel {
  String? sId;
  String? webinarId;
  String? title;
  String? industry;
  String? hostName;
  String? dateAndTime;
  int? durationInMinutes;
  double? amount;
  String? description;
  String? coverImage;
  String? webinarLink;
  int? registeredCount;
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? documentStatus;

  WebinarsModel({
    this.sId,
    this.webinarId,
    this.title,
    this.industry,
    this.hostName,
    this.dateAndTime,
    this.durationInMinutes,
    this.amount,
    this.description,
    this.coverImage,
    this.webinarLink,
    this.registeredCount,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.documentStatus,
  });

  WebinarsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    webinarId = json['webinarId'];
    title = json['title'];
    industry = json['industry'];
    hostName = json['hostName'];
    dateAndTime = json['dateAndTime'];
    durationInMinutes = int.tryParse(json['durationInMinutes'].toString());
    amount = double.tryParse(json['amount'].toString());
    description = json['description'];
    coverImage = json['coverImage'];
    webinarLink = json['webinarLink'];
    registeredCount = int.tryParse(json['registeredCount'].toString());
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    documentStatus = json['documentStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['webinarId'] = webinarId;
    data['title'] = title;
    data['industry'] = industry;
    data['hostName'] = hostName;
    data['dateAndTime'] = dateAndTime;
    data['durationInMinutes'] = durationInMinutes;
    data['amount'] = amount;
    data['description'] = description;
    data['coverImage'] = coverImage;
    data['webinarLink'] = webinarLink;
    data['registeredCount'] = registeredCount;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['documentStatus'] = documentStatus;
    return data;
  }
}
