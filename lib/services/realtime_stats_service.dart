import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RealtimeStatsService extends ChangeNotifier {
  // Stats counters
  int _videosCompleted = 0;
  int _quizzesAttempted = 0;
  int _quizzesCompleted = 0;
  double _totalScore = 0.0;
  int _currentStreak = 0;
  DateTime? _lastActivityDate;
  
  // Session stats (reset each app session)
  int _sessionVideosWatched = 0;
  int _sessionQuizzesCompleted = 0;
  
  SharedPreferences? _prefs;
  
  // Getters for stats
  int get videosCompleted => _videosCompleted;
  int get quizzesAttempted => _quizzesAttempted;
  int get quizzesCompleted => _quizzesCompleted;
  double get averageScore => _quizzesCompleted > 0 ? _totalScore / _quizzesCompleted : 0.0;
  int get currentStreak => _currentStreak;
  int get sessionVideosWatched => _sessionVideosWatched;
  int get sessionQuizzesCompleted => _sessionQuizzesCompleted;
  
  // Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadStats();
  }
  
  // Load stats from SharedPreferences
  Future<void> _loadStats() async {
    _videosCompleted = _prefs?.getInt('stats_videos_completed') ?? 0;
    _quizzesAttempted = _prefs?.getInt('stats_quizzes_attempted') ?? 0;
    _quizzesCompleted = _prefs?.getInt('stats_quizzes_completed') ?? 0;
    _totalScore = _prefs?.getDouble('stats_total_score') ?? 0.0;
    _currentStreak = _prefs?.getInt('stats_current_streak') ?? 0;
    
    final lastActivityMs = _prefs?.getInt('stats_last_activity') ?? 0;
    if (lastActivityMs > 0) {
      _lastActivityDate = DateTime.fromMillisecondsSinceEpoch(lastActivityMs);
    }
    
    // Reset session counters
    _sessionVideosWatched = 0;
    _sessionQuizzesCompleted = 0;
    
    notifyListeners();
  }
  
  // Save stats to SharedPreferences
  Future<void> _saveStats() async {
    await _prefs?.setInt('stats_videos_completed', _videosCompleted);
    await _prefs?.setInt('stats_quizzes_attempted', _quizzesAttempted);
    await _prefs?.setInt('stats_quizzes_completed', _quizzesCompleted);
    await _prefs?.setDouble('stats_total_score', _totalScore);
    await _prefs?.setInt('stats_current_streak', _currentStreak);
    
    if (_lastActivityDate != null) {
      await _prefs?.setInt('stats_last_activity', _lastActivityDate!.millisecondsSinceEpoch);
    }
  }
  
  // Record video completion
  Future<void> recordVideoCompleted(String videoId, String videoTitle) async {
    _videosCompleted++;
    _sessionVideosWatched++;
    _updateActivity();
    
    await _saveStats();
    notifyListeners();
    
    if (kDebugMode) {
      print('📹 Video completed: $videoTitle (Total: $_videosCompleted)');
    }
  }
  
  // Record quiz attempt
  Future<void> recordQuizAttempted(String quizId, String quizTitle) async {
    _quizzesAttempted++;
    _updateActivity();
    
    await _saveStats();
    notifyListeners();
    
    if (kDebugMode) {
      print('🎯 Quiz attempted: $quizTitle (Total: $_quizzesAttempted)');
    }
  }
  
  // Record quiz completion
  Future<void> recordQuizCompleted(String quizId, String quizTitle, double score, double maxScore) async {
    _quizzesCompleted++;
    _sessionQuizzesCompleted++;
    _totalScore += (score / maxScore) * 100; // Convert to percentage
    _updateActivity();
    
    await _saveStats();
    notifyListeners();
    
    if (kDebugMode) {
      final percentage = (score / maxScore) * 100;
      print('✅ Quiz completed: $quizTitle - Score: ${percentage.toStringAsFixed(1)}% (Avg: ${averageScore.toStringAsFixed(1)}%)');
    }
  }
  
  // Update activity and streak
  void _updateActivity() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    if (_lastActivityDate == null) {
      // First activity
      _currentStreak = 1;
      _lastActivityDate = todayDate;
    } else {
      final lastDate = DateTime(_lastActivityDate!.year, _lastActivityDate!.month, _lastActivityDate!.day);
      final daysDifference = todayDate.difference(lastDate).inDays;
      
      if (daysDifference == 0) {
        // Same day, keep streak
      } else if (daysDifference == 1) {
        // Consecutive day, increment streak
        _currentStreak++;
        _lastActivityDate = todayDate;
      } else {
        // Streak broken, reset
        _currentStreak = 1;
        _lastActivityDate = todayDate;
      }
    }
  }
  
  // Get formatted stats for display
  Map<String, dynamic> getFormattedStats() {
    return {
      'videosCompleted': _videosCompleted,
      'quizzesAttempted': _quizzesAttempted,
      'quizzesCompleted': _quizzesCompleted,
      'averageScore': averageScore,
      'currentStreak': _currentStreak,
      'sessionVideosWatched': _sessionVideosWatched,
      'sessionQuizzesCompleted': _sessionQuizzesCompleted,
    };
  }
  
  // Reset all stats (for testing or user request)
  Future<void> resetStats() async {
    _videosCompleted = 0;
    _quizzesAttempted = 0;
    _quizzesCompleted = 0;
    _totalScore = 0.0;
    _currentStreak = 0;
    _lastActivityDate = null;
    _sessionVideosWatched = 0;
    _sessionQuizzesCompleted = 0;
    
    await _saveStats();
    notifyListeners();
    
    if (kDebugMode) {
      print('🔄 Stats reset');
    }
  }
  
  // Get session summary
  String getSessionSummary() {
    if (_sessionVideosWatched == 0 && _sessionQuizzesCompleted == 0) {
      return 'No activity this session';
    }
    
    final parts = <String>[];
    if (_sessionVideosWatched > 0) {
      parts.add('$_sessionVideosWatched video${_sessionVideosWatched == 1 ? '' : 's'} watched');
    }
    if (_sessionQuizzesCompleted > 0) {
      parts.add('$_sessionQuizzesCompleted quiz${_sessionQuizzesCompleted == 1 ? '' : 'zes'} completed');
    }
    
    return 'This session: ${parts.join(', ')}';
  }
}