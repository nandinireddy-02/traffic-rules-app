import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class UserService extends ChangeNotifier {
  User? _currentUser;
  SharedPreferences? _prefs;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadUser();
  }

  // Load user from local storage
  Future<void> _loadUser() async {
    final userJson = _prefs?.getString('current_user');
    if (userJson != null) {
      try {
        _currentUser = User.fromJson(json.decode(userJson));
        notifyListeners();
      } catch (e) {
        print('Error loading user: $e');
      }
    }
  }

  // Save user to local storage
  Future<void> _saveUser() async {
    if (_currentUser != null && _prefs != null) {
      await _prefs!.setString('current_user', json.encode(_currentUser!.toJson()));
    }
  }

  // Create a new user or login with grade
  Future<void> createOrLoginUser({
    required String name,
    required String email,
    required int grade,
  }) async {
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      grade: grade,
      lastActiveDate: DateTime.now(),
    );
    await _saveUser();
    notifyListeners();
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? email,
  }) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      name: name,
      email: email,
    );
    await _saveUser();
    notifyListeners();
  }

  // Update quiz completion stats
  Future<void> updateQuizStats({
    required int correctAnswers,
    required int totalQuestions,
    required String topic,
    required String quizId,
  }) async {
    if (_currentUser == null) return;

    // Update daily streak
    final today = DateTime.now();
    final lastActive = _currentUser!.lastActiveDate;
    int newStreak = _currentUser!.currentStreak;

    if (_isSameDay(today, lastActive)) {
      // Same day, keep current streak
    } else if (_isConsecutiveDay(today, lastActive)) {
      // Consecutive day, increment streak
      newStreak++;
    } else {
      // Streak broken, reset to 1
      newStreak = 1;
    }

    // Update topic progress
    final updatedTopicProgress = Map<String, int>.from(_currentUser!.topicProgress);
    updatedTopicProgress[topic] = (updatedTopicProgress[topic] ?? 0) + correctAnswers;

    // Update completed quizzes
    final updatedCompletedQuizzes = List<String>.from(_currentUser!.completedQuizzes);
    if (!updatedCompletedQuizzes.contains(quizId)) {
      updatedCompletedQuizzes.add(quizId);
    }

    _currentUser = _currentUser!.copyWith(
      totalQuizzesCompleted: _currentUser!.totalQuizzesCompleted + 1,
      totalCorrectAnswers: _currentUser!.totalCorrectAnswers + correctAnswers,
      totalQuestionsAnswered: _currentUser!.totalQuestionsAnswered + totalQuestions,
      currentStreak: newStreak,
      longestStreak: newStreak > _currentUser!.longestStreak ? newStreak : _currentUser!.longestStreak,
      topicProgress: updatedTopicProgress,
      completedQuizzes: updatedCompletedQuizzes,
      lastActiveDate: today,
      currentGrade: _calculateGrade(),
    );

    // Check for new achievements
    await _checkAndAwardBadges();
    await _saveUser();
    notifyListeners();
  }

  // Calculate current academic grade
  String _calculateGrade() {
    if (_currentUser == null) return 'Beginner';
    return _currentUser!.calculatedGrade;
  }

  // Check and award new badges/achievements
  Future<void> _checkAndAwardBadges() async {
    if (_currentUser == null) return;

    final currentBadges = List<String>.from(_currentUser!.achievedBadges);
    final newBadges = <String>[];

    // First Quiz Badge
    if (_currentUser!.totalQuizzesCompleted >= 1 && !currentBadges.contains('first_quiz')) {
      newBadges.add('first_quiz');
    }

    // Quiz Master Badge (10 quizzes)
    if (_currentUser!.totalQuizzesCompleted >= 10 && !currentBadges.contains('quiz_master')) {
      newBadges.add('quiz_master');
    }

    // Accuracy Expert Badge (90% overall accuracy)
    if (_currentUser!.overallAccuracy >= 90 && !currentBadges.contains('accuracy_expert')) {
      newBadges.add('accuracy_expert');
    }

    // Streak Scholar Badge (7 day streak)
    if (_currentUser!.currentStreak >= 7 && !currentBadges.contains('streak_scholar')) {
      newBadges.add('streak_scholar');
    }

    // Perfect Score Badge (100% on any quiz)
    // This would be awarded when processing quiz results

    // Topic Explorer Badge (completed all topics)
    if (_currentUser!.topicProgress.keys.length >= 10 && !currentBadges.contains('topic_explorer')) {
      newBadges.add('topic_explorer');
    }

    // Honor Student Badge (A grade)
    if (_currentUser!.calculatedGrade == 'A' || _currentUser!.calculatedGrade == 'A+' && 
        !currentBadges.contains('honor_student')) {
      newBadges.add('honor_student');
    }

    if (newBadges.isNotEmpty) {
      currentBadges.addAll(newBadges);
      _currentUser = _currentUser!.copyWith(achievedBadges: currentBadges);
    }
  }

  // Add exam history record
  Future<void> addExamHistory(ExamHistory exam) async {
    if (_currentUser == null) return;

    final updatedHistory = List<ExamHistory>.from(_currentUser!.examHistory);
    updatedHistory.add(exam);

    _currentUser = _currentUser!.copyWith(examHistory: updatedHistory);
    await _saveUser();
    notifyListeners();
  }

  // Get user progress for a specific topic
  int getTopicProgress(String topic) {
    return _currentUser?.topicProgress[topic] ?? 0;
  }

  // Get all available badges with descriptions
  Map<String, String> getAllBadges() {
    return {
      'first_quiz': 'Completed your first quiz',
      'quiz_master': 'Completed 10 quizzes',
      'accuracy_expert': 'Achieved 90% overall accuracy',
      'streak_scholar': 'Maintained a 7-day study streak',
      'perfect_score': 'Scored 100% on a quiz',
      'topic_explorer': 'Studied all traffic rule topics',
      'honor_student': 'Achieved A grade overall',
      'speed_demon': 'Completed a quiz in under 5 minutes',
      'persistent_learner': 'Completed 50 quizzes',
      'traffic_expert': 'Achieved 95% overall accuracy',
    };
  }

  // Check if user has a specific badge
  bool hasBadge(String badgeId) {
    return _currentUser?.achievedBadges.contains(badgeId) ?? false;
  }

  // Logout user
  Future<void> logout() async {
    _currentUser = null;
    await _prefs?.remove('current_user');
    notifyListeners();
  }

  // Helper methods for date calculations
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  bool _isConsecutiveDay(DateTime current, DateTime previous) {
    final difference = current.difference(previous).inDays;
    return difference == 1;
  }

  // Get study statistics
  Map<String, dynamic> getStudyStatistics() {
    if (_currentUser == null) {
      return {
        'totalQuizzes': 0,
        'accuracy': 0.0,
        'currentStreak': 0,
        'grade': 'N/A',
        'studyProgress': 0,
      };
    }

    return {
      'totalQuizzes': _currentUser!.totalQuizzesCompleted,
      'accuracy': _currentUser!.overallAccuracy,
      'currentStreak': _currentUser!.currentStreak,
      'grade': _currentUser!.calculatedGrade,
      'studyProgress': _currentUser!.studyProgressPercentage,
      'badges': _currentUser!.achievedBadges.length,
    };
  }

  // Create user method for compatibility with older screens
  Future<void> createUser(String name, String email, int grade) async {
    await createOrLoginUser(name: name, email: email, grade: grade);
  }
}