# HearBat Gamification System

## Overview

The HearBat gamification system transforms the hearing recovery journey into an engaging, rewarding experience. This comprehensive system includes XP/Levels, Achievements, Daily Challenges, and an AI-powered Companion with personality and relationship mechanics.

## Features

### 1. XP and Leveling System
- **50 Levels** with exponential progression
- **Titles** that evolve with level (Novice Listener → Legendary Listener)
- **XP Rewards** for:
  - Completing modules (50 XP)
  - Perfect scores (100 XP bonus)
  - High accuracy (90%+) (20 XP bonus)
  - Daily practice goals (25 XP)
  - Practice time (1 XP per minute)

### 2. Achievement System
- **20+ Achievements** across 5 categories:
  - **Streak Achievements** (3, 7, 30, 100-day streaks)
  - **Accuracy Achievements** (80%, 90%, 100% scores)
  - **Completion Achievements** (first module, category completion, all modules)
  - **Practice Time Achievements** (1hr, 10hr, 50hr total)
  - **Companion Achievements** (first chat, bond levels)

### 3. Daily Challenges
- **3 Fresh Challenges Daily**
  - Practice Time Challenges (5-20 minutes)
  - Module Completion Challenges (1-5 modules)
  - Accuracy Challenges (70-90% target)
- **XP Rewards** for completion (30-100 XP)
- **Automatic Tracking** of progress

### 4. AI Companion (Gamified)
- **Personalized AI Companion** powered by Gemini 2.0 Flash
- **5 Personality Types**:
  - Encouraging (warm, supportive)
  - Motivating (energetic, driven)
  - Friendly (casual, fun)
  - Wise (calm, insightful)
  - Playful (lighthearted, humorous)

- **Relationship System**:
  - 15 Bond Levels (Acquaintance → Soulmate)
  - Bond XP from interactions
  - Evolving conversation style based on relationship

- **Contextual Responses**:
  - Celebrates achievements
  - Encourages during challenges
  - References user progress
  - Remembers conversation history

## File Structure

```
lib/
├── gamification/
│   ├── achievement_model.dart           # Achievement data models and definitions
│   ├── player_profile_model.dart        # XP, levels, player stats
│   ├── companion_model.dart             # Companion data and relationship system
│   ├── daily_challenge_model.dart       # Daily challenge generation and tracking
│   ├── gamification_db.dart             # SQLite database management
│   ├── gamification_provider.dart       # State management provider
│   └── companion_ai_service.dart        # Gemini AI integration
│
├── pages/
│   ├── companion_chat_page.dart         # Companion chat interface
│   ├── achievements_page.dart           # Achievement gallery
│   └── gamification_home_widget.dart    # Home screen gamification widget
│
└── widgets/
    └── gamification/
        ├── xp_level_widget.dart         # XP/Level display
        ├── achievement_grid_widget.dart # Achievement grid display
        ├── daily_challenges_widget.dart # Daily challenges list
        └── celebration_dialog.dart      # Milestone celebrations
```

## Quick Start

### 1. Setup Provider

```dart
// In main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => GamificationProvider()),
  ],
  child: MyApp(),
)
```

### 2. Track Progress

```dart
// Record practice time
await gamificationProvider.recordPracticeSession(300); // 5 minutes

// Record module completion
await gamificationProvider.recordModuleCompletion(
  moduleName: 'Word Recognition - Level 1',
  score: 9,
  maxScore: 10,
);
```

### 3. Add UI Components

```dart
// Home page
GamificationHomeWidget()

// Or individual components
XPLevelWidget(profile: provider.profile!)
DailyChallengesWidget(challenges: provider.dailyChallenges)
```

## XP Calculation

| Action | XP Reward |
|--------|-----------|
| Complete Module | 50 XP |
| Perfect Score | +100 XP |
| 90%+ Accuracy | +20 XP |
| Practice (per minute) | 1 XP |
| Daily Goal Complete | 25 XP |
| Achievement Unlock | 50-5000 XP |
| Daily Challenge | 30-100 XP |

## Level Progression

Levels use exponential XP requirements:
- Level 2: 100 XP
- Level 5: 800 XP
- Level 10: 5,100 XP
- Level 20: 26,100 XP
- Level 50: 242,500 XP

## Achievement Categories

### Streaks 🔥
- **Getting Started** (3 days) - 100 XP
- **Week Warrior** (7 days) - 250 XP
- **Monthly Master** (30 days) - 1,000 XP
- **Centurion** (100 days) - 5,000 XP

### Accuracy 🎯
- **Sharp Ears** (80%) - 150 XP
- **Expert Listener** (90%) - 300 XP
- **Perfect!** (100%) - 500 XP

### Completion ✅
- **First Steps** (1st module) - 50 XP
- **Word Master** (all words) - 750 XP
- **Speech Pro** (all speech) - 750 XP
- **Sound Specialist** (all sounds) - 750 XP
- **Hearing Hero** (all modules) - 2,500 XP

### Practice ⏱️
- **Dedicated** (1 hour) - 100 XP
- **Committed** (10 hours) - 500 XP
- **Master Trainee** (50 hours) - 2,000 XP

### Companion ❤️
- **New Friend** (first chat) - 50 XP
- **Good Friends** (bond level 5) - 300 XP
- **Best Friends** (bond level 10) - 1,000 XP

## Companion Personalities

### Encouraging
- Warm and supportive
- Celebrates small victories
- Focus on positive reinforcement

### Motivating
- Energetic and driven
- Pushes for goals
- High enthusiasm

### Friendly
- Casual and approachable
- Like a close friend
- Fun and relatable

### Wise
- Calm and thoughtful
- Provides perspective
- Mentor-like guidance

### Playful
- Lighthearted and fun
- Gentle humor
- Makes practice enjoyable

## Bond Level System

| Level | Status | XP Required | Behavior |
|-------|--------|-------------|----------|
| 1-2 | Acquaintance | 0-50 | Welcoming, building trust |
| 3-4 | Friends | 150 | Friendly, supportive |
| 5-7 | Good Friends | 500 | Warm, personal |
| 8-9 | Close Friends | 1,300 | Remember shared journey |
| 10-14 | Best Friends | 2,700 | Deeply personal, genuine care |
| 15+ | Soulmate | 5,750+ | Inseparable connection |

## Daily Challenges

Challenges reset daily at midnight and are automatically generated:

### Practice Time
- Practice for 5/10/15/20 minutes (30-90 XP)

### Module Completion
- Complete 1/2/3/5 modules (40-160 XP)

### Accuracy
- Achieve 70/80/85/90% accuracy (50-125 XP)

## API Usage

### Gemini AI
The companion uses Firebase Vertex AI (Gemini 2.0 Flash):
- **Temperature**: 0.8 (creative but coherent)
- **Max Tokens**: 200 (concise responses)
- **Context Awareness**: Yes (recent history, user stats, relationship level)

### Cost Considerations
- Each chat message: 1 API call
- Celebration messages: Automatic, 1 API call
- Auto encouragement: Optional, max 1/day

## Customization

### Modify XP Rewards
Edit `player_profile_model.dart`:
```dart
static const int XP_MODULE_COMPLETE = 50; // Your value
```

### Add Achievements
Edit `achievement_model.dart`:
```dart
Achievement(
  achievementId: 'my_achievement',
  name: 'My Achievement',
  // ...
),
```

### Customize Companion
Edit `companion_ai_service.dart`:
```dart
String _getPersonalityDescription(String personality) {
  // Add or modify personalities
}
```

## Database Schema

### Tables
- `player_profile` - User XP, level, stats
- `user_achievements` - Achievement unlock status
- `companion` - Companion state and relationship
- `companion_messages` - Chat history
- `daily_challenges` - Today's challenges

### Storage
- Local SQLite database
- File: `hearbat_gamification.db`
- Automatic migrations on version changes

## Testing Gamification

```dart
// Test achievement unlock
await provider.unlockAchievement('streak_7');

// Test XP award
await provider.awardXP(1000);

// Test companion chat
Navigator.push(context, MaterialPageRoute(
  builder: (_) => CompanionChatPage(),
));
```

## Performance

- **Database**: Local SQLite (fast, offline-first)
- **Provider**: ChangeNotifier (efficient updates)
- **AI Calls**: Asynchronous (non-blocking UI)
- **Memory**: ~5MB for all gamification data

## Future Enhancements

Potential additions:
- Leaderboards (weekly/monthly)
- Social features (share achievements)
- Streak protection/freeze
- Unlockable themes/avatars
- Mini-games within exercises
- Adaptive difficulty
- Weekly/monthly challenges
- Achievement showcases
- Companion appearance customization

## Troubleshooting

### Database Not Initializing
```dart
// Ensure provider is initialized
if (!provider.isInitialized) {
  await provider.initialize();
}
```

### Companion Not Responding
- Check Firebase Vertex AI configuration
- Verify API keys
- Check network connection

### Achievements Not Unlocking
- Ensure you're calling `checkAchievements()`
- Check achievement conditions in code
- Verify database is initialized

## License

Part of the HearBat project - Google Developer Student Club 2024 Solution Challenge

## Credits

- **Gamification Design**: Comprehensive system with XP, achievements, challenges
- **AI Companion**: Powered by Google Gemini 2.0 Flash
- **UI/UX**: Material Design with custom celebrations and animations

---

For detailed integration instructions, see [GAMIFICATION_INTEGRATION_GUIDE.md](GAMIFICATION_INTEGRATION_GUIDE.md)
