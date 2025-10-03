import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:provider/provider.dart';
import '../services/video_learning_service.dart';

class WebVideoPlayer extends StatefulWidget {
  final VideoLearningData video;
  final VoidCallback? onVideoCompleted;

  const WebVideoPlayer({
    super.key,
    required this.video,
    this.onVideoCompleted,
  });

  @override
  State<WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<WebVideoPlayer> {
  late html.VideoElement _videoElement;
  String _viewId = '';
  bool _isVideoWatched = false;

  @override
  void initState() {
    super.initState();
    _isVideoWatched = widget.video.isWatched;
    _initializeVideo();
  }

  void _initializeVideo() {
    _viewId = 'video-${widget.video.id}';
    
    _videoElement = html.VideoElement()
      ..controls = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = '#000000';
    
    // Convert asset path to web URL
    String videoSrc = widget.video.videoUrl.replaceAll('assets/', 'assets/assets/');
    _videoElement.src = videoSrc;
    
    _videoElement.onEnded.listen((_) {
      _markVideoAsWatched();
    });
    
    // Register the video element
    ui.platformViewRegistry.registerViewFactory(
      _viewId,
      (int id) => _videoElement,
    );
  }

  void _markVideoAsWatched() async {
    if (!_isVideoWatched) {
      setState(() {
        _isVideoWatched = true;
      });
      
      // Mark in the service
      await context.read<VideoLearningService>().markVideoAsWatched(widget.video.id);
      
      // Callback for parent widgets
      widget.onVideoCompleted?.call();
      
      // Show completion message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '✅ Great job! Video completed and marked as watched!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Color _getGradeColor(int grade) {
    switch (grade) {
      case 2:
      case 3:
        return Colors.red.shade400;
      case 4:
      case 5:
        return Colors.orange.shade400;
      case 6:
      case 7:
        return Colors.blue.shade400;
      case 8:
      case 9:
      case 10:
        return Colors.indigo.shade500;
      default:
        return Colors.blue.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            
            // Video Player Area
            Container(
              height: 200,
              width: double.infinity,
              child: HtmlElementView(viewType: _viewId),
            ),

            // Description and Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isVideoWatched ? Colors.green.shade50 : Colors.blue.shade50,
                border: Border(
                  top: BorderSide(
                    color: _isVideoWatched ? Colors.green : gradeColor,
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
                        _isVideoWatched ? Icons.check_circle : Icons.play_circle_outline,
                        color: _isVideoWatched ? Colors.green : gradeColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _isVideoWatched 
                              ? '✨ Video completed! Well done!' 
                              : '🎬 Your local video is ready to play!',
                          style: TextStyle(
                            color: _isVideoWatched ? Colors.green.shade700 : gradeColor,
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