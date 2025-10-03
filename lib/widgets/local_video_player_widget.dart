import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../services/video_learning_service.dart';

class LocalVideoPlayerWidget extends StatefulWidget {
  final VideoLearningData video;
  final VoidCallback? onVideoCompleted;

  const LocalVideoPlayerWidget({
    super.key,
    required this.video,
    this.onVideoCompleted,
  });

  @override
  State<LocalVideoPlayerWidget> createState() => _LocalVideoPlayerWidgetState();
}

class _LocalVideoPlayerWidgetState extends State<LocalVideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isVideoWatched = false;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _isVideoWatched = widget.video.isWatched;
    if (widget.video.videoUrl.startsWith('assets/')) {
      _initializeLocalVideo();
    }
  }

  void _initializeLocalVideo() async {
    try {
      _controller = VideoPlayerController.asset(widget.video.videoUrl);
      await _controller!.initialize();
      
      _controller!.addListener(() {
        if (_controller!.value.position >= _controller!.value.duration) {
          // Video completed
          _markVideoAsWatched();
        }
      });
      
      setState(() {
        _isInitialized = true;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load video: $e';
        _isInitialized = false;
      });
    }
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

  void _togglePlayPause() {
    if (_controller != null && _isInitialized) {
      setState(() {
        if (_isPlaying) {
          _controller!.pause();
          _isPlaying = false;
        } else {
          _controller!.play();
          _isPlaying = true;
        }
      });
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
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
              color: Colors.black,
              child: _hasError
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : _isInitialized
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            // Video player
                            AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              child: VideoPlayer(_controller!),
                            ),
                            // Play/pause button overlay
                            if (!_isPlaying)
                              GestureDetector(
                                onTap: _togglePlayPause,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            // Video controls
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.7),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _togglePlayPause,
                                      child: Icon(
                                        _isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: VideoProgressIndicator(
                                        _controller!,
                                        allowScrubbing: true,
                                        colors: VideoProgressColors(
                                          playedColor: gradeColor,
                                          backgroundColor: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: gradeColor),
                              const SizedBox(height: 8),
                              const Text(
                                'Loading video...',
                                style: TextStyle(color: Colors.white),
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
                              : '🎬 Your downloaded traffic lights video is ready to play!',
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