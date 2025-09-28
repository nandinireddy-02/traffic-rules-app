class User {
  final String id;
  final String name;
  final String email;
  final int grade; // Student's actual grade (2-10)
  final int totalQuizzesCompleted;
  final int totalCorrectAnswers;
  final int totalQuestionsAnswered;
  final int currentStreak;
  final int longestStreak;
  final List<String> achievedBadges;
  final Map<String, int> topicProgress; // topic -> correct answers count
  final List<String> completedQuizzes;
  final DateTime lastActiveDate;
  final int studyHours;
  final String currentGrade;
  final List<ExamHistory> examHistory;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.grade,
    this.totalQuizzesCompleted = 0,
    this.totalCorrectAnswers = 0,
    this.totalQuestionsAnswered = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.achievedBadges = const [],
    this.topicProgress = const {},
    this.completedQuizzes = const [],
    DateTime? lastActiveDate,
    this.studyHours = 0,
    this.currentGrade = 'Beginner',
    this.examHistory = const [],
  }) : lastActiveDate = lastActiveDate ?? DateTime.now();

  // Academic performance calculation
  double get overallAccuracy {
    if (totalQuestionsAnswered == 0) return 0.0;
    return (totalCorrectAnswers / totalQuestionsAnswered) * 100;
  }

  // Student grade calculation based on performance
  String get calculatedGrade {
    final accuracy = overallAccuracy;
    if (accuracy >= 95) return 'A+';
    if (accuracy >= 90) return 'A';
    if (accuracy >= 85) return 'B+';
    if (accuracy >= 80) return 'B';
    if (accuracy >= 75) return 'C+';
    if (accuracy >= 70) return 'C';
    if (accuracy >= 65) return 'D+';
    if (accuracy >= 60) return 'D';
    return 'F';
  }

  // Study progress indicator
  int get studyProgressPercentage {
    const totalTopics = 12; // Total traffic rule topics
    final completedTopics = topicProgress.keys.where((topic) => 
      topicProgress[topic]! >= 5 // Minimum 5 correct answers per topic
    ).length;
    return ((completedTopics / totalTopics) * 100).round();
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? grade,
    int? totalQuizzesCompleted,
    int? totalCorrectAnswers,
    int? totalQuestionsAnswered,
    int? currentStreak,
    int? longestStreak,
    List<String>? achievedBadges,
    Map<String, int>? topicProgress,
    List<String>? completedQuizzes,
    DateTime? lastActiveDate,
    int? studyHours,
    String? currentGrade,
    List<ExamHistory>? examHistory,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      grade: grade ?? this.grade,
      totalQuizzesCompleted: totalQuizzesCompleted ?? this.totalQuizzesCompleted,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalQuestionsAnswered: totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      achievedBadges: achievedBadges ?? this.achievedBadges,
      topicProgress: topicProgress ?? this.topicProgress,
      completedQuizzes: completedQuizzes ?? this.completedQuizzes,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      studyHours: studyHours ?? this.studyHours,
      currentGrade: currentGrade ?? this.currentGrade,
      examHistory: examHistory ?? this.examHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'grade': grade,
      'totalQuizzesCompleted': totalQuizzesCompleted,
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'achievedBadges': achievedBadges,
      'topicProgress': topicProgress,
      'completedQuizzes': completedQuizzes,
      'lastActiveDate': lastActiveDate.toIso8601String(),
      'studyHours': studyHours,
      'currentGrade': currentGrade,
      'examHistory': examHistory.map((e) => e.toJson()).toList(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      grade: json['grade'] ?? 2,
      totalQuizzesCompleted: json['totalQuizzesCompleted'] ?? 0,
      totalCorrectAnswers: json['totalCorrectAnswers'] ?? 0,
      totalQuestionsAnswered: json['totalQuestionsAnswered'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      achievedBadges: List<String>.from(json['achievedBadges'] ?? []),
      topicProgress: Map<String, int>.from(json['topicProgress'] ?? {}),
      completedQuizzes: List<String>.from(json['completedQuizzes'] ?? []),
      lastActiveDate: DateTime.parse(json['lastActiveDate']),
      studyHours: json['studyHours'] ?? 0,
      currentGrade: json['currentGrade'] ?? 'Beginner',
      examHistory: (json['examHistory'] as List<dynamic>?)
          ?.map((e) => ExamHistory.fromJson(e))
          .toList() ?? [],
    );
  }
}

class ExamHistory {
  final String examId;
  final String examName;
  final DateTime date;
  final int score;
  final int totalQuestions;
  final int timeSpentMinutes;
  final String topic;

  ExamHistory({
    required this.examId,
    required this.examName,
    required this.date,
    required this.score,
    required this.totalQuestions,
    required this.timeSpentMinutes,
    required this.topic,
  });

  double get accuracy => (score / totalQuestions) * 100;

  Map<String, dynamic> toJson() {
    return {
      'examId': examId,
      'examName': examName,
      'date': date.toIso8601String(),
      'score': score,
      'totalQuestions': totalQuestions,
      'timeSpentMinutes': timeSpentMinutes,
      'topic': topic,
    };
  }

  factory ExamHistory.fromJson(Map<String, dynamic> json) {
    return ExamHistory(
      examId: json['examId'],
      examName: json['examName'],
      date: DateTime.parse(json['date']),
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      timeSpentMinutes: json['timeSpentMinutes'],
      topic: json['topic'],
    );
  }
}