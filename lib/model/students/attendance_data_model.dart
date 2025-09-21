class AttendanceDataModel {
  final List<AttendanceRecord> attendance;
  final int presentCount;
  final int absentCount;
  final int holidayCount;

  AttendanceDataModel({
    required this.attendance,
    required this.presentCount,
    required this.absentCount,
    required this.holidayCount,
  });

  factory AttendanceDataModel.fromJson(Map<String, dynamic> json) {
    return AttendanceDataModel(
      attendance:
          (json['attendance'] as List?)
              ?.map((record) => AttendanceRecord.fromJson(record))
              .toList() ??
          [],
      presentCount: json['presentCount'] ?? 0,
      absentCount: json['absentCount'] ?? 0,
      holidayCount: json['holidayCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance': attendance.map((record) => record.toJson()).toList(),
      'presentCount': presentCount,
      'absentCount': absentCount,
      'holidayCount': holidayCount,
    };
  }

  // Helper method to get attendance percentage
  double get attendancePercentage {
    final int totalCountedDays = presentCount + absentCount;
    if (totalCountedDays == 0) return 0.0;
    return (presentCount / totalCountedDays) * 100;
  }
}

class AttendanceRecord {
  final String date;
  final AttendanceStatus status;

  AttendanceRecord({required this.date, required this.status});

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: json['date'] ?? '',
      status: _parseStatus(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'status': status.value};
  }

  static AttendanceStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'holiday':
        return AttendanceStatus.holiday;
      case 'no-record':
        return AttendanceStatus.noRecord;
      default:
        return AttendanceStatus.noRecord;
    }
  }
}

enum AttendanceStatus {
  present('present'),
  absent('absent'),
  holiday('holiday'),
  noRecord('no-record');

  final String value;
  const AttendanceStatus(this.value);
}
