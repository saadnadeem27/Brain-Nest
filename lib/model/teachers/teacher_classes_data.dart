class TeacherClassesData {
  final List<ClassWithSubjects> classesAndSubjects;

  TeacherClassesData({required this.classesAndSubjects});

  factory TeacherClassesData.fromJson(Map<String, dynamic> json) {
    return TeacherClassesData(
      classesAndSubjects:
          (json['classesAndSubjects'] as List?)
              ?.map((item) => ClassWithSubjects.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classesAndSubjects':
          classesAndSubjects.map((item) => item.toJson()).toList(),
    };
  }
}

class ClassWithSubjects {
  final String classId;
  final String className;
  final List<SectionWithSubjects> sections;

  ClassWithSubjects({
    required this.classId,
    required this.className,
    required this.sections,
  });

  factory ClassWithSubjects.fromJson(Map<String, dynamic> json) {
    return ClassWithSubjects(
      classId: json['classId'] ?? '',
      className: json['className'] ?? '',
      sections:
          (json['sections'] as List?)
              ?.map((item) => SectionWithSubjects.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'className': className,
      'sections': sections.map((item) => item.toJson()).toList(),
    };
  }
}

class SectionWithSubjects {
  final String sectionId;
  final String section;
  final List<Subject> subjects;

  SectionWithSubjects({
    required this.sectionId,
    required this.section,
    required this.subjects,
  });

  factory SectionWithSubjects.fromJson(Map<String, dynamic> json) {
    return SectionWithSubjects(
      sectionId: json['sectionId'] ?? '',
      section: json['section'] ?? '',
      subjects:
          (json['subjects'] as List?)
              ?.map((item) => Subject.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionId': sectionId,
      'section': section,
      'subjects': subjects.map((item) => item.toJson()).toList(),
    };
  }
}

class Subject {
  final String subjectId;
  final String subjectName;

  Subject({required this.subjectId, required this.subjectName});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['subjectId'] ?? '',
      subjectName: json['subjectName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'subjectId': subjectId, 'subjectName': subjectName};
  }
}
