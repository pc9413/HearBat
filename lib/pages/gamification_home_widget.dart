import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hearbat/gamification/gamification_provider.dart';
import 'package:hearbat/widgets/gamification/xp_level_widget.dart';
import 'package:hearbat/widgets/gamification/daily_challenges_widget.dart';
import 'package:hearbat/pages/companion_chat_page.dart';
import 'package:hearbat/pages/achievements_page.dart';

class GamificationHomeWidget extends StatefulWidget {
  const GamificationHomeWidget({super.key});

  @override
  State<GamificationHomeWidget> createState() => _GamificationHomeWidgetState();
}

class _GamificationHomeWidgetState extends State<GamificationHomeWidget> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeGamification();
  }

  Future<void> _initializeGamification() async {
    final provider = Provider.of<GamificationProvider>(context, listen: false);
    if (!provider.isInitialized) {
      await provider.initialize();
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Consumer<GamificationProvider>(
      builder: (context, provider, _) {
        if (provider.profile == null || provider.companion == null) {
          return SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // XP and Level Display
              XPLevelWidget(profile: provider.profile!),

              SizedBox(height: 16),

              // Quick Action Cards Row
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.pets,
                      title: provider.companion!.name,
                      subtitle: provider.companion!.relationshipStatus,
                      gradient: [
                        Color.fromARGB(255, 110, 211, 97),
                        Color.fromARGB(255, 7, 45, 78),
                      ],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CompanionChatPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.emoji_events,
                      title: 'Achievements',
                      subtitle: '${provider.unlockedAchievements.length}/${provider.achievements.length}',
                      gradient: [
                        Colors.amber,
                        Colors.orange,
                      ],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AchievementsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Daily Challenges
              DailyChallengesWidget(
                challenges: provider.dailyChallenges,
                onRefresh: () async {
                  await provider.refreshDailyChallenges();
                },
              ),

              SizedBox(height: 16),

              // Recently Unlocked Achievements
              if (provider.unlockedAchievements.isNotEmpty) ...[
                _buildRecentAchievements(provider),
                SizedBox(height: 16),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAchievements(GamificationProvider provider) {
    final recentUnlocked = provider.unlockedAchievements.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AchievementsPage()),
                );
              },
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 8),
        ...recentUnlocked.map((achievement) {
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Color.fromARGB(255, 110, 211, 97),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 32,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        achievement.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.amber[700]),
                      SizedBox(width: 2),
                      Text(
                        '+${achievement.xpReward}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
