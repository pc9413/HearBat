import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'achievement_model.dart';
import 'player_profile_model.dart';
import 'companion_model.dart';
import 'daily_challenge_model.dart';

class GamificationDatabase {
  static final GamificationDatabase _instance = GamificationDatabase._internal();
  static Database? _database;

  factory GamificationDatabase() => _instance;

  GamificationDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'hearbat_gamification.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Player profile table
    await db.execute('''
      CREATE TABLE player_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        current_xp INTEGER NOT NULL DEFAULT 0,
        level INTEGER NOT NULL DEFAULT 1,
        total_practice_time INTEGER NOT NULL DEFAULT 0,
        total_modules_completed INTEGER NOT NULL DEFAULT 0,
        total_perfect_scores INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        last_updated TEXT NOT NULL
      )
    ''');

    // User achievements table
    await db.execute('''
      CREATE TABLE user_achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        achievement_id TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        xp_reward INTEGER NOT NULL,
        unlocked_at TEXT,
        category TEXT NOT NULL
      )
    ''');

    // Companion table
    await db.execute('''
      CREATE TABLE companion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        personality TEXT NOT NULL,
        bond_level INTEGER NOT NULL DEFAULT 1,
        bond_xp INTEGER NOT NULL DEFAULT 0,
        total_interactions INTEGER NOT NULL DEFAULT 0,
        last_interaction TEXT NOT NULL,
        avatar_path TEXT,
        personality_traits TEXT
      )
    ''');

    // Companion messages table
    await db.execute('''
      CREATE TABLE companion_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        companion_id INTEGER NOT NULL,
        message TEXT NOT NULL,
        is_from_user INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        context TEXT,
        FOREIGN KEY (companion_id) REFERENCES companion (id)
      )
    ''');

    // Daily challenges table
    await db.execute('''
      CREATE TABLE daily_challenges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        challenge_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        target_value INTEGER NOT NULL,
        current_progress INTEGER NOT NULL DEFAULT 0,
        xp_reward INTEGER NOT NULL,
        date TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Initialize default player profile
    await db.insert('player_profile', {
      'current_xp': 0,
      'level': 1,
      'total_practice_time': 0,
      'total_modules_completed': 0,
      'total_perfect_scores': 0,
      'created_at': DateTime.now().toIso8601String(),
      'last_updated': DateTime.now().toIso8601String(),
    });

    // Initialize default companion
    await db.insert('companion', {
      'name': 'Echo',
      'personality': 'encouraging',
      'bond_level': 1,
      'bond_xp': 0,
      'total_interactions': 0,
      'last_interaction': DateTime.now().toIso8601String(),
      'personality_traits': '{"enthusiasm": 0.7, "supportiveness": 0.9, "humor": 0.5}',
    });

    // Initialize all achievements (locked)
    for (final achievement in AchievementDefinitions.allAchievements) {
      await db.insert('user_achievements', achievement.toMap());
    }
  }

  // Player Profile Methods
  Future<PlayerProfile> getPlayerProfile() async {
    final db = await database;
    final maps = await db.query('player_profile', limit: 1);
    if (maps.isEmpty) {
      throw Exception('Player profile not found');
    }
    return PlayerProfile.fromMap(maps.first);
  }

  Future<void> updatePlayerProfile(PlayerProfile profile) async {
    final db = await database;
    await db.update(
      'player_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<void> addXP(int xp) async {
    final profile = await getPlayerProfile();
    final newXP = profile.currentXP + xp;
    final newLevel = LevelSystem.levelFromXP(newXP);

    await updatePlayerProfile(profile.copyWith(
      currentXP: newXP,
      level: newLevel,
    ));
  }

  // Achievement Methods
  Future<List<Achievement>> getAllAchievements() async {
    final db = await database;
    final maps = await db.query('user_achievements', orderBy: 'category, id');
    return maps.map((map) => Achievement.fromMap(map)).toList();
  }

  Future<List<Achievement>> getUnlockedAchievements() async {
    final db = await database;
    final maps = await db.query(
      'user_achievements',
      where: 'unlocked_at IS NOT NULL',
      orderBy: 'unlocked_at DESC',
    );
    return maps.map((map) => Achievement.fromMap(map)).toList();
  }

  Future<bool> unlockAchievement(String achievementId) async {
    final db = await database;
    final maps = await db.query(
      'user_achievements',
      where: 'achievement_id = ?',
      whereArgs: [achievementId],
    );

    if (maps.isEmpty) return false;

    final achievement = Achievement.fromMap(maps.first);
    if (achievement.isUnlocked) return false; // Already unlocked

    await db.update(
      'user_achievements',
      {'unlocked_at': DateTime.now().toIso8601String()},
      where: 'achievement_id = ?',
      whereArgs: [achievementId],
    );

    // Award XP
    await addXP(achievement.xpReward);

    return true;
  }

  // Companion Methods
  Future<Companion> getCompanion() async {
    final db = await database;
    final maps = await db.query('companion', limit: 1);
    if (maps.isEmpty) {
      throw Exception('Companion not found');
    }
    return Companion.fromMap(maps.first);
  }

  Future<void> updateCompanion(Companion companion) async {
    final db = await database;
    await db.update(
      'companion',
      companion.toMap(),
      where: 'id = ?',
      whereArgs: [companion.id],
    );
  }

  Future<void> addBondXP(int xp) async {
    final companion = await getCompanion();
    final newBondXP = companion.bondXP + xp;
    final newBondLevel = _calculateBondLevel(newBondXP);

    await updateCompanion(companion.copyWith(
      bondXP: newBondXP,
      bondLevel: newBondLevel,
      totalInteractions: companion.totalInteractions + 1,
      lastInteraction: DateTime.now(),
    ));

    // Check for bond achievements
    if (newBondLevel >= 5 && companion.bondLevel < 5) {
      await unlockAchievement('companion_bond_5');
    }
    if (newBondLevel >= 10 && companion.bondLevel < 10) {
      await unlockAchievement('companion_bond_10');
    }
  }

  int _calculateBondLevel(int bondXP) {
    int level = 1;
    while (BondSystem.xpForBondLevel(level + 1) <= bondXP) {
      level++;
    }
    return level;
  }

  Future<List<CompanionMessage>> getCompanionMessages({int limit = 50}) async {
    final db = await database;
    final maps = await db.query(
      'companion_messages',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((map) => CompanionMessage.fromMap(map)).toList().reversed.toList();
  }

  Future<void> addCompanionMessage(CompanionMessage message) async {
    final db = await database;
    await db.insert('companion_messages', message.toMap());
  }

  // Daily Challenge Methods
  Future<List<DailyChallenge>> getTodaysChallenges() async {
    final db = await database;
    final today = DateTime.now();
    final todayStr = DateTime(today.year, today.month, today.day).toIso8601String();

    final maps = await db.query(
      'daily_challenges',
      where: 'date = ?',
      whereArgs: [todayStr],
    );

    if (maps.isEmpty) {
      // Generate new challenges
      return await _generateAndStoreDailyChallenges();
    }

    return maps.map((map) => DailyChallenge.fromMap(map)).toList();
  }

  Future<List<DailyChallenge>> _generateAndStoreDailyChallenges() async {
    final db = await database;
    final challenges = DailyChallengeGenerator.generateDailyChallenges();

    for (final challenge in challenges) {
      await db.insert('daily_challenges', challenge.toMap());
    }

    return challenges;
  }

  Future<void> updateChallengeProgress(String challengeId, int progress) async {
    final db = await database;
    final maps = await db.query(
      'daily_challenges',
      where: 'challenge_id = ?',
      whereArgs: [challengeId],
    );

    if (maps.isEmpty) return;

    final challenge = DailyChallenge.fromMap(maps.first);
    final newProgress = progress;
    final isCompleted = newProgress >= challenge.targetValue;

    await db.update(
      'daily_challenges',
      {
        'current_progress': newProgress,
        'is_completed': isCompleted ? 1 : 0,
      },
      where: 'challenge_id = ?',
      whereArgs: [challengeId],
    );

    // Award XP if just completed
    if (isCompleted && !challenge.isCompleted) {
      await addXP(challenge.xpReward);
    }
  }
}
