import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsBottomSheet(),
          ),
        ],
      ),
      body: Consumer<UserService>(
        builder: (context, userService, child) {
          if (!userService.isLoggedIn) {
            return const Center(
              child: Text('Please log in to view your profile'),
            );
          }

          final user = userService.currentUser!;
          final stats = userService.getStudyStatistics();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileHeader(user, stats),
                const SizedBox(height: 24),
                _buildStatisticsCards(stats),
                const SizedBox(height: 24),
                _buildAchievements(user, userService),
                const SizedBox(height: 24),
                _buildRecentActivity(user),
                const SizedBox(height: 24),
                _buildTopicProgress(user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(User user, Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (user.email.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _getGradeColor(stats['grade']).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getGradeColor(stats['grade']),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.school,
                    color: _getGradeColor(stats['grade']),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Grade: ${stats['grade']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getGradeColor(stats['grade']),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Quizzes Completed',
                '${stats['totalQuizzes']}',
                Icons.quiz,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Overall Accuracy',
                '${stats['accuracy'].toStringAsFixed(1)}%',
                Icons.analytics,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Current Streak',
                '${stats['currentStreak']} days',
                Icons.local_fire_department,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Achievements',
                '${stats['badges']}',
                Icons.emoji_events,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements(User user, UserService userService) {
    final allBadges = userService.getAllBadges();
    final achievedBadges = user.achievedBadges;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${achievedBadges.length}/${allBadges.length}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: allBadges.length,
              itemBuilder: (context, index) {
                final badgeId = allBadges.keys.elementAt(index);
                final badgeName = allBadges[badgeId]!;
                final isAchieved = achievedBadges.contains(badgeId);

                return _buildBadgeItem(badgeId, badgeName, isAchieved);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(String badgeId, String badgeName, bool isAchieved) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isAchieved 
                ? Colors.amber.withValues(alpha: 0.2) 
                : Colors.grey.withValues(alpha: 0.2),
            border: Border.all(
              color: isAchieved ? Colors.amber : Colors.grey,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.emoji_events,
            color: isAchieved ? Colors.amber : Colors.grey,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getBadgeDisplayName(badgeId),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isAchieved ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActivityItem(
                  Icons.quiz,
                  'Quizzes Completed',
                  '${user.totalQuizzesCompleted}',
                  Colors.blue,
                ),
                const Divider(),
                _buildActivityItem(
                  Icons.check_circle,
                  'Correct Answers',
                  '${user.totalCorrectAnswers}',
                  Colors.green,
                ),
                const Divider(),
                _buildActivityItem(
                  Icons.schedule,
                  'Last Active',
                  _formatDate(user.lastActiveDate),
                  Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicProgress(User user) {
    final topicProgress = user.topicProgress;
    
    if (topicProgress.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Topic Progress',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: topicProgress.entries.map((entry) {
                final topic = entry.key;
                final correct = entry.value;
                final progress = (correct / 10).clamp(0.0, 1.0);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            topic,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '$correct correct',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
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

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                _showEditProfileDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification settings coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help section coming soon!')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => _showLogoutDialog(),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final userService = Provider.of<UserService>(context, listen: false);
    final user = userService.currentUser!;
    
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                userService.updateUserProfile(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final userService = Provider.of<UserService>(context, listen: false);
              userService.logout();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'B+':
      case 'B':
        return Colors.blue;
      case 'C+':
      case 'C':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  String _getBadgeDisplayName(String badgeId) {
    switch (badgeId) {
      case 'first_quiz':
        return 'First Quiz';
      case 'quiz_master':
        return 'Quiz Master';
      case 'accuracy_expert':
        return 'Accuracy Expert';
      case 'streak_scholar':
        return 'Streak Scholar';
      case 'perfect_score':
        return 'Perfect Score';
      case 'topic_explorer':
        return 'Topic Explorer';
      case 'honor_student':
        return 'Honor Student';
      case 'speed_demon':
        return 'Speed Demon';
      case 'persistent_learner':
        return 'Persistent';
      case 'traffic_expert':
        return 'Traffic Expert';
      default:
        return badgeId;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}