import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'companion_model.dart';
import 'gamification_db.dart';
import 'player_profile_model.dart';

class CompanionAIService {
  final GamificationDatabase _db = GamificationDatabase();

  // Generate a contextual response from the companion
  Future<String> generateResponse({
    required String userMessage,
    String? context, // achievement, streak, module_complete, encouragement, etc.
    Map<String, dynamic>? contextData,
  }) async {
    try {
      final companion = await _db.getCompanion();
      final profile = await _db.getPlayerProfile();
      final recentMessages = await _db.getCompanionMessages(limit: 10);

      final prompt = _buildPrompt(
        companion: companion,
        profile: profile,
        userMessage: userMessage,
        recentMessages: recentMessages,
        context: context,
        contextData: contextData,
      );

      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-2.0-flash',
        generationConfig: GenerationConfig(
          temperature: 0.8,
          maxOutputTokens: 200,
        ),
      );

      final response = await model.generateContent([Content.text(prompt)]);
      final companionResponse = response.text ?? _getFallbackResponse(companion);

      // Save messages to database
      await _saveMessages(companion, userMessage, companionResponse, context);

      // Add bond XP for interaction
      await _db.addBondXP(BondSystem.XP_DAILY_CHAT);

      // Check for first chat achievement
      if (companion.totalInteractions == 0) {
        await _db.unlockAchievement('first_chat');
      }

      return companionResponse;
    } catch (e) {
      print('Error in CompanionAIService.generateResponse: $e');
      final companion = await _db.getCompanion();
      return _getFallbackResponse(companion);
    }
  }

  String _buildPrompt({
    required Companion companion,
    required PlayerProfile profile,
    required String userMessage,
    required List<CompanionMessage> recentMessages,
    String? context,
    Map<String, dynamic>? contextData,
  }) {
    final personalityDescription = _getPersonalityDescription(companion.personality);
    final conversationHistory = _formatConversationHistory(recentMessages);

    String contextualInfo = '';
    if (context != null && contextData != null) {
      contextualInfo = _buildContextualInfo(context, contextData);
    }

    return '''
You are ${companion.name}, a supportive AI companion helping a cochlear implant user with their hearing recovery journey through the HearBat app.

YOUR PERSONALITY: ${companion.personality.toUpperCase()}
${personalityDescription}

RELATIONSHIP STATUS: ${companion.relationshipStatus} (Bond Level ${companion.bondLevel}/15)
${_getBondLevelGuidance(companion.bondLevel)}

USER PROFILE:
- Level: ${profile.level} (${profile.title})
- XP: ${profile.currentXP}
- Total Practice Time: ${_formatPracticeTime(profile.totalPracticeTime)}
- Modules Completed: ${profile.totalModulesCompleted}

${contextualInfo}

RECENT CONVERSATION:
${conversationHistory}

USER'S NEW MESSAGE: "$userMessage"

INSTRUCTIONS:
1. Respond in 1-3 sentences (max 200 chars)
2. Stay in character with your ${companion.personality} personality
3. Be supportive and encouraging about their hearing recovery journey
4. Reference their progress when relevant
5. If celebrating an achievement, be genuinely enthusiastic
6. Use warm, friendly language appropriate for your bond level
7. Don't use emojis
8. Focus on motivation and support

YOUR RESPONSE:''';
  }

  String _getPersonalityDescription(String personality) {
    switch (personality) {
      case 'encouraging':
        return 'You are warm, supportive, and always see the positive side. You celebrate every small victory and help users stay motivated through challenges.';
      case 'motivating':
        return 'You are energetic and driven. You push users to achieve their goals and celebrate their dedication with high enthusiasm.';
      case 'friendly':
        return 'You are casual, approachable, and fun. You make the journey enjoyable and feel like a close friend cheering them on.';
      case 'wise':
        return 'You are calm, thoughtful, and insightful. You provide perspective and gentle guidance, like a mentor or coach.';
      case 'playful':
        return 'You are lighthearted and fun-loving. You make practice enjoyable with gentle humor while still being supportive.';
      default:
        return 'You are supportive and encouraging, helping users succeed in their hearing recovery journey.';
    }
  }

  String _getBondLevelGuidance(int bondLevel) {
    if (bondLevel >= 10) {
      return 'You are best friends. Be deeply personal, reference shared history, and show genuine care.';
    } else if (bondLevel >= 5) {
      return 'You are good friends. Be warm and personal, show you remember their journey.';
    } else if (bondLevel >= 3) {
      return 'You are becoming friends. Be friendly and supportive, building rapport.';
    } else {
      return 'You are getting acquainted. Be welcoming and encouraging as you build trust.';
    }
  }

  String _buildContextualInfo(String context, Map<String, dynamic> data) {
    switch (context) {
      case 'achievement':
        return '''
SPECIAL CONTEXT: User just unlocked an achievement!
- Achievement: ${data['achievementName']}
- Description: ${data['achievementDescription']}
- XP Earned: ${data['xpReward']}
Celebrate this accomplishment enthusiastically!
''';
      case 'streak':
        return '''
SPECIAL CONTEXT: Streak milestone!
- Current Streak: ${data['streakDays']} days
${data['isRecord'] == true ? '- This is their longest streak ever!' : ''}
Celebrate their consistency and dedication!
''';
      case 'module_complete':
        return '''
SPECIAL CONTEXT: Module completed!
- Module: ${data['moduleName']}
- Score: ${data['score']}/${data['maxScore']} (${data['accuracy']}%)
Congratulate them on completing this module!
''';
      case 'level_up':
        return '''
SPECIAL CONTEXT: LEVEL UP!
- New Level: ${data['newLevel']}
- New Title: ${data['newTitle']}
This is a major milestone! Be very enthusiastic!
''';
      case 'challenge_complete':
        return '''
SPECIAL CONTEXT: Daily challenge completed!
- Challenge: ${data['challengeName']}
- XP Earned: ${data['xpReward']}
Congratulate them on completing today's challenge!
''';
      default:
        return '';
    }
  }

  String _formatConversationHistory(List<CompanionMessage> messages) {
    if (messages.isEmpty) return '(No previous conversation)';

    return messages.take(5).map((msg) {
      final sender = msg.isFromUser ? 'User' : 'You';
      return '$sender: "${msg.message}"';
    }).join('\n');
  }

  String _formatPracticeTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  Future<void> _saveMessages(
    Companion companion,
    String userMessage,
    String companionResponse,
    String? context,
  ) async {
    // Save user message
    await _db.addCompanionMessage(CompanionMessage(
      companionId: companion.id!,
      message: userMessage,
      isFromUser: true,
      context: context,
    ));

    // Save companion response
    await _db.addCompanionMessage(CompanionMessage(
      companionId: companion.id!,
      message: companionResponse,
      isFromUser: false,
      context: context,
    ));
  }

  String _getFallbackResponse(Companion companion) {
    final responses = {
      'encouraging': "I'm here to support you! Keep practicing, you're doing great!",
      'motivating': "You've got this! Every practice session brings you closer to your goals!",
      'friendly': "Hey! I'm always here to chat and cheer you on!",
      'wise': "Remember, consistent practice is the path to progress. I believe in you.",
      'playful': "Let's make today's practice fun! You're doing awesome!",
    };

    return responses[companion.personality] ?? "I'm here to support you on your journey!";
  }

  // Generate automatic encouragement based on user state
  Future<String?> generateAutoEncouragement() async {
    try {
      final companion = await _db.getCompanion();
      final profile = await _db.getPlayerProfile();
      final challenges = await _db.getTodaysChallenges();

      // Check if user needs encouragement
      final lastInteraction = companion.lastInteraction;
      final hoursSinceLastInteraction = DateTime.now().difference(lastInteraction).inHours;

      if (hoursSinceLastInteraction < 12) {
        return null; // Don't spam encouragement
      }

      // Generate context-aware encouragement
      String encouragementContext = '';
      if (challenges.any((c) => !c.isCompleted)) {
        encouragementContext = 'daily_challenges_reminder';
      }

      final prompt = '''
You are ${companion.name}, a ${companion.personality} AI companion in the HearBat app.

Your user hasn't practiced in ${hoursSinceLastInteraction} hours. Send them a brief, encouraging message to practice today.

USER INFO:
- Level: ${profile.level}
- Current challenges: ${challenges.where((c) => !c.isCompleted).map((c) => c.title).join(', ')}

Send a SHORT (1 sentence, max 100 chars), warm reminder in your ${companion.personality} personality.
Don't use emojis.

YOUR MESSAGE:''';

      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-2.0-flash',
        generationConfig: GenerationConfig(
          temperature: 0.8,
          maxOutputTokens: 100,
        ),
      );

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text?.trim();
    } catch (e) {
      print('Error in generateAutoEncouragement: $e');
      return null;
    }
  }
}
