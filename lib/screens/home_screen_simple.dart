import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../services/quiz_service.dart';
import '../models/quiz.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    final userService = Provider.of<UserService>(context, listen: false);
    
    // Create default user if none exists
    if (!userService.isLoggedIn) {
      await _showWelcomeDialog();
    }
  }

  Future<void> _showWelcomeDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Welcome to TrafficAce!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Let\'s get you started with your traffic rules journey.'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                hintText: 'Enter your email',
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final userService = Provider.of<UserService>(context, listen: false);
                final navigator = Navigator.of(context);
                await userService.createUser(
                  nameController.text,
                  emailController.text.isEmpty ? '${nameController.text.toLowerCase().replaceAll(' ', '.')}@student.com' : emailController.text,
                  5, // Default grade
                );
                navigator.pop();
              }
            },
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrafficAce'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer2<UserService, QuizService>(
        builder: (context, userService, quizService, child) {
          if (!userService.isLoggedIn) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final user = userService.currentUser!;
          final stats = userService.getStudyStatistics();
          final recommendedQuizzes = quizService.getRecommendedQuizzes(user.topicProgress);

          return RefreshIndicator(
            onRefresh: () async {
              await _checkUserStatus();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildWelcomeCard(user),
                const SizedBox(height: 16),
                _buildStatsGrid(stats),
                const SizedBox(height: 16),
                _buildProgressCard(stats),
                const SizedBox(height: 16),
                _buildQuizList(recommendedQuizzes),
                const SizedBox(height: 16),
                _buildAchievements(user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hey ${user.name}!',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Ready for your next challenge?',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2,
      children: [
        _buildStatCard('Quizzes', '${stats['totalQuizzes']}', Icons.quiz, Colors.blue),
        _buildStatCard('Accuracy', '${stats['accuracy'].toStringAsFixed(1)}%', Icons.track_changes, Colors.green),
        _buildStatCard('Grade', stats['grade'], Icons.grade, Colors.orange),
        _buildStatCard('Badges', '${stats['badges']}', Icons.emoji_events, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(Map<String, dynamic> stats) {
    final progress = stats['studyProgress'] / 100.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Overall Progress',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizList(List<Quiz> quizzes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Quizzes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quizzes.take(3).length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getDifficultyColor(quiz.difficulty),
                  child: Text(
                    _getQuizEmoji(quiz.topic),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                title: Text(quiz.title),
                subtitle: Text('${quiz.questions.length} questions • ${quiz.difficulty}'),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
                onTap: () {
                  final quizService = Provider.of<QuizService>(context, listen: false);
                  quizService.startQuiz(quiz.id);
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(quiz: quiz),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAchievements(user) {
    final recentBadges = user.achievedBadges.take(3).toList();
    
    if (recentBadges.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.emoji_events, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              const Text(
                'No achievements yet',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Complete your first quiz to earn badges!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Achievements',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: recentBadges.map((badge) {
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getBadgeName(badge),
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
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

  String _getBadgeName(String badgeId) {
    final userService = Provider.of<UserService>(context, listen: false);
    final badges = userService.getAllBadges();
    return badges[badgeId] ?? badgeId;
  }

  String _getQuizEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'road signs':
        return '🚦';
      case 'traffic signals':
        return '🚥';
      case 'parking rules':
        return '🅿️';
      case 'speed limits':
        return '⚡';
      case 'safety rules':
        return '🦺';
      default:
        return '📝';
    }
  }
}