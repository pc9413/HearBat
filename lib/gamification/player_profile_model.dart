class PlayerProfile {
  final int? id;
  final int currentXP;
  final int level;
  final int totalPracticeTime; // in seconds
  final int totalModulesCompleted;
  final int totalPerfectScores;
  final DateTime createdAt;
  final DateTime lastUpdated;

  PlayerProfile({
    this.id,
    required this.currentXP,
    required this.level,
    this.totalPracticeTime = 0,
    this.totalModulesCompleted = 0,
    this.totalPerfectScores = 0,
    DateTime? createdAt,
    DateTime? lastUpdated,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'current_xp': currentXP,
      'level': level,
      'total_practice_time': totalPracticeTime,
      'total_modules_completed': totalModulesCompleted,
      'total_perfect_scores': totalPerfectScores,
      'created_at': createdAt.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory PlayerProfile.fromMap(Map<String, dynamic> map) {
    return PlayerProfile(
      id: map['id'],
      currentXP: map['current_xp'],
      level: map['level'],
      totalPracticeTime: map['total_practice_time'] ?? 0,
      totalModulesCompleted: map['total_modules_completed'] ?? 0,
      totalPerfectScores: map['total_perfect_scores'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      lastUpdated: DateTime.parse(map['last_updated']),
    );
  }

  PlayerProfile copyWith({
    int? currentXP,
    int? level,
    int? totalPracticeTime,
    int? totalModulesCompleted,
    int? totalPerfectScores,
  }) {
    return PlayerProfile(
      id: this.id,
      currentXP: currentXP ?? this.currentXP,
      level: level ?? this.level,
      totalPracticeTime: totalPracticeTime ?? this.totalPracticeTime,
      totalModulesCompleted: totalModulesCompleted ?? this.totalModulesCompleted,
      totalPerfectScores: totalPerfectScores ?? this.totalPerfectScores,
      createdAt: this.createdAt,
      lastUpdated: DateTime.now(),
    );
  }

  // Calculate XP needed for next level (exponential curve)
  int get xpForNextLevel => LevelSystem.xpForLevel(level + 1);

  // Calculate XP progress to next level
  double get progressToNextLevel {
    final currentLevelXP = LevelSystem.xpForLevel(level);
    final nextLevelXP = LevelSystem.xpForLevel(level + 1);
    final xpInCurrentLevel = currentXP - currentLevelXP;
    final xpNeededForLevel = nextLevelXP - currentLevelXP;
    return xpInCurrentLevel / xpNeededForLevel;
  }

  String get title => LevelSystem.titleForLevel(level);
}

class LevelSystem {
  // XP required for each level (exponential growth)
  static int xpForLevel(int level) {
    if (level <= 1) return 0;
    // Formula: 100 * (level - 1)^1.5
    return (100 * Math.pow(level - 1, 1.5)).round();
  }

  // Get level from total XP
  static int levelFromXP(int xp) {
    int level = 1;
    while (xpForLevel(level + 1) <= xp) {
      level++;
    }
    return level;
  }

  // Title for each level range
  static String titleForLevel(int level) {
    if (level >= 50) return 'Legendary Listener';
    if (level >= 40) return 'Master of Sound';
    if (level >= 30) return 'Hearing Expert';
    if (level >= 25) return 'Sound Virtuoso';
    if (level >= 20) return 'Audio Adept';
    if (level >= 15) return 'Skilled Listener';
    if (level >= 10) return 'Practiced Ear';
    if (level >= 5) return 'Apprentice Listener';
    return 'Novice Listener';
  }

  // XP rewards for different actions
  static const int XP_MODULE_COMPLETE = 50;
  static const int XP_PERFECT_SCORE = 100;
  static const int XP_DAILY_GOAL = 25;
  static const int XP_EXERCISE_COMPLETE = 10;
  static const int XP_STREAK_MILESTONE = 50; // per milestone
  static const int XP_COMPANION_CHAT = 5;
  static const int XP_ACCURACY_BONUS = 20; // for 90%+
}

// Helper import for math
import 'dart:math' as Math;
