import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoLearningData {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final int gradeLevel;
  final String topic;
  final bool isWatched;

  VideoLearningData({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.gradeLevel,
    required this.topic,
    this.isWatched = false,
  });

  VideoLearningData copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    int? gradeLevel,
    String? topic,
    bool? isWatched,
  }) {
    return VideoLearningData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      topic: topic ?? this.topic,
      isWatched: isWatched ?? this.isWatched,
    );
  }
}

class VideoLearningService extends ChangeNotifier {
  List<VideoLearningData> _videos = [];
  Set<String> _watchedVideos = {};
  SharedPreferences? _prefs;

  List<VideoLearningData> get videos => _videos;
  Set<String> get watchedVideos => _watchedVideos;

  // Initialize the service with default videos
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadWatchedVideos();
    await _loadDefaultVideos();
    notifyListeners();
  }

  // Load watched video IDs from shared preferences
  Future<void> _loadWatchedVideos() async {
    final watchedList = _prefs?.getStringList('watched_videos') ?? [];
    _watchedVideos = watchedList.toSet();
  }

  // Save watched video IDs to shared preferences
  Future<void> _saveWatchedVideos() async {
    await _prefs?.setStringList('watched_videos', _watchedVideos.toList());
  }

  // Load default video content for all grades
  Future<void> _loadDefaultVideos() async {
    _videos = [
      // Grade 2 Videos
      VideoLearningData(
        id: 'video_g2_traffic_lights',
        title: '🚦 Understanding Traffic Lights',
        description: 'Learn what Red, Yellow, and Green lights mean!',
        videoUrl: 'assets/videos/grade2_traffic_lights.mp4',
        gradeLevel: 2,
        topic: 'Traffic Lights',
      ),
      VideoLearningData(
        id: 'video_g2_crossing_road',
        title: '🚶‍♂️ How to Cross the Road Safely',
        description: 'Look left, look right, then cross carefully!',
        videoUrl: 'assets/videos/grade2_crossing_road.mp4',
        gradeLevel: 2,
        topic: 'Road Safety',
      ),

      // Grade 3 Videos
      VideoLearningData(
        id: 'video_g3_traffic_signs',
        title: '🛑 Important Traffic Signs',
        description: 'Learn about STOP signs and other important signs!',
        videoUrl: 'assets/videos/grade3_traffic_signs.mp4',
        gradeLevel: 3,
        topic: 'Traffic Signs',
      ),
      VideoLearningData(
        id: 'video_g3_pedestrian_safety',
        title: '👨‍👩‍👧‍👦 Walking Safely with Family',
        description: 'Safety tips when walking with grown-ups!',
        videoUrl: 'assets/videos/grade3_pedestrian_safety.mp4',
        gradeLevel: 3,
        topic: 'Pedestrian Safety',
      ),

      // Grade 4 Videos
      VideoLearningData(
        id: 'video_g4_road_signs',
        title: '🚸 Road Signs and Their Meanings',
        description: 'Understanding different road signs and symbols!',
        videoUrl: 'PLACEHOLDER_GRADE_4_ROAD_SIGNS',
        gradeLevel: 4,
        topic: 'Road Signs',
      ),
      VideoLearningData(
        id: 'video_g4_bicycle_safety',
        title: '🚲 Bicycle Safety Rules',
        description: 'How to ride your bike safely on roads!',
        videoUrl: 'PLACEHOLDER_GRADE_4_BICYCLE',
        gradeLevel: 4,
        topic: 'Bicycle Safety',
      ),

      // Grade 5 Videos
      VideoLearningData(
        id: 'video_g5_traffic_rules',
        title: '📋 Basic Traffic Rules',
        description: 'Essential traffic rules everyone should know!',
        videoUrl: 'PLACEHOLDER_GRADE_5_TRAFFIC_RULES',
        gradeLevel: 5,
        topic: 'Traffic Rules',
      ),
      VideoLearningData(
        id: 'video_g5_emergency_situations',
        title: '🚨 What to Do in Emergencies',
        description: 'Staying safe during traffic emergencies!',
        videoUrl: 'PLACEHOLDER_GRADE_5_EMERGENCY',
        gradeLevel: 5,
        topic: 'Emergency Safety',
      ),

      // Grade 6 Videos
      VideoLearningData(
        id: 'video_g6_advanced_signs',
        title: '🚧 Advanced Traffic Signs',
        description: 'More complex traffic signs and regulations!',
        videoUrl: 'PLACEHOLDER_GRADE_6_ADVANCED_SIGNS',
        gradeLevel: 6,
        topic: 'Advanced Signs',
      ),
      VideoLearningData(
        id: 'video_g6_right_of_way',
        title: '👥 Understanding Right of Way',
        description: 'Who goes first at intersections and crosswalks!',
        videoUrl: 'PLACEHOLDER_GRADE_6_RIGHT_OF_WAY',
        gradeLevel: 6,
        topic: 'Right of Way',
      ),

      // Grade 7 Videos
      VideoLearningData(
        id: 'video_g7_intersection_safety',
        title: '🛣️ Intersection Safety',
        description: 'Navigating complex intersections safely!',
        videoUrl: 'PLACEHOLDER_GRADE_7_INTERSECTION',
        gradeLevel: 7,
        topic: 'Intersection Safety',
      ),
      VideoLearningData(
        id: 'video_g7_vehicle_signals',
        title: '🚗 Vehicle Signals and Communications',
        description: 'Understanding what vehicles are telling you!',
        videoUrl: 'PLACEHOLDER_GRADE_7_SIGNALS',
        gradeLevel: 7,
        topic: 'Vehicle Signals',
      ),

      // Grade 8 Videos
      VideoLearningData(
        id: 'video_g8_advanced_rules',
        title: '📖 Advanced Traffic Regulations',
        description: 'Complex traffic rules and scenarios!',
        videoUrl: 'PLACEHOLDER_GRADE_8_ADVANCED_RULES',
        gradeLevel: 8,
        topic: 'Advanced Rules',
      ),
      VideoLearningData(
        id: 'video_g8_road_conditions',
        title: '🌧️ Safety in Different Road Conditions',
        description: 'Adapting to weather and road conditions!',
        videoUrl: 'PLACEHOLDER_GRADE_8_CONDITIONS',
        gradeLevel: 8,
        topic: 'Road Conditions',
      ),

      // Grade 9 Videos
      VideoLearningData(
        id: 'video_g9_driver_preparation',
        title: '🚗 Preparing to Drive',
        description: 'Getting ready for driving responsibilities!',
        videoUrl: 'PLACEHOLDER_GRADE_9_DRIVER_PREP',
        gradeLevel: 9,
        topic: 'Driver Preparation',
      ),
      VideoLearningData(
        id: 'video_g9_traffic_laws',
        title: '⚖️ Traffic Laws and Consequences',
        description: 'Understanding traffic laws and their importance!',
        videoUrl: 'PLACEHOLDER_GRADE_9_TRAFFIC_LAWS',
        gradeLevel: 9,
        topic: 'Traffic Laws',
      ),

      // Grade 10 Videos
      VideoLearningData(
        id: 'video_g10_defensive_driving',
        title: '🛡️ Defensive Driving Concepts',
        description: 'Advanced defensive driving techniques!',
        videoUrl: 'PLACEHOLDER_GRADE_10_DEFENSIVE',
        gradeLevel: 10,
        topic: 'Defensive Driving',
      ),
      VideoLearningData(
        id: 'video_g10_real_world_scenarios',
        title: '🌍 Real-World Traffic Scenarios',
        description: 'Complex real-world traffic situations!',
        videoUrl: 'PLACEHOLDER_GRADE_10_SCENARIOS',
        gradeLevel: 10,
        topic: 'Real-World Scenarios',
      ),
    ];

    // Update watched status based on saved data
    _videos = _videos.map((video) {
      return video.copyWith(isWatched: _watchedVideos.contains(video.id));
    }).toList();
  }

  // Get videos for a specific grade
  List<VideoLearningData> getVideosForGrade(int grade) {
    return _videos.where((video) => video.gradeLevel == grade).toList();
  }

  // Mark a video as watched
  Future<void> markVideoAsWatched(String videoId) async {
    if (!_watchedVideos.contains(videoId)) {
      _watchedVideos.add(videoId);
      await _saveWatchedVideos();
      
      // Update the video object
      final index = _videos.indexWhere((video) => video.id == videoId);
      if (index != -1) {
        _videos[index] = _videos[index].copyWith(isWatched: true);
      }
      
      notifyListeners();
    }
  }

  // Check if user has watched all required videos for a grade
  bool hasWatchedAllVideosForGrade(int grade) {
    final gradeVideos = getVideosForGrade(grade);
    return gradeVideos.every((video) => _watchedVideos.contains(video.id));
  }

  // Get completion percentage for a grade
  double getGradeCompletionPercentage(int grade) {
    final gradeVideos = getVideosForGrade(grade);
    if (gradeVideos.isEmpty) return 1.0;
    
    final watchedCount = gradeVideos.where((video) => _watchedVideos.contains(video.id)).length;
    return watchedCount / gradeVideos.length;
  }

  // Check if quizzes should be unlocked for a grade
  bool areQuizzesUnlockedForGrade(int grade) {
    // For now, require watching at least one video to unlock quizzes
    // You can make this more restrictive (e.g., all videos) based on your requirements
    final gradeVideos = getVideosForGrade(grade);
    return gradeVideos.any((video) => _watchedVideos.contains(video.id));
  }

  // Update a video URL (for when you provide the actual YouTube link)
  Future<void> updateVideoUrl(String videoId, String newUrl) async {
    final index = _videos.indexWhere((video) => video.id == videoId);
    if (index != -1) {
      _videos[index] = _videos[index].copyWith(videoUrl: newUrl);
      notifyListeners();
    }
  }

  // Add or update multiple videos at once
  Future<void> updateMultipleVideoUrls(Map<String, String> videoUpdates) async {
    for (final entry in videoUpdates.entries) {
      await updateVideoUrl(entry.key, entry.value);
    }
  }

  // Reset all video progress (for testing or admin purposes)
  Future<void> resetVideoProgress() async {
    _watchedVideos.clear();
    await _saveWatchedVideos();
    
    _videos = _videos.map((video) => video.copyWith(isWatched: false)).toList();
    notifyListeners();
  }

  // Demo function to show how to add your YouTube video
  Future<void> updateGrade2TrafficLightsVideo(String youtubeUrl) async {
    await updateVideoUrl('video_g2_traffic_lights', youtubeUrl);
    // Video URL updated successfully
  }

  // Current Grade 2 Traffic Lights video (already integrated)
  String get grade2TrafficLightsUrl => 'https://youtu.be/aT61nwd5U-s?si=lgovLFXDRXeCqMpu';

  // Function to get all placeholder video IDs for easy reference
  List<String> getAllPlaceholderVideoIds() {
    return _videos
        .where((video) => video.videoUrl.startsWith('PLACEHOLDER'))
        .map((video) => video.id)
        .toList();
  }

  // Function to get video details for a specific ID (useful for debugging)
  VideoLearningData? getVideoById(String videoId) {
    try {
      return _videos.firstWhere((video) => video.id == videoId);
    } catch (e) {
      return null;
    }
  }
}