import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz.dart';
import '../services/user_service.dart';
import '../services/quiz_service.dart';

class ResultsScreen extends StatelessWidget {
  final QuizResult result;

  const ResultsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildScoreCard(),
            const SizedBox(height: 24),
            _buildPerformanceDetails(),
            const SizedBox(height: 24),
            _buildAnswerReview(),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    final percentage = result.accuracy;
    final isPassing = result.isPassing;
    
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isPassing 
                ? [Colors.green.shade400, Colors.green.shade600]
                : [Colors.red.shade400, Colors.red.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              isPassing ? '🎉 Congratulations!' : '📚 Keep Studying!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${result.score}/${result.totalQuestions}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}% - Grade ${result.grade}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPassing ? 'You passed!' : 'You need 70% to pass',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Quiz', result.quizTitle),
            _buildDetailRow('Topic', result.topic),
            _buildDetailRow('Difficulty', result.difficulty.toUpperCase()),
            _buildDetailRow('Time Spent', result.timeSpentFormatted),
            _buildDetailRow('Correct Answers', '${result.score}'),
            _buildDetailRow('Wrong Answers', '${result.totalQuestions - result.score}'),
            _buildDetailRow('Accuracy', '${result.accuracy.toStringAsFixed(1)}%'),
            _buildDetailRow('Grade', result.grade),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildAnswerReview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.quiz),
                const SizedBox(width: 8),
                const Text(
                  'Answer Review',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${result.correctAnswers.values.where((correct) => correct).length} correct',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<QuizService>(
              builder: (context, quizService, child) {
                final quiz = quizService.getQuizById(result.quizId);
                if (quiz == null) {
                  return const Text('Quiz details not available');
                }

                return Column(
                  children: quiz.questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    final userAnswer = result.userAnswers[question.id];
                    final isCorrect = result.correctAnswers[question.id] ?? false;

                    return _buildQuestionReview(
                      index + 1,
                      question,
                      userAnswer,
                      isCorrect,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionReview(int questionNumber, Question question, int? userAnswer, bool isCorrect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    questionNumber.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 20,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isCorrect ? 'CORRECT' : 'WRONG',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.text,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          
          // Show user's answer if they answered
          if (userAnswer != null) ...[
            Text(
              'Your answer: ${question.options[userAnswer]}',
              style: TextStyle(
                color: isCorrect ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          
          // Show correct answer if user was wrong
          if (!isCorrect) ...[
            Text(
              'Correct answer: ${question.correctAnswer}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          
          // Show explanation
          if (question.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Navigate back to quiz selection
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Back to Home'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Retake the quiz
              final quizService = Provider.of<QuizService>(context, listen: false);
              quizService.startQuiz(result.quizId);
              Navigator.of(context).popUntil((route) => route.isFirst);
              // Navigate to quiz screen
            },
            child: const Text('Retake Quiz'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              // Share results
              _shareResults(context);
            },
            child: const Text('Share Results'),
          ),
        ),
      ],
    );
  }

  void _shareResults(BuildContext context) {
    final text = 'I just scored ${result.score}/${result.totalQuestions} (${result.accuracy.toStringAsFixed(1)}%) on the ${result.quizTitle} quiz in TrafficAce! 🚗📚';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Results'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, integrate with share plugins
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon!')),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }
}