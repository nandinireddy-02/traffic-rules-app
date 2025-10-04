import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../services/grade_aware_quiz_service.dart';
import '../services/video_learning_service.dart';
import '../services/realtime_stats_service.dart';
import '../models/quiz.dart';
import '../models/user.dart';
import '../widgets/grade_video_player_widget.dart';
import 'quiz_screen.dart';

class GradeAwareHomeScreen extends StatefulWidget {
  const GradeAwareHomeScreen({super.key});

  @override
  State<GradeAwareHomeScreen> createState() => _GradeAwareHomeScreenState();
}

class _GradeAwareHomeScreenState extends State<GradeAwareHomeScreen> with TickerProviderStateMixin {
  late AnimationController _welcomeController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _welcomeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _welcomeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _welcomeController,
      curve: Curves.easeOutCubic,
    ));
    
    _welcomeController.forward();
  }

  @override
  void dispose() {
    _welcomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserService, GradeAwareQuizService, VideoLearningService>(
      builder: (context, userService, quizService, videoService, child) {
        final user = userService.currentUser!;
        final gradeQuizzes = quizService.getQuizzesForGrade(user.grade);

        return Scaffold(
          backgroundColor: _getGradeBackgroundColor(user.grade),
          appBar: AppBar(
            title: Text(
              '🚦 TrafficAce Kids - Grade ${user.grade}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                onPressed: () => _showUserProfile(context, userService),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(user),
                const SizedBox(height: 20),
                _buildRealtimeStatsSection(),
                const SizedBox(height: 20),
                _buildProgressSection(user),
                const SizedBox(height: 20),
                _buildVideoLearningSection(user.grade, videoService),
                const SizedBox(height: 20),
                _buildQuizSection(gradeQuizzes, user.grade, videoService),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getGradeBackgroundColor(int grade) {
    switch (grade) {
      case 2:
        return Colors.red.shade400; // Bright red for traffic lights theme
      case 3:
        return Colors.pink.shade400; // Pink for young learners
      case 4:
        return Colors.orange.shade400; // Orange for warning signs theme
      case 5:
        return Colors.amber.shade500; // Amber for caution theme
      case 6:
        return Colors.green.shade400; // Green for safety theme
      case 7:
        return Colors.teal.shade400; // Teal for advanced safety
      case 8:
        return Colors.blue.shade400; // Blue for road awareness
      case 9:
        return Colors.indigo.shade500; // Indigo for pre-driver theme
      case 10:
        return Colors.purple.shade500; // Purple for advanced driver prep
      default:
        return Colors.blue.shade400;
    }
  }

  Widget _buildWelcomeCard(User user) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withValues(alpha: 0.9),
                ],
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getGradeBackgroundColor(user.grade).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getGradeEmoji(user.grade),
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi ${user.name}! 👋',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getGradeWelcomeMessage(user.grade),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getGradeBackgroundColor(user.grade).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Learning Progress',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              _getProgressMessage(user),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getGradeBackgroundColor(user.grade),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGradeEmoji(int grade) {
    switch (grade) {
      case 2:
      case 3:
        return '🚦';
      case 4:
      case 5:
        return '🛑';
      case 6:
      case 7:
        return '🚴‍♀️';
      case 8:
      case 9:
      case 10:
        return '🚗';
      default:
        return '📚';
    }
  }

  String _getGradeWelcomeMessage(int grade) {
    switch (grade) {
      case 2:
      case 3:
        return 'Let\'s learn about traffic lights!';
      case 4:
      case 5:
        return 'Time to learn signs and safety!';
      case 6:
      case 7:
        return 'Become a road safety champion!';
      case 8:
      case 9:
      case 10:
        return 'Master all traffic rules!';
      default:
        return 'Let\'s learn together!';
    }
  }

  String _getProgressMessage(User user) {
    final completed = user.totalQuizzesCompleted;
    if (completed == 0) {
      return 'Ready to start learning! 🌟';
    } else if (completed < 3) {
      return 'Great start! Keep going! 🚀';
    } else if (completed < 6) {
      return 'You\'re doing amazing! 🏆';
    } else {
      return 'Traffic safety expert! 🎉';
    }
  }

  Widget _buildProgressSection(User user) {
    return Consumer<RealtimeStatsService>(
      builder: (context, statsService, child) {
        final realtimeStats = statsService.getFormattedStats();
        final userStats = _calculateGradeStats(user);
        
        // Combine user stats with real-time stats for accuracy
        final combinedQuizzes = userStats['completed'] + realtimeStats['sessionQuizzesCompleted'];
        final combinedVideos = realtimeStats['videosCompleted'];
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics_rounded,
                      color: _getGradeBackgroundColor(user.grade),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Your Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.2,
                  children: [
                    _buildStatCard(
                      'Quizzes Done',
                      '$combinedQuizzes',
                      Icons.quiz_rounded,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Videos Watched',
                      '$combinedVideos',
                      Icons.video_library,
                      Colors.red,
                    ),
                    _buildStatCard(
                      'Streak Days',
                      '${realtimeStats['currentStreak']}',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Grade Level',
                      'Grade ${user.grade}',
                      Icons.school,
                      _getGradeBackgroundColor(user.grade),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _calculateGradeStats(User user) {
    return {
      'completed': user.totalQuizzesCompleted,
      'accuracy': user.overallAccuracy,
      'streak': user.currentStreak,
      'grade': user.grade,
    };
  }

  Widget _buildRealtimeStatsSection() {
    return Consumer<RealtimeStatsService>(
      builder: (context, statsService, child) {
        final stats = statsService.getFormattedStats();
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Colors.purple,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Live Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Real-time',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Session Summary
                if (stats['sessionVideosWatched'] > 0 || stats['sessionQuizzesCompleted'] > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade50, Colors.purple.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flash_on, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            statsService.getSessionSummary(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildMiniStatCard(
                      'Videos',
                      '${stats['videosCompleted']}',
                      Icons.video_library,
                      Colors.red,
                    ),
                    _buildMiniStatCard(
                      'Quizzes',
                      '${stats['quizzesCompleted']}',
                      Icons.quiz,
                      Colors.blue,
                    ),
                    _buildMiniStatCard(
                      'Streak',
                      '${stats['currentStreak']}',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



  Widget _buildVideoLearningSection(int grade, VideoLearningService videoService) {
    final gradeVideos = videoService.getVideosForGrade(grade);
    final completionPercentage = videoService.getGradeCompletionPercentage(grade);
    final areQuizzesUnlocked = videoService.areQuizzesUnlockedForGrade(grade);



    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_filled,
                  color: _getGradeBackgroundColor(grade),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🎥 Video Learning for Grade $grade',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress summary
            VideoLearningProgressWidget(
              gradeLevel: grade,
              completionPercentage: completionPercentage,
              areQuizzesUnlocked: areQuizzesUnlocked,
            ),
            
            const SizedBox(height: 16),
            
            // Video list
            if (gradeVideos.isNotEmpty) ...[
              const Text(
                '📚 Watch these videos to learn:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              // Display video widgets
              ...gradeVideos.map((video) => GradeVideoPlayerWidget(
                video: video,
                onVideoCompleted: () {
                  // Refresh the service to update completion status
                  // The video service will automatically notify listeners when marking video as watched
                },
              )),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Text(
                  '🚧 No videos found for this grade!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuizSection(List<Quiz> quizzes, int grade, VideoLearningService videoService) {
    final areQuizzesUnlocked = videoService.areQuizzesUnlockedForGrade(grade);
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      areQuizzesUnlocked ? Icons.quiz_rounded : Icons.lock,
                      color: areQuizzesUnlocked 
                          ? _getGradeBackgroundColor(grade)
                          : Colors.grey.shade400,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        areQuizzesUnlocked 
                            ? _getQuizSectionTitle(grade)
                            : '🔒 ${_getQuizSectionTitle(grade)} - Watch Videos to Unlock!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: areQuizzesUnlocked ? Colors.black87 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Show lock message if not unlocked
                if (!areQuizzesUnlocked) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.video_library, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Watch at least one video above to unlock quizzes for Grade $grade!',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Show unlocked quizzes
                  Text(
                    '🎉 Great! You\'ve unlocked the quizzes. Test your knowledge!',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Quiz content based on unlock status
                if (!areQuizzesUnlocked)
                  const SizedBox.shrink()
                else if (quizzes.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        'No quizzes available for your grade yet.\nCheck back soon! 📚',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = quizzes[index];
                      return _buildQuizCard(quiz, grade);
                    },
                  ),
              ],
            ),
          ),
        );
  }

  String _getQuizSectionTitle(int grade) {
    switch (grade) {
      case 2:
      case 3:
        return 'Traffic Light Fun! 🚦';
      case 4:
      case 5:
        return 'Signs & Safety 🛑';
      case 6:
      case 7:
        return 'Road Safety Adventures 🚴‍♀️';
      case 8:
      case 9:
      case 10:
        return 'Traffic Master Challenges 🚗';
      default:
        return 'Learning Quizzes';
    }
  }

  Widget _buildQuizCard(Quiz quiz, int grade) {
    final cardColor = _getGradeBackgroundColor(grade);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _startQuiz(quiz),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  cardColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    _getQuizIcon(quiz.topic),
                    color: cardColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quiz.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${quiz.questions.length} questions',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cardColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${quiz.timeLimit} min',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          // Video indicator for Grade 2 video quiz
                          if (quiz.id == 'grade2_video_learning') ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_circle, size: 14, color: Colors.red),
                                  SizedBox(width: 4),
                                  Text(
                                    'VIDEO',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: cardColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getQuizIcon(String topic) {
    switch (topic.toLowerCase()) {
      case 'traffic lights':
        return Icons.traffic;
      case 'traffic signs':
        return Icons.sign_language;
      case 'safety rules':
        return Icons.security;
      case 'bicycle safety':
        return Icons.pedal_bike;
      case 'comprehensive':
        return Icons.school;
      case 'advanced rules':
        return Icons.emoji_events;
      default:
        return Icons.quiz;
    }
  }

  void _startQuiz(Quiz quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(quiz: quiz),
      ),
    );
  }

  void _showUserProfile(BuildContext context, UserService userService) {
    final user = userService.currentUser!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getGradeBackgroundColor(user.grade).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _getGradeEmoji(user.grade),
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 12),
            const Text('My Profile'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileRow('Name', user.name, Icons.person),
            _buildProfileRow('Grade', 'Grade ${user.grade}', Icons.school),
            _buildProfileRow('Quizzes Done', '${user.totalQuizzesCompleted}', Icons.quiz),
            _buildProfileRow('Score Average', '${user.overallAccuracy.toStringAsFixed(1)}%', Icons.trending_up),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              userService.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}