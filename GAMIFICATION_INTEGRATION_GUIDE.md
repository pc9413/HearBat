# HearBat Gamification System - Integration Guide

## Overview

This guide explains how to integrate the new gamification features into the HearBat app, including:
- **XP and Leveling System** - Players earn experience points and level up
- **Achievement System** - Unlockable badges for milestones
- **Daily Challenges** - Daily goals that refresh every day
- **LLM Companion** - AI companion with personality and relationship levels powered by Gemini AI

## Table of Contents
1. [Setup](#setup)
2. [Provider Integration](#provider-integration)
3. [Tracking User Progress](#tracking-user-progress)
4. [UI Integration](#ui-integration)
5. [Companion AI Usage](#companion-ai-usage)
6. [Customization](#customization)

---

## Setup

### 1. Add Dependencies

Add these to `pubspec.yaml` if not already present:

```yaml
dependencies:
  provider: ^6.0.0
  sqflite: ^2.0.0
  path: ^1.8.0
  firebase_vertexai: (already included)
```

### 2. Initialize Provider

In your `main.dart`, wrap your app with the `GamificationProvider`:

```dart
import 'package:hearbat/gamification/gamification_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // ... existing providers
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
      ],
      child: MyApp(),
    ),
  );
}
```

### 3. Initialize Database

The gamification database will automatically initialize on first use. No manual setup required.

---

## Provider Integration

### Access the Provider

```dart
import 'package:provider/provider.dart';
import 'package:hearbat/gamification/gamification_provider.dart';

// In your widget
final gamificationProvider = Provider.of<GamificationProvider>(context);

// Initialize if not done
if (!gamificationProvider.isInitialized) {
  await gamificationProvider.initialize();
}
```

---

## Tracking User Progress

### 1. Record Practice Time

When a user completes a practice session:

```dart
// In your module/exercise completion code
await gamificationProvider.recordPracticeSession(durationInSeconds);
```

This will:
- Award XP (1 XP per minute)
- Update total practice time
- Progress daily challenges
- Check for practice time achievements

### 2. Record Module Completion

When a user completes a module:

```dart
await gamificationProvider.recordModuleCompletion(
  moduleName: 'Word Recognition - Chapter 1',
  score: 8,
  maxScore: 10,
);
```

This will:
- Award XP based on score
- Award bonus XP for perfect scores and high accuracy
- Update daily challenges
- Check for accuracy and completion achievements
- Trigger companion celebration message

### 3. Track Daily Streaks

**Update your existing streak system** in `lib/streaks/streaks_provider.dart`:

```dart
// After updating streak in your existing code
await gamificationProvider.checkAchievements(
  currentStreak: currentStreakValue,
);
```

### 4. Manual XP Awards

For special events or bonuses:

```dart
await gamificationProvider.awardXP(50, reason: 'daily_login_bonus');
```

### 5. Unlock Achievements Manually

```dart
await gamificationProvider.unlockAchievement('achievement_id');
```

---

## UI Integration

### 1. Add Gamification to Home Page

**Option A: Use the Complete Widget**

Add to your `home_page.dart`:

```dart
import 'package:hearbat/pages/gamification_home_widget.dart';

// In your home page build method, add:
GamificationHomeWidget(),
```

**Option B: Add Individual Components**

```dart
import 'package:hearbat/widgets/gamification/xp_level_widget.dart';
import 'package:hearbat/widgets/gamification/daily_challenges_widget.dart';

// In your build method:
Consumer<GamificationProvider>(
  builder: (context, provider, _) {
    if (!provider.isInitialized || provider.profile == null) {
      return CircularProgressIndicator();
    }

    return Column(
      children: [
        // XP and Level display
        XPLevelWidget(profile: provider.profile!),

        // Daily challenges
        DailyChallengesWidget(
          challenges: provider.dailyChallenges,
          onRefresh: () => provider.refreshDailyChallenges(),
        ),
      ],
    );
  },
)
```

### 2. Add Navigation to Companion

Create a button to access the companion chat:

```dart
import 'package:hearbat/pages/companion_chat_page.dart';

ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CompanionChatPage()),
    );
  },
  child: Text('Chat with Companion'),
)
```

### 3. Add Navigation to Achievements

```dart
import 'package:hearbat/pages/achievements_page.dart';

ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AchievementsPage()),
    );
  },
  child: Text('View Achievements'),
)
```

### 4. Show Celebrations

When you want to show a celebration (e.g., after unlocking an achievement):

```dart
import 'package:hearbat/widgets/gamification/celebration_dialog.dart';
import 'package:hearbat/gamification/achievement_model.dart';

// For achievement unlock
final achievement = /* your achievement object */;
showCelebration(
  context,
  CelebrationDialog.achievement(achievement),
);

// For level up
showCelebration(
  context,
  CelebrationDialog.levelUp(newLevel, newTitle),
);

// For perfect score
showCelebration(
  context,
  CelebrationDialog.perfectScore(),
);

// For streak milestone
showCelebration(
  context,
  CelebrationDialog.streak(streakDays),
);
```

---

## Companion AI Usage

### 1. Basic Chat

The companion chat is fully automated in `CompanionChatPage`. Users can chat naturally, and the AI will respond based on:
- Companion personality (encouraging, motivating, friendly, wise, playful)
- Relationship level (bond level)
- User's progress and stats
- Recent conversation history

### 2. Contextual Messages

Trigger companion messages programmatically:

```dart
import 'package:hearbat/gamification/companion_ai_service.dart';

final aiService = CompanionAIService();

// Achievement celebration
final response = await aiService.generateResponse(
  userMessage: 'I unlocked a new achievement!',
  context: 'achievement',
  contextData: {
    'achievementName': 'Week Warrior',
    'achievementDescription': 'Practice for 7 days in a row',
    'xpReward': 250,
  },
);

// Module completion
final response = await aiService.generateResponse(
  userMessage: 'I finished a module!',
  context: 'module_complete',
  contextData: {
    'moduleName': 'Speech Recognition - Level 1',
    'score': 9,
    'maxScore': 10,
    'accuracy': 90,
  },
);
```

### 3. Auto Encouragement

The companion can send automatic encouragement if the user hasn't practiced:

```dart
final encouragement = await aiService.generateAutoEncouragement();
if (encouragement != null) {
  // Show notification or in-app message
}
```

### 4. Customize Companion

```dart
// Change companion name
await gamificationProvider.updateCompanionName('Buddy');

// Change personality
await gamificationProvider.updateCompanionPersonality('playful');
// Options: 'encouraging', 'motivating', 'friendly', 'wise', 'playful'
```

---

## Customization

### 1. Modify XP Rewards

Edit `lib/gamification/player_profile_model.dart`:

```dart
class LevelSystem {
  static const int XP_MODULE_COMPLETE = 50;  // Change this
  static const int XP_PERFECT_SCORE = 100;   // Change this
  static const int XP_DAILY_GOAL = 25;       // Change this
  // ... etc
}
```

### 2. Add Custom Achievements

Edit `lib/gamification/achievement_model.dart`:

```dart
class AchievementDefinitions {
  static final List<Achievement> allAchievements = [
    // ... existing achievements

    // Add new achievement
    Achievement(
      achievementId: 'custom_achievement',
      name: 'My Custom Achievement',
      description: 'Do something special',
      iconName: 'star',
      xpReward: 500,
      category: 'completion',
    ),
  ];
}
```

### 3. Modify Daily Challenges

Edit `lib/gamification/daily_challenge_model.dart`:

```dart
class DailyChallengeGenerator {
  // Modify challenge generation logic
  static DailyChallenge _generatePracticeTimeChallenge() {
    // Customize times, rewards, etc.
  }
}
```

### 4. Customize Companion Personality

Edit `lib/gamification/companion_ai_service.dart`:

```dart
String _getPersonalityDescription(String personality) {
  // Add or modify personality descriptions
}
```

---

## Example: Complete Integration in Module Widget

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hearbat/gamification/gamification_provider.dart';
import 'package:hearbat/widgets/gamification/celebration_dialog.dart';

class ModuleWidget extends StatefulWidget {
  // ... existing code
}

class _ModuleWidgetState extends State<ModuleWidget> {
  int _score = 0;
  int _maxScore = 10;
  DateTime _startTime = DateTime.now();

  Future<void> _completeModule() async {
    // Calculate practice duration
    final duration = DateTime.now().difference(_startTime).inSeconds;

    // Get gamification provider
    final gamificationProvider = Provider.of<GamificationProvider>(
      context,
      listen: false,
    );

    // Record completion
    await gamificationProvider.recordModuleCompletion(
      moduleName: widget.moduleName,
      score: _score,
      maxScore: _maxScore,
    );

    // Record practice time
    await gamificationProvider.recordPracticeSession(duration);

    // Show celebration if perfect score
    if (_score == _maxScore) {
      showCelebration(
        context,
        CelebrationDialog.perfectScore(),
      );
    }

    // Continue with your existing completion logic
    // ...
  }

  @override
  Widget build(BuildContext context) {
    // ... your existing widget code
  }
}
```

---

## Integration with Existing Streak System

In `lib/streaks/streaks_provider.dart`, after updating the streak:

```dart
import 'package:hearbat/gamification/gamification_provider.dart';

class StreakProvider with ChangeNotifier {
  // ... existing code

  Future<void> recordPracticeTimeForDate(int seconds, DateTime date) async {
    // ... existing streak update code

    // Check for streak achievements
    final gamificationProvider = /* get from context or pass as parameter */;
    await gamificationProvider.checkAchievements(
      currentStreak: currentStreak,
    );

    // Check if it's a milestone (3, 7, 30, 100 days)
    if ([3, 7, 30, 100].contains(currentStreak)) {
      // Show celebration
      showCelebration(
        context,
        CelebrationDialog.streak(currentStreak),
      );
    }

    notifyListeners();
  }
}
```

---

## Testing

### 1. Test Achievement Unlocking

```dart
// Manually unlock for testing
await gamificationProvider.unlockAchievement('streak_3');
```

### 2. Test Level Progression

```dart
// Award large XP for testing
await gamificationProvider.awardXP(1000);
```

### 3. Test Companion Responses

Navigate to the Companion Chat page and send test messages.

---

## Troubleshooting

### Database Issues

If you encounter database errors:

```dart
// Reset gamification database (for development only)
final db = await GamificationDatabase().database;
await db.close();
// Delete the database file and restart the app
```

### Provider Not Initialized

Always check before using:

```dart
if (!gamificationProvider.isInitialized) {
  await gamificationProvider.initialize();
}
```

### Companion Not Responding

Check Firebase Vertex AI configuration and API keys are properly set up.

---

## Best Practices

1. **Always use the provider** for recording progress - don't directly modify the database
2. **Show celebrations sparingly** - too many popups can annoy users
3. **Test XP balance** - make sure progression feels rewarding but not too fast
4. **Monitor Gemini API usage** - companion chats use API calls
5. **Handle errors gracefully** - wrap gamification calls in try-catch blocks

---

## Additional Resources

- Achievement Icons: lib/gamification/achievement_model.dart
- XP Levels: lib/gamification/player_profile_model.dart
- Companion Personalities: lib/gamification/companion_ai_service.dart
- UI Widgets: lib/widgets/gamification/

---

## Support

For questions or issues with the gamification system, refer to the code documentation in each file or consult the development team.
