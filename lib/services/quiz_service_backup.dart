import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import '../models/quiz.dart';

class QuizService extends ChangeNotifier {
  List<Quiz> _quizzes = [];
  List<Question> _allQuestions = [];
  Quiz? _currentQuiz;
  QuizResult? _lastResult;
  
  List<Quiz> get quizzes => _quizzes;
  Quiz? get currentQuiz => _currentQuiz;
  QuizResult? get lastResult => _lastResult;

  // Initialize with sample data
  Future<void> initialize() async {
    await _loadSampleQuestions();
    await _generateQuizzes();
    notifyListeners();
  }

  // Load sample traffic rules questions
  Future<void> _loadSampleQuestions() async {
    _allQuestions = [
      // Traffic Signs Questions
      Question(
        id: 'ts001',
        text: 'What does a red octagonal sign typically mean?',
        options: ['Yield', 'Stop', 'Speed Limit', 'No Entry'],
        correctAnswerIndex: 1,
        explanation: 'A red octagonal sign universally means STOP. Drivers must come to a complete halt.',
        topic: 'Traffic Signs',
        difficulty: 'easy',
      ),
      Question(
        id: 'ts002',
        text: 'What should you do when you see a yellow triangle sign with an exclamation mark?',
        options: ['Stop immediately', 'Proceed with caution', 'Speed up', 'Turn around'],
        correctAnswerIndex: 1,
        explanation: 'Yellow triangle signs with exclamation marks indicate general warnings, requiring caution.',
        topic: 'Traffic Signs',
        difficulty: 'medium',
      ),
      Question(
        id: 'ts003',
        text: 'A blue circular sign with a white arrow pointing left means:',
        options: ['No left turn', 'Left turn only', 'Left turn recommended', 'Caution: left curve'],
        correctAnswerIndex: 1,
        explanation: 'Blue circular signs give mandatory instructions. A left arrow means you must turn left.',
        topic: 'Traffic Signs',
        difficulty: 'medium',
      ),

      // Right of Way Questions
      Question(
        id: 'row001',
        text: 'At a four-way intersection with stop signs, who has the right of way?',
        options: ['The largest vehicle', 'The vehicle that arrived first', 'Vehicles going straight', 'Emergency vehicles only'],
        correctAnswerIndex: 1,
        explanation: 'At a four-way stop, the vehicle that arrives first has the right of way. If arriving simultaneously, yield to the right.',
        topic: 'Right of Way',
        difficulty: 'medium',
      ),
      Question(
        id: 'row002',
        text: 'When making a left turn, you should yield to:',
        options: ['No one', 'Oncoming traffic', 'Traffic behind you', 'Parked cars'],
        correctAnswerIndex: 1,
        explanation: 'When making a left turn, you must yield to oncoming traffic and pedestrians.',
        topic: 'Right of Way',
        difficulty: 'easy',
      ),
      Question(
        id: 'row003',
        text: 'At a roundabout, you should yield to:',
        options: ['Traffic entering the roundabout', 'Traffic already in the roundabout', 'Traffic exiting the roundabout', 'All traffic equally'],
        correctAnswerIndex: 1,
        explanation: 'When entering a roundabout, yield to traffic already circulating in the roundabout.',
        topic: 'Right of Way',
        difficulty: 'medium',
      ),

      // Speed Limits Questions
      Question(
        id: 'sl001',
        text: 'What is the typical speed limit in a school zone during school hours?',
        options: ['15-25 mph', '25-35 mph', '35-45 mph', '45-55 mph'],
        correctAnswerIndex: 0,
        explanation: 'School zones typically have reduced speed limits of 15-25 mph during school hours for student safety.',
        topic: 'Speed Limits',
        difficulty: 'easy',
      ),
      Question(
        id: 'sl002',
        text: 'When driving in adverse weather conditions, you should:',
        options: ['Maintain normal speed', 'Increase speed to get through quickly', 'Reduce speed appropriately', 'Stop immediately'],
        correctAnswerIndex: 2,
        explanation: 'In adverse weather, reduce speed to maintain control and increase stopping distance.',
        topic: 'Speed Limits',
        difficulty: 'medium',
      ),

      // Parking Rules Questions
      Question(
        id: 'pr001',
        text: 'How far from a fire hydrant must you park?',
        options: ['5 feet', '10 feet', '15 feet', '20 feet'],
        correctAnswerIndex: 2,
        explanation: 'You must park at least 15 feet away from a fire hydrant to allow emergency access.',
        topic: 'Parking Rules',
        difficulty: 'medium',
      ),
      Question(
        id: 'pr002',
        text: 'Parking is typically prohibited:',
        options: ['On weekends', 'Within 30 feet of a stop sign', 'After 6 PM', 'On odd-numbered days'],
        correctAnswerIndex: 1,
        explanation: 'Parking within 30 feet of a stop sign obstructs visibility and is typically prohibited.',
        topic: 'Parking Rules',
        difficulty: 'medium',
      ),

      // Seat Belt and Safety Questions
      Question(
        id: 'sb001',
        text: 'At what age can a child typically ride in the front seat?',
        options: ['8 years old', '10 years old', '12 years old', '16 years old'],
        correctAnswerIndex: 2,
        explanation: 'Children should typically be 12 years old before riding in the front seat, though laws vary by state.',
        topic: 'Safety Rules',
        difficulty: 'medium',
      ),
      Question(
        id: 'sb002',
        text: 'Seat belts should be worn:',
        options: ['Only on highways', 'Only by drivers', 'By all occupants', 'Only during long trips'],
        correctAnswerIndex: 2,
        explanation: 'All vehicle occupants should wear seat belts for maximum safety protection.',
        topic: 'Safety Rules',
        difficulty: 'easy',
      ),

      // Emergency Procedures Questions
      Question(
        id: 'ep001',
        text: 'If your brakes fail while driving, you should:',
        options: ['Pump the brake pedal', 'Turn off the engine', 'Pull the steering wheel', 'Honk the horn'],
        correctAnswerIndex: 0,
        explanation: 'If brakes fail, pump the brake pedal to try to build pressure, then use emergency brake gradually.',
        topic: 'Emergency Procedures',
        difficulty: 'hard',
      ),
      Question(
        id: 'ep002',
        text: 'What should you do if you have a tire blowout?',
        options: ['Brake hard immediately', 'Grip steering wheel firmly and slow down gradually', 'Speed up to maintain control', 'Turn sharply to the side'],
        correctAnswerIndex: 1,
        explanation: 'During a blowout, grip the wheel firmly, ease off the accelerator, and slow down gradually.',
        topic: 'Emergency Procedures',
        difficulty: 'hard',
      ),

      // Advanced Traffic Laws
      Question(
        id: 'atl001',
        text: 'When is it legal to pass a school bus with flashing red lights?',
        options: ['Never', 'When on a divided highway', 'When the bus is empty', 'When traffic is light'],
        correctAnswerIndex: 0,
        explanation: 'It is never legal to pass a school bus with flashing red lights, regardless of the situation.',
        topic: 'Advanced Rules',
        difficulty: 'hard',
      ),
      Question(
        id: 'atl002',
        text: 'The "Move Over Law" requires drivers to:',
        options: ['Change lanes when possible for emergency vehicles', 'Always drive in the right lane', 'Move over for faster traffic', 'Yield to pedestrians'],
        correctAnswerIndex: 0,
        explanation: 'Move Over Laws require drivers to change lanes or slow down when approaching emergency vehicles.',
        topic: 'Advanced Rules',
        difficulty: 'medium',
      ),

      // Traffic Lights Questions
      Question(
        id: 'tl001',
        text: 'What does a flashing yellow light mean?',
        options: ['Stop completely', 'Proceed with caution', 'Speed up to clear intersection', 'Treat as red light'],
        correctAnswerIndex: 1,
        explanation: 'A flashing yellow light means proceed with caution after checking for traffic and pedestrians.',
        topic: 'Traffic Lights',
        difficulty: 'easy',
      ),
      Question(
        id: 'tl002',
        text: 'When facing a red light with a green arrow, you may:',
        options: ['Not move at all', 'Only move in the direction of the arrow', 'Move in any direction', 'Move straight only'],
        correctAnswerIndex: 1,
        explanation: 'A green arrow allows movement only in the direction indicated, even when the main light is red.',
        topic: 'Traffic Lights',
        difficulty: 'medium',
      ),
      Question(
        id: 'tl003',
        text: 'What should you do if traffic lights are completely out at an intersection?',
        options: ['Speed through quickly', 'Treat as a four-way stop', 'Wait for police', 'Follow the largest vehicle'],
        correctAnswerIndex: 1,
        explanation: 'When traffic lights are out, treat the intersection as a four-way stop sign.',
        topic: 'Traffic Lights',
        difficulty: 'medium',
      ),

      // Road Signs Questions  
      Question(
        id: 'rs001',
        text: 'A diamond-shaped yellow sign typically indicates:',
        options: ['Stop required', 'Warning or caution', 'Speed limit', 'No parking'],
        correctAnswerIndex: 1,
        explanation: 'Diamond-shaped yellow signs are warning signs that alert drivers to potential hazards ahead.',
        topic: 'Road Signs',
        difficulty: 'easy',
      ),
      Question(
        id: 'rs002',
        text: 'What does a white rectangular sign usually indicate?',
        options: ['Warning', 'Prohibition', 'Information or regulation', 'Construction zone'],
        correctAnswerIndex: 2,
        explanation: 'White rectangular signs typically provide regulatory information, speed limits, or traffic laws.',
        topic: 'Road Signs',
        difficulty: 'medium',
      ),

      // Defensive Driving Questions
      Question(
        id: 'dd001',
        text: 'What is the recommended following distance in normal conditions?',
        options: ['1 second', '2 seconds', '3-4 seconds', '5-6 seconds'],
        correctAnswerIndex: 2,
        explanation: 'The 3-4 second rule provides adequate stopping distance in normal driving conditions.',
        topic: 'Defensive Driving',
        difficulty: 'medium',
      ),
      Question(
        id: 'dd002',
        text: 'When should you check your blind spots?',
        options: ['Only when changing lanes', 'Before every turn', 'Before changing lanes or merging', 'Only on highways'],
        correctAnswerIndex: 2,
        explanation: 'Always check blind spots before changing lanes, merging, or when other vehicles might be hidden.',
        topic: 'Defensive Driving',
        difficulty: 'easy',
      ),
    ];
  }

  // Generate different quizzes from the question pool
  Future<void> _generateQuizzes() async {
    _quizzes = [
      // Topic-specific quizzes
      Quiz(
        id: 'quiz_traffic_signs',
        title: 'Traffic Signs & Symbols',
        description: 'Test your knowledge of traffic signs and their meanings',
        topic: 'Traffic Signs',
        difficulty: 'easy',
        questions: _getQuestionsByTopic('Traffic Signs'),
        timeLimit: 15,
      ),
      Quiz(
        id: 'quiz_right_of_way',
        title: 'Right of Way Rules',
        description: 'Learn when to yield and when you have the right of way',
        topic: 'Right of Way',
        difficulty: 'medium',
        questions: _getQuestionsByTopic('Right of Way'),
        timeLimit: 20,
      ),
      Quiz(
        id: 'quiz_speed_limits',
        title: 'Speed Limits & Safe Driving',
        description: 'Understanding speed limits and safe driving practices',
        topic: 'Speed Limits',
        difficulty: 'easy',
        questions: _getQuestionsByTopic('Speed Limits'),
        timeLimit: 10,
      ),
      Quiz(
        id: 'quiz_parking',
        title: 'Parking Rules & Regulations',
        description: 'Learn where and how to park legally',
        topic: 'Parking Rules',
        difficulty: 'medium',
        questions: _getQuestionsByTopic('Parking Rules'),
        timeLimit: 15,
      ),
      Quiz(
        id: 'quiz_safety',
        title: 'Safety & Seat Belt Laws',
        description: 'Important safety rules and regulations',
        topic: 'Safety Rules',
        difficulty: 'easy',
        questions: _getQuestionsByTopic('Safety Rules'),
        timeLimit: 12,
      ),
      Quiz(
        id: 'quiz_traffic_lights',
        title: 'Traffic Lights & Signals',
        description: 'Master traffic light rules and signal meanings',
        topic: 'Traffic Lights',
        difficulty: 'easy',
        questions: _getQuestionsByTopic('Traffic Lights'),
        timeLimit: 10,
      ),
      Quiz(
        id: 'quiz_road_signs',
        title: 'Road Signs & Markings',
        description: 'Understand road signs, markings, and their meanings',
        topic: 'Road Signs',
        difficulty: 'medium',
        questions: _getQuestionsByTopic('Road Signs'),
        timeLimit: 15,
      ),
      Quiz(
        id: 'quiz_defensive_driving',
        title: 'Defensive Driving',
        description: 'Learn defensive driving techniques and best practices',
        topic: 'Defensive Driving',
        difficulty: 'medium',
        questions: _getQuestionsByTopic('Defensive Driving'),
        timeLimit: 18,
      ),
      Quiz(
        id: 'quiz_emergency',
        title: 'Emergency Procedures',
        description: 'Handle emergency situations while driving',
        topic: 'Emergency Procedures',
        difficulty: 'hard',
        questions: _getQuestionsByTopic('Emergency Procedures'),
        timeLimit: 25,
      ),
      Quiz(
        id: 'quiz_advanced',
        title: 'Advanced Traffic Laws',
        description: 'Advanced rules and complex traffic situations',
        topic: 'Advanced Rules',
        difficulty: 'hard',
        questions: _getQuestionsByTopic('Advanced Rules'),
        timeLimit: 30,
      ),
      // Mixed difficulty quizzes
      Quiz(
        id: 'quiz_beginner',
        title: 'Beginner Driver Test',
        description: 'Perfect for new drivers learning the basics',
        topic: 'Mixed',
        difficulty: 'easy',
        questions: _getMixedQuestions('easy', 8),
        timeLimit: 15,
      ),
      Quiz(
        id: 'quiz_intermediate',
        title: 'Intermediate Challenge',
        description: 'Step up your knowledge with medium difficulty questions',
        topic: 'Mixed',
        difficulty: 'medium',
        questions: _getMixedQuestions('medium', 10),
        timeLimit: 20,
      ),
      Quiz(
        id: 'quiz_practice_exam',
        title: 'Practice Exam',
        description: 'A comprehensive practice test covering all topics',
        topic: 'Mixed',
        difficulty: 'medium',
        questions: _getRandomQuestions(10),
        timeLimit: 30,
        isExamMode: true,
      ),
      Quiz(
        id: 'quiz_final_exam',
        title: 'Final Exam',
        description: 'The ultimate test of your traffic rules knowledge',
        topic: 'Mixed',
        difficulty: 'hard',
        questions: _getRandomQuestions(15),
        timeLimit: 45,
        isExamMode: true,
      ),
    ];
  }

  // Get questions by topic
  List<Question> _getQuestionsByTopic(String topic) {
    return _allQuestions.where((q) => q.topic == topic).toList();
  }

  // Get random questions for mixed quizzes
  List<Question> _getRandomQuestions(int count) {
    final shuffled = List<Question>.from(_allQuestions)..shuffle(Random());
    return shuffled.take(count).toList();
  }

  // Get mixed questions by difficulty
  List<Question> _getMixedQuestions(String difficulty, int count) {
    final filteredQuestions = _allQuestions.where((q) => q.difficulty == difficulty).toList();
    final shuffled = List<Question>.from(filteredQuestions)..shuffle(Random());
    return shuffled.take(count).toList();
  }

  // Get quiz by ID
  Quiz? getQuizById(String quizId) {
    try {
      return _quizzes.firstWhere((quiz) => quiz.id == quizId);
    } catch (e) {
      return null;
    }
  }

  // Start a quiz
  void startQuiz(String quizId) {
    _currentQuiz = getQuizById(quizId);
    _lastResult = null;
    notifyListeners();
  }

  // Submit quiz answers and calculate result
  QuizResult submitQuiz({
    required String userId,
    required Map<String, int> userAnswers,
    required int timeSpentSeconds,
  }) {
    if (_currentQuiz == null) {
      throw Exception('No active quiz');
    }

    int score = 0;
    Map<String, bool> correctAnswers = {};

    for (final question in _currentQuiz!.questions) {
      final userAnswer = userAnswers[question.id];
      final isCorrect = userAnswer == question.correctAnswerIndex;
      
      if (isCorrect) score++;
      correctAnswers[question.id] = isCorrect;
    }

    _lastResult = QuizResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      quizId: _currentQuiz!.id,
      quizTitle: _currentQuiz!.title,
      score: score,
      totalQuestions: _currentQuiz!.totalQuestions,
      timeSpentSeconds: timeSpentSeconds,
      completedAt: DateTime.now(),
      userAnswers: userAnswers,
      correctAnswers: correctAnswers,
      topic: _currentQuiz!.topic,
      difficulty: _currentQuiz!.difficulty,
    );

    notifyListeners();
    return _lastResult!;
  }

  // Get quizzes by difficulty
  List<Quiz> getQuizzesByDifficulty(String difficulty) {
    return _quizzes.where((quiz) => quiz.difficulty == difficulty).toList();
  }

  // Get quizzes by topic
  List<Quiz> getQuizzesByTopic(String topic) {
    return _quizzes.where((quiz) => quiz.topic == topic).toList();
  }

  // Get available topics
  List<String> getAvailableTopics() {
    final topics = _quizzes.map((quiz) => quiz.topic).toSet().toList();
    topics.sort();
    return topics;
  }

  // Get available difficulties
  List<String> getAvailableDifficulties() {
    return ['easy', 'medium', 'hard'];
  }

  // Search quizzes by title or description
  List<Quiz> searchQuizzes(String query) {
    if (query.isEmpty) return _quizzes;
    
    return _quizzes.where((quiz) => 
      quiz.title.toLowerCase().contains(query.toLowerCase()) ||
      quiz.description.toLowerCase().contains(query.toLowerCase()) ||
      quiz.topic.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Get recommended quizzes based on user progress
  List<Quiz> getRecommendedQuizzes(Map<String, int> userTopicProgress) {
    // Find topics with least progress
    final topicScores = <String, int>{};
    
    for (final quiz in _quizzes) {
      if (quiz.topic != 'Mixed') {
        topicScores[quiz.topic] = userTopicProgress[quiz.topic] ?? 0;
      }
    }
    
    // Sort topics by progress (ascending)
    final sortedTopics = topicScores.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    // Return quizzes for topics with least progress
    final recommendations = <Quiz>[];
    for (final entry in sortedTopics.take(3)) {
      final topicQuizzes = getQuizzesByTopic(entry.key);
      recommendations.addAll(topicQuizzes.take(2));
    }
    
    return recommendations;
  }

  // Clear current quiz
  void clearCurrentQuiz() {
    _currentQuiz = null;
    _lastResult = null;
    notifyListeners();
  }
}