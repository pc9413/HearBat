class Companion {
  final int? id;
  final String name;
  final String personality; // encouraging, motivating, friendly, wise, playful
  final int bondLevel;
  final int bondXP;
  final int totalInteractions;
  final DateTime lastInteraction;
  final String? avatarPath;
  final Map<String, dynamic> personalityTraits; // stored as JSON

  Companion({
    this.id,
    required this.name,
    this.personality = 'encouraging',
    this.bondLevel = 1,
    this.bondXP = 0,
    this.totalInteractions = 0,
    DateTime? lastInteraction,
    this.avatarPath,
    Map<String, dynamic>? personalityTraits,
  })  : this.lastInteraction = lastInteraction ?? DateTime.now(),
        this.personalityTraits = personalityTraits ?? _defaultTraits(personality);

  static Map<String, dynamic> _defaultTraits(String personality) {
    switch (personality) {
      case 'motivating':
        return {'enthusiasm': 0.9, 'supportiveness': 0.8, 'humor': 0.5};
      case 'friendly':
        return {'enthusiasm': 0.7, 'supportiveness': 0.9, 'humor': 0.7};
      case 'wise':
        return {'enthusiasm': 0.5, 'supportiveness': 0.7, 'humor': 0.3};
      case 'playful':
        return {'enthusiasm': 0.8, 'supportiveness': 0.6, 'humor': 0.9};
      case 'encouraging':
      default:
        return {'enthusiasm': 0.7, 'supportiveness': 0.9, 'humor': 0.5};
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'personality': personality,
      'bond_level': bondLevel,
      'bond_xp': bondXP,
      'total_interactions': totalInteractions,
      'last_interaction': lastInteraction.toIso8601String(),
      'avatar_path': avatarPath,
      'personality_traits': personalityTraits.toString(),
    };
  }

  factory Companion.fromMap(Map<String, dynamic> map) {
    return Companion(
      id: map['id'],
      name: map['name'],
      personality: map['personality'],
      bondLevel: map['bond_level'],
      bondXP: map['bond_xp'],
      totalInteractions: map['total_interactions'],
      lastInteraction: DateTime.parse(map['last_interaction']),
      avatarPath: map['avatar_path'],
      personalityTraits: map['personality_traits'] != null
          ? _parseTraits(map['personality_traits'])
          : null,
    );
  }

  static Map<String, dynamic> _parseTraits(String traitsStr) {
    // Simple parser for stored traits
    return _defaultTraits('encouraging'); // Fallback
  }

  Companion copyWith({
    String? name,
    String? personality,
    int? bondLevel,
    int? bondXP,
    int? totalInteractions,
    DateTime? lastInteraction,
    String? avatarPath,
  }) {
    return Companion(
      id: this.id,
      name: name ?? this.name,
      personality: personality ?? this.personality,
      bondLevel: bondLevel ?? this.bondLevel,
      bondXP: bondXP ?? this.bondXP,
      totalInteractions: totalInteractions ?? this.totalInteractions,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      avatarPath: avatarPath ?? this.avatarPath,
      personalityTraits: this.personalityTraits,
    );
  }

  // Bond level system
  int get xpForNextBondLevel => BondSystem.xpForBondLevel(bondLevel + 1);

  double get progressToNextBondLevel {
    final currentLevelXP = BondSystem.xpForBondLevel(bondLevel);
    final nextLevelXP = BondSystem.xpForBondLevel(bondLevel + 1);
    final xpInCurrentLevel = bondXP - currentLevelXP;
    final xpNeededForLevel = nextLevelXP - currentLevelXP;
    return xpInCurrentLevel / xpNeededForLevel;
  }

  String get relationshipStatus => BondSystem.relationshipStatus(bondLevel);
}

class BondSystem {
  // XP required for each bond level
  static int xpForBondLevel(int level) {
    if (level <= 1) return 0;
    return 50 * (level - 1) * level ~/ 2; // Triangular number * 50
  }

  // Relationship status for bond level
  static String relationshipStatus(int level) {
    if (level >= 15) return 'Soulmate';
    if (level >= 12) return 'Inseparable';
    if (level >= 10) return 'Best Friends';
    if (level >= 8) return 'Close Friends';
    if (level >= 5) return 'Good Friends';
    if (level >= 3) return 'Friends';
    return 'Acquaintance';
  }

  // XP rewards for interactions
  static const int XP_DAILY_CHAT = 10;
  static const int XP_MILESTONE_CELEBRATE = 20;
  static const int XP_ENCOURAGEMENT_ACCEPTED = 5;
  static const int XP_SHARED_ACHIEVEMENT = 15;
}

class CompanionMessage {
  final int? id;
  final int companionId;
  final String message;
  final bool isFromUser;
  final DateTime timestamp;
  final String? context; // achievement, streak, module_complete, etc.

  CompanionMessage({
    this.id,
    required this.companionId,
    required this.message,
    required this.isFromUser,
    DateTime? timestamp,
    this.context,
  }) : this.timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companion_id': companionId,
      'message': message,
      'is_from_user': isFromUser ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
    };
  }

  factory CompanionMessage.fromMap(Map<String, dynamic> map) {
    return CompanionMessage(
      id: map['id'],
      companionId: map['companion_id'],
      message: map['message'],
      isFromUser: map['is_from_user'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
      context: map['context'],
    );
  }
}
