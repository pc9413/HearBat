import 'dart:math';

class DailyChallenge {
  final int? id;
  final String challengeId;
  final String title;
  final String description;
  final String type; // practice_time, module_complete, accuracy, streak
  final int targetValue;
  final int currentProgress;
  final int xpReward;
  final DateTime date;
  final bool isCompleted;

  DailyChallenge({
    this.id,
    required this.challengeId,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    this.currentProgress = 0,
    required this.xpReward,
    DateTime? date,
    this.isCompleted = false,
  }) : this.date = date ?? _getToday();

  static DateTime _getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'challenge_id': challengeId,
      'title': title,
      'description': description,
      'type': type,
      'target_value': targetValue,
      'current_progress': currentProgress,
      'xp_reward': xpReward,
      'date': date.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory DailyChallenge.fromMap(Map<String, dynamic> map) {
    return DailyChallenge(
      id: map['id'],
      challengeId: map['challenge_id'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      targetValue: map['target_value'],
      currentProgress: map['current_progress'] ?? 0,
      xpReward: map['xp_reward'],
      date: DateTime.parse(map['date']),
      isCompleted: map['is_completed'] == 1,
    );
  }

  DailyChallenge copyWith({
    int? currentProgress,
    bool? isCompleted,
  }) {
    return DailyChallenge(
      id: this.id,
      challengeId: this.challengeId,
      title: this.title,
      description: this.description,
      type: this.type,
      targetValue: this.targetValue,
      currentProgress: currentProgress ?? this.currentProgress,
      xpReward: this.xpReward,
      date: this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  double get progress => currentProgress / targetValue;
}

class DailyChallengeGenerator {
  static final Random _random = Random();

  static List<DailyChallenge> generateDailyChallenges({int count = 3}) {
    final challenges = <DailyChallenge>[];
    final availableTypes = ['practice_time', 'module_complete', 'accuracy'];
    final selectedTypes = <String>[];

    // Ensure variety in challenges
    for (int i = 0; i < count && i < availableTypes.length; i++) {
      final type = availableTypes[i];
      selectedTypes.add(type);
    }

    for (final type in selectedTypes) {
      challenges.add(_generateChallengeForType(type));
    }

    return challenges;
  }

  static DailyChallenge _generateChallengeForType(String type) {
    switch (type) {
      case 'practice_time':
        return _generatePracticeTimeChallenge();
      case 'module_complete':
        return _generateModuleCompleteChallenge();
      case 'accuracy':
        return _generateAccuracyChallenge();
      default:
        return _generatePracticeTimeChallenge();
    }
  }

  static DailyChallenge _generatePracticeTimeChallenge() {
    final times = [300, 600, 900, 1200]; // 5, 10, 15, 20 minutes
    final timeIndex = _random.nextInt(times.length);
    final targetSeconds = times[timeIndex];
    final minutes = targetSeconds ~/ 60;

    return DailyChallenge(
      challengeId: 'daily_practice_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Practice Session',
      description: 'Practice for $minutes minutes today',
      type: 'practice_time',
      targetValue: targetSeconds,
      xpReward: 30 + (timeIndex * 20),
    );
  }

  static DailyChallenge _generateModuleCompleteChallenge() {
    final counts = [1, 2, 3, 5];
    final countIndex = _random.nextInt(counts.length);
    final targetCount = counts[countIndex];

    return DailyChallenge(
      challengeId: 'daily_modules_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Module Marathon',
      description: 'Complete $targetCount ${targetCount == 1 ? "module" : "modules"} today',
      type: 'module_complete',
      targetValue: targetCount,
      xpReward: 40 + (countIndex * 30),
    );
  }

  static DailyChallenge _generateAccuracyChallenge() {
    final accuracies = [70, 80, 85, 90];
    final accuracyIndex = _random.nextInt(accuracies.length);
    final targetAccuracy = accuracies[accuracyIndex];

    return DailyChallenge(
      challengeId: 'daily_accuracy_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Accuracy Goal',
      description: 'Achieve $targetAccuracy% accuracy on any module',
      type: 'accuracy',
      targetValue: targetAccuracy,
      xpReward: 50 + (accuracyIndex * 25),
    );
  }

  // Check if we need new challenges for today
  static bool needsNewChallenges(List<DailyChallenge> challenges) {
    if (challenges.isEmpty) return true;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return challenges.first.date.isBefore(todayDate);
  }
}
