import 'package:flutter/material.dart';

class StudyCenterScreen extends StatefulWidget {
  const StudyCenterScreen({super.key});

  @override
  State<StudyCenterScreen> createState() => _StudyCenterScreenState();
}

class _StudyCenterScreenState extends State<StudyCenterScreen> {
  final List<StudyTopic> topics = [
    StudyTopic(
      title: 'Traffic Signs & Symbols',
      description: 'Learn about different traffic signs and their meanings',
      icon: Icons.warning,
      color: Colors.red,
      lessons: [
        'Regulatory Signs',
        'Warning Signs',
        'Guide Signs',
        'Construction Signs',
      ],
    ),
    StudyTopic(
      title: 'Right of Way Rules',
      description: 'Understanding who goes first in different traffic situations',
      icon: Icons.merge_type,
      color: Colors.blue,
      lessons: [
        'Intersections',
        'Roundabouts',
        'Pedestrian Crossings',
        'Emergency Vehicles',
      ],
    ),
    StudyTopic(
      title: 'Speed Limits & Safety',
      description: 'Safe driving speeds and speed limit regulations',
      icon: Icons.speed,
      color: Colors.orange,
      lessons: [
        'Residential Areas',
        'School Zones',
        'Highway Driving',
        'Weather Conditions',
      ],
    ),
    StudyTopic(
      title: 'Parking Rules',
      description: 'Where and how to park legally and safely',
      icon: Icons.local_parking,
      color: Colors.green,
      lessons: [
        'Parallel Parking',
        'No Parking Zones',
        'Parking Meters',
        'Disability Parking',
      ],
    ),
    StudyTopic(
      title: 'Safety Equipment',
      description: 'Seat belts, airbags, and other safety features',
      icon: Icons.security,
      color: Colors.purple,
      lessons: [
        'Seat Belt Laws',
        'Child Safety Seats',
        'Motorcycle Helmets',
        'Vehicle Maintenance',
      ],
    ),
    StudyTopic(
      title: 'Emergency Procedures',
      description: 'What to do in emergency driving situations',
      icon: Icons.warning_amber,
      color: Colors.deepOrange,
      lessons: [
        'Brake Failure',
        'Tire Blowout',
        'Steering Problems',
        'Accident Procedures',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Center'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildTopicsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.school,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Master Traffic Rules',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Study comprehensive lessons on traffic rules and regulations. Each topic includes detailed explanations and real-world examples.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Study Topics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final topic = topics[index];
            return _buildTopicCard(topic);
          },
        ),
      ],
    );
  }

  Widget _buildTopicCard(StudyTopic topic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _openTopic(topic),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: topic.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      topic.icon,
                      color: topic.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          topic.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: topic.lessons.take(3).map((lesson) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: topic.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: topic.color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      lesson,
                      style: TextStyle(
                        color: topic.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (topic.lessons.length > 3) ...[
                const SizedBox(height: 8),
                Text(
                  '+${topic.lessons.length - 3} more lessons',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openTopic(StudyTopic topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicDetailScreen(topic: topic),
      ),
    );
  }
}

class StudyTopic {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> lessons;

  StudyTopic({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.lessons,
  });
}

class TopicDetailScreen extends StatelessWidget {
  final StudyTopic topic;

  const TopicDetailScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topic.title),
        backgroundColor: topic.color,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [topic.color.withValues(alpha: 0.1), topic.color.withValues(alpha: 0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(topic.icon, size: 64, color: topic.color),
                    const SizedBox(height: 16),
                    Text(
                      topic.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topic.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Lessons',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ...topic.lessons.asMap().entries.map((entry) {
              final index = entry.key;
              final lesson = entry.value;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: topic.color,
                    foregroundColor: Colors.white,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(lesson),
                  subtitle: const Text('Coming soon - Interactive lesson'),
                  trailing: const Icon(Icons.play_circle_outline),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Interactive lessons coming in future updates!'),
                      ),
                    );
                  },
                ),
              );
            }),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Practice quiz for ${topic.title} coming soon!'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: topic.color),
                child: const Text('Take Practice Quiz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}