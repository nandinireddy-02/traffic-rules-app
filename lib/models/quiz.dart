class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String topic;
  final String difficulty; // 'easy', 'medium', 'hard'
  final String? imageUrl;
  final List<int> gradeLevel; // Which grades this question is appropriate for

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.topic,
    this.difficulty = 'medium',
    this.imageUrl,
    this.gradeLevel = const [2, 3, 4, 5, 6, 7, 8, 9, 10], // Default: all grades
  });

  String get correctAnswer => options[correctAnswerIndex];

  bool isCorrectAnswer(int selectedIndex) {
    return selectedIndex == correctAnswerIndex;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'topic': topic,
      'difficulty': difficulty,
      'imageUrl': imageUrl,
      'gradeLevel': gradeLevel,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
      explanation: json['explanation'],
      topic: json['topic'],
      difficulty: json['difficulty'] ?? 'medium',
      imageUrl: json['imageUrl'],
      gradeLevel: List<int>.from(json['gradeLevel'] ?? [2, 3, 4, 5, 6, 7, 8, 9, 10]),
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final String description;
  final String topic;
  final String difficulty;
  final List<Question> questions;
  final int timeLimit; // in minutes
  final bool isExamMode;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.topic,
    required this.difficulty,
    required this.questions,
    this.timeLimit = 30,
    this.isExamMode = false,
  });

  int get totalQuestions => questions.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'topic': topic,
      'difficulty': difficulty,
      'questions': questions.map((q) => q.toJson()).toList(),
      'timeLimit': timeLimit,
      'isExamMode': isExamMode,
    };
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      topic: json['topic'],
      difficulty: json['difficulty'],
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
      timeLimit: json['timeLimit'] ?? 30,
      isExamMode: json['isExamMode'] ?? false,
    );
  }
}

class QuizResult {
  final String id;
  final String userId;
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final int timeSpentSeconds;
  final DateTime completedAt;
  final Map<String, int> userAnswers; // questionId -> selectedAnswerIndex
  final Map<String, bool> correctAnswers; // questionId -> isCorrect
  final String topic;
  final String difficulty;

  QuizResult({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.timeSpentSeconds,
    required this.completedAt,
    required this.userAnswers,
    required this.correctAnswers,
    required this.topic,
    required this.difficulty,
  });

  double get accuracy => (score / totalQuestions) * 100;

  String get grade {
    final percentage = accuracy;
    if (percentage >= 95) return 'A+';
    if (percentage >= 90) return 'A';
    if (percentage >= 85) return 'B+';
    if (percentage >= 80) return 'B';
    if (percentage >= 75) return 'C+';
    if (percentage >= 70) return 'C';
    if (percentage >= 65) return 'D+';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  bool get isPassing => accuracy >= 70; // 70% passing grade

  String get timeSpentFormatted {
    final minutes = timeSpentSeconds ~/ 60;
    final seconds = timeSpentSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'timeSpentSeconds': timeSpentSeconds,
      'completedAt': completedAt.toIso8601String(),
      'userAnswers': userAnswers,
      'correctAnswers': correctAnswers,
      'topic': topic,
      'difficulty': difficulty,
    };
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'],
      userId: json['userId'],
      quizId: json['quizId'],
      quizTitle: json['quizTitle'],
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      timeSpentSeconds: json['timeSpentSeconds'],
      completedAt: DateTime.parse(json['completedAt']),
      userAnswers: Map<String, int>.from(json['userAnswers']),
      correctAnswers: Map<String, bool>.from(json['correctAnswers']),
      topic: json['topic'],
      difficulty: json['difficulty'],
    );
  }
}