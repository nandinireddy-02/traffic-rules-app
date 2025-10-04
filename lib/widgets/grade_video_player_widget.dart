import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/video_learning_service.dart';
import '../services/realtime_stats_service.dart';
import 'local_video_player_widget.dart';

class GradeVideoPlayerWidget extends StatefulWidget {
  final VideoLearningData video;
  final VoidCallback? onVideoCompleted;

  const GradeVideoPlayerWidget({
    super.key,
    required this.video,
    this.onVideoCompleted,
  });

  @override
  State<GradeVideoPlayerWidget> createState() => _GradeVideoPlayerWidgetState();
}

class _GradeVideoPlayerWidgetState extends State<GradeVideoPlayerWidget> {
  bool _isVideoWatched = false;

  @override
  void initState() {
    super.initState();
    _isVideoWatched = widget.video.isWatched;
  }

  void _markVideoAsWatched() async {
    if (!_isVideoWatched) {
      setState(() {
        _isVideoWatched = true;
      });
      
      // Mark in the service
      await context.read<VideoLearningService>().markVideoAsWatched(widget.video.id);
      
      // Track in real-time stats
      final statsService = context.read<RealtimeStatsService>();
      await statsService.recordVideoCompleted(widget.video.id, widget.video.title);
      
      // Callback for parent widgets
      widget.onVideoCompleted?.call();
    }
  }

  void _showVideoDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.play_circle, color: _getGradeColor(widget.video.gradeLevel)),
            const SizedBox(width: 8),
            Text('🎥 Grade ${widget.video.gradeLevel}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.video.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(widget.video.description),
            const SizedBox(height: 16),
            const Text('🚧 Video content coming soon! 📹\n\nFor now, you can mark this as watched to proceed with quizzes.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _markVideoAsWatched();
            },
            child: const Text('Mark as Watched'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(int grade) {
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

  @override
  Widget build(BuildContext context) {
    // If this is a local video file, use the local video player
    if (widget.video.videoUrl.startsWith('assets/')) {
      return LocalVideoPlayerWidget(
        video: widget.video,
        onVideoCompleted: widget.onVideoCompleted,
      );
    }
    
    // Otherwise, use the placeholder dialog approach
    final gradeColor = _getGradeColor(widget.video.gradeLevel);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradeColor, gradeColor.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.play_circle_filled, 
                      color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.video.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Topic: ${widget.video.topic}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isVideoWatched)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                ],
              ),
            ),
            
            // Video Player Area - Click to Watch
            GestureDetector(
              onTap: _showVideoDialog,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gradeColor.withValues(alpha: 0.7), gradeColor.withValues(alpha: 0.5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCA0MCA0MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPGNpcmNsZSBjeD0iMjAiIGN5PSIyMCIgcj0iMiIgZmlsbD0icmdiYSgyNTUsIDI1NSwgMjU1LCAwLjEpIi8+Cjwvc3ZnPgo='
                            ),
                            repeat: ImageRepeat.repeat,
                          ),
                        ),
                      ),
                    ),
                    // Play button and text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isVideoWatched ? Icons.replay : Icons.play_arrow,
                            size: 30,
                            color: gradeColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _isVideoWatched ? '✅ Watch Again' : '🎥 Watch Video',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Description and Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isVideoWatched ? Colors.green.shade50 : Colors.orange.shade50,
                border: Border(
                  top: BorderSide(
                    color: _isVideoWatched ? Colors.green : Colors.orange,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _isVideoWatched ? Icons.check_circle : Icons.access_time,
                        color: _isVideoWatched ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _isVideoWatched 
                              ? '✨ Video completed!' 
                              : '👀 Tap to watch and unlock quizzes!',
                          style: TextStyle(
                            color: _isVideoWatched ? Colors.green.shade700 : Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for showing video learning progress summary
class VideoLearningProgressWidget extends StatelessWidget {
  final int gradeLevel;
  final double completionPercentage;
  final bool areQuizzesUnlocked;
  
  const VideoLearningProgressWidget({
    super.key,
    required this.gradeLevel,
    required this.completionPercentage,
    required this.areQuizzesUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: areQuizzesUnlocked 
              ? [Colors.green.shade100, Colors.green.shade50]
              : [Colors.orange.shade100, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: areQuizzesUnlocked ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                areQuizzesUnlocked ? Icons.video_library : Icons.play_circle,
                size: 24,
                color: areQuizzesUnlocked ? Colors.green.shade700 : Colors.orange.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Grade $gradeLevel Video Learning',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: areQuizzesUnlocked ? Colors.green.shade700 : Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress bar
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: completionPercentage,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    areQuizzesUnlocked ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(completionPercentage * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: areQuizzesUnlocked ? Colors.green.shade700 : Colors.orange.shade700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Status message
          Text(
            areQuizzesUnlocked 
                ? '🎉 Great! You\'ve watched videos and unlocked quizzes!'
                : '📹 Watch at least one video to unlock quizzes!',
            style: TextStyle(
              fontSize: 12,
              color: areQuizzesUnlocked ? Colors.green.shade700 : Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}