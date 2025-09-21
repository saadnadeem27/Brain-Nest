class ExamScoreReportResponse {
  String? studentName;
  String? className;
  String? section;
  String? year;
  List<SchoolAllExamsReports>? reports;

  ExamScoreReportResponse({
    this.studentName,
    this.className,
    this.section,
    this.year,
    this.reports,
  });

  ExamScoreReportResponse.fromJson(Map<String, dynamic> json) {
    studentName = json['studentName'];
    className = json['class'];
    section = json['section'];
    year = json['year'];

    if (json['report'] != null) {
      reports = <SchoolAllExamsReports>[];
      json['report'].forEach((v) {
        reports!.add(SchoolAllExamsReports.fromJson(v));
      });
    }
  }
}

class SchoolAllExamsReports {
  String? title;
  List<Scores>? scores;
  int? total;
  String? percentage;
  int? rank;

  SchoolAllExamsReports({
    this.title,
    this.scores,
    this.total,
    this.percentage,
    this.rank,
  });

  SchoolAllExamsReports.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    if (json['scores'] != null) {
      scores = <Scores>[];
      json['scores'].forEach((v) {
        scores!.add(Scores.fromJson(v));
      });
    }
    total = json['total'];
    percentage = json['percentage'];
    rank = json['rank'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = title;
    if (scores != null) {
      data['scores'] = scores!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    data['percentage'] = percentage;
    data['rank'] = rank;
    return data;
  }
}

class Scores {
  String? subjectId;
  String? subjectName;
  int? score;

  Scores({this.subjectId, this.subjectName, this.score});

  Scores.fromJson(Map<String, dynamic> json) {
    subjectId = json['subjectId'];
    subjectName = json['subjectName'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['score'] = score;
    return data;
  }
}
