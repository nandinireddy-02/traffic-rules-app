import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/quiz_service.dart';
import '../models/quiz.dart';
import 'quiz_screen.dart';

class QuizSelectionScreen extends StatefulWidget {
  const QuizSelectionScreen({super.key});

  @override
  State<QuizSelectionScreen> createState() => _QuizSelectionScreenState();
}

class _QuizSelectionScreenState extends State<QuizSelectionScreen> {
  String selectedTopic = 'All';
  String selectedDifficulty = 'All';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Quiz'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<QuizService>(
        builder: (context, quizService, child) {
          final allQuizzes = quizService.quizzes;
          final filteredQuizzes = _filterQuizzes(allQuizzes);

          return Column(
            children: [
              _buildFilters(quizService),
              Expanded(
                child: _buildQuizList(filteredQuizzes),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(QuizService quizService) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search quizzes...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          
          // Filter chips
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Topic filter
                      _buildFilterChip(
                        'All Topics',
                        selectedTopic == 'All',
                        () => setState(() => selectedTopic = 'All'),
                      ),
                      ...quizService.getAvailableTopics().map(
                        (topic) => _buildFilterChip(
                          topic,
                          selectedTopic == topic,
                          () => setState(() => selectedTopic = topic),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Difficulty filter
                      _buildFilterChip(
                        'All Levels',
                        selectedDifficulty == 'All',
                        () => setState(() => selectedDifficulty = 'All'),
                      ),
                      ...[
                        'Easy',
                        'Medium',
                        'Hard'
                      ].map(
                        (difficulty) => _buildFilterChip(
                          difficulty,
                          selectedDifficulty == difficulty,
                          () => setState(() => selectedDifficulty = difficulty),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        checkmarkColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildQuizList(List<Quiz> quizzes) {
    if (quizzes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No quizzes found'),
            Text('Try adjusting your filters'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return _buildQuizCard(quiz);
      },
    );
  }

  Widget _buildQuizCard(Quiz quiz) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _startQuiz(quiz),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(quiz.difficulty),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      quiz.difficulty.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (quiz.isExamMode)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'EXAM',
                        style: TextStyle(
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
                quiz.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                quiz.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${quiz.totalQuestions} Questions'),
                  const SizedBox(width: 16),
                  Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${quiz.timeLimit} minutes'),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => _startQuiz(quiz),
                    child: const Text('Start Quiz'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Quiz> _filterQuizzes(List<Quiz> allQuizzes) {
    return allQuizzes.where((quiz) {
      // Topic filter
      if (selectedTopic != 'All' && quiz.topic != selectedTopic) {
        return false;
      }
      
      // Difficulty filter
      if (selectedDifficulty != 'All' && 
          quiz.difficulty.toLowerCase() != selectedDifficulty.toLowerCase()) {
        return false;
      }
      
      // Search filter
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return quiz.title.toLowerCase().contains(query) ||
               quiz.description.toLowerCase().contains(query) ||
               quiz.topic.toLowerCase().contains(query);
      }
      
      return true;
    }).toList();
  }

  void _startQuiz(Quiz quiz) {
    final quizService = Provider.of<QuizService>(context, listen: false);
    quizService.startQuiz(quiz.id);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(quiz: quiz),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}