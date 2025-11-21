class Achievement {
  final int? id;
  final String achievementId;
  final String name;
  final String description;
  final String iconName;
  final int xpReward;
  final DateTime? unlockedAt;
  final String category; // streak, accuracy, completion, practice, companion

  Achievement({
    this.id,
    required this.achievementId,
    required this.name,
    required this.description,
    required this.iconName,
    required this.xpReward,
    this.unlockedAt,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'achievement_id': achievementId,
      'name': name,
      'description': description,
      'icon_name': iconName,
      'xp_reward': xpReward,
      'unlocked_at': unlockedAt?.toIso8601String(),
      'category': category,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      achievementId: map['achievement_id'],
      name: map['name'],
      description: map['description'],
      iconName: map['icon_name'],
      xpReward: map['xp_reward'],
      unlockedAt: map['unlocked_at'] != null
          ? DateTime.parse(map['unlocked_at'])
          : null,
      category: map['category'],
    );
  }

  bool get isUnlocked => unlockedAt != null;
}

// Predefined achievements
class AchievementDefinitions {
  static final List<Achievement> allAchievements = [
    // Streak achievements
    Achievement(
      achievementId: 'streak_3',
      name: 'Getting Started',
      description: 'Practice for 3 days in a row',
      iconName: 'local_fire_department',
      xpReward: 100,
      category: 'streak',
    ),
    Achievement(
      achievementId: 'streak_7',
      name: 'Week Warrior',
      description: 'Practice for 7 days in a row',
      iconName: 'local_fire_department',
      xpReward: 250,
      category: 'streak',
    ),
    Achievement(
      achievementId: 'streak_30',
      name: 'Monthly Master',
      description: 'Practice for 30 days in a row',
      iconName: 'local_fire_department',
      xpReward: 1000,
      category: 'streak',
    ),
    Achievement(
      achievementId: 'streak_100',
      name: 'Centurion',
      description: 'Practice for 100 days in a row',
      iconName: 'emoji_events',
      xpReward: 5000,
      category: 'streak',
    ),

    // Accuracy achievements
    Achievement(
      achievementId: 'accuracy_80',
      name: 'Sharp Ears',
      description: 'Achieve 80% accuracy on any module',
      iconName: 'hearing',
      xpReward: 150,
      category: 'accuracy',
    ),
    Achievement(
      achievementId: 'accuracy_90',
      name: 'Expert Listener',
      description: 'Achieve 90% accuracy on any module',
      iconName: 'hearing',
      xpReward: 300,
      category: 'accuracy',
    ),
    Achievement(
      achievementId: 'perfect_score',
      name: 'Perfect!',
      description: 'Get 100% on any module',
      iconName: 'star',
      xpReward: 500,
      category: 'accuracy',
    ),

    // Completion achievements
    Achievement(
      achievementId: 'first_module',
      name: 'First Steps',
      description: 'Complete your first module',
      iconName: 'check_circle',
      xpReward: 50,
      category: 'completion',
    ),
    Achievement(
      achievementId: 'complete_words',
      name: 'Word Master',
      description: 'Complete all word modules',
      iconName: 'abc',
      xpReward: 750,
      category: 'completion',
    ),
    Achievement(
      achievementId: 'complete_speech',
      name: 'Speech Pro',
      description: 'Complete all speech modules',
      iconName: 'record_voice_over',
      xpReward: 750,
      category: 'completion',
    ),
    Achievement(
      achievementId: 'complete_sounds',
      name: 'Sound Specialist',
      description: 'Complete all sound modules',
      iconName: 'music_note',
      xpReward: 750,
      category: 'completion',
    ),
    Achievement(
      achievementId: 'complete_all',
      name: 'Hearing Hero',
      description: 'Complete all modules',
      iconName: 'emoji_events',
      xpReward: 2500,
      category: 'completion',
    ),

    // Practice time achievements
    Achievement(
      achievementId: 'practice_1hr',
      name: 'Dedicated',
      description: 'Practice for 1 hour total',
      iconName: 'access_time',
      xpReward: 100,
      category: 'practice',
    ),
    Achievement(
      achievementId: 'practice_10hr',
      name: 'Committed',
      description: 'Practice for 10 hours total',
      iconName: 'access_time',
      xpReward: 500,
      category: 'practice',
    ),
    Achievement(
      achievementId: 'practice_50hr',
      name: 'Master Trainee',
      description: 'Practice for 50 hours total',
      iconName: 'military_tech',
      xpReward: 2000,
      category: 'practice',
    ),

    // Companion achievements
    Achievement(
      achievementId: 'first_chat',
      name: 'New Friend',
      description: 'Chat with your companion for the first time',
      iconName: 'chat',
      xpReward: 50,
      category: 'companion',
    ),
    Achievement(
      achievementId: 'companion_bond_5',
      name: 'Good Friends',
      description: 'Reach bond level 5 with your companion',
      iconName: 'favorite',
      xpReward: 300,
      category: 'companion',
    ),
    Achievement(
      achievementId: 'companion_bond_10',
      name: 'Best Friends',
      description: 'Reach bond level 10 with your companion',
      iconName: 'favorite',
      xpReward: 1000,
      category: 'companion',
    ),
  ];
}
