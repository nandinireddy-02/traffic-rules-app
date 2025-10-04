import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/video_learning_service.dart';
import '../services/realtime_stats_service.dart';

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
  Duration _lastPosition = Duration.zero;

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
      
      // Load saved position
      await _loadVideoProgress();
      
      _controller!.addListener(() {
        // Save progress every 5 seconds
        final currentPosition = _controller!.value.position;
        if (currentPosition.inSeconds % 5 == 0 && currentPosition != _lastPosition) {
          _saveVideoProgress();
          _lastPosition = currentPosition;
        }
        
        // Check if video completed
        if (_controller!.value.position >= _controller!.value.duration) {
          _markVideoAsWatched();
          _clearVideoProgress(); // Clear saved position when completed
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
      
      // Track in real-time stats
      final statsService = context.read<RealtimeStatsService>();
      await statsService.recordVideoCompleted(widget.video.id, widget.video.title);
      
      // Callback for parent widgets
      widget.onVideoCompleted?.call();
      
      // Show completion message with stats
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '✅ Great job! Video completed! (${statsService.videosCompleted} total videos watched)',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
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

  // Video progress tracking methods
  Future<void> _loadVideoProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positionMs = prefs.getInt('video_position_${widget.video.id}') ?? 0;
      if (positionMs > 0 && _controller != null) {
        final savedPosition = Duration(milliseconds: positionMs);
        // Only seek if we're not close to the end (avoid auto-completion)
        if (savedPosition < _controller!.value.duration - const Duration(seconds: 10)) {
          await _controller!.seekTo(savedPosition);
          _lastPosition = savedPosition;
          
          // Show resume notification
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Resumed from ${_formatDuration(savedPosition)} ⏯️'),
                    ),
                  ],
                ),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading video progress: $e');
    }
  }

  Future<void> _saveVideoProgress() async {
    try {
      if (_controller != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('video_position_${widget.video.id}', 
                           _controller!.value.position.inMilliseconds);
      }
    } catch (e) {
      debugPrint('Error saving video progress: $e');
    }
  }

  Future<void> _clearVideoProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('video_position_${widget.video.id}');
    } catch (e) {
      debugPrint('Error clearing video progress: $e');
    }
  }

  // Helper method to format duration for display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
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
                              : 'Tap to play this traffic safety video!',
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