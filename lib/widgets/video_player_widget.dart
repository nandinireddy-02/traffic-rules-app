import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final String? videoDescription;
  final VoidCallback? onVideoWatched;

  const VideoPlayerWidget({
    super.key,
    this.videoUrl,
    this.videoDescription,
    this.onVideoWatched,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool _isVideoWatched = false;

  void _markVideoAsWatched() {
    if (!_isVideoWatched) {
      setState(() {
        _isVideoWatched = true;
      });
      widget.onVideoWatched?.call();
    }
  }

  void _openVideoInNewTab() {
    if (widget.videoUrl != null && kIsWeb) {
      html.window.open(widget.videoUrl!, '_blank');
      _markVideoAsWatched(); // Mark as watched when clicked
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            // Video Description Header
            if (widget.videoDescription != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.purple.shade400],
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
                      child: Text(
                        widget.videoDescription!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Video Player Area - Click to Watch
            GestureDetector(
              onTap: _openVideoInNewTab,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.pink.shade300],
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
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: const NetworkImage(
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
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '🎥 Click to Watch Video',
                            style: TextStyle(
                              fontSize: 16,
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

            // Watch Status Indicator
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
              child: Row(
                children: [
                  Icon(
                    _isVideoWatched ? Icons.check_circle : Icons.access_time,
                    color: _isVideoWatched ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isVideoWatched 
                        ? '✨ Great! You watched the video!' 
                        : '👀 Click above to watch the video!',
                    style: TextStyle(
                      color: _isVideoWatched ? Colors.green.shade700 : Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
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
}

// Widget for showing video learning progress
class VideoLearningBadge extends StatelessWidget {
  final bool hasWatchedVideo;
  
  const VideoLearningBadge({
    super.key,
    required this.hasWatchedVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasWatchedVideo ? Colors.green.shade100 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasWatchedVideo ? Colors.green : Colors.blue,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasWatchedVideo ? Icons.video_library : Icons.play_circle,
            size: 16,
            color: hasWatchedVideo ? Colors.green.shade700 : Colors.blue.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            hasWatchedVideo ? 'Video Watched!' : 'Has Video',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: hasWatchedVideo ? Colors.green.shade700 : Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}