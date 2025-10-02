import 'package:flutter/material.dart';
import '../models/quiz.dart';

class GradeAwareQuizService extends ChangeNotifier {
  List<Quiz> _quizzes = [];
  List<Question> _allQuestions = [];
  Quiz? _currentQuiz;
  QuizResult? _lastResult;
  
  List<Quiz> get quizzes => _quizzes;
  Quiz? get currentQuiz => _currentQuiz;
  QuizResult? get lastResult => _lastResult;

  // Initialize with grade-appropriate sample data
  Future<void> initialize() async {
    await _loadGradeAppropriateQuestions();
    await _generateGradeSpecificQuizzes();
    notifyListeners();
  }

  // Load age-appropriate questions by grade level
  Future<void> _loadGradeAppropriateQuestions() async {
    _allQuestions = [
      // GRADE 2-3: Traffic Lights Only (Simple, Visual)
      Question(
        id: 'tl_g23_001',
        text: '🚦 What does RED light mean?',
        options: ['Go fast! 🏃‍♂️', 'Stop! ✋', 'Slow down 🐌', 'Turn left ⬅️'],
        correctAnswerIndex: 1,
        explanation: 'Red light means STOP! Just like when mommy says stop. 🛑',
        topic: 'Traffic Lights',
        difficulty: 'easy',
        gradeLevel: [2, 3],
      ),
      Question(
        id: 'tl_g23_002',
        text: '🚦 What does GREEN light mean?',
        options: ['Stop ✋', 'Go carefully! 👀', 'Sleep 😴', 'Dance 💃'],
        correctAnswerIndex: 1,
        explanation: 'Green light means GO! But always look both ways first. 👀',
        topic: 'Traffic Lights',
        difficulty: 'easy',
        gradeLevel: [2, 3],
      ),
      Question(
        id: 'tl_g23_003',
        text: '🚦 What does YELLOW light mean?',
        options: ['Go faster! 🏃‍♂️', 'Jump up! 🦘', 'Get ready to stop! ⚠️', 'Close your eyes 👀'],
        correctAnswerIndex: 2,
        explanation: 'Yellow light means get ready to stop! Like when teacher says "5 more minutes!" ⏰',
        topic: 'Traffic Lights',
        difficulty: 'easy',
        gradeLevel: [2, 3],
      ),
      Question(
        id: 'tl_g23_004',
        text: '🚶‍♀️ When can you cross the street?',
        options: ['When cars are coming 🚗', 'When adults say it\'s safe ✅', 'Anytime you want 🤷‍♀️', 'When it\'s dark 🌙'],
        correctAnswerIndex: 1,
        explanation: 'Always wait for an adult to say it\'s safe! They help keep you safe. 👨‍👩‍👧‍👦',
        topic: 'Traffic Lights',
        difficulty: 'easy',
        gradeLevel: [2, 3],
      ),

      // GRADE 2 VIDEO ENHANCED QUESTIONS - Traffic Lights Learning
      Question(
        id: 'tl_g2_video_001',
        text: '📺 Watch the Traffic Light Song! What do you do when you see RED? 🚦',
        options: ['🏃‍♀️ Run across!', '✋ STOP and wait!', '🚗 Drive faster!', '👀 Close my eyes!'],
        correctAnswerIndex: 1,
        explanation: 'RED means STOP! Just like in the song - we stop and stay safe! 🛑✨',
        topic: 'Video Learning',
        difficulty: 'easy',
        gradeLevel: [2],
        videoUrl: 'https://www.youtube.com/watch?v=0Rqw4krMOug',
        videoDescription: '🎵 Learn the Traffic Light Song! Red means STOP, Green means GO!',
      ),
      Question(
        id: 'tl_g2_video_002', 
        text: '📺 After watching the video, what does GREEN light tell cars to do? 🚦',
        options: ['🛑 Stop right now!', '⏰ Wait a little!', '🚗 Go carefully!', '📱 Use phone!'],
        correctAnswerIndex: 2,
        explanation: 'GREEN means GO! But cars must still be careful and watch for people. 🚗💚',
        topic: 'Video Learning',
        difficulty: 'easy',
        gradeLevel: [2],
        videoUrl: 'https://www.youtube.com/watch?v=b6UIZjG-fEE',
        videoDescription: '🚦 Learn how traffic lights keep everyone safe on the road!',
      ),
      Question(
        id: 'tl_g2_video_003',
        text: '📺 Watch how to cross the street safely! What should you do FIRST? 🚶‍♀️',
        options: ['🏃‍♀️ Run fast across!', '👀 Look both ways!', '📱 Play games!', '🎵 Sing loud songs!'],
        correctAnswerIndex: 1,
        explanation: 'Always look LEFT, RIGHT, LEFT again before crossing! Safety first! 👀✨',
        topic: 'Video Learning',
        difficulty: 'easy', 
        gradeLevel: [2],
        videoUrl: 'https://www.youtube.com/watch?v=lX6RRoyAVCg',
        videoDescription: '🚶‍♀️ Learn the safe way to cross streets with grown-ups!',
      ),
      Question(
        id: 'tl_g2_video_004',
        text: '📺 Watch about STOP signs! What shape is a STOP sign? 🛑',
        options: ['🔵 Circle like a ball!', '🔺 Triangle like pizza!', '🛑 8 sides like octopus!', '⭐ Star like twinkle!'],
        correctAnswerIndex: 2,
        explanation: 'STOP signs have 8 sides like an octopus! They\'re red and say STOP! 🛑🐙',
        topic: 'Video Learning',
        difficulty: 'easy',
        gradeLevel: [2],
        videoUrl: 'https://www.youtube.com/watch?v=SYc8gjcrB-4',
        videoDescription: '🛑 Learn about different traffic signs and what they mean!',
      ),
      Question(
        id: 'tl_g2_video_005',
        text: '📺 Watch about seatbelts! Why do we wear seatbelts in the car? 🚗',
        options: ['🎀 To look pretty!', '🛡️ To stay safe!', '🎮 To play games!', '🍎 To eat snacks!'],
        correctAnswerIndex: 1,
        explanation: 'Seatbelts are like superhero belts that keep us safe in cars! 🦸‍♀️🚗',
        topic: 'Video Learning',
        difficulty: 'easy',
        gradeLevel: [2],
        videoUrl: 'https://www.youtube.com/watch?v=kUjKxtJd0Wk',
        videoDescription: '🚗 Learn why seatbelts are important for staying safe in cars!',
      ),

      // GRADE 4-5: Traffic Lights + Basic Signs
      Question(
        id: 'ts_g45_001',
        text: 'What does this red octagonal sign mean? 🛑',
        options: ['Slow down', 'STOP completely', 'Look around', 'Speed up'],
        correctAnswerIndex: 1,
        explanation: 'The red STOP sign means you must stop completely and look both ways before going.',
        topic: 'Traffic Signs',
        difficulty: 'easy',
        gradeLevel: [4, 5],
      ),
      Question(
        id: 'ts_g45_002',
        text: 'What should you do at a crosswalk? 🚶‍♀️',
        options: ['Run across quickly', 'Look both ways and walk', 'Close your eyes', 'Play games'],
        correctAnswerIndex: 1,
        explanation: 'At crosswalks, always stop, look both ways, listen for cars, and then walk across safely.',
        topic: 'Pedestrian Safety',
        difficulty: 'easy',
        gradeLevel: [4, 5],
      ),
      Question(
        id: 'ts_g45_003',
        text: 'What does a yellow triangular warning sign mean? ⚠️',
        options: ['Stop immediately', 'Be careful - danger ahead!', 'Go faster', 'Turn around'],
        correctAnswerIndex: 1,
        explanation: 'Yellow warning signs tell us to be careful because there might be danger ahead.',
        topic: 'Traffic Signs',
        difficulty: 'medium',
        gradeLevel: [4, 5],
      ),

      // GRADE 6-7: Road Safety & Basic Rules
      Question(
        id: 'rs_g67_001',
        text: 'Why should you always wear a seatbelt in a car?',
        options: ['It looks cool', 'To keep you safe in case of an accident', 'It\'s the law only', 'To sit up straighter'],
        correctAnswerIndex: 1,
        explanation: 'Seatbelts protect you by keeping you in your seat during sudden stops or accidents.',
        topic: 'Safety Rules',
        difficulty: 'medium',
        gradeLevel: [6, 7],
      ),
      Question(
        id: 'rs_g67_002',
        text: 'When riding a bicycle, what should you always wear?',
        options: ['Sunglasses', 'A helmet', 'Gloves', 'A jacket'],
        correctAnswerIndex: 1,
        explanation: 'A helmet protects your head, which is the most important part of your body to keep safe.',
        topic: 'Bicycle Safety',
        difficulty: 'easy',
        gradeLevel: [6, 7],
      ),
      Question(
        id: 'rs_g67_003',
        text: 'What does "right of way" mean?',
        options: ['The right to go first', 'Turning right only', 'The right side of the road', 'Going the right speed'],
        correctAnswerIndex: 0,
        explanation: 'Right of way means who gets to go first at intersections or crossings.',
        topic: 'Right of Way',
        difficulty: 'medium',
        gradeLevel: [6, 7],
      ),

      // GRADE 8-10: Comprehensive Traffic Rules
      Question(
        id: 'cr_g810_001',
        text: 'What is the typical speed limit in a school zone during school hours?',
        options: ['15-25 mph', '25-35 mph', '35-45 mph', '45-55 mph'],
        correctAnswerIndex: 0,
        explanation: 'School zones have reduced speed limits (15-25 mph) to protect students walking to and from school.',
        topic: 'Speed Limits',
        difficulty: 'medium',
        gradeLevel: [8, 9, 10],
      ),
      Question(
        id: 'cr_g810_002',
        text: 'At a four-way intersection with stop signs, who has the right of way?',
        options: ['The largest vehicle', 'The vehicle that arrived first', 'Vehicles going straight', 'Emergency vehicles only'],
        correctAnswerIndex: 1,
        explanation: 'At four-way stops, the first vehicle to arrive and stop has the right of way.',
        topic: 'Right of Way',
        difficulty: 'hard',
        gradeLevel: [8, 9, 10],
      ),
      Question(
        id: 'cr_g810_003',
        text: 'How far should you park from a fire hydrant?',
        options: ['5 feet', '10 feet', '15 feet', '20 feet'],
        correctAnswerIndex: 2,
        explanation: 'You must park at least 15 feet away from fire hydrants so fire trucks can access them in emergencies.',
        topic: 'Parking Rules',
        difficulty: 'hard',
        gradeLevel: [8, 9, 10],
      ),
      Question(
        id: 'cr_g810_004',
        text: 'What should you do if you see a school bus with flashing red lights?',
        options: ['Pass on the left', 'Stop and wait', 'Pass on the right', 'Honk your horn'],
        correctAnswerIndex: 1,
        explanation: 'When a school bus has flashing red lights, ALL traffic must stop to protect children getting on or off.',
        topic: 'School Bus Safety',
        difficulty: 'hard',
        gradeLevel: [8, 9, 10],
      ),

      // Additional questions for older grades
      Question(
        id: 'adv_g810_001',
        text: 'What is defensive driving?',
        options: ['Driving aggressively', 'Driving to protect yourself and others', 'Driving fast', 'Driving with music loud'],
        correctAnswerIndex: 1,
        explanation: 'Defensive driving means being alert, following rules, and anticipating what other drivers might do wrong.',
        topic: 'Defensive Driving',
        difficulty: 'medium',
        gradeLevel: [9, 10],
      ),
      Question(
        id: 'adv_g810_002',
        text: 'What is the "3-second rule"?',
        options: ['Count to 3 at lights', 'Wait 3 seconds to honk', 'Keep 3 seconds distance behind cars', 'Stop for 3 seconds'],
        correctAnswerIndex: 2,
        explanation: 'The 3-second rule helps you keep a safe following distance behind other vehicles.',
        topic: 'Defensive Driving',
        difficulty: 'hard',
        gradeLevel: [9, 10],
      ),
    ];
  }

  // Generate grade-specific quizzes
  Future<void> _generateGradeSpecificQuizzes() async {
    _quizzes = [
      // Grade 2-3: Traffic Lights only
      Quiz(
        id: 'grade23_traffic_lights',
        title: '🚦 Traffic Lights for Little Learners',
        description: 'Learn what red, yellow, and green lights mean! 🌈',
        topic: 'Traffic Lights',
        difficulty: 'easy',
        questions: _getQuestionsByGradeAndTopic([2, 3], 'Traffic Lights'),
        timeLimit: 10,
      ),

      // Grade 2: Video Learning Experience - NEW!
      Quiz(
        id: 'grade2_video_learning',
        title: '📺 Watch & Learn Traffic Safety!',
        description: 'Watch fun videos and learn about staying safe! 🎬✨',
        topic: 'Video Learning',
        difficulty: 'easy',
        questions: _getQuestionsByGradeAndTopic([2], 'Video Learning'),
        timeLimit: 15,
      ),

      // Grade 4-5: Traffic Lights + Basic Signs
      Quiz(
        id: 'grade45_traffic_signs',
        title: '🚦 Traffic Lights & Basic Signs',
        description: 'Master traffic lights and learn about stop signs!',
        topic: 'Traffic Signs',
        difficulty: 'easy',
        questions: _getQuestionsByGrade([4, 5]),
        timeLimit: 12,
      ),

      // Grade 6-7: Road Safety
      Quiz(
        id: 'grade67_road_safety',
        title: '🚴‍♀️ Road Safety Champions',
        description: 'Learn important safety rules for walking and biking!',
        topic: 'Safety Rules',
        difficulty: 'medium',
        questions: _getQuestionsByGrade([6, 7]),
        timeLimit: 15,
      ),

      // Grade 8-10: Comprehensive Rules
      Quiz(
        id: 'grade810_comprehensive',
        title: '🚗 Complete Traffic Rules',
        description: 'Master all traffic rules and become a safety expert!',
        topic: 'Comprehensive',
        difficulty: 'hard',
        questions: _getQuestionsByGrade([8, 9, 10]).take(6).toList(),
        timeLimit: 20,
      ),
      Quiz(
        id: 'grade910_advanced',
        title: '🏆 Advanced Traffic Knowledge',
        description: 'Challenge yourself with complex traffic scenarios!',
        topic: 'Advanced Rules',
        difficulty: 'hard',
        questions: _getQuestionsByGrade([9, 10]),
        timeLimit: 18,
      ),
    ];
  }

  // Get questions appropriate for specific grade levels
  List<Question> _getQuestionsByGrade(List<int> targetGrades) {
    return _allQuestions.where((question) {
      return question.gradeLevel.any((grade) => targetGrades.contains(grade));
    }).toList();
  }

  // Get questions by grade and topic
  List<Question> _getQuestionsByGradeAndTopic(List<int> targetGrades, String topic) {
    return _allQuestions.where((question) {
      final gradeMatch = question.gradeLevel.any((grade) => targetGrades.contains(grade));
      final topicMatch = question.topic.toLowerCase().contains(topic.toLowerCase());
      return gradeMatch && topicMatch;
    }).toList();
  }

  // Get quizzes appropriate for a student's grade
  List<Quiz> getQuizzesForGrade(int studentGrade) {
    return _quizzes.where((quiz) {
      // Check if any question in the quiz is appropriate for the student's grade
      return quiz.questions.any((question) => 
        question.gradeLevel.contains(studentGrade));
    }).toList();
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

  // Clear current quiz
  void clearCurrentQuiz() {
    _currentQuiz = null;
    _lastResult = null;
    notifyListeners();
  }

  // Get available topics for a grade
  List<String> getAvailableTopicsForGrade(int grade) {
    final gradeQuestions = _getQuestionsByGrade([grade]);
    final topics = gradeQuestions.map((q) => q.topic).toSet().toList();
    topics.sort();
    return topics;
  }

  // Search quizzes by title or description for a specific grade
  List<Quiz> searchQuizzesForGrade(String query, int grade) {
    final gradeQuizzes = getQuizzesForGrade(grade);
    
    if (query.isEmpty) return gradeQuizzes;
    
    return gradeQuizzes.where((quiz) => 
      quiz.title.toLowerCase().contains(query.toLowerCase()) ||
      quiz.description.toLowerCase().contains(query.toLowerCase()) ||
      quiz.topic.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}