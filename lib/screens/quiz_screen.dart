import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/quiz.dart';
import '../services/user_service.dart';
import '../services/realtime_stats_service.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  Map<String, int> userAnswers = {};
  Timer? timer;
  int timeRemainingSeconds = 0;
  bool isQuizCompleted = false;
  DateTime? quizStartTime;

  @override
  void initState() {
    super.initState();
    timeRemainingSeconds = widget.quiz.timeLimit * 60;
    quizStartTime = DateTime.now();
    
    // Track quiz attempt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final statsService = Provider.of<RealtimeStatsService>(context, listen: false);
      statsService.recordQuizAttempted(widget.quiz.id, widget.quiz.title);
    });
    
    _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (timeRemainingSeconds > 0) {
            timeRemainingSeconds--;
          } else {
            _submitQuiz();
          }
        });
      }
    });
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      final currentQuestion = widget.quiz.questions[currentQuestionIndex];
      userAnswers[currentQuestion.id] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitQuiz() async {
    if (isQuizCompleted) return;
    
    timer?.cancel();
    
    // Calculate results
    int correctAnswers = 0;
    final questions = widget.quiz.questions;
    
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final userAnswer = userAnswers[question.id];
      if (userAnswer != null && userAnswer == question.correctAnswerIndex) {
        correctAnswers++;
      }
    }
    final timeTaken = DateTime.now().difference(quizStartTime!);
    
    // Create proper QuizResult object
    final result = QuizResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: Provider.of<UserService>(context, listen: false).currentUser?.id ?? 'guest',
      quizId: widget.quiz.id,
      quizTitle: widget.quiz.title,
      topic: widget.quiz.topic,
      difficulty: widget.quiz.difficulty,
      score: correctAnswers,
      totalQuestions: questions.length,
      timeSpentSeconds: timeTaken.inSeconds,
      userAnswers: userAnswers,
      correctAnswers: Map.fromEntries(
        questions.asMap().entries.map((entry) {
          final question = entry.value;
          final userAnswer = userAnswers[question.id];
          return MapEntry(question.id, userAnswer != null && userAnswer == question.correctAnswerIndex);
        }),
      ),
      completedAt: DateTime.now(),
    );
    
    isQuizCompleted = true;
    
    // Track in real-time stats
    final statsService = Provider.of<RealtimeStatsService>(context, listen: false);
    await statsService.recordQuizCompleted(
      widget.quiz.id, 
      widget.quiz.title, 
      correctAnswers.toDouble(), 
      questions.length.toDouble(),
    );
    
    // Navigate to results
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(result: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.quiz.questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / widget.quiz.questions.length;
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.quiz.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.quiz.topic,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _showExitDialog(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  _formatTime(timeRemainingSeconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced Progress indicator
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Enhanced Question content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Question text
                  Card(
                    elevation: 8,
                    shadowColor: Colors.blue.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.blue.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.help_outline_rounded,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Question',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentQuestion.text,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (currentQuestion.imageUrl != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text('Image placeholder'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Answer options
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentQuestion.options.length,
                      itemBuilder: (context, index) {
                        final isSelected = userAnswers[currentQuestion.id] == index;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: isSelected ? 4 : 1,
                            color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : null,
                            child: InkWell(
                              onTap: () => _selectAnswer(index),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected 
                                              ? Theme.of(context).primaryColor 
                                              : Colors.grey,
                                          width: 2,
                                        ),
                                        color: isSelected 
                                            ? Theme.of(context).primaryColor 
                                            : Colors.transparent,
                                      ),
                                      child: isSelected
                                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        currentQuestion.options[index],
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: isSelected 
                                              ? Theme.of(context).primaryColor 
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      child: const Text('Previous'),
                    ),
                  ),
                if (currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  flex: currentQuestionIndex > 0 ? 1 : 2,
                  child: ElevatedButton(
                    onPressed: userAnswers.containsKey(currentQuestion.id)
                        ? (currentQuestionIndex < widget.quiz.questions.length - 1
                            ? _nextQuestion
                            : _submitQuiz)
                        : null,
                    child: Text(
                      currentQuestionIndex < widget.quiz.questions.length - 1
                          ? 'Next'
                          : 'Submit Quiz',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text('Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}