import 'package:flutter/material.dart';

/// Static data service for Brain Nest app
/// Provides mock data for all screens without API dependencies
class StaticDataService {
  // User Profile Data
  static Map<String, dynamic> currentUser = {
    'id': 'user_001',
    'name': 'Alex Johnson',
    'email': 'alex.johnson@example.com',
    'avatar': null, // Using Material Icons instead
    'role': 'Premium Student',
    'school': 'Brain Nest Academy',
    'grade': '10th Grade',
    'section': 'A',
    'subjects': ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'English'],
    'joinDate': '2024-01-15',
    'isPremium': true,
  };

  // Dashboard Stats
  static Map<String, dynamic> dashboardStats = {
    'totalCourses': 12,
    'completedCourses': 8,
    'totalQuizzes': 45,
    'completedQuizzes': 32,
    'totalPoints': 2450,
    'currentStreak': 15,
    'weeklyGoal': 7,
    'weeklyProgress': 5,
  };

  // Course/Subject Data
  static List<Map<String, dynamic>> courses = [
    {
      'id': 'course_001',
      'title': 'Advanced Mathematics',
      'description': 'Master complex mathematical concepts',
      'icon': Icons.calculate,
      'color': Color(0xFF6C5CE7),
      'progress': 0.75,
      'totalLessons': 24,
      'completedLessons': 18,
      'difficulty': 'Advanced',
      'duration': '8 weeks',
      'instructor': 'Dr. Sarah Wilson',
    },
    {
      'id': 'course_002', 
      'title': 'Physics Fundamentals',
      'description': 'Explore the laws of physics',
      'icon': Icons.science,
      'color': Color(0xFF3742FA),
      'progress': 0.60,
      'totalLessons': 20,
      'completedLessons': 12,
      'difficulty': 'Intermediate',
      'duration': '6 weeks',
      'instructor': 'Prof. Michael Chen',
    },
    {
      'id': 'course_003',
      'title': 'Chemistry Essentials', 
      'description': 'Chemical reactions and properties',
      'icon': Icons.biotech,
      'color': Color(0xFF00D2D3),
      'progress': 0.45,
      'totalLessons': 18,
      'completedLessons': 8,
      'difficulty': 'Beginner',
      'duration': '5 weeks',
      'instructor': 'Dr. Emma Davis',
    },
    {
      'id': 'course_004',
      'title': 'Biology Deep Dive',
      'description': 'Life sciences and ecosystems',
      'icon': Icons.local_florist,
      'color': Color(0xFF00E676),
      'progress': 0.80,
      'totalLessons': 22,
      'completedLessons': 17,
      'difficulty': 'Intermediate',
      'duration': '7 weeks',
      'instructor': 'Dr. Robert Brown',
    },
    {
      'id': 'course_005',
      'title': 'English Literature',
      'description': 'Classic and modern literature analysis',
      'icon': Icons.menu_book,
      'color': Color(0xFFFF9F43),
      'progress': 0.90,
      'totalLessons': 16,
      'completedLessons': 14,
      'difficulty': 'Advanced',
      'duration': '4 weeks',
      'instructor': 'Ms. Jennifer Lee',
    },
    {
      'id': 'course_006',
      'title': 'Computer Science',
      'description': 'Programming and algorithms',
      'icon': Icons.computer,
      'color': Color(0xFFFC427B),
      'progress': 0.35,
      'totalLessons': 30,
      'completedLessons': 10,
      'difficulty': 'Advanced',
      'duration': '12 weeks',
      'instructor': 'Dr. Kevin Park',
    },
  ];

  // Quiz/Test Data
  static List<Map<String, dynamic>> quizzes = [
    {
      'id': 'quiz_001',
      'title': 'Calculus Practice Test',
      'subject': 'Mathematics',
      'questionCount': 25,
      'duration': 45,
      'difficulty': 'Hard',
      'score': 88,
      'maxScore': 100,
      'completed': true,
      'icon': Icons.quiz,
      'color': Color(0xFF6C5CE7),
    },
    {
      'id': 'quiz_002',
      'title': 'Physics Motion Laws',
      'subject': 'Physics',
      'questionCount': 20,
      'duration': 30,
      'difficulty': 'Medium',
      'score': 92,
      'maxScore': 100,
      'completed': true,
      'icon': Icons.science,
      'color': Color(0xFF3742FA),
    },
    {
      'id': 'quiz_003',
      'title': 'Organic Chemistry Basics',
      'subject': 'Chemistry',
      'questionCount': 15,
      'duration': 25,
      'difficulty': 'Easy',
      'score': null,
      'maxScore': 100,
      'completed': false,
      'icon': Icons.biotech,
      'color': Color(0xFF00D2D3),
    },
  ];

  // Notifications
  static List<Map<String, dynamic>> notifications = [
    {
      'id': 'notif_001',
      'title': 'New Assignment Available',
      'message': 'Calculus Assignment #3 has been posted',
      'type': 'assignment',
      'timestamp': DateTime.now().subtract(Duration(hours: 2)),
      'icon': Icons.assignment,
      'color': Color(0xFF6C5CE7),
      'isRead': false,
    },
    {
      'id': 'notif_002',
      'title': 'Quiz Reminder',
      'message': 'Physics quiz deadline in 2 days',
      'type': 'reminder',
      'timestamp': DateTime.now().subtract(Duration(hours: 6)),
      'icon': Icons.alarm,
      'color': Color(0xFFFF9F43),
      'isRead': false,
    },
    {
      'id': 'notif_003',
      'title': 'Achievement Unlocked!',
      'message': 'You\'ve completed 5 courses this month',
      'type': 'achievement',
      'timestamp': DateTime.now().subtract(Duration(days: 1)),
      'icon': Icons.emoji_events,
      'color': Color(0xFF00E676),
      'isRead': true,
    },
  ];

  // Study Materials/Resources
  static List<Map<String, dynamic>> studyMaterials = [
    {
      'id': 'material_001',
      'title': 'Calculus Formulas Cheat Sheet',
      'type': 'PDF',
      'subject': 'Mathematics',
      'size': '2.4 MB',
      'downloadCount': 1250,
      'icon': Icons.picture_as_pdf,
      'color': Colors.red,
    },
    {
      'id': 'material_002',
      'title': 'Physics Lab Manual',
      'type': 'Document',
      'subject': 'Physics',
      'size': '5.1 MB',
      'downloadCount': 890,
      'icon': Icons.description,
      'color': Colors.blue,
    },
    {
      'id': 'material_003',
      'title': 'Chemistry Periodic Table',
      'type': 'Image',
      'subject': 'Chemistry',
      'size': '800 KB',
      'downloadCount': 2100,
      'icon': Icons.image,
      'color': Colors.green,
    },
  ];

  // Announcements
  static List<Map<String, dynamic>> announcements = [
    {
      'id': 'announcement_001',
      'title': 'Mid-term Exam Schedule Released',
      'content': 'The mid-term examination schedule for all subjects has been released. Please check your individual timetables.',
      'author': 'Academic Office',
      'timestamp': DateTime.now().subtract(Duration(days: 2)),
      'priority': 'high',
      'icon': Icons.campaign,
    },
    {
      'id': 'announcement_002',
      'title': 'New Learning Resources Available',
      'content': 'We\'ve added new interactive learning modules for Physics and Chemistry. Access them from your dashboard.',
      'author': 'Learning Team',
      'timestamp': DateTime.now().subtract(Duration(days: 5)),
      'priority': 'medium',
      'icon': Icons.library_books,
    },
  ];

  // Performance Analytics
  static Map<String, dynamic> performanceData = {
    'weeklyProgress': [
      {'day': 'Mon', 'hours': 3.5, 'completed': 4},
      {'day': 'Tue', 'hours': 2.8, 'completed': 3},
      {'day': 'Wed', 'hours': 4.2, 'completed': 5},
      {'day': 'Thu', 'hours': 3.1, 'completed': 3},
      {'day': 'Fri', 'hours': 2.5, 'completed': 2},
      {'day': 'Sat', 'hours': 5.0, 'completed': 6},
      {'day': 'Sun', 'hours': 3.8, 'completed': 4},
    ],
    'subjectScores': [
      {'subject': 'Math', 'score': 88, 'maxScore': 100},
      {'subject': 'Physics', 'score': 92, 'maxScore': 100},
      {'subject': 'Chemistry', 'score': 85, 'maxScore': 100},
      {'subject': 'Biology', 'score': 94, 'maxScore': 100},
      {'subject': 'English', 'score': 87, 'maxScore': 100},
    ],
    'monthlyGoals': {
      'target': 50,
      'completed': 38,
      'percentage': 76,
    },
  };

  // Community/Social Features
  static List<Map<String, dynamic>> studyGroups = [
    {
      'id': 'group_001',
      'name': 'Advanced Math Study Group',
      'memberCount': 24,
      'subject': 'Mathematics',
      'description': 'Collaborative learning for calculus and beyond',
      'icon': Icons.group,
      'color': Color(0xFF6C5CE7),
      'isJoined': true,
    },
    {
      'id': 'group_002',
      'name': 'Physics Problem Solvers',
      'memberCount': 18,
      'subject': 'Physics',
      'description': 'Tackle challenging physics problems together',
      'icon': Icons.group,
      'color': Color(0xFF3742FA),
      'isJoined': false,
    },
  ];

  // Calendar/Schedule Data
  static List<Map<String, dynamic>> scheduleEvents = [
    {
      'id': 'event_001',
      'title': 'Mathematics Class',
      'subject': 'Mathematics',
      'startTime': DateTime.now().add(Duration(hours: 2)),
      'endTime': DateTime.now().add(Duration(hours: 3)),
      'type': 'class',
      'location': 'Room 101',
      'icon': Icons.calculate,
      'color': Color(0xFF6C5CE7),
    },
    {
      'id': 'event_002',
      'title': 'Physics Lab',
      'subject': 'Physics',
      'startTime': DateTime.now().add(Duration(days: 1, hours: 1)),
      'endTime': DateTime.now().add(Duration(days: 1, hours: 3)),
      'type': 'lab',
      'location': 'Physics Lab A',
      'icon': Icons.science,
      'color': Color(0xFF3742FA),
    },
  ];

  // Premium Features
  static Map<String, dynamic> premiumFeatures = {
    'isSubscribed': true,
    'planName': 'Premium Pro',
    'expiryDate': DateTime.now().add(Duration(days: 90)),
    'features': [
      'Unlimited course access',
      'AI-powered study assistant',
      'Advanced analytics',
      'Priority support',
      'Offline downloads',
      'Custom study plans',
    ],
  };

  // Methods to simulate API calls
  static Future<List<Map<String, dynamic>>> getCourses() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    return courses;
  }

  static Future<List<Map<String, dynamic>>> getQuizzes() async {
    await Future.delayed(Duration(milliseconds: 300));
    return quizzes;
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    await Future.delayed(Duration(milliseconds: 200));
    return notifications;
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    await Future.delayed(Duration(milliseconds: 400));
    return currentUser;
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    await Future.delayed(Duration(milliseconds: 350));
    return dashboardStats;
  }

  // New methods for Learner Dashboard
  Map<String, dynamic> getLearnerProfile() {
    return {
      'id': 'learner_001',
      'name': 'Alex Johnson',
      'email': 'alex.johnson@brainnest.com',
      'grade': 'Grade 10',
      'avatar': null,
      'joinedDate': '2024-09-01',
      'totalCourses': 8,
      'completedCourses': 3,
      'currentStreak': 12,
    };
  }

  List<Map<String, dynamic>> getActiveCourses() {
    return courses.where((course) => course['progress'] > 0 && course['progress'] < 1).toList();
  }

  List<Map<String, dynamic>> getRecentLearningActivities() {
    return [
      {
        'id': 'activity_001',
        'type': 'lesson_completed',
        'title': 'Completed "Derivative Applications" lesson',
        'course': 'Advanced Mathematics',
        'time': '2 hours ago',
        'icon': 'check_circle',
      },
      {
        'id': 'activity_002',
        'type': 'quiz_completed',
        'title': 'Scored 95% on Physics Quiz #3',
        'course': 'Physics Fundamentals',
        'time': '5 hours ago',
        'icon': 'quiz',
      },
      {
        'id': 'activity_003',
        'type': 'assignment_submitted',
        'title': 'Submitted Creative Writing Assignment',
        'course': 'English Literature',
        'time': '1 day ago',
        'icon': 'assignment_turned_in',
      },
    ];
  }

  Map<String, dynamic> getLearningStatistics() {
    return {
      'coursesCompleted': 3,
      'totalHours': 142,
      'achievements': 8,
      'streakDays': 12,
      'averageGrade': 87,
      'weeklyGoal': 15,
      'weeklyProgress': 12,
    };
  }

  List<Map<String, dynamic>> getUpcomingEvents() {
    return [
      {
        'id': 'event_001',
        'title': 'Mathematics Study Group',
        'description': 'Weekly study session for advanced topics',
        'date': 'Tomorrow',
        'time': '3:00 PM',
        'location': 'Virtual Room A',
        'type': 'study_group',
      },
      {
        'id': 'event_002',
        'title': 'Physics Lab Session',
        'description': 'Hands-on experiments in optics',
        'date': 'Oct 25',
        'time': '10:00 AM',
        'location': 'Lab 204',
        'type': 'lab',
      },
    ];
  }

  // New methods for Educator Dashboard
  Map<String, dynamic> getEducatorProfile() {
    return {
      'id': 'educator_001',
      'name': 'Dr. Patricia Williams',
      'email': 'patricia.williams@brainnest.com',
      'department': 'Mathematics Department',
      'title': 'Professor',
      'experience': '15 years',
      'avatar': null,
      'specialization': 'Advanced Mathematics & Statistics',
      'officeHours': 'Mon-Wed-Fri 2:00-4:00 PM',
    };
  }

  List<Map<String, dynamic>> getEducatorCourses() {
    return [
      {
        'id': 'course_001',
        'title': 'Advanced Calculus',
        'description': 'Graduate level calculus for engineering students',
        'students': 24,
        'semester': 'Fall 2024',
        'schedule': 'MWF 10:00-11:00 AM',
        'room': 'Math 205',
        'nextClass': 'Tomorrow 10:00 AM',
        'assignments': 3,
        'pendingGrades': 8,
      },
      {
        'id': 'course_002',
        'title': 'Statistics & Probability',
        'description': 'Introduction to statistical analysis and probability theory',
        'students': 32,
        'semester': 'Fall 2024',
        'schedule': 'TTh 2:00-3:30 PM',
        'room': 'Math 101',
        'nextClass': 'Oct 24 2:00 PM',
        'assignments': 2,
        'pendingGrades': 12,
      },
    ];
  }

  Map<String, dynamic> getStudentMetrics() {
    return {
      'totalStudents': 74,
      'activeStudents': 68,
      'averageGrade': 83,
      'pendingAssignments': 23,
      'gradeDistribution': {
        'A': 18,
        'B': 32,
        'C': 15,
        'D': 3,
        'F': 0,
      },
      'attendanceRate': 92,
      'submissionRate': 88,
    };
  }

  List<Map<String, dynamic>> getRecentSubmissions() {
    return [
      {
        'id': 'submission_001',
        'studentName': 'Emma Thompson',
        'studentId': 'student_024',
        'assignmentTitle': 'Calculus Problem Set #5',
        'course': 'Advanced Calculus',
        'submittedAt': '2 hours ago',
        'status': 'pending',
        'type': 'assignment',
      },
      {
        'id': 'submission_002',
        'studentName': 'James Wilson',
        'studentId': 'student_031',
        'assignmentTitle': 'Statistical Analysis Project',
        'course': 'Statistics & Probability',
        'submittedAt': '4 hours ago',
        'status': 'graded',
        'grade': 92,
        'type': 'project',
      },
    ];
  }

  List<Map<String, dynamic>> getUpcomingClasses() {
    return [
      {
        'id': 'class_001',
        'title': 'Advanced Calculus - Integration Techniques',
        'course': 'Advanced Calculus',
        'date': 'Tomorrow',
        'time': '10:00 AM',
        'duration': '60 minutes',
        'room': 'Math 205',
        'students': 24,
        'topic': 'Integration by Parts',
        'materials': ['Textbook Ch. 8', 'Practice Problems'],
      },
      {
        'id': 'class_002',
        'title': 'Statistics - Hypothesis Testing',
        'course': 'Statistics & Probability',
        'date': 'Oct 24',
        'time': '2:00 PM',
        'duration': '90 minutes',
        'room': 'Math 101',
        'students': 32,
        'topic': 'T-tests and Chi-square',
        'materials': ['Lab Manual', 'Dataset Files'],
      },
    ];
  }

  Map<String, dynamic> getClassPerformanceData() {
    return {
      'weeklyPerformance': [
        {'week': 'Week 1', 'average': 78},
        {'week': 'Week 2', 'average': 82},
        {'week': 'Week 3', 'average': 85},
        {'week': 'Week 4', 'average': 83},
        {'week': 'Week 5', 'average': 87},
      ],
      'courseComparison': [
        {'course': 'Advanced Calculus', 'average': 85},
        {'course': 'Statistics', 'average': 83},
        {'course': 'Linear Algebra', 'average': 88},
      ],
      'studentEngagement': {
        'highlyEngaged': 45,
        'moderatelyEngaged': 25,
        'needsAttention': 4,
      },
    };
  }
}