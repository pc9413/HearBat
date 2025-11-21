import 'package:flutter/material.dart';
import 'gamification_db.dart';
import 'player_profile_model.dart';
import 'achievement_model.dart';
import 'companion_model.dart';
import 'daily_challenge_model.dart';
import 'companion_ai_service.dart';

class GamificationProvider with ChangeNotifier {
  final GamificationDatabase _db = GamificationDatabase();
  final CompanionAIService _aiService = CompanionAIService();

  PlayerProfile? _profile;
  List<Achievement> _achievements = [];
  Companion? _companion;
  List<DailyChallenge> _dailyChallenges = [];

  bool _isInitialized = false;

  // Getters
  PlayerProfile? get profile => _profile;
  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();
  Companion? get companion => _companion;
  List<DailyChallenge> get dailyChallenges => _dailyChallenges;
  bool get isInitialized => _isInitialized;

  // Initialize gamification system
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadProfile();
      await _loadAchievements();
      await _loadCompanion();
      await _loadDailyChallenges();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing gamification: $e');
    }
  }

  Future<void> _loadProfile() async {
    _profile = await _db.getPlayerProfile();
  }

  Future<void> _loadAchievements() async {
    _achievements = await _db.getAllAchievements();
  }

  Future<void> _loadCompanion() async {
    _companion = await _db.getCompanion();
  }

  Future<void> _loadDailyChallenges() async {
    _dailyChallenges = await _db.getTodaysChallenges();
  }

  // XP and Level Methods
  Future<void> awardXP(int xp, {String? reason}) async {
    if (_profile == null) await _loadProfile();

    final oldLevel = _profile!.level;
    await _db.addXP(xp);
    await _loadProfile();

    // Check for level up
    if (_profile!.level > oldLevel) {
      await _handleLevelUp(oldLevel, _profile!.level);
    }

    notifyListeners();
  }

  Future<void> _handleLevelUp(int oldLevel, int newLevel) async {
    // Celebrate level up with companion
    if (_companion != null) {
      final message = await _aiService.generateResponse(
        userMessage: 'I leveled up!',
        context: 'level_up',
        contextData: {
          'oldLevel': oldLevel,
          'newLevel': newLevel,
          'newTitle': LevelSystem.titleForLevel(newLevel),
        },
      );
      // Companion message is already saved by the AI service
    }
  }

  // Achievement Methods
  Future<bool> unlockAchievement(String achievementId, {bool notify = true}) async {
    final unlocked = await _db.unlockAchievement(achievementId);

    if (unlocked) {
      await _loadAchievements();
      await _loadProfile(); // XP was awarded

      // Celebrate with companion
      final achievement = _achievements.firstWhere((a) => a.achievementId == achievementId);
      if (_companion != null && notify) {
        await _aiService.generateResponse(
          userMessage: 'I got a new achievement!',
          context: 'achievement',
          contextData: {
            'achievementName': achievement.name,
            'achievementDescription': achievement.description,
            'xpReward': achievement.xpReward,
          },
        );
      }

      notifyListeners();
      return true;
    }

    return false;
  }

  Future<void> checkAchievements({
    int? currentStreak,
    int? moduleAccuracy,
    bool? moduleCompleted,
    int? totalPracticeTime,
  }) async {
    // Check streak achievements
    if (currentStreak != null) {
      if (currentStreak >= 100) await unlockAchievement('streak_100', notify: false);
      if (currentStreak >= 30) await unlockAchievement('streak_30', notify: false);
      if (currentStreak >= 7) await unlockAchievement('streak_7', notify: false);
      if (currentStreak >= 3) await unlockAchievement('streak_3', notify: false);
    }

    // Check accuracy achievements
    if (moduleAccuracy != null) {
      if (moduleAccuracy >= 100) await unlockAchievement('perfect_score');
      if (moduleAccuracy >= 90) await unlockAchievement('accuracy_90', notify: false);
      if (moduleAccuracy >= 80) await unlockAchievement('accuracy_80', notify: false);
    }

    // Check completion achievements
    if (moduleCompleted == true && _profile != null) {
      if (_profile!.totalModulesCompleted == 1) {
        await unlockAchievement('first_module');
      }
    }

    // Check practice time achievements
    if (totalPracticeTime != null) {
      if (totalPracticeTime >= 180000) await unlockAchievement('practice_50hr', notify: false); // 50 hours
      if (totalPracticeTime >= 36000) await unlockAchievement('practice_10hr', notify: false); // 10 hours
      if (totalPracticeTime >= 3600) await unlockAchievement('practice_1hr', notify: false); // 1 hour
    }
  }

  // Daily Challenge Methods
  Future<void> updateChallengeProgress(String challengeId, int progress) async {
    await _db.updateChallengeProgress(challengeId, progress);
    await _loadDailyChallenges();
    await _loadProfile(); // XP might have been awarded
    notifyListeners();
  }

  Future<void> refreshDailyChallenges() async {
    await _loadDailyChallenges();
    notifyListeners();
  }

  // Track practice session
  Future<void> recordPracticeSession(int durationSeconds) async {
    if (_profile == null) return;

    // Update profile
    await _db.updatePlayerProfile(_profile!.copyWith(
      totalPracticeTime: _profile!.totalPracticeTime + durationSeconds,
    ));
    await _loadProfile();

    // Award XP for practice time (1 XP per minute)
    final xpEarned = (durationSeconds / 60).round();
    await awardXP(xpEarned, reason: 'practice_time');

    // Update practice time challenges
    for (final challenge in _dailyChallenges) {
      if (challenge.type == 'practice_time' && !challenge.isCompleted) {
        await updateChallengeProgress(
          challenge.challengeId,
          challenge.currentProgress + durationSeconds,
        );
      }
    }

    // Check achievements
    await checkAchievements(totalPracticeTime: _profile!.totalPracticeTime);

    notifyListeners();
  }

  // Track module completion
  Future<void> recordModuleCompletion({
    required String moduleName,
    required int score,
    required int maxScore,
  }) async {
    if (_profile == null) return;

    final accuracy = ((score / maxScore) * 100).round();
    final isPerfect = score == maxScore;

    // Update profile
    await _db.updatePlayerProfile(_profile!.copyWith(
      totalModulesCompleted: _profile!.totalModulesCompleted + 1,
      totalPerfectScores: isPerfect
          ? _profile!.totalPerfectScores + 1
          : _profile!.totalPerfectScores,
    ));
    await _loadProfile();

    // Award XP
    int xpEarned = LevelSystem.XP_MODULE_COMPLETE;
    if (isPerfect) xpEarned += LevelSystem.XP_PERFECT_SCORE;
    if (accuracy >= 90) xpEarned += LevelSystem.XP_ACCURACY_BONUS;
    await awardXP(xpEarned, reason: 'module_complete');

    // Update module completion challenges
    for (final challenge in _dailyChallenges) {
      if (challenge.type == 'module_complete' && !challenge.isCompleted) {
        await updateChallengeProgress(
          challenge.challengeId,
          challenge.currentProgress + 1,
        );
      }
    }

    // Update accuracy challenges
    for (final challenge in _dailyChallenges) {
      if (challenge.type == 'accuracy' && !challenge.isCompleted) {
        if (accuracy >= challenge.targetValue) {
          await updateChallengeProgress(challenge.challengeId, challenge.targetValue);
        }
      }
    }

    // Check achievements
    await checkAchievements(
      moduleAccuracy: accuracy,
      moduleCompleted: true,
    );

    // Celebrate with companion
    if (_companion != null) {
      await _aiService.generateResponse(
        userMessage: 'I completed a module!',
        context: 'module_complete',
        contextData: {
          'moduleName': moduleName,
          'score': score,
          'maxScore': maxScore,
          'accuracy': accuracy,
        },
      );
      await _loadCompanion();
    }

    notifyListeners();
  }

  // Companion Methods
  Future<void> updateCompanionName(String name) async {
    if (_companion == null) return;

    await _db.updateCompanion(_companion!.copyWith(name: name));
    await _loadCompanion();
    notifyListeners();
  }

  Future<void> updateCompanionPersonality(String personality) async {
    if (_companion == null) return;

    await _db.updateCompanion(_companion!.copyWith(personality: personality));
    await _loadCompanion();
    notifyListeners();
  }
}
